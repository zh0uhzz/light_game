import Foundation

struct BoardSnapshot {
    var bulbs: Set<GridPoint>
}

struct LightingResult {
    let litCells: Set<GridPoint>
    let isWin: Bool
    let usedBulbs: Int
}

struct LightingEngine {
    func compute(level: Level, bulbs: Set<GridPoint>, extraBlocked: Set<GridPoint> = []) -> LightingResult {
        let blocked = Set(level.blockedCells).union(extraBlocked)
        let targets = Set(level.targetMask)
        let playableTargets = targets.subtracting(blocked)
        let litCells = litCellsFor(level: level, bulbs: bulbs, extraBlocked: extraBlocked)

        let litAllTargets = playableTargets.isSubset(of: litCells)
        let withinBudget: Bool
        if level.shouldEnforceOptimalBulbs, let optimal = level.optimalBulbs {
            withinBudget = bulbs.count == optimal
        } else {
            withinBudget = bulbs.count <= level.maxBulbs
        }
        return LightingResult(
            litCells: litCells,
            isWin: litAllTargets && withinBudget,
            usedBulbs: bulbs.count
        )
    }

    func litCellsFor(level: Level, bulbs: Set<GridPoint>, extraBlocked: Set<GridPoint> = []) -> Set<GridPoint> {
        let blocked = Set(level.blockedCells).union(extraBlocked)
        var litCells: Set<GridPoint> = []
        for row in 0..<level.gridSize {
            for col in 0..<level.gridSize {
                let point = GridPoint(row: row, col: col)
                if blocked.contains(point) { continue }
                if GameRules.isCellLitCross(cell: point, by: bulbs) {
                    litCells.insert(point)
                }
            }
        }

        // 斜镜：灯与镜格正交相邻（十字照明）时参与反射，按平面镜（/ 与 \）求出射方向；可多镜迭代。
        var mirrorGrowing = true
        while mirrorGrowing {
            mirrorGrowing = false
            for mirror in level.mirrorCells ?? [] {
                let mirrorPoint = mirror.point
                guard litCells.contains(mirrorPoint), !blocked.contains(mirrorPoint) else { continue }
                for bulb in bulbs {
                    guard GameRules.isOrthogonalPlusAdjacent(mirrorPoint, bulb) else { continue }
                    guard let reflected = reflectedGridNeighbor(
                        mirror: mirror,
                        bulb: bulb,
                        gridSize: level.gridSize,
                        blocked: blocked
                    ) else { continue }
                    if !litCells.contains(reflected) {
                        litCells.insert(reflected)
                        mirrorGrowing = true
                    }
                }
            }
        }

        // 水平缝镜：链式穿透直至不动点。
        let slitPoints = Set(level.slitMirrorCells ?? [])
        var slitGrowing = true
        while slitGrowing {
            slitGrowing = false
            for s in slitPoints {
                guard litCells.contains(s), !blocked.contains(s) else { continue }
                for bulb in bulbs {
                    guard bulb.row == s.row else { continue }
                    let t: GridPoint?
                    if bulb.col == s.col - 1 {
                        t = GridPoint(row: s.row, col: s.col + 1)
                    } else if bulb.col == s.col + 1 {
                        t = GridPoint(row: s.row, col: s.col - 1)
                    } else {
                        t = nil
                    }
                    guard let cell = t,
                          cell.row >= 0, cell.col >= 0,
                          cell.row < level.gridSize, cell.col < level.gridSize,
                          !blocked.contains(cell) else { continue }
                    if !litCells.contains(cell) {
                        litCells.insert(cell)
                        slitGrowing = true
                    }
                }
            }
        }

        return litCells
    }

    private func isSlashMirror(_ direction: MirrorDirection) -> Bool {
        direction == .up || direction == .right
    }

    /// 平面镜反射：屏幕 **x=列向右、y=行向下**（与棋盘一致）。
    /// - **up / right**（`BoardView` 中左下角→右上角）：镜线切线 **(1,-1)**，单位法线 **n = (1,1)/√2**。
    /// - **down / left**（左上角→右下角）：切线 **(1,1)**，**n = (1,-1)/√2**。
    /// 入射 **u**（灯→镜）单位向量，**u' = u − 2(u·n)n**，再量化到八邻格。
    private func reflectedGridNeighbor(
        mirror: MirrorCell,
        bulb: GridPoint,
        gridSize: Int,
        blocked: Set<GridPoint>
    ) -> GridPoint? {
        let m = mirror.point
        // 自灯泡指向镜格（光传播方向）
        let ux = Double(m.col - bulb.col)
        let uy = Double(m.row - bulb.row)
        let len = hypot(ux, uy)
        guard len > 1e-9 else { return nil }

        var vx = ux / len
        var vy = uy / len

        let s = 1.0 / 2.0.squareRoot()
        let nx: Double
        let ny: Double
        if isSlashMirror(mirror.direction) {
            nx = s
            ny = s
        } else {
            nx = s
            ny = -s
        }

        let dot = vx * nx + vy * ny
        vx -= 2.0 * dot * nx
        vy -= 2.0 * dot * ny

        guard let (dRow, dCol) = snapToEightNeighbor(reflX: vx, reflY: vy) else { return nil }
        let t = GridPoint(row: m.row + dRow, col: m.col + dCol)
        guard t.row >= 0, t.col >= 0, t.row < gridSize, t.col < gridSize else { return nil }
        guard !blocked.contains(t) else { return nil }
        return t
    }

    /// 与屏幕坐标一致：邻格一步 (dRow, dCol) 对应方向向量 (dCol, dRow)。
    private func snapToEightNeighbor(reflX: Double, reflY: Double) -> (Int, Int)? {
        let len = hypot(reflX, reflY)
        guard len > 1e-9 else { return nil }
        let x = reflX / len
        let y = reflY / len
        let candidates: [(Int, Int)] = [
            (-1, -1), (-1, 0), (-1, 1),
            (0, -1), (0, 1),
            (1, -1), (1, 0), (1, 1)
        ]
        var bestDot = -1.1
        var best: (Int, Int)?
        for (dr, dc) in candidates {
            let ex = Double(dc)
            let ey = Double(dr)
            let eLen = hypot(ex, ey)
            guard eLen > 1e-9 else { continue }
            let dot = (x * ex + y * ey) / eLen
            if dot > bestDot {
                bestDot = dot
                best = (dr, dc)
            }
        }
        return best
    }

}
