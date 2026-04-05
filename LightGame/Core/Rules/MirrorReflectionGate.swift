import Foundation

/// 斜镜产生反射光条件：只要镜面格有**至少一盏正交相邻**的灯，就按几何做八邻格反射（单侧入射即可）。
/// 「整格泛亮 vs 半扇入射」仅影响 `BoardViewModel.mirrorCellVisual` 的展示，不由本闸门限制。
/// 无相邻灯但远处十字扫过镜面时，仍会在 `LightingEngine` 末尾被移出 `litCells`，不当作点亮镜格。
enum MirrorReflectionGate {

    static func allowsReflection(mirrorPoint: GridPoint, direction _: MirrorDirection, bulbs: Set<GridPoint>) -> Bool {
        bulbs.contains { GameRules.isOrthogonalPlusAdjacent(mirrorPoint, $0) }
    }
}
