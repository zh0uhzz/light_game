import Foundation

// 示例测试逻辑（可迁移到 XCTest Target）
struct LightingEngineTests {
    static func testCenterLight() -> Bool {
        let level = Level(
            id: "t1",
            chapterId: "test",
            title: "test",
            gridSize: 5,
            maxBulbs: 1,
            radiusSet: [1.5],
            blockedCells: [],
            targetMask: [GridPoint(row: 2, col: 2)],
            mirrorCells: nil,
            slitMirrorCells: nil,
            parScore: 1,
            optimalBulbs: nil,
            difficultyRank: nil
        )
        let result = LightingEngine().compute(level: level, bulbs: [GridPoint(row: 2, col: 2)])
        return result.isWin
    }
}
