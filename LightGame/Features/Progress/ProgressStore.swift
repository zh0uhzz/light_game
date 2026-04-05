import Foundation

/// 单关棋盘快照（灯泡布局、提示遮罩、剩余提示次数）；仅「设置 → 重置全部进度」清空。
struct LevelPlayState: Codable, Equatable {
    var bulbs: [GridPoint]
    var hintMaskedCells: [GridPoint]
    var hintsRemaining: Int
}

/// v1：完整本地进度备份（Base64 封装 JSON）。
private struct ProgressBackupPayload: Codable {
    var v: Int
    var completedLevels: [String]
    var playStates: [String: LevelPlayState]
    var infiniteLevelsCleared: Int
    var mainCampaignLevelCount: Int
    var companionModeOpenCount: Int
    var lifetimeHintsConsumed: Int
    var lifetimeLevelRestarts: Int
    /// 旧备份可无此字段。
    var companionBarrageSeen: [String]?
    var infiniteBarrageSeen: [String]?
}

enum ProgressImportError: LocalizedError {
    case notBase64
    case notJSON
    case unsupportedVersion(Int)

    var errorDescription: String? {
        switch self {
        case .notBase64: return "不是有效的备份字符串。"
        case .notJSON: return "解码失败，内容可能损坏。"
        case .unsupportedVersion(let v): return "不支持的备份版本（\(v)）。"
        }
    }
}

final class ProgressStore: ObservableObject {
    @Published private(set) var completedLevels: Set<String> = []
    /// 主线关卡总数（不含无限）；由 `ChapterListView` 载入关卡包后写入。
    @Published private(set) var mainCampaignLevelCount: Int = 0
    /// 无限模式已通关的最高递进步数：下一关序号为 `infiniteLevelsCleared + 1`（无限关不写入 `completedLevels`）。
    @Published private(set) var infiniteLevelsCleared: Int = 0
    @Published private(set) var companionModeOpenCount: Int = 0
    /// 成功消耗提示次数的累计（点提示并真的用掉 1 次计数）。
    @Published private(set) var lifetimeHintsConsumed: Int = 0
    /// 在棋盘点击「重开」的累计次数。
    @Published private(set) var lifetimeLevelRestarts: Int = 0
    /// 陪伴模式全屏底部弹幕：已显示过的不同台词条数（用于成就）。
    @Published private(set) var companionBarrageUniqueCount: Int = 0
    /// 无限模式棋盘话唠条：已显示过的不同台词条数（仅 inf 轮换池）。
    @Published private(set) var infiniteBarrageUniqueCount: Int = 0

    private let key = "light_game_completed_levels"
    private let playStatesKey = "light_game_level_play_states"
    private let infiniteClearedKey = "light_game_infinite_cleared"
    private let mainCountKey = "light_game_main_level_count"
    private let companionOpensKey = "light_game_companion_opens"
    private let hintsLifetimeKey = "light_game_lifetime_hints"
    private let restartsLifetimeKey = "light_game_lifetime_restarts"
    private let companionBarrageKey = "light_game_companion_barrage_lines"
    private let infiniteBarrageKey = "light_game_infinite_barrage_lines"
    private var playStates: [String: LevelPlayState] = [:]
    private var companionBarrageSeen: Set<String> = []
    private var infiniteBarrageSeen: Set<String> = []

    init() {
        load()
        loadPlayStates()
        loadInfiniteStats()
        loadCompanionStats()
        loadLifetimeCounters()
        loadBarrageCollections()
        migrateLegacyInfiniteCompletionIfNeeded()
    }

    func isCompleted(levelId: String) -> Bool {
        completedLevels.contains(levelId)
    }

    /// 主线关卡按 `orderedLevels` 全包顺序：仅首关默认可玩，之后需「上一关至少通关一次」才解锁。
    func isSequentialMainUnlocked(levelIndex: Int, orderedLevels: [Level]) -> Bool {
        guard levelIndex >= 0, levelIndex < orderedLevels.count else { return false }
        if levelIndex == 0 { return true }
        return isCompleted(levelId: orderedLevels[levelIndex - 1].id)
    }

