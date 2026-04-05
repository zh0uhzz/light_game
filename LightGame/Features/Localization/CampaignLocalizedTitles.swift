import Foundation

/// 主线关卡包名：JSON 为中文；`en` / `ja` 主攻美、日。`zhHans` 与 `ko` 使用包内原文（韩文暂无则用英文兜底）。
enum CampaignLocalizedTitles {

    static func chapterTitle(chapterId: String, packTitle: String, lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans:
            return packTitle
        case .en:
            return chapterEN[chapterId] ?? packTitle
        case .ja:
            return chapterJA[chapterId] ?? packTitle
        case .ko:
            return chapterEN[chapterId] ?? packTitle
        }
    }

    static func levelTitle(levelId: String, packTitle: String, lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans:
            return packTitle
        case .en:
            return levelEN[levelId] ?? packTitle
        case .ja:
            return levelJA[levelId] ?? packTitle
        case .ko:
            return levelEN[levelId] ?? packTitle
        }
    }

    /// 主页关卡卡片上的缩写字（中文仍按「章名后四字」习惯；其它语言取前 4 个字符）。
    static func homeCardAbbreviation(_ full: String, lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans:
            var title = full
            if let idx = title.firstIndex(of: " ") {
                title = String(title[title.index(after: idx)...])
            }
            let chars = Array(title)
            if chars.count == 4 { return title }
            if chars.count > 4 { return String(chars.prefix(4)) }
            return title.padding(toLength: 4, withPad: "·", startingAt: 0)
        default:
            let t = full.trimmingCharacters(in: .whitespacesAndNewlines)
            if t.isEmpty { return "····" }
            return String(t.prefix(4))
        }
    }

    // MARK: - Chapters

    private static let chapterEN: [String: String] = [
        "ch1": "Chapter 1 · Tutorial",
        "ch2": "Chapter 2 · Advanced",
        "ch3": "Chapter 3 · Challenge",
        "ch4": "Chapter 4 · Reflection",
        "ch5": "Chapter 5 · Refraction",
        "ch6": "Chapter 6 · Refraction & Reflection",
        "ch7": "Chapter 7 · Labyrinth",
        "ch8": "Chapter 8 · Starfield",
        "ch9": "Chapter 9 · Abyss Trial",
        "ch10": "Chapter 10 · Heart's Door",
    ]

    private static let chapterJA: [String: String] = [
        "ch1": "第1章 チュートリアル",
        "ch2": "第2章 ステップアップ",
        "ch3": "第3章 チャレンジ",
        "ch4": "第4章 反射",
        "ch5": "第5章 屈折",
        "ch6": "第6章 屈折と反射",
        "ch7": "第7章 迷路",
        "ch8": "第8章 星の原野",
        "ch9": "第9章 深淵の試練",
        "ch10": "第10章 心の扉",
    ]

    // MARK: - Levels (en)

    private static let levelEN: [String: String] = [
        "ch1_l1": "Dawn Bloom", "ch1_l2": "Golden Cross", "ch1_l3": "Corner Light",
        "ch1_l4": "Deep Path", "ch1_l5": "Solo Flame", "ch1_l6": "Five Stars",
        "ch1_l7": "Gallery Echo", "ch1_l8": "All Sides", "ch1_l9": "Last Glow",
        "ch2_l1": "Twin Lamps", "ch2_l2": "Triple Glow", "ch2_l3": "Four Corners",
        "ch2_l4": "Center Axis", "ch2_l5": "Outer Ring", "ch2_l6": "Inner Save",
        "ch2_l7": "Diagonal Gleam", "ch2_l8": "Eightfold Weave", "ch2_l9": "Calm Close",
        "ch3_l1": "Mirror Gleam", "ch3_l2": "Slant Guide", "ch3_l3": "Zigzag Shine",
        "ch3_l4": "Twin Mirrors", "ch3_l5": "Mirror Grid", "ch3_l6": "Light Cut",
        "ch3_l7": "Quiet Hall", "ch3_l8": "Double Bounce", "ch3_l9": "Heart Flame",
        "ch4_l1": "First Mirror", "ch4_l2": "Single Fold", "ch4_l3": "Breakthrough",
        "ch4_l4": "Square Hide", "ch4_l5": "Long Mirror", "ch4_l6": "One Corner",
        "ch4_l7": "Twin Axis", "ch4_l8": "Off Axis", "ch4_l9": "Final Beam",
        "ch5_l1": "Slit Dawn", "ch5_l2": "Both Sides", "ch5_l3": "Hall Corner",
        "ch5_l4": "Bend Light", "ch5_l5": "Narrow Gate", "ch5_l6": "Broken Line",
        "ch5_l7": "Edge Ferry", "ch5_l8": "Shallow Split", "ch5_l9": "Gather Light",
        "ch6_l1": "Framed Slit", "ch6_l2": "One Mirror Gap", "ch6_l3": "Twin Bounce",
        "ch6_l4": "Triple Mirror", "ch6_l5": "Twin Mirrors & Slit", "ch6_l6": "Narrow Core",
        "ch6_l7": "Three-Lamp Pass", "ch6_l8": "Mirror & Slit", "ch6_l9": "Final Coronet",
        "ch7_l1": "Shifting Mirror", "ch7_l2": "Twin Folds", "ch7_l3": "Tri-Mirror Act",
        "ch7_l4": "Bend the Well", "ch7_l5": "Three Bulb Slit", "ch7_l6": "Encore Duet",
        "ch7_l7": "Coronet Shift", "ch7_l8": "Stacked Gaps", "ch7_l9": "Many-Mirror Pit",
        "ch8_l1": "Mirror Shadow", "ch8_l2": "Twin Lines", "ch8_l3": "Walled Lattice",
        "ch8_l4": "Deep Detour", "ch8_l5": "Long Slit Trio", "ch8_l6": "Variant Duet",
        "ch8_l7": "Crown Aside", "ch8_l8": "Heart Through Wall", "ch8_l9": "Spark Debate",
        "ch9_l1": "Abyss Mirror", "ch9_l2": "Slit Escort", "ch9_l3": "Trap Reset",
        "ch9_l4": "Bedrock Bend", "ch9_l5": "Slit Surge", "ch9_l6": "Crossfade",
        "ch9_l7": "Halo Aside", "ch9_l8": "Curtain Heart", "ch9_l9": "Spine Split",
        "ch10_l1": "Little Lamp",
    ]

    // MARK: - Levels (ja) — 短め、ゲーム向け

    private static let levelJA: [String: String] = [
        "ch1_l1": "はじめの光", "ch1_l2": "十字の光", "ch1_l3": "角の灯り",
        "ch1_l4": "深い小道", "ch1_l5": "ひとつ灯", "ch1_l6": "五つ星",
        "ch1_l7": "回廊", "ch1_l8": "八方", "ch1_l9": "余光を集める",
        "ch2_l1": "双子の灯", "ch2_l2": "三つの光", "ch2_l3": "四隅めぐり",
        "ch2_l4": "中心線", "ch2_l5": "外輪", "ch2_l6": "内側の節約",
        "ch2_l7": "斜光", "ch2_l8": "八つの文様", "ch2_l9": "波おさまる",
        "ch3_l1": "鏡ひらく", "ch3_l2": "斜光のみち", "ch3_l3": "蛇行の光",
        "ch3_l4": "双鏡", "ch3_l5": "鏡の陣", "ch3_l6": "軽やかに",
        "ch3_l7": "しずかな回廊", "ch3_l8": "二段ばね返り", "ch3_l9": "心の炎",
        "ch4_l1": "初めの鏡", "ch4_l2": "一本折れ", "ch4_l3": "隙をうがつ",
        "ch4_l4": "回字に灯", "ch4_l5": "長い鏡ばなし", "ch4_l6": "一角に映す",
        "ch4_l7": "ふたつの軸", "ch4_l8": "軸ずれ", "ch4_l9": "終わりの光",
        "ch5_l1": "スリット夜明け", "ch5_l2": "両側の光", "ch5_l3": "廊下の角",
        "ch5_l4": "屈折まがる", "ch5_l5": "狭い扉", "ch5_l6": "かすれた線",
        "ch5_l7": "端のすきま", "ch5_l8": "浅い分かれ", "ch5_l9": "光を集める",
        "ch6_l1": "枠とすきま", "ch6_l2": "一枚鏡の渡り", "ch6_l3": "双鏡の分かれ",
        "ch6_l4": "三鏡の防ぎ", "ch6_l5": "双鏡とすきま", "ch6_l6": "狭間の演習",
        "ch6_l7": "三灯すきま", "ch6_l8": "鏡と継ぎ目", "ch6_l9": "終試の冕",
        "ch7_l1": "鏡を越えて", "ch7_l2": "双った折れ", "ch7_l3": "三鏡再演",
        "ch7_l4": "深い屈折", "ch7_l5": "三灯すきま", "ch7_l6": "続く二重奏",
        "ch7_l7": "冕の移り", "ch7_l8": "壁の重なり", "ch7_l9": "多鏡の穴",
        "ch8_l1": "影の廊", "ch8_l2": "双線の灯", "ch8_l3": "壁と鏡",
        "ch8_l4": "遠い迂回", "ch8_l5": "長い三すきま", "ch8_l6": "変奏の響き",
        "ch8_l7": "冕の横顔", "ch8_l8": "壁を貫く", "ch8_l9": "火花の論",
        "ch9_l1": "淵の鏡", "ch9_l2": "すきま道", "ch9_l3": "罠を組み直す",
        "ch9_l4": "底の四折", "ch9_l5": "潮のすきま", "ch9_l6": "交差点",
        "ch9_l7": "環の片側", "ch9_l8": "幕のむこう", "ch9_l9": "背骨の分かれ",
        "ch10_l1": "灯",
    ]
}
