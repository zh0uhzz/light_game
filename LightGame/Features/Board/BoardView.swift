import SwiftUI
import UIKit

struct BoardView: View {

    /// 黄金比例与斐波那契近似，用于主内容区间距。
    private enum LayoutRhythm {
        // 比例参考 φ≈1.618（斐波那契取整），便于随手微调。
        /// 标题区下沿到灯泡灰条顶：固定 padding（勿在此处用可伸长 Spacer，否则会顶开棋盘）。
        static let topToHud: CGFloat = 10
        /// 灯泡栏垂直微调（负值整体上移，偏正值往下）。
        static let hudLift: CGFloat = -6
        /// 横幅与棋盘之间的留白。
        static let bannerToBoardPad: CGFloat = 2
        /// 提示 / 限灯横幅相对上方内容的下移（略增大则横幅整体更靠下）。
        static let bannerTopPad: CGFloat = 9
        /// 主列堆叠间距（≈ floor(13×φ)）。
        static let vStack: CGFloat = 21
        /// 棋盘与话唠小灯之间。
        static let boardToCompanion: CGFloat = 6
        /// 话唠条与底边的留白。
        static let companionBottomPad: CGFloat = 4
        /// 话唠主文案区最小高度（按约两行 footnote），减少 1↔2 行换行时高度闪动。
        static let companionNarrationMinHeight: CGFloat = 52
        /// 系统大标题整体略下沉（UIKit 微调，见 `NavigationBarLargeTitlePushDown`）。
        static let navLargeTitlePushDown: CGFloat = 3.5
    }

    /// 顶栏 trailing：加高「栏围」以免角标贴顶被裁；各按钮同宽同高；略收紧宽度减少最右侧被系统收成「⋯」的概率。
    private enum TopBarItem {
        static let minWidth: CGFloat = 44
        static let minHeight: CGFloat = 54
        static let padH: CGFloat = 3
        static let padV: CGFloat = 3
        static let circleIconFont: CGFloat = 19
        static let bookIconFont: CGFloat = 13
        /// 提示次数角标（数字与胶囊整体略小）。
        static let hintBadgeFont: CGFloat = 8
        static let hintBadgePadH: CGFloat = 3
        static let hintBadgePadV: CGFloat = 2
    }

    @EnvironmentObject private var progressStore: ProgressStore
    @EnvironmentObject private var audioManager: AudioManager
    @EnvironmentObject private var localization: LocalizationManager
    @StateObject private var viewModel: BoardViewModel
    @State private var levels: [Level]
    /// 无限列表末尾正在后台生成下一批 10 关，避免连点。
    @State private var isExtendingInfinitePlaylist = false
    /// 已生成的下一批关卡（在距缓冲区末端约 3 关时预取，减弱 10→11 关等边界卡顿）。
    @State private var prefetchedInfiniteBatch: [Level]?
    @State private var infinitePrefetchTask: Task<Void, Never>?
    /// 发起预取时「当前缓冲区最后一关」的全局序号，用于丢弃过时完成的任务。
    @State private var infinitePrefetchAnchorLastGlobal: Int?
    @State private var showTutorial = false
    @State private var showWinOverlay = false
    @State private var showLimitHint = false
    @State private var hintBannerText: String?
    @State private var showLightIntro = false
    @State private var companionSessionStart = Date()
    @State private var currentIndex: Int

    /// 无限模式：无「上一关」；列表按批扩展。
    private var isInfinitePlaylist: Bool {
        levels.first?.chapterId == "inf"
    }

    private var infiniteCanExtendPastEnd: Bool {
        isInfinitePlaylist
    }

    /// 无限模式：侧栏「下一关」须当前盘面已达成胜利，禁止未通关跳关。
    /// 主线：须当前关至少通关一次后才能进入下一关（与主页顺序解锁一致）。
    private var sideNextButtonDisabled: Bool {
        if isInfinitePlaylist {
            if !viewModel.didWin { return true }
            if currentIndex >= levels.count - 1 {
                return !infiniteCanExtendPastEnd || isExtendingInfinitePlaylist
            }
            return false
        }
        if currentIndex >= levels.count - 1 { return true }
        return !progressStore.isCompleted(levelId: levels[currentIndex].id)
    }

    /// - Parameter hintsPerLevel: 未解锁为 3，永久会员为 9（见 `ChapterListView`）。
    init(level: Level, hintsPerLevel: Int = 3) {
        let quota = max(1, hintsPerLevel)
        _levels = State(initialValue: [level])
        _currentIndex = State(initialValue: 0)
        _viewModel = StateObject(wrappedValue: BoardViewModel(level: level, hintsPerLevel: quota))
    }

    init(levels: [Level], startIndex: Int, hintsPerLevel: Int = 3) {
        precondition(!levels.isEmpty, "BoardView requires non-empty levels")
        let safeLevels = levels
        let safeIndex = min(max(startIndex, 0), safeLevels.count - 1)
        let quota = max(1, hintsPerLevel)
        _levels = State(initialValue: safeLevels)
        _currentIndex = State(initialValue: safeIndex)
        _viewModel = StateObject(wrappedValue: BoardViewModel(level: safeLevels[safeIndex], hintsPerLevel: quota))
    }