    /// 第十章全部关卡均已通关（用于无限模式入口；日后若增加 10 章多关会自动涵盖）。
    func isChapter10FullyCompleted(orderedLevels: [Level]) -> Bool {
        let ch10 = orderedLevels.filter { $0.chapterId == "ch10" }
        guard !ch10.isEmpty else { return false }
        return ch10.allSatisfy { isCompleted(levelId: $0.id) }
    }

    func setMainCampaignLevelCount(_ count: Int) {
        guard count > 0, count != mainCampaignLevelCount else { return }
        mainCampaignLevelCount = count
        UserDefaults.standard.set(count, forKey: mainCountKey)
    }

    /// 无限模式下一关全局序号（从 1 起，无上限）。
    func infiniteNextPlayNumber() -> Int {
        infiniteLevelsCleared + 1
    }

    func markCompleted(levelId: String) {
        if levelId.hasPrefix("inf_l") { return }
        completedLevels.insert(levelId)
        save()
    }

    /// 通关无限模式第 `n` 关（须按顺序）；同步清理过早前的 `inf_l*` 盘面存档与生成器缓存。
    func registerInfiniteLevelCompleted(atGlobalNumber n: Int) {
        guard n == infiniteLevelsCleared + 1 else { return }
        infiniteLevelsCleared += 1
        UserDefaults.standard.set(infiniteLevelsCleared, forKey: infiniteClearedKey)
        pruneStaleInfiniteData(globalCompleted: n)
        InfiniteLevelGenerator.pruneCache(keepFromGlobalNumber: max(1, n - 24))
    }

    func recordCompanionModeOpened() {
        companionModeOpenCount += 1
        UserDefaults.standard.set(companionModeOpenCount, forKey: companionOpensKey)
    }

    func recordHintConsumed() {
        lifetimeHintsConsumed += 1
        UserDefaults.standard.set(lifetimeHintsConsumed, forKey: hintsLifetimeKey)
    }

    func recordLevelRestartTapped() {
        lifetimeLevelRestarts += 1
        UserDefaults.standard.set(lifetimeLevelRestarts, forKey: restartsLifetimeKey)
    }

    /// 陪伴模式当前轮到的一句台词显示时调用（去重计数）。
    func recordCompanionBarrageLineDisplayed(_ line: String) {
        let t = line.trimmingCharacters(in: .whitespacesAndNewlines)
        guard t.count > 1 else { return }
        if companionBarrageSeen.count >= 400 { return }
        if companionBarrageSeen.insert(t).inserted {
            companionBarrageUniqueCount = companionBarrageSeen.count
            saveCompanionBarrage()
        }
    }

    /// 无限模式话唠轮换句显示时调用（去重计数）。
    func recordInfiniteBarrageLineDisplayed(_ line: String) {
        let t = line.trimmingCharacters(in: .whitespacesAndNewlines)
        guard t.count > 1 else { return }
        if infiniteBarrageSeen.count >= 400 { return }
        if infiniteBarrageSeen.insert(t).inserted {
            infiniteBarrageUniqueCount = infiniteBarrageSeen.count
            saveInfiniteBarrage()
        }
    }

    /// 主线已通关数（不含无限关）。
    var mainCampaignCompletedCount: Int {
        completedLevels.filter { !$0.hasPrefix("inf_l") }.count
    }

    var isMainCampaignFullyCompleted: Bool {
        mainCampaignLevelCount > 0 && mainCampaignCompletedCount >= mainCampaignLevelCount
    }

    /// 导出当前全部进度为一串 Base64（URL 安全字符，便于粘贴）。
    func exportProgressToken() -> String {
        let payload = ProgressBackupPayload(
            v: 1,
            completedLevels: Array(completedLevels).sorted(),
            playStates: playStates,
            infiniteLevelsCleared: infiniteLevelsCleared,
            mainCampaignLevelCount: mainCampaignLevelCount,
            companionModeOpenCount: companionModeOpenCount,
            lifetimeHintsConsumed: lifetimeHintsConsumed,
            lifetimeLevelRestarts: lifetimeLevelRestarts,
            companionBarrageSeen: Array(companionBarrageSeen).sorted(),
            infiniteBarrageSeen: Array(infiniteBarrageSeen).sorted()
        )
        guard let data = try? JSONEncoder().encode(payload) else { return "" }
        return data.base64EncodedString()
    }

