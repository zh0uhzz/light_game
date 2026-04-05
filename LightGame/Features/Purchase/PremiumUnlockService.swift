import Combine
import Foundation
import StoreKit

/// 非消耗型内购：一次性解锁陪伴模式 + 无限模式。产品须在 App Store Connect 配置（建议参考价 ¥9.90 档，中国区由后台定价）。
@MainActor
final class PremiumUnlockService: ObservableObject {
    static let unlockProductId = "com.nihao.lightgame.full_unlock"

    @Published private(set) var isUnlocked = false
    @Published private(set) var storeProduct: Product?
    /// 面向用户的商店提示（不向用户展示商品 ID、Bundle ID 等开发信息）。
    @Published private(set) var storefrontHint: StorefrontHint = .none

    enum StorefrontHint: Equatable {
        case none
        case productNotFound
        case genericLoadError
    }

    private var updatesTask: Task<Void, Never>?

    init() {
        updatesTask = Task { await listenForTransactionUpdates() }
        Task {
            await refreshEntitlements()
            await loadProducts()
        }
    }

    deinit {
        updatesTask?.cancel()
    }

    func loadProducts() async {
        storefrontHint = .none
        do {
            let products = try await Product.products(for: [Self.unlockProductId])
            storeProduct = products.first
            if storeProduct == nil {
                storefrontHint = .productNotFound
            }
        } catch {
            storefrontHint = .genericLoadError
        }
    }

    func refreshEntitlements() async {
        var unlocked = false
        for await result in Transaction.currentEntitlements {
            guard case .verified(let t) = result else { continue }
            if t.productID == Self.unlockProductId {
                unlocked = true
                break
            }
        }
        isUnlocked = unlocked
    }

    func purchase() async {
        storefrontHint = .none
        if storeProduct == nil {
            await loadProducts()
        }
        guard let product = storeProduct else { return }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try Self.verify(verification)
                guard transaction.productID == Self.unlockProductId else { return }
                await transaction.finish()
                await refreshEntitlements()
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            storefrontHint = .genericLoadError
        }
    }

    func restorePurchases() async {
        storefrontHint = .none
        do {
            try await AppStore.sync()
            await refreshEntitlements()
        } catch {
            storefrontHint = .genericLoadError
        }
    }

    private func listenForTransactionUpdates() async {
        for await result in Transaction.updates {
            do {
                let transaction = try Self.verify(result)
                guard transaction.productID == Self.unlockProductId else { continue }
                await transaction.finish()
                await refreshEntitlements()
            } catch {
                continue
            }
        }
    }

    nonisolated private static func verify(_ result: VerificationResult<Transaction>) throws -> Transaction {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let transaction):
            return transaction
        }
    }
}
