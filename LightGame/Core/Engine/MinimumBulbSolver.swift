import Foundation

/// 在给定盘面下求「能照亮全部目标格」的最少盏数（枚举组合；与 `LightingEngine` 一致）。
/// 用于无限模式生成：**仅在返回非 nil 时**才采用该随机盘面。
enum MinimumBulbSolver {
    /// - Parameters:
    ///   - maxK: 搜索上界（含），避免过大组合爆炸。
    ///   - maxEvaluations: 单次调用内最多评估的摆法次数；超出则放弃（返回 nil）。
    static func findMinimumBulbs(level: Level, maxK: Int = 8, maxEvaluations: Int = 200_000) -> Int? {
        let engine = LightingEngine()
        let blocked = Set(level.blockedCells)
        let playableTargets = Set(level.targetMask).subtracting(blocked)
        guard !playableTargets.isEmpty else { return nil }
        let candidates = WinningPlacementAnalyzer.bulbCandidatePoints(level: level, extraBlocked: [])
        guard !candidates.isEmpty else { return nil }

        var totalEvals = 0
        let cap = max(1, maxK)

        for k in 1...min(cap, candidates.count) {
            var path: [GridPoint] = []
            func dfs(_ start: Int) -> Bool {
                if path.count == k {
                    totalEvals += 1
                    if totalEvals > maxEvaluations {
                        return false
                    }
                    let lit = engine.litCellsFor(level: level, bulbs: Set(path))
                    return playableTargets.isSubset(of: lit)
                }
                for i in start..<candidates.count {
                    if candidates.count - i < k - path.count {
                        break
                    }
                    path.append(candidates[i])
                    if dfs(i + 1) {
                        return true
                    }
                    path.removeLast()
                }
                return false
            }
            if dfs(0) {
                return k
            }
            if totalEvals > maxEvaluations {
                return nil
            }
        }
        return nil
    }
}