    /// 从导出串恢复进度（覆盖当前存档）。
    func importProgressToken(_ token: String) throws {
        let t = token.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let data = Data(base64Encoded: t) else { throw ProgressImportError.notBase64 }
        let p: ProgressBackupPayload
        do {
            p = try JSONDecoder().decode(ProgressBackupPayload.self, from: data)
        } catch {
            throw ProgressImportError.notJSON
        }
        guard p.v == 1 else { throw ProgressImportError.unsupportedVersion(p.v) }
        applyBackup(p)
    }

    private func applyBackup(_ p: ProgressBackupPayload) {
        completedLevels = Set(p.completedLevels.filter { !$0.hasPrefix("inf_l") })
        playStates = p.playStates
        infiniteLevelsCleared = max(0, p.infiniteLevelsCleared)
        mainCampaignLevelCount = max(0, p.mainCampaignLevelCount)
        companionModeOpenCount = max(0, p.companionModeOpenCount)
        lifetimeHintsConsumed = max(0, p.lifetimeHintsConsumed)
        lifetimeLevelRestarts = max(0, p.lifetimeLevelRestarts)
        companionBarrageSeen = Set((p.companionBarrageSeen ?? []).prefix(400))
        infiniteBarrageSeen = Set((p.infiniteBarrageSeen ?? []).prefix(400))
        companionBarrageUniqueCount = companionBarrageSeen.count
        infiniteBarrageUniqueCount = infiniteBarrageSeen.count
        save()
        savePlayStates()
        saveCompanionBarrage()
        saveInfiniteBarrage()
        UserDefaults.standard.set(infiniteLevelsCleared, forKey: infiniteClearedKey)
        UserDefaults.standard.set(mainCampaignLevelCount, forKey: mainCountKey)
        UserDefaults.standard.set(companionModeOpenCount, forKey: companionOpensKey)
        UserDefaults.standard.set(lifetimeHintsConsumed, forKey: hintsLifetimeKey)
        UserDefaults.standard.set(lifetimeLevelRestarts, forKey: restartsLifetimeKey)
        InfiniteLevelGenerator.pruneCache(keepFromGlobalNumber: max(1, infiniteLevelsCleared - 24))
        objectWillChange.send()
    }

    func resetAllProgress() {
        completedLevels.removeAll()
        playStates.removeAll()
        infiniteLevelsCleared = 0
        mainCampaignLevelCount = 0
        companionModeOpenCount = 0
        lifetimeHintsConsumed = 0
        lifetimeLevelRestarts = 0
        companionBarrageSeen.removeAll()
        infiniteBarrageSeen.removeAll()
        companionBarrageUniqueCount = 0
        infiniteBarrageUniqueCount = 0
        save()
        savePlayStates()
        UserDefaults.standard.removeObject(forKey: infiniteClearedKey)
        UserDefaults.standard.removeObject(forKey: mainCountKey)
        UserDefaults.standard.removeObject(forKey: companionOpensKey)
        UserDefaults.standard.removeObject(forKey: hintsLifetimeKey)
        UserDefaults.standard.removeObject(forKey: restartsLifetimeKey)
        UserDefaults.standard.removeObject(forKey: companionBarrageKey)
        UserDefaults.standard.removeObject(forKey: infiniteBarrageKey)
        objectWillChange.send()
    }

    func playState(for levelId: String) -> LevelPlayState? {
        playStates[levelId]
    }

    func savePlayState(levelId: String, state: LevelPlayState) {
        playStates[levelId] = state
        savePlayStates()
    }

    func removePlayState(for levelId: String) {
        playStates.removeValue(forKey: levelId)
        savePlayStates()
    }

    /// 进入棋盘时：已通关则恢复上次摆法；未通关则丢弃该关草稿，始终空白进入。
    func playStateWhenEntering(levelId: String) -> LevelPlayState? {
        if isCompleted(levelId: levelId) || infinitePlayStateRestoreAllowed(levelId: levelId) {
            return playState(for: levelId)
        }
        removePlayState(for: levelId)
        return nil
    }

