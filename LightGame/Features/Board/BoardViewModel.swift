import Foundation

/// 镜格 UI：单侧直射为半格，两侧同时有直射则整格亮。
struct MirrorCellVisual {
    var illuminateFull: Bool
    var halfIncomingDelta: (dRow: Int, dCol: Int)?
}

enum HintToolbarAttention: Equatable {
    case idle
    case shaking
    case glowing
}

/// 点提示按钮后的结果；`consumedHint` 表示成功消耗 1 次提示次数。
enum HintApplyOutcome: Equatable {
    case idle
    case showedBanner(String)
    case consumedHint
}

final class BoardViewModel: ObservableObject {
    @Published private(set) var litCells: Set<GridPoint> = []
    @Published private(set) var bulbs: Set<GridPoint> = []
    @Published private(set) var didWin = false
    @Published private(set) var winCondition: WinCondition
    @Published private(set) var limitWarning = false

    @Published private(set) var level: Level

    /// 提示标记为「假障碍」的格子（不可再放灯泡，参与遮光计算）。
    @Published private(set) var hintMaskedCells: Set<GridPoint> = []

    /// 每关提示次数（默认 3；永久会员 9）。
    @Published private(set) var hintsRemaining: Int

    private let hintsPerLevel: Int

    @Published private(set) var hintToolbarAttention: HintToolbarAttention = .idle

    /// 供界面监听以持久化棋盘（仅玩家操作后递增）。
    @Published private(set) var playStateSaveNonce: UInt64 = 0

    private let engine = LightingEngine()
    private let placementAnalyzer = WinningPlacementAnalyzer()
    private var history: [BoardSnapshot] = []
    /// 进入「放满灯泡但未通关」状态的累计次数（离开满灯不重置；通关/换关/重开清零）。满 3 次且提示条空闲时触发抖动。
    private var fullFailureEpisodes: Int = 0
    private var wasInFullFailedState: Bool = false

    init(level: Level, hintsPerLevel: Int = 3) {
        let quota = max(1, hintsPerLevel)
        self.hintsPerLevel = quota
        self.hintsRemaining = quota
        self.level = level
        self.winCondition = WinCondition(
            totalTargets: Set(level.targetMask).count,
            litTargets: 0,
            usedBulbs: 0,
            maxBulbs: level.maxBulbs
        )
        recompute()
    }

    func loadLevel(_ level: Level, restored: LevelPlayState? = nil) {
        self.level = level
        bulbs.removeAll()
        history.removeAll()
        limitWarning = false
        hintMaskedCells.removeAll()
        hintsRemaining = hintsPerLevel
        fullFailureEpisodes = 0
        wasInFullFailedState = false
        hintToolbarAttention = .idle
        if let r = restored {
            bulbs = Set(r.bulbs)
            hintMaskedCells = Set(r.hintMaskedCells)
            hintsRemaining = r.hintsRemaining
        }
        recompute()
    }

    func currentPlayState() -> LevelPlayState {
        LevelPlayState(
            bulbs: Array(bulbs),
            hintMaskedCells: Array(hintMaskedCells),
            hintsRemaining: hintsRemaining
        )
    }

    private func notePlayStateChanged() {
        playStateSaveNonce &+= 1
    }

    /// 由界面在抖动满 5 秒后调用。
    func finishHintButtonShaking() {
        if hintToolbarAttention == .shaking {
            hintToolbarAttention = .glowing
        }
    }

    @discardableResult
    func applyHint() -> HintApplyOutcome {
        guard hintToolbarAttention != .idle else { return .idle }
        guard hintsRemaining > 0 else { return .showedBanner("本关提示已用完") }
        let targets = Set(level.targetMask)
        let (unionWinBulbs, capped) = placementAnalyzer.unionOfBulbsInAnyWinningPlacement(
            level: level,
            extraBlocked: hintMaskedCells
        )

        let candidates = Self.bulbCandidates(level: level, extraBlocked: hintMaskedCells)
        let badMath = candidates.filter { !unionWinBulbs.contains($0) && !targets.contains($0) && !bulbs.contains($0) }
        let pick: GridPoint?
        if !badMath.isEmpty {
            pick = badMath.randomElement()
        } else if capped {
            let fallback = candidates.filter { !targets.contains($0) && !bulbs.contains($0) && !hintMaskedCells.contains($0) }
            pick = fallback.randomElement()
        } else {
            let fallback = candidates.filter { !targets.contains($0) && !bulbs.contains($0) && !hintMaskedCells.contains($0) }
            pick = fallback.randomElement()
        }

        guard let cell = pick else { return .showedBanner("当前没有可用提示格") }
        hintMaskedCells.insert(cell)
        hintsRemaining -= 1
        if bulbs.contains(cell) {
            bulbs.remove(cell)
        }
        recompute()
        notePlayStateChanged()
        return .consumedHint
    }