    var body: some View {
        VStack(spacing: 0) {
            compactLevelHud
                .padding(.top, LayoutRhythm.topToHud + LayoutRhythm.hudLift)
            if let hintBannerText {
                Text(hintBannerText)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(Color.orange.opacity(0.95))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, LayoutRhythm.bannerTopPad)
                    .transition(.opacity)
            }
            if showLimitHint {
                Text(AppLocalizedStrings.bulbCapBanner(localization.content))
                    .font(.footnote)
                    .foregroundStyle(.pink)
                    .padding(.top, LayoutRhythm.bannerTopPad)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
            boardWithSideLevelNav
                .padding(.top, LayoutRhythm.bannerToBoardPad)
            companionWhisperStrip
                .padding(.top, LayoutRhythm.boardToCompanion)
                .padding(.bottom, LayoutRhythm.companionBottomPad)
            // 竖直方向余量全部落在话唠下方，避免在「灯泡条—棋盘」之间被 Spacer 拉大。
            Spacer(minLength: 0)
        }
        .padding()
        .background(
            ZStack {
                LinearGradient(
                    colors: [Color(red: 0.13, green: 0.14, blue: 0.18), Color(red: 0.16, green: 0.17, blue: 0.21)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                FireflyBackgroundView()
            }
            .ignoresSafeArea()
        )
        .overlay {
            if showWinOverlay {
                winSuccessOverlay
            }
        }
        .overlay {
            if showLightIntro {
                LevelWelcomeOverlay(line: welcomePlayfulLine)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.94)),
                        removal: .opacity.combined(with: .scale(scale: 0.97))
                    ))
            }
        }
        .overlay {
            if isInfinitePlaylist && isExtendingInfinitePlaylist {
                infiniteNextBatchLoadingOverlay
            }
        }
        .navigationTitle(boardNavigationTitle)
        .navigationBarTitleDisplayMode(.large)
        .background(
            NavigationBarLargeTitlePushDown(dy: LayoutRhythm.navLargeTitlePushDown)
                .frame(width: 0, height: 0)
                .accessibilityHidden(true)
        )
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    audioManager.playClick()
                    showTutorial = true
                } label: {
                    Image(systemName: "book.fill")
                        .font(.system(size: TopBarItem.bookIconFont, weight: .semibold))
                        .symbolRenderingMode(.hierarchical)
                        .frame(minWidth: TopBarItem.minWidth, minHeight: TopBarItem.minHeight, alignment: .center)
                        .padding(.horizontal, TopBarItem.padH)
                        .padding(.vertical, TopBarItem.padV)
                }
                .accessibilityLabel(AppLocalizedStrings.rulesA11y(localization.content))
                TimelineView(.animation(minimumInterval: 1.0 / 20.0)) { timeline in
                    let shakeX: CGFloat = {
                        guard viewModel.hintToolbarAttention == .shaking else { return 0 }
                        return CGFloat(sin(timeline.date.timeIntervalSinceReferenceDate * 19)) * 6
                    }()
                    hintToolbarButton(shakeX: shakeX)
                }
                Button {
                    audioManager.playClick()
                    showWinOverlay = false
                    progressStore.removePlayState(for: viewModel.level.id)
                    viewModel.restart()
                    progressStore.recordLevelRestartTapped()
                } label: {
                    Image(systemName: "arrow.counterclockwise.circle.fill")
                        .font(.system(size: TopBarItem.circleIconFont))
                        .symbolRenderingMode(.hierarchical)
                        .frame(minWidth: TopBarItem.minWidth, minHeight: TopBarItem.minHeight, alignment: .center)
                        .padding(.horizontal, TopBarItem.padH)
                        .padding(.vertical, TopBarItem.padV)
                }
                .accessibilityLabel(AppLocalizedStrings.restartA11y(localization.content))
                Button {
                    audioManager.playClick()
                    viewModel.undo()
                } label: {
                    Image(systemName: "arrow.uturn.backward.circle.fill")
                        .font(.system(size: TopBarItem.circleIconFont))
                        .symbolRenderingMode(.hierarchical)
                        .frame(minWidth: TopBarItem.minWidth, minHeight: TopBarItem.minHeight, alignment: .center)
                        .padding(.horizontal, TopBarItem.padH)
                        .padding(.vertical, TopBarItem.padV)
                }
                .accessibilityLabel(AppLocalizedStrings.undoA11y(localization.content))
            }
        }
        .sheet(isPresented: $showTutorial) {
            TutorialView()
                .environmentObject(localization)
        }
        .onChange(of: viewModel.didWin) { won in
            if won {
                if isInfinitePlaylist, let g = infiniteLevelNumber(from: viewModel.level.id) {
                    progressStore.registerInfiniteLevelCompleted(atGlobalNumber: g)
                } else {
                    progressStore.markCompleted(levelId: viewModel.level.id)
                }
                progressStore.savePlayState(levelId: viewModel.level.id, state: viewModel.currentPlayState())
                showWinOverlay = true
                Haptics.success()
                audioManager.playWinCheer()
            }
        }
        .onChange(of: viewModel.hintToolbarAttention) { phase in
            if phase == .shaking {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    if viewModel.hintToolbarAttention == .shaking {
                        viewModel.finishHintButtonShaking()
                    }
                }
            }
        }
        .onChange(of: viewModel.limitWarning) { warned in
            guard warned else { return }
            Haptics.warning()
            withAnimation(.easeInOut(duration: 0.2)) {
                showLimitHint = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showLimitHint = false
                }
            }
        }
        .onChange(of: viewModel.playStateSaveNonce) { _ in
            progressStore.savePlayState(levelId: viewModel.level.id, state: viewModel.currentPlayState())
        }
        .onAppear {
            if !levels.isEmpty {
                if !isInfinitePlaylist {
                    let clamped = Self.clampedMainStartIndex(currentIndex, levels: levels, progress: progressStore)
                    if clamped != currentIndex {
                        currentIndex = clamped
                    }
                }
                let id = levels[currentIndex].id
                viewModel.loadLevel(levels[currentIndex], restored: progressStore.playStateWhenEntering(levelId: id))
                applyLightIntroIfNeeded(forLevelId: id)
            }
            companionSessionStart = Date()
            scheduleInfinitePrefetchIfNeeded()
        }
        .onChange(of: viewModel.level.id) { _ in
            companionSessionStart = Date()
            scheduleInfinitePrefetchIfNeeded()
        }
        .onChange(of: currentIndex) { _ in
            scheduleInfinitePrefetchIfNeeded()
        }
        .onChange(of: levels.count) { _ in
            scheduleInfinitePrefetchIfNeeded()
        }
        .onDisappear {
            infinitePrefetchTask?.cancel()
            infinitePrefetchTask = nil
        }
    }

    @ViewBuilder
    private func hintToolbarButton(shakeX: CGFloat) -> some View {
        let hintBadgeFill = Color(uiColor: UIColor(white: 0.4, alpha: 1))
        Button {
            audioManager.playClick()
            switch viewModel.applyHint() {
            case .idle:
                break
            case .showedBanner(let msg):
                hintBannerText = msg
                Haptics.warning()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                    hintBannerText = nil
                }
            case .consumedHint:
                progressStore.recordHintConsumed()
            }
        } label: {
            // 角标与灯泡同一 ZStack + 中心偏移，避免 overlay 贴小框被栏裁切、与图标「分离」。
            ZStack(alignment: .center) {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.yellow.opacity(0.5), Color.yellow.opacity(0.06)],
                            center: .center,
                            startRadius: 2,
                            endRadius: 18
                        )
                    )
                    .frame(width: 34, height: 34)
                    .blur(radius: 4)
                    .opacity(viewModel.hintToolbarAttention == .glowing ? 1 : 0)
                    .allowsHitTesting(false)
                Image(systemName: "lightbulb.circle.fill")
                    .font(.system(size: TopBarItem.circleIconFont))
                    .symbolRenderingMode(.hierarchical)
                if viewModel.hintsRemaining > 0 {
                    Text("\(viewModel.hintsRemaining)")
                        .font(.system(size: TopBarItem.hintBadgeFont, weight: .heavy))
                        .foregroundStyle(Color.white)
                        .monospacedDigit()
                        .padding(.horizontal, TopBarItem.hintBadgePadH)
                        .padding(.vertical, TopBarItem.hintBadgePadV)
                        .background(Capsule().fill(hintBadgeFill))
                        .compositingGroup()
                        .drawingGroup()
                        .offset(x: 9, y: -9)
                }
            }
            .frame(minWidth: TopBarItem.minWidth, minHeight: TopBarItem.minHeight, alignment: .center)
            .padding(.horizontal, TopBarItem.padH)
            .padding(.vertical, TopBarItem.padV)
            .contentShape(Rectangle())
        }
        .disabled(viewModel.hintsRemaining <= 0 || viewModel.hintToolbarAttention == .idle)
        .offset(x: shakeX)
        .accessibilityLabel(AppLocalizedStrings.hintA11y(localization.content, remaining: viewModel.hintsRemaining))
    }

    private var boardNavigationTitle: String {
        let lang = localization.content
        let id = viewModel.level.id
        if viewModel.level.chapterId == "inf", let n = infiniteLevelNumber(from: id) {
            return AppLocalizedStrings.navInfiniteShort(lang, n: n)
        }
        let pack = viewModel.level.title.trimmingCharacters(in: .whitespacesAndNewlines)
        let loc = CampaignLocalizedTitles.levelTitle(levelId: id, packTitle: pack, lang: lang)
        if !loc.isEmpty { return loc }
        return AppLocalizedStrings.homeTitle(lang)
    }

    private func infiniteLevelNumber(from levelId: String) -> Int? {
        guard let r = levelId.range(of: "_l", options: .backwards),
              let n = Int(levelId[r.upperBound...]) else { return nil }
        return n
    }

    /// 仅未通关关卡展示晃动小灯欢迎层；主线已点亮、无限已计入通关序号的关再进不弹。
    private func shouldShowLightIntro(forLevelId levelId: String) -> Bool {
        if levelId.hasPrefix("inf_l") {
            guard let n = infiniteLevelNumber(from: levelId) else { return true }
            return n > progressStore.infiniteLevelsCleared
        }
        return !progressStore.isCompleted(levelId: levelId)
    }

    private func applyLightIntroIfNeeded(forLevelId levelId: String) {
        guard shouldShowLightIntro(forLevelId: levelId) else {
            showLightIntro = false
            return
        }
        showLightIntro = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeOut(duration: 0.5)) { showLightIntro = false }
        }
    }

    /// 进关 / 换关时随机一句俏皮话，避免和导航标题抢同一块「说明文字」。
    private var welcomePlayfulLine: String {
        let lang = localization.content
        if viewModel.level.id == "ch10_l1" {
            return AppLocalizedStrings.welcomeLineFinale(lang)
        }
        let pool = AppLocalizedStrings.welcomeLinePool(lang)
        let i = abs(viewModel.level.id.hashValue) % pool.count
        return pool[i]
    }

    private var companionWhisperStrip: some View {
        let level = viewModel.level
        let lang = localization.content
        let interval = LevelCompanionNarration.lineIntervalSeconds
        return HStack(alignment: .center, spacing: 12) {
            Image(systemName: "lightbulb.min.fill")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.97, blue: 0.88),
                            Color(red: 1.0, green: 0.85, blue: 0.55)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: Color(red: 1.0, green: 0.92, blue: 0.5).opacity(0.35), radius: 4, y: 0)
                .offset(y: 3)
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Text(AppLocalizedStrings.companionStripTitle(lang))
                        .font(.system(.caption, design: .rounded).weight(.heavy))
                        .foregroundStyle(Color(red: 1.0, green: 0.93, blue: 0.78))
                    Text("·")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white.opacity(0.35))
                    Text(LevelCompanionNarration.isFinale(level)
                         ? AppLocalizedStrings.companionStripSubtitleFinale(lang)
                         : AppLocalizedStrings.companionStripSubtitleNormal(lang))
                        .font(.system(.caption2, design: .rounded).weight(.semibold))
                        .foregroundStyle(.white.opacity(0.52))
                }
                TimelineView(.periodic(from: .now, by: interval)) { context in
                    let line: String = {
                        if LevelCompanionNarration.isFinale(level) {
                            return LevelCompanionNarration.finaleLine(sessionStart: companionSessionStart, now: context.date, language: lang)
                        }
                        let tick = Int(context.date.timeIntervalSinceReferenceDate / interval)
                        return LevelCompanionNarration.rotatingLine(for: level, wallClockTick: tick, language: lang)
                    }()
                    Text(line)
                        .font(.system(.footnote, design: .rounded).weight(.medium))
                        .foregroundStyle(.white.opacity(0.8))
                        .italic()
                        .multilineTextAlignment(.leading)
                        .lineSpacing(3)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .frame(minHeight: LayoutRhythm.companionNarrationMinHeight, alignment: .topLeading)
                        .animation(nil, value: line)
                        .transaction { $0.animation = nil }
                        .task(id: line) {
                            if level.chapterId == "inf" {
                                progressStore.recordInfiniteBarrageLineDisplayed(line)
                            }
                        }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.94, blue: 0.88).opacity(0.14),
                            Color(red: 0.88, green: 0.91, blue: 1.0).opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.22),
                                    Color(red: 1.0, green: 0.85, blue: 0.7).opacity(0.18)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: Color.black.opacity(0.12), radius: 8, y: 3)
        .accessibilityElement(children: .combine)
    }

    /// 落在大标题与棋盘之间；灯泡条恢复大尺寸素材，和早期版本一致。
    private var compactLevelHud: some View {
        let wc = viewModel.winCondition
        let level = viewModel.level
        let lang = localization.content
        return VStack(alignment: .leading, spacing: 10) {
            if isInfinitePlaylist, let g = infiniteLevelNumber(from: level.id) {
                Text(AppLocalizedStrings.hudLevelOrdinal(lang, g: g))
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(Color(red: 0.72, green: 0.92, blue: 1.0).opacity(0.92))
            }
            HStack(alignment: .center, spacing: 14) {
                BulbQuotaStrip(placed: wc.usedBulbs, maxBulbs: wc.maxBulbs, lang: lang)
                Spacer(minLength: 8)
                VStack(alignment: .trailing, spacing: 6) {
                    Text(AppLocalizedStrings.hudLitTargets(lang))
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white.opacity(0.62))
                    HStack(spacing: 3) {
                        Text("\(wc.litTargets)")
                            .font(.system(size: 22, weight: .heavy, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(Color(red: 1.0, green: 0.9, blue: 0.42))
                        Text("/")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.38))
                        Text("\(wc.totalTargets)")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(.white.opacity(0.92))
                    }
                    .padding(.horizontal, 13)
                    .padding(.vertical, 7)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.1))
                            .overlay(Capsule().stroke(Color.white.opacity(0.16), lineWidth: 1))
                    )
                }
            }
            if level.shouldEnforceOptimalBulbs {
                Label(AppLocalizedStrings.hudOptimalBulbs(lang, max: level.maxBulbs), systemImage: "sparkles")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color(red: 1.0, green: 0.78, blue: 0.38).opacity(0.95))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.07))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.11), lineWidth: 1)
                )
        )
    }

    private var winSuccessOverlay: some View {
        ZStack {
            Color.black.opacity(0.48)
                .ignoresSafeArea()
            ZStack {
                WinCelebrationSparkles(compact: true)
                VStack(spacing: 18) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.98, blue: 0.65),
                                    Color(red: 1.0, green: 0.82, blue: 0.25)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Color(red: 1.0, green: 0.92, blue: 0.35).opacity(0.85), radius: 8, y: 1)
                    Text(AppLocalizedStrings.winTargetsLit(localization.content))
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white.opacity(0.82))
                        .padding(.horizontal, 8)
                    HStack(spacing: 14) {
                        Button {
                            audioManager.playClick()
                            showWinOverlay = false
                        } label: {
                            Text(AppLocalizedStrings.winKeepViewing(localization.content))
                                .frame(minWidth: 100)
                        }
                        .buttonStyle(.bordered)
                        .tint(.white.opacity(0.9))
                        Button {
                            audioManager.playClick()
                            showWinOverlay = false
                            goNextLevel()
                        } label: {
                            Text(AppLocalizedStrings.winNextLevel(localization.content))
                                .font(.headline)
                                .frame(minWidth: 100)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.yellow)
                        .disabled(
                            (currentIndex >= levels.count - 1 && !infiniteCanExtendPastEnd)
                                || isExtendingInfinitePlaylist
                        )
                    }
                }
                .padding(26)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 28)
            }
        }
    }

    /// 棋盘占用区域与侧键宽度固定；格子边长随 `gridSize` 在区域内缩放，避免大棋盘挤出侧栏。
    private enum BoardPlayArea {
        static let sideButton: CGFloat = 44
        static let rowSpacing: CGFloat = 12
        static let cellGap: CGFloat = 4
        static let boardPad: CGFloat = 8
        /// 棋盘外框（含内边距）最大边长，不随关卡变大。
        static let slotMax: CGFloat = 352
        /// 极窄屏时允许缩小，避免侧键与棋盘总宽超过容器。
        static let slotFloor: CGFloat = 136

        static func slotSide(containerWidth: CGFloat) -> CGFloat {
            let reserved = 2 * (sideButton + rowSpacing)
            let cap = max(0, containerWidth - reserved)
            return min(slotMax, max(slotFloor, cap))
        }

        static func cellSide(gridSize n: Int, slot: CGFloat) -> CGFloat {
            guard n > 0 else { return 32 }
            let inner = slot - 2 * boardPad
            let gutters = CGFloat(max(0, n - 1)) * cellGap
            return max(10, (inner - gutters) / CGFloat(n))
        }

        static func boardOuterSize(gridSize n: Int, cellSide: CGFloat) -> CGFloat {
            CGFloat(n) * cellSide + CGFloat(max(0, n - 1)) * cellGap + 2 * boardPad
        }
    }

    private func boardGrid(cellSide: CGFloat) -> some View {
        let size = viewModel.level.gridSize
        return VStack(spacing: BoardPlayArea.cellGap) {
            ForEach(0..<size, id: \.self) { row in
                HStack(spacing: BoardPlayArea.cellGap) {
                    ForEach(0..<size, id: \.self) { col in
                        let point = GridPoint(row: row, col: col)
                        CellView(
                            point: point,
                            cellType: viewModel.cellType(at: point),
                            isLit: viewModel.litCells.contains(point),
                            hasBulb: viewModel.bulbs.contains(point),
                            isTarget: viewModel.isTarget(point),
                            isHintMasked: viewModel.isHintMasked(point),
                            lightTier: viewModel.lightVisualTier(at: point),
                            mirrorDirection: viewModel.mirrorDirection(at: point),
                            mirrorCellVisual: viewModel.mirrorCellVisual(at: point),
                            hasSlitMirror: viewModel.hasSlitMirror(at: point),
                            cellSide: cellSide
                        )
                        .onTapGesture {
                            audioManager.playClick()
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.toggleBulb(at: point)
                            }
                            Haptics.tap()
                        }
                    }
                }
            }
        }
        .padding(BoardPlayArea.boardPad)
        .background(Color(red: 0.18, green: 0.19, blue: 0.24))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var boardWithSideLevelNav: some View {
        GeometryReader { geo in
            let slot = BoardPlayArea.slotSide(containerWidth: geo.size.width)
            let n = viewModel.level.gridSize
            let cell = BoardPlayArea.cellSide(gridSize: n, slot: slot)
            let outer = BoardPlayArea.boardOuterSize(gridSize: n, cellSide: cell)

            ZStack {
                HStack(alignment: .center, spacing: BoardPlayArea.rowSpacing) {
                    Group {
                        if isInfinitePlaylist {
                            Color.clear
                                .frame(width: BoardPlayArea.sideButton, height: BoardPlayArea.sideButton)
                        } else {
                            sideLevelCircleButton(
                                systemImage: "chevron.left",
                                accessibilityLabel: AppLocalizedStrings.prevLevelA11y(localization.content),
                                disabled: currentIndex == 0,
                                action: {
                                    audioManager.playClick()
                                    goPrevLevel()
                                }
                            )
                        }
                    }
                    .fixedSize()

                    ZStack {
                        Color.clear
                            .frame(width: slot, height: slot)
                        boardGrid(cellSide: cell)
                            .frame(width: outer, height: outer)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: slot)

                    sideLevelCircleButton(
                        systemImage: "chevron.right",
                        accessibilityLabel: AppLocalizedStrings.nextLevelA11y(localization.content),
                        disabled: sideNextButtonDisabled,
                        action: {
                            audioManager.playClick()
                            goNextLevel()
                        }
                    )
                    .fixedSize()
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .frame(height: BoardPlayArea.slotMax)
        .frame(maxWidth: .infinity)
    }

    private func sideLevelCircleButton(systemImage: String, accessibilityLabel: String, disabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.white.opacity(disabled ? 0.3 : 0.92))
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(Color.white.opacity(disabled ? 0.06 : 0.12))
                )
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.18), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .disabled(disabled)
        .accessibilityLabel(accessibilityLabel)
    }

    private var infiniteNextBatchLoadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.42)
                .ignoresSafeArea()
            VStack(spacing: 18) {
                TimelineView(.animation(minimumInterval: 1.0 / 24.0)) { ctx in
                    let deg = (ctx.date.timeIntervalSinceReferenceDate * 220)
                        .truncatingRemainder(dividingBy: 360)
                    VStack(spacing: 10) {
                        ProgressView()
                            .controlSize(.large)
                            .tint(Color(red: 1.0, green: 0.92, blue: 0.4))
                        Image(systemName: "lightbulb.min.fill")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.white, Color(red: 1.0, green: 0.88, blue: 0.45)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .rotationEffect(.degrees(deg))
                    }
                }
                Text(AppLocalizedStrings.batchLoadingTitle(localization.content))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.92))
                Text(AppLocalizedStrings.batchLoadingSubtitle(localization.content))
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.55))
            }
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 36)
        }
        .allowsHitTesting(true)
    }

    private func goNextLevel() {
        if isInfinitePlaylist, !viewModel.didWin { return }
        if !isInfinitePlaylist, !progressStore.isCompleted(levelId: levels[currentIndex].id) { return }
        if currentIndex < levels.count - 1 {
            stepToNextLevel()
            return
        }
        guard isInfinitePlaylist, infiniteCanExtendPastEnd else { return }
        guard !isExtendingInfinitePlaylist else { return }
        isExtendingInfinitePlaylist = true
        Task { @MainActor in
            defer { isExtendingInfinitePlaylist = false }
            await appendInfiniteBatchThenStep()
        }
    }

    private func stepToNextLevel() {
        guard currentIndex < levels.count - 1 else { return }
        currentIndex += 1
        showWinOverlay = false
        let lvl = levels[currentIndex]
        viewModel.loadLevel(lvl, restored: progressStore.playStateWhenEntering(levelId: lvl.id))
        applyLightIntroIfNeeded(forLevelId: lvl.id)
    }

    private func scheduleInfinitePrefetchIfNeeded() {
        guard isInfinitePlaylist else { return }
        guard levels.count >= 2, currentIndex >= max(0, levels.count - 3) else { return }
        guard prefetchedInfiniteBatch == nil else { return }
        guard let lastN = infiniteLevelNumber(from: levels[levels.count - 1].id) else { return }
        let nextStart = lastN + 1
        let anchor = lastN
        infinitePrefetchTask?.cancel()
        infinitePrefetchAnchorLastGlobal = anchor
        infinitePrefetchTask = Task { @MainActor in
            let batch = await Task.detached(priority: .userInitiated) {
                InfiniteLevelGenerator.levels(inGlobalRange: nextStart...(nextStart + 9))
            }.value
            guard !Task.isCancelled else { return }
            guard let expect = infinitePrefetchAnchorLastGlobal,
                  expect == anchor,
                  let curLast = levels.last.flatMap({ infiniteLevelNumber(from: $0.id) }),
                  curLast == anchor else {
                return
            }
            prefetchedInfiniteBatch = batch
        }
    }

    /// 每批 10 关玩到最后时，优先生成或使用预取队列，再进入下一关。
    @MainActor
    private func appendInfiniteBatchThenStep() async {
        showWinOverlay = false
        infinitePrefetchTask?.cancel()
        infinitePrefetchTask = nil
        infinitePrefetchAnchorLastGlobal = nil
        guard let lastN = infiniteLevelNumber(from: levels[levels.count - 1].id) else { return }
        let nextStart = lastN + 1
        let batch: [Level]
        if let pre = prefetchedInfiniteBatch,
           let head = pre.first,
           infiniteLevelNumber(from: head.id) == nextStart {
            batch = pre
            prefetchedInfiniteBatch = nil
        } else {
            batch = await Task.detached(priority: .userInitiated) {
                InfiniteLevelGenerator.levels(inGlobalRange: nextStart...(nextStart + 9))
            }.value
        }
        levels.append(contentsOf: batch)
        stepToNextLevel()
        scheduleInfinitePrefetchIfNeeded()
    }

    private func goPrevLevel() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
        showWinOverlay = false
        let lvl = levels[currentIndex]
        viewModel.loadLevel(lvl, restored: progressStore.playStateWhenEntering(levelId: lvl.id))
        applyLightIntroIfNeeded(forLevelId: lvl.id)
    }

    /// 防止存档异常或旧数据导致进入未解锁主线关：回退到此前连续可达的最大序号。
    private static func clampedMainStartIndex(_ requested: Int, levels: [Level], progress: ProgressStore) -> Int {
        guard levels.first?.chapterId != "inf" else {
            return min(max(requested, 0), levels.count - 1)
        }
        let r = min(max(requested, 0), levels.count - 1)
        var i = r
        while i > 0, !progress.isCompleted(levelId: levels[i - 1].id) {
            i -= 1
        }
        return i
    }
}

