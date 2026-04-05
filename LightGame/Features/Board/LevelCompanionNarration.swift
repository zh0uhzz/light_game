import Foundation

/// 关卡底部「话唠小灯」旁白：按章节与语种换一批话，按 `lineIntervalSeconds` 轮换；第十章为终章顺序台词。
enum LevelCompanionNarration {

    static let finaleLevelId = "ch10_l1"

    static let lineIntervalSeconds: Double = 10

    static func isFinale(_ level: Level) -> Bool {
        level.id == finaleLevelId
    }

    static func levelPhraseOffset(_ level: Level) -> Int {
        if let range = level.id.range(of: "_l", options: .backwards),
           let n = Int(level.id[range.upperBound...]) {
            return n
        }
        return 0
    }

    static func rotatingLine(for level: Level, wallClockTick: Int, language: AppContentLanguage) -> String {
        let pool = CompanionLinePools.lines(for: level.chapterId, language: language)
        let i = (wallClockTick + levelPhraseOffset(level)) % pool.count
        return pool[i]
    }

    static func finaleLine(sessionStart: Date, now: Date, language: AppContentLanguage) -> String {
        let script = CompanionLinePools.finaleScript(language: language)
        guard !script.isEmpty else { return "" }
        let elapsed = max(0, now.timeIntervalSince(sessionStart))
        let step = min(script.count - 1, Int(elapsed / lineIntervalSeconds))
        return script[step]
    }
}
