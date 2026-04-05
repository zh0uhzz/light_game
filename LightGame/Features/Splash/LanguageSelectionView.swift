import SwiftUI

/// 首次启动：点灯后、开场说明前，选择界面语言。
struct LanguageSelectionView: View {
    @EnvironmentObject private var audioManager: AudioManager
    @EnvironmentObject private var localization: LocalizationManager
    var onComplete: () -> Void

    @State private var selection: LanguagePreference = .system
    /// 屏幕文案用「试选」语种预览，避免未选时无文案。
    private var preview: AppContentLanguage {
        switch selection {
        case .system:
            return LocalizationManager.inferSystemPreviewLanguage()
        case .zhHans:
            return .zhHans
        case .en:
            return .en
        case .ja:
            return .ja
        case .ko:
            return .ko
        }
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, Color(red: 0.07, green: 0.08, blue: 0.12)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            FireflyBackgroundView(fireflyCount: 18, luminosity: 0.5)
                .ignoresSafeArea()

            VStack(spacing: 22) {
                Image(systemName: "globe")
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.white, Color(red: 1.0, green: 0.92, blue: 0.55)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .padding(.top, 28)

                Text(AppLocalizedStrings.languagePickTitle(preview))
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white.opacity(0.95))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                Text(AppLocalizedStrings.languagePickHint(preview))
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.62))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)

                VStack(spacing: 10) {
                    ForEach(LanguagePreference.allCases) { pref in
                        Button {
                            audioManager.playClick()
                            selection = pref
                        } label: {
                            HStack {
                                Text(AppLocalizedStrings.languagePreferenceLabel(pref, content: preview))
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(.white.opacity(0.92))
                                Spacer()
                                if selection == pref {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color.yellow.opacity(0.95))
                                }
                            }
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color.white.opacity(selection == pref ? 0.12 : 0.06))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .stroke(Color.white.opacity(selection == pref ? 0.22 : 0.1), lineWidth: 1)
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 22)

                Spacer(minLength: 12)

                Button {
                    audioManager.playClick()
                    localization.setPreference(selection)
                    onComplete()
                } label: {
                    Text(AppLocalizedStrings.languageContinue(preview))
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .tint(.yellow)
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .frame(maxWidth: 520)
            .frame(maxWidth: .infinity)
        }
    }
}

#if DEBUG
#Preview {
    LanguageSelectionView(onComplete: {})
        .environmentObject(AudioManager())
        .environmentObject(LocalizationManager())
}
#endif