/// 关卡内可用灯泡：左侧槽位宽度恒等于 4 盏并排，避免盏数变化时整行错位；≤4 从左向右只画实际盏数；>4 为固定 logo + 分数。
private struct BulbQuotaStrip: View {
    let placed: Int
    let maxBulbs: Int
    let lang: AppContentLanguage

    private static let iconHeight: CGFloat = 52
    private static let iconWidth: CGFloat = iconHeight * 0.75
    private static let rowSpacing: CGFloat = 8
    /// 仅灯泡列占位宽度，与「最多并排 4 盏」同宽，右侧「已照亮」位置不随盏数横跳。
    private static var fixedLaneWidth: CGFloat {
        4 * iconWidth + 3 * rowSpacing
    }

    var body: some View {
        Group {
            if maxBulbs <= 4 {
                HStack(spacing: Self.rowSpacing) {
                    ForEach(0..<maxBulbs, id: \.self) { index in
                        Image(index < placed ? "SplashBulbOn" : "SplashBulbOff")
                            .resizable()
                            .scaledToFit()
                            .frame(width: Self.iconWidth, height: Self.iconHeight)
                            .clipped()
                            .accessibilityHidden(true)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                HStack(spacing: 10) {
                    Image(placed > 0 ? "SplashBulbOn" : "SplashBulbOff")
                        .resizable()
                        .scaledToFit()
                        .frame(width: Self.iconWidth, height: Self.iconHeight)
                        .clipped()
                        .accessibilityHidden(true)
                    Text("\(placed)/\(maxBulbs)")
                        .font(.system(size: 20, weight: .heavy, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(.white.opacity(0.92))
                        .lineLimit(1)
                        .minimumScaleFactor(0.65)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(width: Self.fixedLaneWidth, alignment: .leading)
        // PNG 上灯泡视觉重心偏上，略下移与灰条、右侧标记光学对齐。
        .offset(y: 5)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(AppLocalizedStrings.quotaA11y(lang, placed: placed, max: maxBulbs))
    }
}

private enum Haptics {
    static func tap() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
}

private struct CellView: View {
    let point: GridPoint
    let cellType: CellType
    let isLit: Bool
    let hasBulb: Bool
    let isTarget: Bool
    let isHintMasked: Bool
    let lightTier: Int?
    let mirrorDirection: MirrorDirection?
    /// 半格或整格镜面高光（两侧直射时整格）
    let mirrorCellVisual: MirrorCellVisual?
    let hasSlitMirror: Bool
    let cellSide: CGFloat

    private var cellCorner: CGFloat { max(3, cellSide * (6 / 38)) }
    private var glowEndRadius: CGFloat { cellSide * (28 / 38) }
    private var glowBlur: CGFloat { cellSide * (1.8 / 38) }
    private var targetRing: CGFloat { cellSide * (24 / 38) }
    private var bulbIconSize: CGFloat { cellSide * (14 / 38) }

    private var litShade: CGFloat {
        guard let t = lightTier else { return 1 }
        let scales: [CGFloat] = [1.0, 0.97, 0.94, 0.91]
        return scales[min(max(0, t), 3)]
    }

    private var litInnerGlowOpacity: Double {
        guard lightTier != nil, isLit, !isHintMasked else { return 0 }
        let o = [0.5, 0.46, 0.43, 0.4]
        let t = min(max(0, lightTier ?? 0), 3)
        return o[t]
    }

    private var litOuterGlowOpacity: Double {
        guard lightTier != nil, isLit, !isHintMasked else { return 0 }
        let o = [0.2, 0.18, 0.16, 0.14]
        let t = min(max(0, lightTier ?? 0), 3)
        return o[t]
    }

    /// 仅单侧直射：用半格裁剪；两侧同时直射见 `mirrorCellVisual?.illuminateFull`。
    private var mirrorUsesHalfClip: Bool {
        guard mirrorDirection != nil, isLit, !isHintMasked,
              let v = mirrorCellVisual else { return false }
        return !v.illuminateFull && v.halfIncomingDelta != nil
    }

    var body: some View {
        ZStack {
            if mirrorUsesHalfClip, let inc = mirrorCellVisual?.halfIncomingDelta, let dir = mirrorDirection {
                let isSlash = dir == .up || dir == .right
                ZStack {
                    RoundedRectangle(cornerRadius: cellCorner)
                        .fill(Color(red: 0.26, green: 0.27, blue: 0.32))
                        .frame(width: cellSide, height: cellSide)
                    ZStack {
                        RoundedRectangle(cornerRadius: cellCorner)
                            .fill(
                                Color(
                                    red: 0.92 * Double(litShade),
                                    green: 0.82 * Double(litShade),
                                    blue: 0.35 * Double(litShade)
                                )
                            )
                            .frame(width: cellSide, height: cellSide)
                            .overlay(
                                RoundedRectangle(cornerRadius: cellCorner)
                                    .fill(
                                        RadialGradient(
                                            colors: [
                                                Color(red: 1.0, green: 0.95, blue: 0.55, opacity: litInnerGlowOpacity),
                                                Color(red: 1.0, green: 0.90, blue: 0.45, opacity: litOuterGlowOpacity),
                                                Color.clear
                                            ],
                                            center: .center,
                                            startRadius: 1,
                                            endRadius: glowEndRadius
                                        )
                                    )
                                    .blur(radius: glowBlur)
                            )
                    }
                    .clipShape(
                        MirrorIncomingLitHalfShape(
                            isSlash: isSlash,
                            incomingDCol: CGFloat(inc.dCol),
                            incomingDRow: CGFloat(inc.dRow)
                        )
                    )
                }
            } else {
                RoundedRectangle(cornerRadius: cellCorner)
                    .fill(backgroundColor)
                    .frame(width: cellSide, height: cellSide)
                    .overlay(
                        RoundedRectangle(cornerRadius: cellCorner)
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.95, blue: 0.55, opacity: litInnerGlowOpacity),
                                        Color(red: 1.0, green: 0.90, blue: 0.45, opacity: litOuterGlowOpacity),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 1,
                                    endRadius: glowEndRadius
                                )
                            )
                            .blur(radius: isLit && !isHintMasked ? glowBlur : 0)
                    )
            }
            if isTarget, !isHintMasked {
                Circle()
                    .strokeBorder(Color(red: 1.0, green: 0.89, blue: 0.4), lineWidth: 1)
                    .frame(width: targetRing, height: targetRing)
            }
            if hasBulb {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: bulbIconSize, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.white, Color(white: 0.92)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: Color.white.opacity(0.55), radius: 3, x: 0, y: 0)
                    .shadow(color: Color.black.opacity(0.35), radius: 1, x: 0, y: 1)
                    .scaleEffect(hasBulb ? 1.0 : 0.7)
                    .rotationEffect(.degrees(hasBulb ? 0 : -8))
                    .animation(.spring(response: 0.32, dampingFraction: 0.55), value: hasBulb)
            }
            if let mirrorDirection = mirrorDirection, cellType == .playable, !isHintMasked {
                MirrorDividerView(
                    direction: mirrorDirection,
                    isReflecting: isLit,
                    illuminateFullCell: mirrorCellVisual?.illuminateFull ?? false,
                    incomingDRow: mirrorCellVisual?.halfIncomingDelta?.dRow,
                    incomingDCol: mirrorCellVisual?.halfIncomingDelta?.dCol
                )
                    .frame(width: cellSide, height: cellSide)
            }
            if hasSlitMirror, cellType == .playable, !isHintMasked {
                SlitMirrorView(isActive: isLit)
                    .frame(width: cellSide, height: cellSide)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cellCorner))
    }

    private var backgroundColor: Color {
        if isHintMasked {
            return Color(red: 0.72, green: 0.74, blue: 0.78)
        }
        switch cellType {
        case .blocked:
            return Color(red: 0.72, green: 0.74, blue: 0.78)
        case .playable:
            guard isLit else {
                return Color(red: 0.26, green: 0.27, blue: 0.32)
            }
            return Color(
                red: 0.92 * Double(litShade),
                green: 0.82 * Double(litShade),
                blue: 0.35 * Double(litShade)
            )
        }
    }
}

/// 以镜面为界，朝向灯泡来源的一侧为「被照亮的半格」（与 `LightingEngine` 物理侧一致）。
private struct MirrorIncomingLitHalfShape: Shape {
    var isSlash: Bool
    var incomingDCol: CGFloat
    var incomingDRow: CGFloat

    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        guard w > 1, h > 1 else { return Path() }
        let cx = w * 0.5
        let cy = h * 0.5
        let vx = incomingDCol
        let vy = incomingDRow
        let len = hypot(vx, vy)
        guard len > 1e-4 else {
            return slashFallbackPath(width: w, height: h)
        }
        let nx = vx / len
        let ny = vy / len
        let step = min(w, h) * 0.28
        let px = cx - nx * step
        let py = cy - ny * step

        var p = Path()
        if isSlash {
            if px / w + py / h < 1 {
                p.move(to: CGPoint(x: 0, y: 0))
                p.addLine(to: CGPoint(x: w, y: 0))
                p.addLine(to: CGPoint(x: 0, y: h))
            } else {
                p.move(to: CGPoint(x: w, y: h))
                p.addLine(to: CGPoint(x: w, y: 0))
                p.addLine(to: CGPoint(x: 0, y: h))
            }
        } else {
            if h * px > w * py {
                p.move(to: CGPoint(x: 0, y: 0))
                p.addLine(to: CGPoint(x: w, y: 0))
                p.addLine(to: CGPoint(x: w, y: h))
            } else {
                p.move(to: CGPoint(x: 0, y: 0))
                p.addLine(to: CGPoint(x: 0, y: h))
                p.addLine(to: CGPoint(x: w, y: h))
            }
        }
        p.closeSubpath()
        return p
    }

    private func slashFallbackPath(width w: CGFloat, height h: CGFloat) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: 0, y: 0))
        p.addLine(to: CGPoint(x: w, y: 0))
        p.addLine(to: CGPoint(x: 0, y: h))
        p.closeSubpath()
        return p
    }
}

