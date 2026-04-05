import Foundation

struct LevelPack: Codable {
    let chapters: [Chapter]
}

struct Chapter: Codable, Identifiable {
    let id: String
    let title: String
    let levels: [Level]
}

enum MirrorDirection: String, Codable, CaseIterable {
    case up
    case down
    case left
    case right
}

struct MirrorCell: Codable, Hashable {
    let row: Int
    let col: Int
    let direction: MirrorDirection

    var point: GridPoint {
        GridPoint(row: row, col: col)
    }
}

struct Level: Codable, Identifiable {
    let id: String
    let chapterId: String
    let title: String
    let gridSize: Int
    let maxBulbs: Int
    let radiusSet: [Double]
    let blockedCells: [GridPoint]
    let targetMask: [GridPoint]
    let mirrorCells: [MirrorCell]?
    /// 水平缝镜：格内上下为「墙」，光仅能从左或右贯穿到对侧相邻格（与第三章斜镜不同）。
    let slitMirrorCells: [GridPoint]?
    let parScore: Int
    let optimalBulbs: Int?
    let difficultyRank: Int?

    /// 兼容 JSON；实际照明为十字形（见 `GameRules.isCellLitCross`），不再使用圆形半径判定。
    var defaultRadius: Double {
        radiusSet.first ?? 1.0
    }

    var chapterNumber: Int {
        if chapterId == "inf" { return 100 }
        let digits = chapterId.filter { $0.isNumber }
        return Int(digits) ?? 1
    }

    var shouldEnforceOptimalBulbs: Bool {
        chapterNumber >= 2
    }

    /// 卡片难度星：1–7 章内前 4 关 ★、后 5 关 ★★（递增）；8–9 章均为 ★★★；第 10 章特殊关 ★；无限模式均为 ★★ 或 ★★★。
    var homeStarTier: Int {
        if chapterId == "inf" {
            let d = difficultyRank ?? 5
            return min(3, max(2, 1 + d / 6))
        }
        if chapterNumber >= 10 { return 1 }
        if chapterNumber >= 8 { return 3 }
        let idx = levelIndexInChapter
        return idx < 4 ? 1 : 2
    }

    /// 章内关卡序号 0…8（由 `id` 如 `ch5_l3` 解析）。
    var levelIndexInChapter: Int {
        guard let range = id.range(of: "_l", options: .backwards),
              let n = Int(id[range.upperBound...]) else { return 0 }
        return max(0, n - 1)
    }

    // Higher score means tighter illumination budget and generally harder puzzle（十字照明每盏最多 5 格）。
    var difficultyScore: Double {
        let cellsPerBulb = 5.0
        let totalCapacity = cellsPerBulb * Double(maxBulbs)
        guard totalCapacity > 0 else { return 0 }
        return Double(targetMask.count) / totalCapacity
    }

    var mirrorPoints: Set<GridPoint> {
        Set((mirrorCells ?? []).map(\.point))
    }

    var slitMirrorPoints: Set<GridPoint> {
        Set(slitMirrorCells ?? [])
    }
}
