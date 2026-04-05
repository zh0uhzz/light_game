import SwiftUI
import StoreKit

/// 永久会员购买页：需与 App Store Connect 非消耗型商品 ID 一致。
struct PremiumPaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var premium: PremiumUnlockService
    @EnvironmentObject private var audioManager: AudioManager
    @EnvironmentObject private var localization: LocalizationManager

    private var lang: AppContentLanguage { localization.content }
    @State private var isPurchasing = false
    @State private var isRestoring = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(AppLocalizedStrings.premiumPaywallTitle(lang))
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white.opacity(0.96))
                    Text(AppLocalizedStrings.premiumPaywallSubtitle(lang))
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.72))
                        .fixedSize(horizontal: false, vertical: true)

                    VStack(alignment: .leading, spacing: 10) {
                        benefitRow(systemImage: "lightbulb.min.fill", text: AppLocalizedStrings.premiumBenefitCompanion(lang))
                        benefitRow(systemImage: "infinity", text: AppLocalizedStrings.premiumBenefitInfinite(lang))
                        benefitRow(systemImage: "sparkles", text: AppLocalizedStrings.premiumBenefitHints(lang))
                        benefitRow(systemImage: "arrow.triangle.2.circlepath", text: AppLocalizedStrings.premiumBenefitOnce(lang))
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.white.opacity(0.07))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
                            )
                    )

                    switch premium.storefrontHint {
                    case .none:
                        EmptyView()
                    case .productNotFound:
                        Text(AppLocalizedStrings.premiumProductNotFound(lang))
                            .font(.caption)
                            .foregroundStyle(.orange)
                            .fixedSize(horizontal: false, vertical: true)
                    case .genericLoadError:
                        Text(AppLocalizedStrings.premiumStoreTemporaryError(lang))
                            .font(.caption)
                            .foregroundStyle(.orange)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Button {
                        audioManager.playClick()
                        Task {
                            isPurchasing = true
                            await premium.purchase()
                            isPurchasing = false
                        }
                    } label: {
                        HStack {
                            if isPurchasing {
                                ProgressView()
                                    .tint(.black.opacity(0.8))
                            }
                            Text(
                                premium.storeProduct?.displayPrice
                                    ?? AppLocalizedStrings.premiumPricePlaceholder(lang)
                            )
                            .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.yellow)
                    .disabled(isPurchasing || premium.isUnlocked || premium.storeProduct == nil)

                    Button {
                        audioManager.playClick()
                        Task {
                            isRestoring = true
                            await premium.restorePurchases()
                            isRestoring = false
                        }
                    } label: {
                        HStack {
                            if isRestoring {
                                ProgressView()
                                    .tint(.white.opacity(0.8))
                            }
                            Text(AppLocalizedStrings.premiumRestore(lang))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                    }
                    .buttonStyle(.bordered)
                    .tint(.white.opacity(0.55))
                    .disabled(isRestoring)
                }
                .padding(24)
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
            }
            .scrollContentBackground(.hidden)
            .background(
                ZStack {
                    LinearGradient(
                        colors: [Color.black, Color(red: 0.08, green: 0.08, blue: 0.11)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    FireflyBackgroundView(fireflyCount: 12, luminosity: 0.42)
                }
                .ignoresSafeArea()
            )
            .navigationTitle(AppLocalizedStrings.premiumNavTitle(lang))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(AppLocalizedStrings.premiumClose(lang)) {
                        audioManager.playClick()
                        dismiss()
                    }
                }
            }
            .task {
                if premium.storeProduct == nil {
                    await premium.loadProducts()
                }
            }
            .onChange(of: premium.isUnlocked) { unlocked in
                guard unlocked else { return }
                dismiss()
            }
        }
    }

    private func benefitRow(systemImage: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: systemImage)
                .font(.body.weight(.semibold))
                .foregroundStyle(Color(red: 1.0, green: 0.9, blue: 0.45))
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.88))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