/// 反射镜：斜线表示镜面；单侧直射强调半格，两侧同时直射则整格暖色。
private struct MirrorDividerView: View {
    let direction: MirrorDirection
    let isReflecting: Bool
    /// 两盏灯均十字照到镜格且分处镜面法向两侧
    let illuminateFullCell: Bool
    let incomingDRow: Int?
    let incomingDCol: Int?

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let isSlash = direction == .up || direction == .right
            let gradient = LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.88, blue: 0.4, opacity: isReflecting ? 0.55 : 0.06),
                    Color(red: 1.0, green: 0.75, blue: 0.25, opacity: isReflecting ? 0.28 : 0.03)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            ZStack {
                if illuminateFullCell && isReflecting {
                    RoundedRectangle(cornerRadius: min(w, h) * 0.12)
                        .fill(gradient)
                        .padding(1)
                } else if let ir = incomingDRow, let ic = incomingDCol {
                    MirrorIncomingLitHalfShape(
                        isSlash: isSlash,
                        incomingDCol: CGFloat(ic),
                        incomingDRow: CGFloat(ir)
                    )
                    .fill(gradient)
                } else {
                    reflectedHalfFillPath(width: w, height: h)
                        .fill(gradient)
                }
                Group {
                    mirrorLinePath(width: w, height: h)
                        .stroke(
                            Color(red: 0.75, green: 0.95, blue: 0.88, opacity: isReflecting ? 0.95 : 0.45),
                            lineWidth: max(0.7, min(w, h) * 0.036)
                        )
                }
            }
        }
    }

    private func mirrorLinePath(width w: CGFloat, height h: CGFloat) -> Path {
        var p = Path()
        switch direction {
        case .up, .right:
            p.move(to: CGPoint(x: 0, y: h))
            p.addLine(to: CGPoint(x: w, y: 0))
        case .down, .left:
            p.move(to: CGPoint(x: 0, y: 0))
            p.addLine(to: CGPoint(x: w, y: h))
        }
        return p
    }

    private func reflectedHalfFillPath(width w: CGFloat, height h: CGFloat) -> Path {
        var p = Path()
        switch direction {
        case .up:
            p.move(to: CGPoint(x: 0, y: 0))
            p.addLine(to: CGPoint(x: w, y: 0))
            p.addLine(to: CGPoint(x: w, y: h))
            p.closeSubpath()
        case .down:
            p.move(to: CGPoint(x: 0, y: 0))
            p.addLine(to: CGPoint(x: 0, y: h))
            p.addLine(to: CGPoint(x: w, y: h))
            p.closeSubpath()
        case .left:
            p.move(to: CGPoint(x: 0, y: 0))
            p.addLine(to: CGPoint(x: w, y: 0))
            p.addLine(to: CGPoint(x: 0, y: h))
            p.closeSubpath()
        case .right:
            p.move(to: CGPoint(x: w, y: 0))
            p.addLine(to: CGPoint(x: w, y: h))
            p.addLine(to: CGPoint(x: 0, y: h))
            p.closeSubpath()
        }
        return p
    }
}

