import SwiftUI

struct FireflyBackgroundView: View {
    /// 萤点颗数；主界面等默认 36，陪伴模式等可降至十余颗。
    var fireflyCount: Int = 36
    /// 亮度系数（整体不透明度）。
    var luminosity: Double = 1

    var body: some View {
        TimelineView(.animation(minimumInterval: 0.04)) { timeline in
            Canvas { context, size in
                let t = timeline.date.timeIntervalSinceReferenceDate
                let n = max(0, fireflyCount)
                for i in 0..<n {
                    let seed = Double(i)
                    let baseX = (sin(seed * 12.17) * 0.5 + 0.5) * size.width
                    let baseY = (cos(seed * 8.33) * 0.5 + 0.5) * size.height
                    let driftX = sin(t * (0.15 + seed * 0.005) + seed) * 18
                    let driftY = cos(t * (0.2 + seed * 0.004) + seed * 0.7) * 14
                    let x = baseX + driftX
                    let y = baseY + driftY
                    let radius = 0.8 + (seed.truncatingRemainder(dividingBy: 4)) * 0.45
                    let alpha = (0.1 + (sin(t * 1.2 + seed) * 0.5 + 0.5) * 0.22) * luminosity
                    let rect = CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2)
                    context.fill(
                        Path(ellipseIn: rect),
                        with: .color(Color(red: 1.0, green: 0.93, blue: 0.65, opacity: alpha))
                    )
                }
            }
        }
        .allowsHitTesting(false)
    }
}
