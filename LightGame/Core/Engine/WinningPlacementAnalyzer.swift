import Foundation

private final class CombinationEvalCounter {
    var n = 0
}

/// 枚举这一关所有「通关」摆法里出现过的灯泡格并集，用于推理提示：
/// **不在并集里的可放格** 在数学上不可能出现在任意一种通关方案中（在当前障碍/提示假墙下）。
struct WinningPlacementAnalyzer {
    private let engine = LightingEngine()

    /// - Returns: `(union, hitEvaluationCap)` — 若 `hitEvaluationCap == true` 则搜索被截断，提示将退化为随机安全格。
    func unionOfBulbsInAnyWinningPlacement(
        level: Level,
        extraBlocked: Set<GridPoint>,
        maxEvaluations: Int = 280_000
    ) -> (union: Set<GridPoint>, hitEvaluationCap: Bool) {
        let playable = Self.bulbCandidatePoints(level: level, extraBlocked: extraBlocked)
        var union: Set<GridPoint> = []
        let evalBox = CombinationEvalCounter()

        let bulbCounts: [Int]
        if level.shouldEnforceOptimalBulbs, let opt = level.optimalBulbs {
            bulbCounts = [opt]
        } else {
            bulbCounts = Array(0...level.maxBulbs)
        }

        for k in bulbCounts {
            guard k <= playable.count else { continue }
            if k == 0 {
                guard evalBox.n < maxEvaluations else { break }
                evalBox.n += 1
                _ = engine.compute(level: level, bulbs: [], extraBlocked: extraBlocked).isWin
                continue
            }
            enumerateCombinations(playable, k: k, evalBox: evalBox, maxEvaluations: maxEvaluations) { combo in
                guard evalBox.n < maxEvaluations else { return }
                evalBox.n += 1
                if engine.compute(level: level, bulbs: Set(combo), extraBlocked: extraBlocked).isWin {
                    union.formUnion(combo)
                }
            }
            if evalBox.n >= maxEvaluations { break }
        }

        return (union, evalBox.n >= maxEvaluations)
    }

    static func bulbCandidatePoints(level: Level, extraBlocked: Set<GridPoint>) -> [GridPoint] {
        let blocked = Set(level.blockedCells).union(extraBlocked)
        var pts: [GridPoint] = []
        for row in 0..<level.gridSize {
            for col in 0..<level.gridSize {
                let p = GridPoint(row: row, col: col)
                if blocked.contains(p) { continue }
                if level.mirrorPoints.contains(p) || level.slitMirrorPoints.contains(p) {
                    continue
                }
                pts.append(p)
            }
        }
        return pts
    }

    private func enumerateCombinations(
        _ arr: [GridPoint],
        k: Int,
        evalBox: CombinationEvalCounter,
        maxEvaluations: Int,
        visit: ([GridPoint]) -> Void
    ) {
        var path: [GridPoint] = []
        func dfs(_ start: Int) {
            guard evalBox.n < maxEvaluations else { return }
            if path.count == k {
                visit(path)
                return
            }
            for i in start..<arr.count {
                guard evalBox.n < maxEvaluations else { return }
                path.append(arr[i])
                dfs(i + 1)
                path.removeLast()
            }
        }
        dfs(0)
    }
}