/// 水平缝镜：上下深色挡条 + 中部横向镜条，表示仅左右可透光贯穿。
private struct SlitMirrorView: View {
    let isActive: Bool

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let band = max(2.0, h * 0.2)
            let lineW = max(0.8, min(w, h) * 0.028)
            ZStack {
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(Color(red: 0.12, green: 0.13, blue: 0.16).opacity(isActive ? 0.72 : 0.55))
                        .frame(height: band)
                    Spacer(minLength: 0)
                    Rectangle()
                        .fill(Color(red: 0.12, green: 0.13, blue: 0.16).opacity(isActive ? 0.72 : 0.55))
                        .frame(height: band)
                }
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.82, green: 0.93, blue: 0.9, opacity: isActive ? 0.92 : 0.5),
                                Color(red: 0.55, green: 0.78, blue: 0.86, opacity: isActive ? 0.75 : 0.38)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: lineW)
                    .shadow(color: Color.cyan.opacity(isActive ? 0.35 : 0.12), radius: 2, y: 0)
            }
        }
    }
}

private struct TutorialView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var localization: LocalizationManager

    var body: some View {
        let lang = localization.content
        NavigationStack {
            List {
                Section(AppLocalizedStrings.tutorialListTitle(lang)) {
                    ForEach(AppLocalizedStrings.tutorialSteps(lang), id: \.self) { step in
                        Text(step)
                    }
                }
            }
            .navigationTitle(AppLocalizedStrings.tutorialNavTitle(lang))
            .toolbar {
                Button(AppLocalizedStrings.tutorialDone(lang)) { dismiss() }
            }
        }
    }
}

