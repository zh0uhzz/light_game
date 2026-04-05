import Foundation

struct LevelValidator {
    func validate(level: Level) -> [String] {
        var issues: [String] = []

        if level.gridSize <= 0 {
            issues.append("gridSize 必须 > 0")
        }
        if level.maxBulbs <= 0 {
            issues.append("maxBulbs 必须 > 0")
        }
        if level.radiusSet.isEmpty {
            issues.append("radiusSet 不能为空")
        }

        let range = 0..<level.gridSize
        for p in level.blockedCells where !range.contains(p.row) || !range.contains(p.col) {
            issues.append("blockedCells 越界: (\(p.row), \(p.col))")
        }
        for p in level.targetMask where !range.contains(p.row) || !range.contains(p.col) {
            issues.append("targetMask 越界: (\(p.row), \(p.col))")
        }

        let blocked = Set(level.blockedCells)
        for p in level.targetMask where blocked.contains(p) {
            issues.append("targetMask 包含 blockedCells: (\(p.row), \(p.col))")
        }

        return issues
    }
}