    func toggleBulb(at point: GridPoint) {
        guard isPlayableForBulb(point) else { return }
        if bulbs.contains(point) {
            saveSnapshot()
            bulbs.remove(point)
        } else {
            guard bulbs.count < level.maxBulbs else {
                limitWarning = true
                return
            }
            saveSnapshot()
            bulbs.insert(point)
        }
        limitWarning = false
        recompute()
        notePlayStateChanged()
    }

    func undo() {
        guard let snapshot = history.popLast() else { return }
        bulbs = snapshot.bulbs
        recompute()
        notePlayStateChanged()
    }

    func restart() {
        bulbs.removeAll()
        history.removeAll()
        hintMaskedCells.removeAll()
        hintsRemaining = hintsPerLevel
        fullFailureEpisodes = 0
        wasInFullFailedState = false
        hintToolbarAttention = .idle
        recompute()
    }

    func lightVisualTier(at point: GridPoint) -> Int? {
        GameRules.lightVisualTier(
            cell: point,
            bulbs: bulbs,
            isLit: litCells.contains(point)
        )
    }

    func cellType(at point: GridPoint) -> CellType {
        Set(level.blockedCells).contains(point) ? .blocked : .playable
    }

    func isHintMasked(_ point: GridPoint) -> Bool {
        hintMaskedCells.contains(point)
    }

    func isPlayableForBulb(_ point: GridPoint) -> Bool {
        if point.row < 0 || point.col < 0 || point.row >= level.gridSize || point.col >= level.gridSize {
            return false
        }
        if hintMaskedCells.contains(point) { return false }
        let blocked = Set(level.blockedCells)
        if blocked.contains(point) { return false }
        if level.mirrorPoints.contains(point) { return false }
        if level.slitMirrorPoints.contains(point) { return false }
        return true
    }

    func isTarget(_ point: GridPoint) -> Bool {
        Set(level.targetMask).contains(point)
    }

    func mirrorDirection(at point: GridPoint) -> MirrorDirection? {
        level.mirrorCells?.first(where: { $0.row == point.row && $0.col == point.col })?.direction
    }

    /// 镜格展示用：直射与经缝/经他镜反射的入射合并；若法向两侧皆有则整格亮，否则按最近源画半格。
    func mirrorCellVisual(at point: GridPoint) -> MirrorCellVisual? {
        guard level.mirrorPoints.contains(point), litCells.contains(point) else { return nil }
        guard let dir = mirrorDirection(at: point) else { return nil }
        let isSlash = dir == .up || dir == .right

        func sideBucket(_ b: GridPoint) -> Int? {
            let dc = b.col - point.col
            let dr = b.row - point.row
            let raw = isSlash ? (dc + dr) : (dc - dr)
            if raw > 0 { return 1 }
            if raw < 0 { return -1 }
            return nil
        }

        var bulbsInRange: [GridPoint] = []
        for b in bulbs where GameRules.isOrthogonalPlusAdjacent(point, b) {
            bulbsInRange.append(b)
        }

        let directBuckets = Set(bulbsInRange.compactMap { sideBucket($0) })
        let (indirectBuckets, indirectDeltas) = indirectMirrorSideData(at: point, sideBucket: sideBucket)
        let allBuckets = directBuckets.union(indirectBuckets)
        /// 两盏灯分别在镜格「上下」与「左右」相邻时，几何上已从两垂直边直入，但 slash / 反斜镜像下 `sideBucket` 可能同为 1 或同为 -1，仍需整格亮。
        let multiAxisDirect = bulbsInRange.contains { $0.row == point.row }
            && bulbsInRange.contains { $0.col == point.col }

        if multiAxisDirect || (allBuckets.contains(1) && allBuckets.contains(-1)) {
            return MirrorCellVisual(illuminateFull: true, halfIncomingDelta: nil)
        }

        if !bulbsInRange.isEmpty {
            var bestBulb: GridPoint?
            var bestDist = Double.infinity
            for b in bulbsInRange {
                let d = GameRules.gridDistance(b, point)
                if d < bestDist {
                    bestDist = d
                    bestBulb = b
                }
            }
            if let b = bestBulb {
                let delta = (dRow: point.row - b.row, dCol: point.col - b.col)
                return MirrorCellVisual(illuminateFull: false, halfIncomingDelta: delta)
            }
        }

        guard !indirectDeltas.isEmpty else { return nil }
        let best = indirectDeltas.min(by: { abs($0.dRow) + abs($0.dCol) < abs($1.dRow) + abs($1.dCol) })!
        return MirrorCellVisual(illuminateFull: false, halfIncomingDelta: best)
    }

