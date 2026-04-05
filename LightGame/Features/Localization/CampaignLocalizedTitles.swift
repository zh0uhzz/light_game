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
        "ch6": "Chapter 6 · Slit Mirrors",
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
        "ch6": "第6章 スリット鏡",
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
        "ch6_l1": "Slit Chorus", "ch6_l2": "Fold & Slit", "ch6_l3": "Slanting Slit",
        "ch6_l4": "Echo Slit", "ch6_l5": "Double Slit", "ch6_l6": "Dark Corner",
        "ch6_l7": "Mirror Pool", "ch6_l8": "Far Glow", "ch6_l9": "Slit Pause",
        "ch7_l1": "Maze Shade", "ch7_l2": "Triple Slit", "ch7_l3": "Mirror Lattice",
        "ch7_l4": "Edge Bulbs", "ch7_l5": "Long Run", "ch7_l6": "Cross Slits",
        "ch7_l7": "Hidden Peg", "ch7_l8": "Floating Zig", "ch7_l9": "Maze End",
        "ch8_l1": "Nebula Start", "ch8_l2": "Wide Slit", "ch8_l3": "Twin Guard",
        "ch8_l4": "Far Corner", "ch8_l5": "Deep Return", "ch8_l6": "Sparse Stars",
        "ch8_l7": "Light Wedge", "ch8_l8": "Outer Wind", "ch8_l9": "Star Tide",
        "ch9_l1": "Polar Trial", "ch9_l2": "Carved Maze", "ch9_l3": "Twin Race",
        "ch9_l4": "Mirror Deep", "ch9_l5": "Quiet Dawn", "ch9_l6": "Near Finish",
        "ch9_l7": "Shattered", "ch9_l8": "Fading Echo", "ch9_l9": "Crown Light",
        "ch10_l1": "Chatty Lamp",
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
        "ch6_l1": "鏡と継ぎ目", "ch6_l2": "折れとすきま", "ch6_l3": "斜めスリット",
        "ch6_l4": "反響のすきま", "ch6_l5": "両すきま", "ch6_l6": "暗い角",
        "ch6_l7": "鏡とみず", "ch6_l8": "遠い借光", "ch6_l9": "ひとやすみ",
        "ch7_l1": "迷路のかげ", "ch7_l2": "三すきま", "ch7_l3": "鏡の陣ひらく",
        "ch7_l4": "端に灯を", "ch7_l5": "長い隙間光", "ch7_l6": "十字すきま",
        "ch7_l7": "かくれ杭", "ch7_l8": "うかんだ折れ線", "ch7_l9": "迷路の終わり",
        "ch8_l1": "星あかり", "ch8_l2": "ひろいスリット", "ch8_l3": "双護り",
        "ch8_l4": "遠い角", "ch8_l5": "深空もどり", "ch8_l6": "まばら星",
        "ch8_l7": "光のくさび", "ch8_l8": "そとの風", "ch8_l9": "星しおふる",
        "ch9_l1": "極みの試練", "ch9_l2": "光を刻む迷路", "ch9_l3": "双すきま競走",
        "ch9_l4": "鏡の淵", "ch9_l5": "よあけまえ", "ch9_l6": "ゴール手前",
        "ch9_l7": "砕けた鏡", "ch9_l8": "光の余響", "ch9_l9": "戴冠の光",
        "ch10_l1": "灯",
    ]
}
