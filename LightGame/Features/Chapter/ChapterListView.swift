import SwiftUI

struct ChapterListView: View {
    @EnvironmentObject private var progressStore: ProgressStore
    @EnvironmentObject private var audioManager: AudioManager
    @EnvironmentObject private var localization: LocalizationManager
    @EnvironmentObject private var premiumUnlock: PremiumUnlockService

    private var lang: AppContentLanguage { localization.content }
    @State private var chapters: [Chapter] = []
    /// 全包关卡顺序（用于章节末关 ↔ 下一章首关连续导航）
    @State private var allLevelsFlat: [Level] = []
    @State private var loadError: String?
    @State private var showCompanionMode = false
    @State private var showInfiniteWelcome = false
    @State private var showPremiumPaywall = false
    @State private var showInfiniteNeedChapter10Alert = false
    /// 通关第十章后每次进入主页时戳，用于 ∞ 图标约 3 秒弹跳动画。
    @State private var infiniteIconBounceAnchor: Date?

    private var chapter10Complete: Bool {
        progressStore.isChapter10FullyCompleted(orderedLevels: allLevelsFlat)
    }

    /// iPad 等宽屏：列数自适应；窄屏仍约 3 列。
    private var levelGridColumns: [GridItem] {
        [GridItem(.adaptive(minimum: 100))]
    }