/// 通关时在弹窗周围冒出来的小点缀。
private struct WinCelebrationSparkles: View {
    @State private var pop = false
    var compact: Bool = false

    var body: some View {
        let baseR: CGFloat = compact ? 22 : 42
        let stepR: CGFloat = compact ? 8 : 14
        ZStack {
            ForEach(0..<12, id: \.self) { i in
                let angle = Double(i) / 12.0 * 2 * Double.pi + Double(i % 3) * 0.08
                let radius: CGFloat = pop ? (baseR + CGFloat(i % 4) * stepR) : 4
                let symbol = i % 3 == 0 ? "sparkle" : (i % 3 == 1 ? "star.fill" : "circle.fill")
                Image(systemName: symbol)
                    .font(.system(size: CGFloat([12, 10, 8][i % 3]), weight: .black))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color.white,
                                Color(red: 1.0, green: 0.94, blue: 0.72)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: Color.white.opacity(0.9), radius: 3, y: 0)
                    .offset(x: cos(angle) * radius, y: sin(angle) * radius)
                    .scaleEffect(pop ? 1 : 0.15)
                    .opacity(pop ? 1 : 0)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(false)
        .onAppear {
            withAnimation(.spring(response: 0.44, dampingFraction: 0.62)) {
                pop = true
            }
        }
    }
}

/// 进关 / 换关：居中轻提示，不与导航大标题抢「第二行说明」。
private struct LevelWelcomeOverlay: View {
    let line: String
    @State private var cardIn = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.12)
                .ignoresSafeArea()
                .allowsHitTesting(false)

