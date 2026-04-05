import SwiftUI

/// 多页自我介绍：用于首次启动或设置中「重新播放」，以 sheet 弹窗呈现（非全屏）。
struct OnboardingIntroFlow: View {
    @EnvironmentObject private var audioManager: AudioManager
    @EnvironmentObject private var localization: LocalizationManager
    var onFinished: () -> Void

    @State private var step = 0

    private var lang: AppContentLanguage { localization.content }
    private var titles: [String] { AppLocalizedStrings.onboardingTitles(lang) }
    private var bodies: [String] { AppLocalizedStrings.onboardingBodies(lang) }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.05, green: 0.06, blue: 0.1), Color(red: 0.09, green: 0.1, blue: 0.14)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            FireflyBackgroundView(fireflyCount: 14, luminosity: 0.48)

            GeometryReader { geo in
                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        Button {
                            audioManager.playClick()
                            onFinished()
                        } label: {
                            Text(AppLocalizedStrings.onboardingSkip(lang))
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.white.opacity(0.55))
                        }
                        .padding(.trailing, 4)
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 10)

                    ScrollView {
                        VStack(spacing: 0) {
                            Image(systemName: "lightbulb.min.fill")
                                .font(.system(size: 40, weight: .medium))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.white, Color(red: 1.0, green: 0.9, blue: 0.5)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .shadow(color: Color(red: 1.0, green: 0.88, blue: 0.45).opacity(0.35), radius: 12, y: 2)
                                .padding(.top, 4)
                                .padding(.bottom, 16)

                            Text(titles[step])
                                .font(.title3.weight(.bold))
                                .foregroundStyle(.white.opacity(0.95))
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)

                            Text(bodies[step])
                                .font(.body)
                                .foregroundStyle(.white.opacity(0.82))
                                .multilineTextAlignment(.leading)
                                .lineSpacing(6)
                                .padding(.top, 14)
                        }
                        .frame(maxWidth: .infinity, alignment: .top)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 12)
                    }
                    .scrollContentBackground(.hidden)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    HStack(spacing: 10) {
                        ForEach(0..<titles.count, id: \.self) { i in
                            Circle()
                                .fill(i == step ? Color.yellow.opacity(0.9) : Color.white.opacity(0.22))
                                .frame(width: 7, height: 7)
                        }
                    }
                    .padding(.bottom, 12)

                    Button {
                        audioManager.playClick()
                        if step < titles.count - 1 {
                            withAnimation(.easeInOut(duration: 0.25)) { step += 1 }
                        } else {
                            onFinished()
                        }
                    } label: {
                        Text(step < titles.count - 1 ? AppLocalizedStrings.onboardingNext(lang) : AppLocalizedStrings.onboardingStart(lang))
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.yellow)
                    .padding(.horizontal, 24)
                    .padding(.bottom, max(12, geo.safeAreaInsets.bottom + 8))
                }
                .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .id(lang)
    }
}

#if DEBUG
#Preview {
    OnboardingIntroFlow(onFinished: {})
        .environmentObject(AudioManager())
        .environmentObject(LocalizationManager())
        .presentationDetents([.large])
}
#endif
