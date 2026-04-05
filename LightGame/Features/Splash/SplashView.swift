import SwiftUI
import UIKit

/// 纯黑开屏：手写体「Lux」→ 点击灯泡点亮 → 「Lumos」过渡后进入主页。
struct SplashView: View {
    var onFinished: () -> Void

    @EnvironmentObject private var audioManager: AudioManager
    @EnvironmentObject private var localization: LocalizationManager

    @State private var bulbLit = false
    @State private var luxOpacity: Double = 1
    @State private var luxBlur: CGFloat = 0
    @State private var lumosOpacity: Double = 0
    @State private var lumosBlur: CGFloat = 6
    @State private var allowTap = true

    var body: some View {
        GeometryReader { geo in
            // 真机首帧常出现 width/height 为 0，会导致字号与图片为 0、整屏纯黑。
            let layoutW = Self.resolveLayoutWidth(geo.size.width)
            let topInset = max(geo.safeAreaInsets.top, Self.notchTopFallback)
            let titleSize = max(28, min(layoutW * 0.22, 88))
            let lumosSize = max(22, min(layoutW * 0.16, 68))
            let bulbWidth = max(200, min(layoutW * 0.92, 440))

            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 0) {
                    ZStack {
                        Text("Lux")
                            .font(Self.scriptFont(size: titleSize))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.92, green: 0.9, blue: 0.82),
                                        Color(red: 0.75, green: 0.72, blue: 0.65)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .opacity(luxOpacity)
                            .blur(radius: luxBlur)

                        Text("Lumos")
                            .font(Self.scriptFont(size: lumosSize))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.96, blue: 0.78),
                                        Color(red: 0.95, green: 0.85, blue: 0.45)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .opacity(lumosOpacity)
                            .blur(radius: lumosBlur)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, topInset + 36)
                    .animation(.easeInOut(duration: 0.55), value: luxOpacity)
                    .animation(.easeInOut(duration: 0.55), value: luxBlur)
                    .animation(.easeInOut(duration: 0.6), value: lumosOpacity)
                    .animation(.easeInOut(duration: 0.6), value: lumosBlur)

                    Spacer()

                    Button {
                        handleBulbTap()
                    } label: {
                        SplashBulbArtwork(lit: bulbLit, maxWidth: bulbWidth)
                    }
                    .buttonStyle(.plain)
                    .offset(x: 14)
                    .accessibilityLabel(AppLocalizedStrings.splashBulbA11yLabel(localization.content))
                    .accessibilityHint(AppLocalizedStrings.splashBulbA11yHint(localization.content))

                    Spacer()
                    Spacer()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    /// 与横边略小的窗口（如分屏）兼容；未知宽度时用主屏逻辑宽。
    private static func resolveLayoutWidth(_ proposed: CGFloat) -> CGFloat {
        let screenW = UIScreen.main.bounds.width
        if proposed > 1 { return proposed }
        return max(screenW, 320)
    }

    private static var notchTopFallback: CGFloat {
        let h = UIScreen.main.bounds.height
        return h >= 812 ? 47 : 20
    }

    private func handleBulbTap() {
        guard allowTap else { return }
        allowTap = false
        audioManager.playClick()
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        withAnimation(.easeInOut(duration: 0.55)) {
            bulbLit = true
        }

        withAnimation(.easeOut(duration: 0.4)) {
            luxOpacity = 0
            luxBlur = 14
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            withAnimation(.easeIn(duration: 0.55)) {
                lumosOpacity = 1
                lumosBlur = 0
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.45) {
            onFinished()
        }
    }

    private static func scriptFont(size: CGFloat) -> Font {
        let clamped = max(12, size)
        let names = [
            "Bradley Hand ITC",
            "Bradley Hand",
            "Noteworthy-Bold",
            "Noteworthy",
            "Snell Roundhand",
            "Savoye LET",
            "Zapfino"
        ]
        for name in names where UIFont(name: name, size: clamped) != nil {
            return .custom(name, size: clamped)
        }
        return .system(size: clamped, weight: .ultraLight, design: .serif)
    }
}

// MARK: - 开屏灯泡素材（关灯 / 开灯）

private struct SplashBulbArtwork: View {
    var lit: Bool
    var maxWidth: CGFloat

    var body: some View {
        ZStack {
            Image("SplashBulbOff")
                .resizable()
                .scaledToFit()
                .opacity(lit ? 0 : 1)
            Image("SplashBulbOn")
                .resizable()
                .scaledToFit()
                .opacity(lit ? 1 : 0)
        }
        .frame(maxWidth: max(maxWidth, 120))
        .animation(.easeInOut(duration: 0.55), value: lit)
    }
}

#if DEBUG
#Preview {
    SplashView(onFinished: {})
        .environmentObject(AudioManager())
        .environmentObject(LocalizationManager())
}
#endif
