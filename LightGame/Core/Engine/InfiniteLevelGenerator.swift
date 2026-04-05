import Foundation

/// 无限关 `inf_l{n}`：**从参考答案逆向生成**——先随机盘面与若干盏「后台答案灯」、再取照亮区域的一小部分为目标；
/// 用 `LightingEngine` 仅做一次正向验证（答案能否通关），**不再**枚举最小盏数。同一 `n` 仍确定性可复现。
/// 通关规则：`optimalBulbs == nil` 时视为「盏数不超过 `maxBulbs` 且点亮全部目标」即可（与主线「恰为最优盏」不同）。
enum InfiniteLevelGenerator {
    private static var cache: [Int: Level] = [:]
    private static let cacheLock = NSLock()

    private static let maxProceduralAttempts = 48

    /// 无限模式分块加载：按全局序号闭区间连续生成（缓存 + 与 `level(number:)` 相同）。
    static func levels(inGlobalRange range: ClosedRange<Int>) -> [Level] {
        precondition(range.lowerBound >= 1 && range.upperBound >= range.lowerBound)
        return range.map { level(number: $0) }
    }

    /// 释放过久前的关卡缓存，避免序号极大时内存无限涨（存档只保留计数、不保留旧关）。
    static func pruneCache(keepFromGlobalNumber minKey: Int) {
        let floor = minKey - 1
        guard floor >= 1 else { return }
        cacheLock.lock()
        cache = cache.filter { $0.key >= minKey }
        cacheLock.unlock()
    }

    static func level(number: Int) -> Level {
        precondition(number >= 1)
        cacheLock.lock()
        if let hit = cache[number] {
            cacheLock.unlock()
            return hit
        }
        cacheLock.unlock()

        let built: Level
        if let proc = generateFromAnswerReverse(number: number) {
            built = proc
        } else {
            built = levelFromPresetFallback(number: number)
        }
        cacheLock.lock()
        cache[number] = built
        cacheLock.unlock()
        return built
    }

    // MARK: - 逆向生成（答案 → 目标）

    private static func generateFromAnswerReverse(number: Int) -> Level? {
        for attempt in 0..<maxProceduralAttempts {
            if let lv = tryAnswerReverseLayout(number: number, attempt: attempt) {
                return lv
            }
        }
        return nil
    }