            VStack(spacing: 14) {
                TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { ctx in
                    let t = ctx.date.timeIntervalSinceReferenceDate
                    let wobble = sin(t * 2.1) * 4.2
                    Image(systemName: "lightbulb.min.fill")
                        .font(.system(size: 38, weight: .medium))
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
                        .shadow(color: Color(red: 1.0, green: 0.88, blue: 0.45).opacity(0.45), radius: 10, y: 2)
                        .rotationEffect(.degrees(wobble))
                }

                Text(line)
                    .font(.system(.subheadline, design: .rounded).weight(.medium))
                    .foregroundStyle(Color.white.opacity(0.93))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 20)
            .frame(maxWidth: 300)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.32),
                                        Color.white.opacity(0.06)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(color: Color.black.opacity(0.2), radius: 16, y: 6)
            .scaleEffect(cardIn ? 1 : 0.88)
            .opacity(cardIn ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.52, dampingFraction: 0.78)) {
                cardIn = true
            }
        }
    }
}

/// 在导航栏视图层级里找到大标题容器并整体下移若干 pt；离开页面时还原，避免影响其它界面。
private struct NavigationBarLargeTitlePushDown: UIViewControllerRepresentable {
    var dy: CGFloat

    func makeCoordinator() -> Coordinator { Coordinator() }

