import SwiftUI

extension Notification.Name {
    /// 设置里「重新播放开场说明」、由根视图弹出 sheet。
    static let lightGameReplayOnboardingIntro = Notification.Name("lightGameReplayOnboardingIntro")
}

@main
struct LightGameApp: App {
    @StateObject private var progressStore = ProgressStore()
    @StateObject private var audioManager = AudioManager()
    @StateObject private var localization = LocalizationManager()
    @StateObject private var premiumUnlock = PremiumUnlockService()
    @State private var showOpeningSplash = true
    /// 首启全黑 loading，避免首帧空白并提示「已点开应用」。
    @State private var showBootLoadingOverlay = true
    @State private var showOnboardingSheet = false
    @AppStorage("light_game_onboarding_intro_seen") private var onboardingIntroSeen = false
    /// 首次选择界面语言（升级用户若已看过开场说明则自动视为已完成）。
    @AppStorage("light_game_language_onboarding_done") private var languageOnboardingDone = false

    var body: some Scene {
        WindowGroup {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                if showOpeningSplash {
                    SplashView {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showOpeningSplash = false
                        }
                    }
                    .environmentObject(audioManager)
                    .environmentObject(localization)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if !languageOnboardingDone {
                    LanguageSelectionView {
                        withAnimation(.easeInOut(duration: 0.35)) {
                            languageOnboardingDone = true
                        }
                    }
                    .environmentObject(audioManager)
                    .environmentObject(localization)
                } else {
                    ChapterListView()
                        .environmentObject(progressStore)
                        .environmentObject(audioManager)
                        .environmentObject(localization)
                        .environmentObject(premiumUnlock)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .onAppear {
                            if onboardingIntroSeen { languageOnboardingDone = true }
                            guard !onboardingIntroSeen else { return }
                            DispatchQueue.main.async {
                                showOnboardingSheet = true
                            }
                        }
                        .onChange(of: onboardingIntroSeen) { seen in
                            if seen { languageOnboardingDone = true }
                        }
                        .onReceive(NotificationCenter.default.publisher(for: .lightGameReplayOnboardingIntro)) { _ in
                            showOnboardingSheet = true
                        }
                        .sheet(isPresented: $showOnboardingSheet, onDismiss: {
                            if !onboardingIntroSeen {
                                onboardingIntroSeen = true
                            }
                        }) {
                            OnboardingIntroFlow {
                                showOnboardingSheet = false
                            }
                            .environmentObject(audioManager)
                            .environmentObject(localization)
                            .preferredColorScheme(.dark)
                            .presentationDetents([.large])
                            .presentationDragIndicator(.visible)
                        }
                }
            }
            .animation(.easeInOut(duration: 0.5), value: showOpeningSplash)
            .animation(.easeInOut(duration: 0.35), value: languageOnboardingDone)
            .preferredColorScheme(.dark)
            .onAppear {
                if onboardingIntroSeen {
                    languageOnboardingDone = true
                }
            }
            .overlay {
                if showBootLoadingOverlay {
                    ZStack {
                        Color.black
                            .ignoresSafeArea()
                        ProgressView()
                            .tint(Color.white.opacity(0.72))
                            .scaleEffect(1.05)
                    }
                    .transition(.opacity)
                }
            }
            .task {
                try? await Task.sleep(nanoseconds: 380_000_000)
                await MainActor.run {
                    withAnimation(.easeOut(duration: 0.22)) {
                        showBootLoadingOverlay = false
                    }
                }
            }
        }
    }
}