    /// 无限关未「计数通关」前仍允许从存档恢复同一局。
    private func infinitePlayStateRestoreAllowed(levelId: String) -> Bool {
        guard levelId.hasPrefix("inf_l"),
              let n = infiniteNumber(fromInfId: levelId) else { return false }
        return n > infiniteLevelsCleared
    }

    private func pruneStaleInfiniteData(globalCompleted n: Int) {
        let keepMin = max(1, n - 8)
        let victims = playStates.keys.filter { id in
            guard let k = infiniteNumber(fromInfId: id) else { return false }
            return k < keepMin
        }
        for id in victims {
            playStates.removeValue(forKey: id)
        }
        let oldInf = completedLevels.filter { $0.hasPrefix("inf_l") }
        if !oldInf.isEmpty {
            completedLevels = completedLevels.subtracting(oldInf)
            save()
        } else if !victims.isEmpty {
            savePlayStates()
        }
    }

    private func infiniteNumber(fromInfId id: String) -> Int? {
        guard let r = id.range(of: "_l", options: .backwards),
              let n = Int(id[r.upperBound...]) else { return nil }
        return n
    }

    private func migrateLegacyInfiniteCompletionIfNeeded() {
        guard infiniteLevelsCleared == 0 else { return }
        let legacy = completedLevels.filter { $0.hasPrefix("inf_l") }
        guard !legacy.isEmpty else { return }
        var migratedCleared = 0
        var foundGap = false
        for n in 1...999 {
            if !completedLevels.contains("inf_l\(n)") {
                migratedCleared = n - 1
                foundGap = true
                break
            }
        }
        if !foundGap {
            migratedCleared = 999
        }
        infiniteLevelsCleared = migratedCleared
        UserDefaults.standard.set(infiniteLevelsCleared, forKey: infiniteClearedKey)
        completedLevels = completedLevels.subtracting(legacy)
        save()
        pruneStaleInfiniteData(globalCompleted: migratedCleared)
        InfiniteLevelGenerator.pruneCache(keepFromGlobalNumber: max(1, migratedCleared - 24))
    }

    private func loadInfiniteStats() {
        let v = UserDefaults.standard.integer(forKey: infiniteClearedKey)
        infiniteLevelsCleared = max(0, v)
        mainCampaignLevelCount = max(0, UserDefaults.standard.integer(forKey: mainCountKey))
    }

    private func loadCompanionStats() {
        companionModeOpenCount = max(0, UserDefaults.standard.integer(forKey: companionOpensKey))
    }

    private func loadLifetimeCounters() {
        lifetimeHintsConsumed = max(0, UserDefaults.standard.integer(forKey: hintsLifetimeKey))
        lifetimeLevelRestarts = max(0, UserDefaults.standard.integer(forKey: restartsLifetimeKey))
    }

    private func loadBarrageCollections() {
        if let a = UserDefaults.standard.array(forKey: companionBarrageKey) as? [String] {
            companionBarrageSeen = Set(a)
            companionBarrageUniqueCount = companionBarrageSeen.count
        }
        if let b = UserDefaults.standard.array(forKey: infiniteBarrageKey) as? [String] {
            infiniteBarrageSeen = Set(b)
            infiniteBarrageUniqueCount = infiniteBarrageSeen.count
        }
    }

    private func saveCompanionBarrage() {
        UserDefaults.standard.set(Array(companionBarrageSeen), forKey: companionBarrageKey)
    }

    private func saveInfiniteBarrage() {
        UserDefaults.standard.set(Array(infiniteBarrageSeen), forKey: infiniteBarrageKey)
    }

    private func load() {
        guard let saved = UserDefaults.standard.array(forKey: key) as? [String] else {
            completedLevels = []
            return
        }
        completedLevels = Set(saved)
    }

    private func save() {
        UserDefaults.standard.set(Array(completedLevels), forKey: key)
    }

    private func loadPlayStates() {
        guard let data = UserDefaults.standard.data(forKey: playStatesKey),
              let decoded = try? JSONDecoder().decode([String: LevelPlayState].self, from: data) else {
            playStates = [:]
            return
        }
        playStates = decoded
    }

    private func savePlayStates() {
        guard let data = try? JSONEncoder().encode(playStates) else { return }
        UserDefaults.standard.set(data, forKey: playStatesKey)
    }
}