    private static func tryAnswerReverseLayout(number: Int, attempt: Int) -> Level? {
        var rng = SplitMix64(seed: mixSeed(UInt64(number), UInt64(attempt)))
        let n = 5 + rng.nextInt(4)
        /// n=5 为基准；每大一号，障碍/光学件/目标下限略增。
        let tier = n - 5

        let (blkLo, blkHi) = scaledBlockedRange(gridSize: n, tier: tier)
        var nBlocked = blkLo + (blkHi >= blkLo ? rng.nextInt(blkHi - blkLo + 1) : 0)
        nBlocked = min(nBlocked, n * n)

        var blocked: Set<GridPoint> = []
        var tries = 0
        while blocked.count < nBlocked && tries < nBlocked * 30 {
            tries += 1
            blocked.insert(GridPoint(row: rng.nextInt(n), col: rng.nextInt(n)))
        }
        guard !blocked.isEmpty else { return nil }

        let maxOptic = scaledMaxSlitsMirrors(gridSize: n, tier: tier)
        let nSlitsTarget = rng.nextInt(maxOptic + 1)
        var slitPts: Set<GridPoint> = []
        tries = 0
        while slitPts.count < nSlitsTarget && tries < 400 {
            tries += 1
            let p = GridPoint(row: rng.nextInt(n), col: rng.nextInt(n))
            if !blocked.contains(p) { slitPts.insert(p) }
        }

        let nMirrorsTarget = rng.nextInt(maxOptic + 1)
        var mirrors: [MirrorCell] = []
        tries = 0
        while mirrors.count < nMirrorsTarget && tries < 600 {
            tries += 1
            let r = rng.nextInt(n)
            let c = rng.nextInt(n)
            let p = GridPoint(row: r, col: c)
            if blocked.contains(p) || slitPts.contains(p) { continue }
            if mirrors.contains(where: { $0.row == r && $0.col == c }) { continue }
            let dirs = MirrorDirection.allCases
            mirrors.append(MirrorCell(row: r, col: c, direction: dirs[rng.nextInt(dirs.count)]))
        }

        let mirrorSet = Set(mirrors.map(\.point))
        let kBulb = weightedAnswerBulbCount(rng: &rng, gridSize: n)
        guard kBulb >= 2, kBulb <= 7 else { return nil }

        guard let answerBulbs = placeAnswerBulbsNearOptics(
            count: kBulb,
            gridSize: n,
            blocked: blocked,
            mirrorPoints: mirrorSet,
            slitPoints: slitPts,
            rng: &rng
        ) else { return nil }

        let baseDraft = Level(
            id: "inf_l\(number)",
            chapterId: "inf",
            title: "",
            gridSize: n,
            maxBulbs: kBulb,
            radiusSet: [1.0],
            blockedCells: Array(blocked),
            targetMask: [],
            mirrorCells: mirrors.isEmpty ? nil : mirrors,
            slitMirrorCells: slitPts.isEmpty ? nil : Array(slitPts),
            parScore: kBulb,
            optimalBulbs: nil,
            difficultyRank: 1
        )

        let engine = LightingEngine()
        let lit = engine.litCellsFor(level: baseDraft, bulbs: Set(answerBulbs))

        func isTargetable(_ p: GridPoint) -> Bool {
            if p.row < 0 || p.col < 0 || p.row >= n || p.col >= n { return false }
            if blocked.contains(p) || mirrorSet.contains(p) || slitPts.contains(p) { return false }
            return true
        }

        let litCandidates = lit.filter(isTargetable)
        let minLitPool = 2 + tier * 2
        guard litCandidates.count >= minLitPool else { return nil }

        let (tMin, tMaxCap) = scaledTargetRange(gridSize: n, tier: tier, litCount: litCandidates.count)
        let upper = min(tMaxCap, litCandidates.count)
        guard upper >= tMin else { return nil }
        let tcount = tMin + (upper > tMin ? rng.nextInt(upper - tMin + 1) : 0)

        var pool = Array(litCandidates)
        for i in stride(from: pool.count - 1, through: 1, by: -1) {
            let j = rng.nextInt(i + 1)
            pool.swapAt(i, j)
        }
        let targets = Array(pool.prefix(tcount))

        let dr = targets.count + mirrors.count * 2 + slitPts.count + max(0, 9 - n) + rng.nextInt(6)
        let finalLevel = Level(
            id: "inf_l\(number)",
            chapterId: "inf",
            title: "",
            gridSize: n,
            maxBulbs: kBulb,
            radiusSet: [1.0],
            blockedCells: Array(blocked),
            targetMask: targets,
            mirrorCells: mirrors.isEmpty ? nil : mirrors,
            slitMirrorCells: slitPts.isEmpty ? nil : Array(slitPts),
            parScore: kBulb,
            optimalBulbs: nil,
            difficultyRank: dr
        )

        guard engine.compute(level: finalLevel, bulbs: Set(answerBulbs)).isWin else { return nil }
        return finalLevel
    }

    /// n=5：障碍约 2…8（与原逻辑一致）；棋盘越大，障碍越多。
    private static func scaledBlockedRange(gridSize n: Int, tier: Int) -> (Int, Int) {
        let lo = 2 + tier
        let hi = min(8 + tier * 3, max(lo, n * n - 6))
        return (min(lo, hi), hi)
    }

    /// 缝 / 镜各自上限：n=5 时 0…6；n 每 +1 上限 +2，封顶随边长。
    private static func scaledMaxSlitsMirrors(gridSize n: Int, tier: Int) -> Int {
        min(n + 1, 6 + tier * 2)
    }

    /// 目标盏数范围：大盘需更多目标、且不超过照亮候选格。
    private static func scaledTargetRange(gridSize n: Int, tier: Int, litCount: Int) -> (Int, Int) {
        let tMin = min(2 + tier, litCount)
        let cap = min(7 + tier * 2, litCount)
        let tMaxCap = max(tMin, cap)
        return (tMin, tMaxCap)
    }

    /// 2–7 盏，3–4 盏权重最高；棋盘越大整体略偏向多盏。
    private static func weightedAnswerBulbCount(rng: inout SplitMix64, gridSize n: Int) -> Int {
        let tier = n - 5
        var r = rng.nextInt(100)
        r = min(99, r + tier * 6)
        switch r {
        case 0..<5: return 2
        case 5..<32: return 3
        case 32..<62: return 4
        case 62..<82: return 5
        case 82..<94: return 6
        default: return 7
        }
    }

