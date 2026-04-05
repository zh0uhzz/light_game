import SwiftUI

private enum AchievementCategory: String, CaseIterable, Identifiable {
    case story
    case infinite
    case companion
    case barrage
    case habits

    var id: String { rawValue }
}

private struct AchievementEntry: Identifiable {
    let id: String
    let category: AchievementCategory
    let order: Int
    let symbol: String
    let isUnlocked: (ProgressStore) -> Bool
}

struct AchievementsListView: View {
    @EnvironmentObject private var progressStore: ProgressStore
    @EnvironmentObject private var localization: LocalizationManager

    private var lang: AppContentLanguage { localization.content }
    private var entries: [AchievementEntry] { Self.definitionList }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                ForEach(AchievementCategory.allCases) { category in
                    VStack(alignment: .leading, spacing: 12) {
                        Text(AppLocalizedStrings.achievementCategory(category.rawValue, lang: lang))
                            .font(.headline)
                            .foregroundStyle(.white.opacity(0.92))
                            .padding(.horizontal, 4)

                        LazyVGrid(
                            columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                            spacing: 12
                        ) {
                            ForEach(entries.filter { $0.category == category }.sorted(by: { $0.order < $1.order })) { item in
                                AchievementTileUnlocked(
                                    title: AppLocalizedStrings.achievementTitle(item.id, lang: lang),
                                    unlockRule: AppLocalizedStrings.achievementRule(item.id, lang: lang),
                                    symbol: item.symbol,
                                    unlocked: item.isUnlocked(progressStore)
                                )
                            }
                        }
                    }
                }
            }
            .padding()
            .frame(maxWidth: 820, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .scrollContentBackground(.hidden)
        .background(
            ZStack {
                LinearGradient(
                    colors: [Color.black, Color(red: 0.08, green: 0.08, blue: 0.11)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                FireflyBackgroundView(fireflyCount: 18, luminosity: 0.48)
            }
            .ignoresSafeArea()
        )
        .navigationTitle(AppLocalizedStrings.achievementsTitle(lang))
        .navigationBarTitleDisplayMode(.inline)
    }

    private static let definitionList: [AchievementEntry] = [
        // 主线旅程
        AchievementEntry(
            id: "story_first",
            category: .story,
            order: 0,
            symbol: "hand.wave.fill",
            isUnlocked: { $0.mainCampaignCompletedCount >= 1 }
        ),
        AchievementEntry(
            id: "story_ch3",
            category: .story,
            order: 1,
            symbol: "leaf.fill",
            isUnlocked: { $0.isCompleted(levelId: "ch3_l1") }
        ),
        AchievementEntry(
            id: "story_ch5",
            category: .story,
            order: 2,
            symbol: "arrow.left.and.right",
            isUnlocked: { $0.isCompleted(levelId: "ch5_l1") }
        ),
        AchievementEntry(
            id: "story_ch9boss",
            category: .story,
            order: 3,
            symbol: "cloud.bolt.fill",
            isUnlocked: { $0.isCompleted(levelId: "ch9_l9") }
        ),
        AchievementEntry(
            id: "story_all_full",
            category: .story,
            order: 4,
            symbol: "book.closed.fill",
            isUnlocked: { $0.isMainCampaignFullyCompleted }
        ),
        AchievementEntry(
            id: "story_finale",
            category: .story,
            order: 5,
            symbol: "heart.rectangle.fill",
            isUnlocked: { $0.isCompleted(levelId: "ch10_l1") }
        ),
        // 无限挑战
        AchievementEntry(
            id: "inf_1",
            category: .infinite,
            order: 0,
            symbol: "infinity",
            isUnlocked: { $0.infiniteLevelsCleared >= 1 }
        ),
        AchievementEntry(
            id: "inf_10",
            category: .infinite,
            order: 1,
            symbol: "figure.run",
            isUnlocked: { $0.infiniteLevelsCleared >= 10 }
        ),
        AchievementEntry(
            id: "inf_50",
            category: .infinite,
            order: 2,
            symbol: "figure.walk",
            isUnlocked: { $0.infiniteLevelsCleared >= 50 }
        ),
        AchievementEntry(
            id: "inf_99",
            category: .infinite,
            order: 3,
            symbol: "flag.checkered",
            isUnlocked: { $0.infiniteLevelsCleared >= 99 }
        ),
        AchievementEntry(
            id: "inf_500",
            category: .infinite,
            order: 4,
            symbol: "building.2.fill",
            isUnlocked: { $0.infiniteLevelsCleared >= 500 }
        ),
        AchievementEntry(
            id: "inf_999",
            category: .infinite,
            order: 5,
            symbol: "sparkles",
            isUnlocked: { $0.infiniteLevelsCleared >= 999 }
        ),
        AchievementEntry(
            id: "inf_9999",
            category: .infinite,
            order: 6,
            symbol: "star.leadinghalf.filled",
            isUnlocked: { $0.infiniteLevelsCleared >= 9999 }
        ),
        // 陪伴小憩
        AchievementEntry(
            id: "comp_1",
            category: .companion,
            order: 0,
            symbol: "sparkle",
            isUnlocked: { $0.companionModeOpenCount >= 1 }
        ),
        AchievementEntry(
            id: "comp_5",
            category: .companion,
            order: 1,
            symbol: "sofa.fill",
            isUnlocked: { $0.companionModeOpenCount >= 5 }
        ),
        AchievementEntry(
            id: "comp_10",
            category: .companion,
            order: 2,
            symbol: "lightbulb.min.fill",
            isUnlocked: { $0.companionModeOpenCount >= 10 }
        ),
        AchievementEntry(
            id: "comp_30",
            category: .companion,
            order: 3,
            symbol: "moon.stars.fill",
            isUnlocked: { $0.companionModeOpenCount >= 30 }
        ),
        // 弹幕心语（陪伴 / 无限专用池，各至少 20 条不重复展示）
        AchievementEntry(
            id: "barr_companion_20",
            category: .barrage,
            order: 0,
            symbol: "heart.text.square.fill",
            isUnlocked: { $0.companionBarrageUniqueCount >= 20 }
        ),
        AchievementEntry(
            id: "barr_infinite_20",
            category: .barrage,
            order: 1,
            symbol: "infinity.circle.fill",
            isUnlocked: { $0.infiniteBarrageUniqueCount >= 20 }
        ),
        // 棋盘习惯
        AchievementEntry(
            id: "hab_hint_1",
            category: .habits,
            order: 0,
            symbol: "questionmark.circle.fill",
            isUnlocked: { $0.lifetimeHintsConsumed >= 1 }
        ),
        AchievementEntry(
            id: "hab_hint_30",
            category: .habits,
            order: 1,
            symbol: "list.bullet.rectangle.fill",
            isUnlocked: { $0.lifetimeHintsConsumed >= 30 }
        ),
        AchievementEntry(
            id: "hab_restart_10",
            category: .habits,
            order: 2,
            symbol: "arrow.counterclockwise.circle.fill",
            isUnlocked: { $0.lifetimeLevelRestarts >= 10 }
        ),
        AchievementEntry(
            id: "hab_restart_50",
            category: .habits,
            order: 3,
            symbol: "arrow.triangle.2.circlepath",
            isUnlocked: { $0.lifetimeLevelRestarts >= 50 }
        ),
    ]
}

private struct AchievementTileUnlocked: View {
    let title: String
    let unlockRule: String
    let symbol: String
    let unlocked: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                Image(systemName: symbol)
                    .font(.title3)
                    .foregroundStyle(
                        unlocked
                            ? LinearGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.96, blue: 0.78),
                                    Color(red: 1.0, green: 0.82, blue: 0.42),
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            : LinearGradient(colors: [.white.opacity(0.32), .white.opacity(0.22)], startPoint: .top, endPoint: .bottom)
                    )
                Spacer(minLength: 6)
                if unlocked {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.caption)
                        .foregroundStyle(Color(red: 1.0, green: 0.88, blue: 0.4))
                }
            }
            Text(title)
                .font(.subheadline.bold())
                .foregroundStyle(unlocked ? Color.white : Color.white.opacity(0.52))
            Text(unlockRule)
                .font(.caption2)
                .foregroundStyle(.white.opacity(unlocked ? 0.62 : 0.36))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 132, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    unlocked
                        ? LinearGradient(
                            colors: [Color(red: 0.22, green: 0.19, blue: 0.14), Color(red: 0.14, green: 0.15, blue: 0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        : LinearGradient(
                            colors: [Color(red: 0.15, green: 0.15, blue: 0.18), Color(red: 0.11, green: 0.11, blue: 0.14)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(
                            unlocked
                                ? Color(red: 1.0, green: 0.85, blue: 0.4).opacity(0.35)
                                : Color.white.opacity(0.08),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: unlocked ? Color(red: 1.0, green: 0.82, blue: 0.35).opacity(0.15) : .clear, radius: 10, y: 2)
    }
}