    final class Coordinator {
        var restored: [(UIView, CGAffineTransform)] = []
        var didApply = false
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .clear
        vc.view.isUserInteractionEnabled = false
        return vc
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        guard dy != 0, !context.coordinator.didApply else { return }
        tryApplyPushDown(uiViewController, context: context, attempt: 0)
    }

    private func tryApplyPushDown(_ uiViewController: UIViewController, context: Context, attempt: Int) {
        guard attempt < 6 else { return }
        let delay = attempt == 0 ? 0.0 : 0.07
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            guard !context.coordinator.didApply else { return }
            guard let nav = findNavigationController(from: uiViewController) else {
                tryApplyPushDown(uiViewController, context: context, attempt: attempt + 1)
                return
            }
            let views = largeTitleLikeViews(under: nav.navigationBar)
            if views.isEmpty {
                tryApplyPushDown(uiViewController, context: context, attempt: attempt + 1)
                return
            }
            for v in views {
                context.coordinator.restored.append((v, v.transform))
                v.transform = v.transform.translatedBy(x: 0, y: dy)
            }
            context.coordinator.didApply = true
        }
    }

    static func dismantleUIViewController(_ uiViewController: UIViewController, coordinator: Coordinator) {
        DispatchQueue.main.async {
            for (v, t) in coordinator.restored {
                v.transform = t
            }
            coordinator.restored.removeAll()
            coordinator.didApply = false
        }
    }

    private func findNavigationController(from vc: UIViewController) -> UINavigationController? {
        var cur: UIViewController? = vc.parent
        var steps = 0
        while let c = cur, steps < 14 {
            if let n = c as? UINavigationController { return n }
            cur = c.parent
            steps += 1
        }
        return nil
    }

    private func largeTitleLikeViews(under bar: UINavigationBar) -> [UIView] {
        var out: [UIView] = []
        func walk(_ v: UIView) {
            let name = String(describing: type(of: v))
            if name.contains("LargeTitle") || name.contains("navigationBarLargeTitle") {
                out.append(v)
            }
            for s in v.subviews { walk(s) }
        }
        walk(bar)
        return out
    }
}