    /// 尽量把答案灯放在折射/反射格的正交邻格（若无光学件则全棋盘可放格随机）。
    private static func placeAnswerBulbsNearOptics(
        count k: Int,
        gridSize n: Int,
        blocked: Set<GridPoint>,
        mirrorPoints: Set<GridPoint>,
        slitPoints: Set<GridPoint>,
        rng: inout SplitMix64
    ) -> [GridPoint]? {
        func playable(_ p: GridPoint) -> Bool {
            guard p.row >= 0, p.col >= 0, p.row < n, p.col < n else { return false }
            if blocked.contains(p) || mirrorPoints.contains(p) || slitPoints.contains(p) { return false }
            return true
        }

        var allPlayable: [GridPoint] = []
        for r in 0..<n {
            for c in 0..<n {
                let p = GridPoint(row: r, col: c)
                if playable(p) { allPlayable.append(p) }
            }
        }
        guard allPlayable.count >= k else { return nil }

        let optics = mirrorPoints.union(slitPoints)
        var nearOptics: [GridPoint] = []
        var seenNear: Set<GridPoint> = []
        for o in optics {
            for d in [(0, 1), (0, -1), (1, 0), (-1, 0)] {
                let q = GridPoint(row: o.row + d.0, col: o.col + d.1)
                if playable(q), !seenNear.contains(q) {
                    seenNear.insert(q)
                    nearOptics.append(q)
                }
            }
        }

        var bulbs: Set<GridPoint> = []
        for i in 0..<k {
            let preferNear = !nearOptics.isEmpty && rng.nextInt(100) < 82
            let pool: [GridPoint]
            if preferNear {
                pool = nearOptics.filter { !bulbs.contains($0) }
            } else {
                pool = allPlayable.filter { !bulbs.contains($0) }
            }
            let usable = pool.isEmpty ? allPlayable.filter { !bulbs.contains($0) } : pool
            guard !usable.isEmpty else { return nil }
            bulbs.insert(usable[rng.nextInt(usable.count)])
        }
        return Array(bulbs)
    }

    private static func levelFromPresetFallback(number: Int) -> Level {
        let i = (number * 37 + (number >> 3)) % presets.count
        let p = presets[i]
        let dr = 3 + (number % 14)
        return Level(
            id: "inf_l\(number)",
            chapterId: "inf",
            title: "",
            gridSize: p.n,
            maxBulbs: p.k,
            radiusSet: [1.0],
            blockedCells: p.blocked,
            targetMask: p.targets,
            mirrorCells: p.mirrors,
            slitMirrorCells: p.slits,
            parScore: p.k,
            optimalBulbs: nil,
            difficultyRank: dr
        )
    }

    private static func mixSeed(_ a: UInt64, _ b: UInt64) -> UInt64 {
        (a &* 2685821657736338717 &+ b) ^ (a &+ b &* 1876413366123096121)
    }

    private struct SplitMix64 {
        private var state: UInt64

        init(seed: UInt64) {
            state = seed
        }

        mutating func nextUInt64() -> UInt64 {
            state &+= 0x9E3779B97F4A7C15
            var z = state
            z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
            z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
            return z ^ (z >> 31)
        }

        mutating func nextInt(_ upper: Int) -> Int {
            guard upper > 0 else { return 0 }
            return Int(nextUInt64() % UInt64(upper))
        }
    }

    private struct Preset {
        let n: Int
        let blocked: [GridPoint]
        let targets: [GridPoint]
        let mirrors: [MirrorCell]?
        let slits: [GridPoint]?
        let k: Int
    }