    var body: some View {
        NavigationStack {
            Group {
                if let loadError {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundStyle(.orange)
                        Text(AppLocalizedStrings.loadFailed(lang))
                            .font(.headline)
                        Text(loadError)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 18) {
                            ForEach(chapters) { chapter in
                                Text(CampaignLocalizedTitles.chapterTitle(chapterId: chapter.id, packTitle: chapter.title, lang: lang))
                                    .font(.headline)
                                    .foregroundStyle(.white.opacity(0.9))
                                    .padding(.horizontal, 4)

                                LazyVGrid(columns: levelGridColumns, spacing: 12) {
                                    ForEach(Array(chapter.levels.enumerated()), id: \.element.id) { _, level in
                                        let flatIdx = allLevelsFlat.firstIndex(where: { $0.id == level.id }) ?? 0
                                        let unlocked = progressStore.isSequentialMainUnlocked(levelIndex: flatIdx, orderedLevels: allLevelsFlat)
                                        let levelFull = CampaignLocalizedTitles.levelTitle(levelId: level.id, packTitle: level.title, lang: lang)
                                        let levelCard = CampaignLocalizedTitles.homeCardAbbreviation(levelFull, lang: lang)
                                        Group {
                                            if unlocked {
                                                NavigationLink {
                                                    BoardView(
                                                        levels: allLevelsFlat,
                                                        startIndex: flatIdx,
                                                        hintsPerLevel: premiumUnlock.isUnlocked ? 9 : 3
                                                    )
                                                } label: {
                                                    LevelCard(
                                                        lang: lang,
                                                        title: levelCard,
                                                        accessibilityLevelName: levelFull,
                                                        starTier: level.homeStarTier,
                                                        isCompleted: progressStore.isCompleted(levelId: level.id),
                                                        isLocked: false,
                                                        starA11y: AppLocalizedStrings.a11yDifficultyStars(lang, tier: level.homeStarTier)
                                                    )
                                                }
                                                .buttonStyle(.plain)
                                                .simultaneousGesture(TapGesture().onEnded {
                                                    audioManager.playClick()
                                                })
                                            } else {
                                                LevelCard(
                                                    lang: lang,
                                                    title: levelCard,
                                                    accessibilityLevelName: levelFull,
                                                    starTier: level.homeStarTier,
                                                    isCompleted: progressStore.isCompleted(levelId: level.id),
                                                    isLocked: true,
                                                    starA11y: AppLocalizedStrings.a11yDifficultyStars(lang, tier: level.homeStarTier)
                                                )
                                                .onTapGesture {
                                                    audioManager.playClick()
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: 820, alignment: .leading)
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle(AppLocalizedStrings.homeTitle(lang))
            .background(
                ZStack {
                    LinearGradient(
                        colors: [Color.black, Color(red: 0.08, green: 0.08, blue: 0.11)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    FireflyBackgroundView()
                }
                .ignoresSafeArea()
            )
            .onAppear {
                loadLevels()
                syncInfiniteToolbarBounce()
            }
            .task {
                await premiumUnlock.refreshEntitlements()
            }
            .onChange(of: progressStore.completedLevels.count) { _ in
                loadLevels()
                syncInfiniteToolbarBounce()
            }
            .fullScreenCover(isPresented: $showCompanionMode) {
                CompanionModeSheet()
                    .environmentObject(progressStore)
                    .environmentObject(localization)
                    .environmentObject(premiumUnlock)
            }
            .fullScreenCover(isPresented: $showInfiniteWelcome) {
                InfiniteWelcomeSheet(chapter10Complete: chapter10Complete)
                    .environmentObject(progressStore)
                    .environmentObject(audioManager)
                    .environmentObject(localization)
                    .environmentObject(premiumUnlock)
            }
            .sheet(isPresented: $showPremiumPaywall) {
                PremiumPaywallView()
                    .environmentObject(premiumUnlock)
                    .environmentObject(audioManager)
                    .environmentObject(localization)
            }
            .alert(AppLocalizedStrings.infiniteNeedChapter10Title(lang), isPresented: $showInfiniteNeedChapter10Alert) {
                Button(AppLocalizedStrings.ok(lang), role: .cancel) {}
            } message: {
                Text(AppLocalizedStrings.infiniteNeedChapter10Message(lang))
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        audioManager.playClick()
                        audioManager.toggleMute()
                    } label: {
                        Image(systemName: audioManager.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                            .foregroundStyle(.white.opacity(0.9))
                    }
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        audioManager.playClick()
                    })
                    Button {
                        audioManager.playClick()
                        if premiumUnlock.isUnlocked {
                            showCompanionMode = true
                        } else {
                            showPremiumPaywall = true
                        }
                    } label: {
                        Image(systemName: "lightbulb.min.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.96, blue: 0.78),
                                        Color(red: 1.0, green: 0.82, blue: 0.45)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .opacity(premiumUnlock.isUnlocked ? 1 : 0.55)
                            .shadow(color: Color(red: 1.0, green: 0.88, blue: 0.45).opacity(0.35), radius: 3, y: 0)
                    }
                    .accessibilityLabel(AppLocalizedStrings.a11yCompanionMode(lang))
                    Button {
                        audioManager.playClick()
                        guard chapter10Complete else {
                            showInfiniteNeedChapter10Alert = true
                            return
                        }
                        guard premiumUnlock.isUnlocked else {
                            showPremiumPaywall = true
                            return
                        }
                        showInfiniteWelcome = true
                    } label: {
                        InfiniteToolbarIcon(
                            finaleUnlocked: chapter10Complete,
                            bounceAnchor: infiniteIconBounceAnchor
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(AppLocalizedStrings.a11yInfiniteMode(lang))
                }
            }
        }
    }

    private func loadLevels() {
        do {
            let levelURL: URL
            if let bundled = Bundle.main.url(forResource: "levels_pack_01", withExtension: "json") {
                levelURL = bundled
            } else {
                let root = URL(fileURLWithPath: #filePath)
                    .deletingLastPathComponent()
                    .deletingLastPathComponent()
                    .deletingLastPathComponent()
                levelURL = root.appendingPathComponent("Data/levels_pack_01.json")
            }
            let pack = try LevelLoader().load(from: levelURL)
            let raw = pack.chapters
            let ult = progressStore.isCompleted(levelId: "ch9_l9")
            let visible = raw.filter { ch in
                if ch.id == "ch10" { return ult }
                return true
            }
            chapters = visible
            allLevelsFlat = visible.flatMap(\.levels)
            progressStore.setMainCampaignLevelCount(allLevelsFlat.count)
        } catch {
            loadError = AppLocalizedStrings.loadFailedHint(lang, detail: error.localizedDescription)
        }
    }

    private func syncInfiniteToolbarBounce() {
        if chapter10Complete {
            infiniteIconBounceAnchor = Date()
        } else {
            infiniteIconBounceAnchor = nil
        }
    }
}

// MARK: - 陪伴模式（全屏黑场 + 居中摇灯 + 底部轮换文案）

private struct CompanionModeSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var progressStore: ProgressStore
    @EnvironmentObject private var localization: LocalizationManager
    @EnvironmentObject private var premiumUnlock: PremiumUnlockService

    var body: some View {
        GeometryReader { geo in
            let shortest = min(geo.size.width, geo.size.height)
            let bulbFont = max(96, shortest * 0.38)

            // 勿用 ZStack(alignment: .topTrailing)，否则 Canvas 萤点层会被挤到一角。
            ZStack {
                Color.black
                    .frame(width: geo.size.width, height: geo.size.height)
                    .ignoresSafeArea()

                FireflyBackgroundView(fireflyCount: 14, luminosity: 0.5)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .opacity(0.9)

                CompanionBottomFluorescentGlow()
                    .frame(width: geo.size.width, height: geo.size.height)

                TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { ctx in
                    let wobble = sin(ctx.date.timeIntervalSinceReferenceDate * 2.1) * 4.2
                    Image(systemName: "lightbulb.min.fill")
                        .font(.system(size: bulbFont, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color.white,
                                    Color(red: 1.0, green: 0.93, blue: 0.58)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: Color(red: 1.0, green: 0.88, blue: 0.45).opacity(0.42), radius: 22, y: 4)
                        .rotationEffect(.degrees(wobble))
                        .position(x: geo.size.width / 2, y: geo.size.height * 0.44)
                }

                VStack {
                    Spacer()
                    TimelineView(.periodic(from: .now, by: 20.0)) { context in
                        let lines = CompanionLinePools.hangoutLines(language: localization.content)
                        let tick = Int(context.date.timeIntervalSinceReferenceDate / 20.0)
                        let line = lines[abs(tick) % lines.count]
                        Text(line)
                            .font(.system(.body, design: .rounded).weight(.medium))
                            .foregroundStyle(Color.white.opacity(0.78))
                            .multilineTextAlignment(.center)
                            .lineSpacing(5)
                            .padding(.horizontal, 36)
                            .padding(.bottom, geo.safeAreaInsets.bottom + 100)
                            .animation(.easeInOut(duration: 0.45), value: line)
                            .task(id: line) {
                                progressStore.recordCompanionBarrageLineDisplayed(line)
                            }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .overlay(alignment: .topTrailing) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle")
                        .font(.system(size: 22, weight: .light))
                        .foregroundStyle(Color.white.opacity(0.22))
                        .symbolRenderingMode(.hierarchical)
                }
                .buttonStyle(.plain)
                .padding(.top, max(6, geo.safeAreaInsets.top - 2))
                .padding(.trailing, 18)
                .accessibilityLabel(AppLocalizedStrings.closeCompanion(localization.content))
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            if !premiumUnlock.isUnlocked {
                dismiss()
                return
            }
            progressStore.recordCompanionModeOpened()
        }
    }
}

/// 屏底微弱、缓慢飘动的荧黄光晕（多相位近似随机）。
private struct CompanionBottomFluorescentGlow: View {
    var body: some View {
        GeometryReader { geo in
            TimelineView(.animation(minimumInterval: 0.22)) { ctx in
                let t = ctx.date.timeIntervalSinceReferenceDate
                let wobbleX = sin(t * 0.74) * 0.38 + sin(t * 0.31 + 1.1) * 0.22
                let wobbleW = 0.55 + 0.2 * sin(t * 0.52 + 0.7)
                let flicker = 0.045 + 0.028 * (0.5 + 0.5 * sin(t * 0.88))
                let w = geo.size.width

                VStack {
                    Spacer()
                    ZStack {
                        Ellipse()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.96, blue: 0.55).opacity(flicker),
                                        Color(red: 1.0, green: 0.9, blue: 0.38).opacity(flicker * 0.45),
                                        .clear
                                    ],
                                    center: .center,
                                    startRadius: 8,
                                    endRadius: 220
                                )
                            )
                            .frame(width: w * (0.92 + wobbleW * 0.15), height: 160)
                            .offset(x: CGFloat(wobbleX * 70), y: 28)
                            .blur(radius: 42)

                        Ellipse()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.94, blue: 0.62).opacity(flicker * 0.55),
                                        Color(red: 1.0, green: 0.92, blue: 0.5).opacity(flicker * 0.22),
                                        .clear
                                    ],
                                    center: UnitPoint(x: 0.45 + wobbleX * 0.08, y: 0.35),
                                    startRadius: 4,
                                    endRadius: 140
                                )
                            )
                            .frame(width: w * 0.55, height: 100)
                            .offset(x: CGFloat(sin(t * 0.61 + 2) * 35), y: 44)
                            .blur(radius: 28)
                    }
                    .frame(maxWidth: .infinity)
                    .allowsHitTesting(false)
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
        .allowsHitTesting(false)
    }
}

private struct LevelCard: View {
    let lang: AppContentLanguage
    /// 卡片上展示的缩略字。
    let title: String
    /// 无障碍朗读用完整关卡名。
    let accessibilityLevelName: String
    let starTier: Int
    let isCompleted: Bool
    let isLocked: Bool
    let starA11y: String
    private var tiltAngle: Double {
        let seed = abs(accessibilityLevelName.hashValue % 7)
        return Double(seed) - 3.0
    }

    var body: some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.subheadline.bold())
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .foregroundStyle(foregroundForTitle)
            HStack(spacing: 6) {
                ForEach(1...starTier, id: \.self) { _ in
                    Image(systemName: "star.fill")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color.white,
                                    Color(red: 0.98, green: 0.98, blue: 1.0)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Color.white.opacity(0.4), radius: 2, x: 0, y: 0)
                        .shadow(color: Color.white.opacity(0.22), radius: 5, x: 0, y: 0)
                }
            }
            .opacity(isLocked ? 0.38 : 1)
        }
        .frame(maxWidth: .infinity, minHeight: 100, maxHeight: 100)
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(cardFillGradient)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(cardStrokeColor, lineWidth: 1)
        )
        .shadow(color: cardShadowColor, radius: isCompleted && !isLocked ? 10 : 6, x: 0, y: 2)
        .rotationEffect(.degrees(tiltAngle * 0.8))
        .scaleEffect(isCompleted && !isLocked ? 1.02 : 1.0)
        .shadow(color: isCompleted && !isLocked ? Color(red: 1.0, green: 0.93, blue: 0.5, opacity: 0.35) : .clear, radius: 14, x: 0, y: 0)
        .animation(.easeInOut(duration: 0.35), value: isCompleted)
        .animation(.easeInOut(duration: 0.35), value: isLocked)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            isLocked
                ? "\(accessibilityLevelName)，\(AppLocalizedStrings.a11yLevelCardLocked(lang))"
                : "\(accessibilityLevelName)，\(starA11y)"
        )
    }

    private var foregroundForTitle: Color {
        if isLocked { return Color.white.opacity(0.52) }
        return isCompleted ? Color.black.opacity(0.8) : Color.white.opacity(0.88)
    }

    private var cardFillGradient: LinearGradient {
        if isLocked {
            return LinearGradient(
                colors: [Color(red: 0.11, green: 0.11, blue: 0.14), Color(red: 0.08, green: 0.08, blue: 0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        if isCompleted {
            return LinearGradient(
                colors: [Color(red: 0.99, green: 0.9, blue: 0.58), Color(red: 0.95, green: 0.8, blue: 0.32)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        return LinearGradient(
            colors: [Color(red: 0.19, green: 0.20, blue: 0.25), Color(red: 0.15, green: 0.16, blue: 0.2)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var cardStrokeColor: Color {
        if isLocked { return Color.white.opacity(0.08) }
        return isCompleted ? Color(red: 1.0, green: 0.94, blue: 0.65) : Color.white.opacity(0.15)
    }

    private var cardShadowColor: Color {
        if isLocked { return .black.opacity(0.45) }
        return isCompleted ? Color(red: 1.0, green: 0.87, blue: 0.3, opacity: 0.45) : .black.opacity(0.35)
    }
}

// MARK: - 无限模式（弹窗 + 分数进度）

/// 顶栏 ∞：未通第十章为白色；通关后为金色，并在 `bounceAnchor` 之后约 3 秒内上下弹跳。
private struct InfiniteToolbarIcon: View {
    let finaleUnlocked: Bool
    let bounceAnchor: Date?

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            Group {
                if finaleUnlocked {
                    Image(systemName: "infinity")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Self.goldStyle)
                        .shadow(
                            color: Color(red: 1.0, green: 0.88, blue: 0.45).opacity(0.35),
                            radius: 3,
                            y: 0
                        )
                } else {
                    Image(systemName: "infinity")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.92))
                }
            }
            .offset(y: bounceY(at: timeline.date))
        }
    }

    private func bounceY(at date: Date) -> CGFloat {
        guard let t0 = bounceAnchor else { return 0 }
        let e = date.timeIntervalSince(t0)
        guard e >= 0, e < 3 else { return 0 }
        return CGFloat(sin(e * 13)) * 5
    }

    private static var goldStyle: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 1.0, green: 0.96, blue: 0.78),
                Color(red: 1.0, green: 0.82, blue: 0.45),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

}

/// 首批只生成当前窗口至多 10 关；玩到本批最后一关再生成后续 10 关，见 `BoardView.appendInfiniteBatchThenStep`。
private struct InfinitePlayRootView: View {
    let startGlobalNumber: Int
    @EnvironmentObject private var localization: LocalizationManager
    @EnvironmentObject private var premiumUnlock: PremiumUnlockService
    @State private var levels: [Level]?

    var body: some View {
        Group {
            if let levels {
                BoardView(levels: levels, startIndex: 0, hintsPerLevel: premiumUnlock.isUnlocked ? 9 : 3)
            } else {
                ProgressView(AppLocalizedStrings.infiniteLoadingLevels(localization.content))
                    .tint(.yellow)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .task {
                        let n = startGlobalNumber
                        let upper = n + 9
                        let built = await Task.detached(priority: .userInitiated) {
                            InfiniteLevelGenerator.levels(inGlobalRange: n...upper)
                        }.value
                        levels = built
                    }
            }
        }
    }
}

private struct InfiniteWelcomeSheet: View {
    let chapter10Complete: Bool
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var progressStore: ProgressStore
    @EnvironmentObject private var audioManager: AudioManager
    @EnvironmentObject private var localization: LocalizationManager
    @EnvironmentObject private var premiumUnlock: PremiumUnlockService

    private var lang: AppContentLanguage { localization.content }

    private var nextPlayNumber: Int {
        progressStore.infiniteNextPlayNumber()
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { ctx in
                    let wobble = sin(ctx.date.timeIntervalSinceReferenceDate * 2.1) * 4.2
                    Image(systemName: "lightbulb.min.fill")
                        .font(.system(size: 72, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.white, Color(red: 1.0, green: 0.93, blue: 0.58)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: Color(red: 1.0, green: 0.88, blue: 0.45).opacity(0.45), radius: 18, y: 3)
                        .rotationEffect(.degrees(wobble))
                }
                Spacer(minLength: 0)
                VStack(spacing: 26) {
                    Text(AppLocalizedStrings.infiniteWelcomeHeadline(lang))
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.96))
                        .multilineTextAlignment(.center)
                    Text(AppLocalizedStrings.infiniteLevelOrdinal(lang, n: nextPlayNumber))
                        .font(.system(size: 36, weight: .heavy, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(Color(red: 1.0, green: 0.92, blue: 0.45))
                    Text("∞")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.45))
                    Text(AppLocalizedStrings.infiniteNextOnly(lang))
                        .font(.subheadline)
                        .foregroundStyle(Color.white.opacity(0.65))
                }
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                Spacer(minLength: 0)
                VStack(spacing: 14) {
                    NavigationLink {
                        InfinitePlayRootView(startGlobalNumber: nextPlayNumber)
                            .environmentObject(localization)
                            .environmentObject(progressStore)
                            .environmentObject(audioManager)
                            .environmentObject(premiumUnlock)
                    } label: {
                        Text(AppLocalizedStrings.infiniteEnter(lang))
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.yellow)
                    Button(AppLocalizedStrings.infiniteClose(lang)) {
                        dismiss()
                    }
                    .font(.body.weight(.medium))
                    .foregroundStyle(Color.white.opacity(0.58))
                }
                .padding(.horizontal, 4)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                ZStack {
                    LinearGradient(
                        colors: [Color.black, Color(red: 0.08, green: 0.08, blue: 0.11)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    FireflyBackgroundView()
                }
                .ignoresSafeArea()
            )
            .navigationTitle(AppLocalizedStrings.infiniteWelcomeTitle(lang))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(AppLocalizedStrings.infiniteToolbarDone(lang)) {
                        dismiss()
                    }
                    .foregroundStyle(.white.opacity(0.9))
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            if !chapter10Complete || !premiumUnlock.isUnlocked {
                dismiss()
            }
        }
    }
}
