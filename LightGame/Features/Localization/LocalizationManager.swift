import Foundation
import SwiftUI

/// 界面与话唠文案的实际语种（不含「跟随系统」这一 meta 选项）。
enum AppContentLanguage: String, CaseIterable, Identifiable {
    case zhHans = "zh-Hans"
    case en = "en"
    case ja = "ja"
    case ko = "ko"

    var id: String { rawValue }
}

/// 设置中可选：含跟随系统。
enum LanguagePreference: String, CaseIterable, Identifiable {
    case system
    case zhHans
    case en
    case ja
    case ko

    var id: String { rawValue }
}

/// 运行时语言：UserDefaults + 跟随系统解析。
final class LocalizationManager: ObservableObject {
    private let prefsKey = "light_game_language_preference"

    @Published private(set) var preference: LanguagePreference
    @Published private(set) var content: AppContentLanguage

    init() {
        let raw = UserDefaults.standard.string(forKey: prefsKey) ?? LanguagePreference.system.rawValue
        let p = LanguagePreference(rawValue: raw) ?? .system
        preference = p
        content = Self.resolveContent(for: p)
    }

    func setPreference(_ newValue: LanguagePreference) {
        preference = newValue
        UserDefaults.standard.set(newValue.rawValue, forKey: prefsKey)
        content = Self.resolveContent(for: newValue)
        objectWillChange.send()
    }

    private static func resolveContent(for preference: LanguagePreference) -> AppContentLanguage {
        switch preference {
        case .zhHans: return .zhHans
        case .en: return .en
        case .ja: return .ja
        case .ko: return .ko
        case .system:
            return inferSystemContentLanguage()
        }
    }

    private static func inferSystemContentLanguage() -> AppContentLanguage {
        inferSystemPreviewLanguage()
    }

    /// 语言选择页、尚未写入偏好时，用系统列表推断预览语种。
    /// 仅简中 / 英 / 日 / 韩有完整界面；其余系统语言（含繁体）回退英语。
    static func inferSystemPreviewLanguage() -> AppContentLanguage {
        for raw in Locale.preferredLanguages {
            let pref = raw.lowercased()
            if pref.hasPrefix("ja") { return .ja }
            if pref.hasPrefix("ko") { return .ko }
            if pref.hasPrefix("en") { return .en }
            if pref.hasPrefix("zh") {
                // 无繁体资源：港台澳与 zh-Hant 一律英语
                if pref.hasPrefix("zh-hant")
                    || pref.hasPrefix("zh-tw")
                    || pref.hasPrefix("zh-hk")
                    || pref.hasPrefix("zh-mo") {
                    return .en
                }
                return .zhHans
            }
        }
        return .en
    }
}
