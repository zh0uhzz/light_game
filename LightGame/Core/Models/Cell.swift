import Foundation

struct GridPoint: Hashable, Codable {
    let row: Int
    let col: Int
}

enum CellType: Codable {
    case playable
    case blocked
}

struct CellState: Hashable {
    let point: GridPoint
    let type: CellType
    var hasBulb: Bool
    var isLit: Bool
    var isTarget: Bool
}
