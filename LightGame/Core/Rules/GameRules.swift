import Foundation

enum GameRules {

    /// 十字照明：灯泡所在格与四向正交一格（共最多 5 格）。
    static func isCellLitCross(cell: GridPoint, by bulbs: Set<GridPoint>) -> Bool {
        for bulb in bulbs where isOrthogonalPlusAdjacent(cell, bulb) {
            return true
        }
        return false
    }

    static func isOrthogonalPlusAdjacent(_ cell: GridPoint, _ bulb: GridPoint) -> Bool {
        let dr = cell.row - bulb.row
        let dc = cell.col - bulb.col
        if dr == 0 && dc == 0 { return true }
        if dr == 0 && abs(dc) == 1 { return true }
        if dc == 0 && abs(dr) == 1 { return true }
        return false
    }

    static func gridDistance(_ cell: GridPoint, _ bulb: GridPoint) -> Double {
        let dRow = Double(cell.row - bulb.row)
        let dCol = Double(cell.col - bulb.col)
        return (dRow * dRow + dCol * dCol).squareRoot()
    }

    /// UI 色阶：十字心最亮；正交邻格略淡；仅靠镜面/折射缝等间接照亮用中间色阶。
    static func lightVisualTier(cell: GridPoint, bulbs: Set<GridPoint>, isLit: Bool) -> Int? {
        guard isLit else { return nil }
        let onBulb = bulbs.contains(cell)
        if onBulb { return 0 }
        let ortho = bulbs.filter { isOrthogonalPlusAdjacent(cell, $0) }
        if ortho.isEmpty {
            return 2
        }
        var band = 1
        if ortho.count >= 2 {
            band = max(0, band - 1)
        }
        return min(3, band)
    }
}
