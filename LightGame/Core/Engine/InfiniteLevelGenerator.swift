import Foundation

/// 无限关 `inf_l{n}`：**按关卡编号的确定性种子**随机摆盘 → 用 `MinimumBulbSolver` 验证必有解 → 缓存；
/// 若在预算内找不到可解图则回退到预设池（仍保证可解）。同一 `n` 永远同一盘面。
enum InfiniteLevelGenerator {
    private static var cache: [Int: Level] = [:]
    private static let cacheLock = NSLock()

    /// 单次随机生成的枚举预算（略小可减卡顿；过小易退回预设）。
    private static let solveEvalBudget = 130_000
    private static let maxProceduralAttempts = 56
    private static let proceduralMaxOptimal = 8

    /// 无限模式分块加载：按全局序号闭区间连续生成（缓存 + 可解校验与 `level(number:)` 相同）。
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
        if let proc = generateVerifiedRandom(number: number) {
            built = proc
        } else {
            built = levelFromPresetFallback(number: number)
        }
        cacheLock.lock()
        cache[number] = built
        cacheLock.unlock()
        return built
    }

    /// 随机几何 + 求解器：仅在存在 `k≤proceduralMaxOptimal` 的解时返回。
    private static func generateVerifiedRandom(number: Int) -> Level? {
        for attempt in 0..<maxProceduralAttempts {
            if let lv = tryRandomLayout(number: number, attempt: attempt) {
                return lv
            }
        }
        return nil
    }

    private static func tryRandomLayout(number: Int, attempt: Int) -> Level? {
        var rng = SplitMix64(seed: mixSeed(UInt64(number), UInt64(attempt)))
        let n = 6 + rng.nextInt(3)
        var blocked: Set<GridPoint> = []
        let nBlk = rng.nextInt(4)
        for _ in 0..<nBlk {
            blocked.insert(GridPoint(row: rng.nextInt(n), col: rng.nextInt(n)))
        }

        var slitPts: Set<GridPoint> = []
        let nSl = 1 + rng.nextInt(2)
        for _ in 0..<nSl {
            guard n > 3 else { break }
            let row = 1 + rng.nextInt(max(1, n - 2))
            let col = 1 + rng.nextInt(max(1, n - 2))
            let p = GridPoint(row: row, col: col)
            if !blocked.contains(p) {
                slitPts.insert(p)
            }
        }

        var mirrors: [MirrorCell] = []
        let nMir = rng.nextInt(3)
        for _ in 0..<nMir {
            let r = rng.nextInt(n)
            let c = rng.nextInt(n)
            let p = GridPoint(row: r, col: c)
            if blocked.contains(p) || slitPts.contains(p) { continue }
            if mirrors.contains(where: { $0.row == r && $0.col == c }) { continue }
            let dirs = MirrorDirection.allCases
            mirrors.append(MirrorCell(row: r, col: c, direction: dirs[rng.nextInt(dirs.count)]))
        }

        let mirrorSet = Set(mirrors.map(\.point))
        var playable: [GridPoint] = []
        for r in 0..<n {
            for c in 0..<n {
                let p = GridPoint(row: r, col: c)
                if blocked.contains(p) || mirrorSet.contains(p) || slitPts.contains(p) {
                    continue
                }
                playable.append(p)
            }
        }
        guard playable.count >= 10 else { return nil }

        for i in stride(from: playable.count - 1, through: 1, by: -1) {
            let j = rng.nextInt(i + 1)
            playable.swapAt(i, j)
        }

        let minT = 3
        let maxT = min(8, playable.count - 2)
        guard maxT >= minT else { return nil }
        let tcount = minT + rng.nextInt(maxT - minT + 1)
        let targets = Array(playable.prefix(tcount))

        let draft = Level(
            id: "inf_l\(number)",
            chapterId: "inf",
            title: "",
            gridSize: n,
            maxBulbs: proceduralMaxOptimal,
            radiusSet: [1.0],
            blockedCells: Array(blocked),
            targetMask: targets,
            mirrorCells: mirrors.isEmpty ? nil : mirrors,
            slitMirrorCells: slitPts.isEmpty ? nil : Array(slitPts),
            parScore: 1,
            optimalBulbs: 1,
            difficultyRank: 1
        )

        guard let k = MinimumBulbSolver.findMinimumBulbs(
            level: draft,
            maxK: proceduralMaxOptimal,
            maxEvaluations: solveEvalBudget
        ), k >= 1 else {
            return nil
        }

        let dr = targets.count + mirrors.count * 2 + slitPts.count + max(0, 9 - n) + rng.nextInt(6)
        return Level(
            id: "inf_l\(number)",
            chapterId: "inf",
            title: "",
            gridSize: n,
            maxBulbs: k,
            radiusSet: [1.0],
            blockedCells: Array(blocked),
            targetMask: targets,
            mirrorCells: mirrors.isEmpty ? nil : mirrors,
            slitMirrorCells: slitPts.isEmpty ? nil : Array(slitPts),
            parScore: k,
            optimalBulbs: k,
            difficultyRank: dr
        )
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
            optimalBulbs: p.k,
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