    private static let presets: [Preset] = {
        func c7() -> [GridPoint] {
            [
                GridPoint(row: 0, col: 0), GridPoint(row: 0, col: 6),
                GridPoint(row: 6, col: 0), GridPoint(row: 6, col: 6),
            ]
        }
        return [
            Preset(
                n: 7, blocked: c7(),
                targets: [GridPoint(row: 3, col: 2), GridPoint(row: 3, col: 4)],
                mirrors: nil, slits: [GridPoint(row: 3, col: 3)], k: 1
            ),
            Preset(
                n: 7, blocked: [],
                targets: [
                    GridPoint(row: 2, col: 1), GridPoint(row: 2, col: 5),
                    GridPoint(row: 4, col: 1), GridPoint(row: 4, col: 5),
                ],
                mirrors: nil, slits: [GridPoint(row: 3, col: 3)], k: 2
            ),
            Preset(
                n: 7, blocked: [GridPoint(row: 0, col: 3), GridPoint(row: 6, col: 3)],
                targets: [GridPoint(row: 1, col: 1), GridPoint(row: 5, col: 5)],
                mirrors: nil, slits: [GridPoint(row: 3, col: 3)], k: 2
            ),
            Preset(
                n: 7, blocked: [],
                targets: [GridPoint(row: 3, col: 0), GridPoint(row: 3, col: 6), GridPoint(row: 1, col: 3)],
                mirrors: nil, slits: [GridPoint(row: 3, col: 2)], k: 3
            ),
            Preset(
                n: 7, blocked: [GridPoint(row: 1, col: 1), GridPoint(row: 1, col: 5)],
                targets: [GridPoint(row: 2, col: 3), GridPoint(row: 4, col: 3), GridPoint(row: 3, col: 0)],
                mirrors: nil, slits: [GridPoint(row: 3, col: 4)], k: 2
            ),
            Preset(
                n: 7, blocked: [],
                targets: [GridPoint(row: 3, col: 1), GridPoint(row: 3, col: 5), GridPoint(row: 1, col: 4)],
                mirrors: nil, slits: [GridPoint(row: 3, col: 3)], k: 3
            ),
            Preset(
                n: 7, blocked: c7(),
                targets: [GridPoint(row: 3, col: 1), GridPoint(row: 5, col: 5)],
                mirrors: nil, slits: [GridPoint(row: 3, col: 2)], k: 2
            ),
            Preset(
                n: 7, blocked: [],
                targets: [GridPoint(row: 2, col: 2), GridPoint(row: 2, col: 4), GridPoint(row: 4, col: 3)],
                mirrors: nil, slits: [GridPoint(row: 3, col: 3)], k: 2
            ),
            Preset(
                n: 7, blocked: [],
                targets: [GridPoint(row: 0, col: 2), GridPoint(row: 6, col: 4), GridPoint(row: 3, col: 6)],
                mirrors: nil, slits: [GridPoint(row: 3, col: 3)], k: 3
            ),
            Preset(
                n: 7, blocked: [GridPoint(row: 1, col: 1)],
                targets: [GridPoint(row: 2, col: 4), GridPoint(row: 4, col: 2)],
                mirrors: [MirrorCell(row: 3, col: 3, direction: .up)],
                slits: [GridPoint(row: 3, col: 2)], k: 2
            ),
            Preset(
                n: 7, blocked: [],
                targets: [GridPoint(row: 1, col: 3), GridPoint(row: 5, col: 3), GridPoint(row: 3, col: 5)],
                mirrors: [MirrorCell(row: 2, col: 2, direction: .right)],
                slits: [GridPoint(row: 3, col: 3)], k: 3
            ),
            Preset(
                n: 7, blocked: c7(),
                targets: [GridPoint(row: 2, col: 4), GridPoint(row: 4, col: 4)],
                mirrors: [MirrorCell(row: 4, col: 3, direction: .left)],
                slits: [GridPoint(row: 3, col: 3)], k: 1
            ),
            Preset(
                n: 8, blocked: [GridPoint(row: 2, col: 2), GridPoint(row: 1, col: 5)],
                targets: [GridPoint(row: 0, col: 3), GridPoint(row: 7, col: 4), GridPoint(row: 4, col: 7), GridPoint(row: 3, col: 0)],
                mirrors: [MirrorCell(row: 5, col: 3, direction: .up)],
                slits: [GridPoint(row: 3, col: 4)], k: 4
            ),
            Preset(
                n: 8, blocked: [],
                targets: [
                    GridPoint(row: 2, col: 2), GridPoint(row: 2, col: 5), GridPoint(row: 5, col: 5),
                ],
                mirrors: nil, slits: [GridPoint(row: 4, col: 3), GridPoint(row: 4, col: 4)], k: 3
            ),
            Preset(
                n: 8, blocked: [GridPoint(row: 0, col: 0)],
                targets: [GridPoint(row: 3, col: 2), GridPoint(row: 5, col: 6), GridPoint(row: 7, col: 3)],
                mirrors: [
                    MirrorCell(row: 2, col: 4, direction: .right),
                    MirrorCell(row: 6, col: 4, direction: .left),
                ],
                slits: [GridPoint(row: 4, col: 3)], k: 3
            ),
            Preset(
                n: 8, blocked: [
                    GridPoint(row: 0, col: 0), GridPoint(row: 0, col: 7),
                    GridPoint(row: 7, col: 0), GridPoint(row: 7, col: 7),
                ],
                targets: [GridPoint(row: 1, col: 1), GridPoint(row: 6, col: 6), GridPoint(row: 4, col: 4)],
                mirrors: [MirrorCell(row: 3, col: 3, direction: .down)],
                slits: [GridPoint(row: 4, col: 4)], k: 3
            ),
        ]
    }()
}