    private func indirectMirrorSideData(
        at point: GridPoint,
        sideBucket: (GridPoint) -> Int?
    ) -> (buckets: Set<Int>, deltas: [(dRow: Int, dCol: Int)]) {
        let blocked = Set(level.blockedCells).union(hintMaskedCells)
        var deltas: [(dRow: Int, dCol: Int)] = []

        let r = point.row
        let c = point.col
        let leftSlit = GridPoint(row: r, col: c - 1)
        let leftBeam = GridPoint(row: r, col: c - 2)
        if c >= 2, level.slitMirrorPoints.contains(leftSlit), litCells.contains(leftBeam), !blocked.contains(leftBeam) {
            deltas.append((0, c - leftBeam.col))
        }
        let rightSlit = GridPoint(row: r, col: c + 1)
        let rightBeam = GridPoint(row: r, col: c + 2)
        if c + 2 < level.gridSize, level.slitMirrorPoints.contains(rightSlit), litCells.contains(rightBeam), !blocked.contains(rightBeam) {
            deltas.append((0, c - rightBeam.col))
        }

        if let mirrors = level.mirrorCells {
            for m in mirrors {
                let mp = m.point
                if mp == point { continue }
                guard litCells.contains(mp) else { continue }
                for b in bulbs where GameRules.isOrthogonalPlusAdjacent(mp, b) {
                    if let t = Self.reflectedNeighbor(mirror: m, bulb: b, gridSize: level.gridSize, blocked: blocked), t == point {
                        deltas.append((point.row - mp.row, point.col - mp.col))
                    }
                }
            }
        }

        guard !deltas.isEmpty else { return ([], []) }
        let sources = deltas.map { GridPoint(row: point.row - $0.dRow, col: point.col - $0.dCol) }
        let buckets = Set(sources.compactMap { sideBucket($0) })
        return (buckets, deltas)
    }

    private static func isSlashMirror(_ direction: MirrorDirection) -> Bool {
        direction == .up || direction == .right
    }

    private static func reflectedNeighbor(
        mirror: MirrorCell,
        bulb: GridPoint,
        gridSize: Int,
        blocked: Set<GridPoint>
    ) -> GridPoint? {
        let m = mirror.point
        var ux = Double(m.col - bulb.col)
        var uy = Double(m.row - bulb.row)
        let len = hypot(ux, uy)
        guard len > 1e-9 else { return nil }
        ux /= len
        uy /= len

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
        var vx = ux
        var vy = uy
        let dot = vx * nx + vy * ny
        vx -= 2.0 * dot * nx
        vy -= 2.0 * dot * ny
        guard let step = snapReflectedToEightNeighbor(vx, vy) else { return nil }
        let t = GridPoint(row: m.row + step.dr, col: m.col + step.dc)
        guard t.row >= 0, t.col >= 0, t.row < gridSize, t.col < gridSize else { return nil }
        guard !blocked.contains(t) else { return nil }
        return t
    }

    private static func snapReflectedToEightNeighbor(_ reflX: Double, _ reflY: Double) -> (dr: Int, dc: Int)? {
        let length = hypot(reflX, reflY)
        guard length > 1e-9 else { return nil }
        let x = reflX / length
        let y = reflY / length
        let candidates: [(Int, Int)] = [
            (-1, -1), (-1, 0), (-1, 1),
            (0, -1), (0, 1),
            (1, -1), (1, 0), (1, 1),
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
        guard let b = best else { return nil }
        return (dr: b.0, dc: b.1)
    }

    func hasSlitMirror(at point: GridPoint) -> Bool {
        level.slitMirrorPoints.contains(point)
    }

    func demoBulbPoint() -> GridPoint {
        let center = GridPoint(row: level.gridSize / 2, col: level.gridSize / 2)
        if isPlayableForBulb(center) { return center }
        for row in 0..<level.gridSize {
            for col in 0..<level.gridSize {
                let p = GridPoint(row: row, col: col)
                if isPlayableForBulb(p) { return p }
            }
        }
        return center
    }

    func demoLitCells() -> Set<GridPoint> {
        let demoBulb = demoBulbPoint()
        return engine.litCellsFor(level: level, bulbs: [demoBulb], extraBlocked: hintMaskedCells)
    }

    private static func bulbCandidates(level: Level, extraBlocked: Set<GridPoint>) -> [GridPoint] {
        WinningPlacementAnalyzer.bulbCandidatePoints(level: level, extraBlocked: extraBlocked)
    }

    private func saveSnapshot() {
        history.append(BoardSnapshot(bulbs: bulbs))
    }

    private func recompute() {
        let result = engine.compute(level: level, bulbs: bulbs, extraBlocked: hintMaskedCells)
        litCells = result.litCells
        didWin = result.isWin

        let nowFullFailed = bulbs.count == level.maxBulbs && !didWin
        if nowFullFailed, !wasInFullFailedState {
            fullFailureEpisodes += 1
            if fullFailureEpisodes >= 3, hintToolbarAttention == .idle {
                hintToolbarAttention = .shaking
            }
        }
        wasInFullFailedState = nowFullFailed
        if didWin {
            fullFailureEpisodes = 0
            wasInFullFailedState = false
        }

        let targets = Set(level.targetMask).subtracting(Set(level.blockedCells).union(hintMaskedCells))
        let litTargets = targets.intersection(litCells).count
        winCondition = WinCondition(
            totalTargets: max(targets.count, 0),
            litTargets: litTargets,
            usedBulbs: result.usedBulbs,
            maxBulbs: level.maxBulbs
        )
    }
}
