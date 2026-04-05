import Foundation

/// 界面文案：按 `AppContentLanguage` 分支。日文偏やさしさ・中性、英文可爱轻魔法感、韩文带一点精灵式语感；非中文控制篇幅。
enum AppLocalizedStrings {

    // MARK: - Language UI

    static func languagePickTitle(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "先选个语言吧"
        case .en: return "Choose a language"
        case .ja: return "言語を選んでください"
        case .ko: return "언어를 골라 주세요"
        }
    }

    static func languagePickHint(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "之后随时能在设置里改～"
        case .en: return "You can change this anytime in Settings."
        case .ja: return "あとから設定でいつでも変更できます。"
        case .ko: return "나중에 설정에서 언제든 바꿀 수 있어요."
        }
    }

    static func languageContinue(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "继续"
        case .en: return "Continue"
        case .ja: return "続ける"
        case .ko: return "계속하기"
        }
    }

    static func languageFollowSystem(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "跟随系统"
        case .en: return "System default"
        case .ja: return "システムに合わせる"
        case .ko: return "시스템과 같게"
        }
    }

    static func languageSectionTitle(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "语言"
        case .en: return "Language"
        case .ja: return "言語"
        case .ko: return "언어"
        }
    }

    static func languageSectionFootnote(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "界面与提示会随选择切换；主线关卡与章节名随语言切换（中文为关卡包原文）。"
        case .en: return "The UI follows your pick. Chapter and stage names are localized."
        case .ja: return "画面の文言はここで切り替わります。本編の章・ステージ名も選択した言語に合わせて表示されます。"
        case .ko: return "화면 문구는 여기서 바뀌어요. 본편 챕터·스테이지 이름도 함께 맞춰져요."
        }
    }

    static func languagePreferenceLabel(_ pref: LanguagePreference, content: AppContentLanguage) -> String {
        switch pref {
        case .system:
            return languageFollowSystem(content)
        case .zhHans:
            return "简体中文"
        case .en:
            return "English"
        case .ja:
            return "日本語"
        case .ko:
            return "한국어"
        }
    }

    // MARK: - Premium (IAP)

    static func premiumNavTitle(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "永久会员"
        case .en: return "Full Unlock"
        case .ja: return "永久アンロック"
        case .ko: return "영구 잠금 해제"
        }
    }

    static func premiumPaywallTitle(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "解锁话唠小灯的全部陪伴玩法"
        case .en: return "Unlock every cozy mode—companion & endless puzzles"
        case .ja: return "灯の特別な遊び方をアンロック"
        case .ko: return "반짝 램프의 특별 모드를 모두 열어요"
        }
    }

    static func premiumPaywallSubtitle(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "一次购买，永久有效。"
        case .en: return "One purchase—always yours."
        case .ja: return "一度お買い上げいただければ、ずっとご利用いただけます。"
        case .ko: return "한 번만 구매하면 계속 이어져요."
        }
    }

    static func premiumBenefitCompanion(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "陪伴模式：全屏小灯与碎碎念"
        case .en: return "Companion mode: a big bulb and gentle chatter"
        case .ja: return "おともモード：大きな灯といっしょに、やさしいつぶやき"
        case .ko: return "동반 모드: 큰 등불과 살랑이는 수다"
        }
    }

    static func premiumBenefitInfinite(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "无限模式：通关第十章后可挑战无尽关卡"
        case .en: return "Endless mode: new puzzles keep going after Chapter 10"
        case .ja: return "エンドレスモード：第10章をクリアすると、続きから遊べます"
        case .ko: return "무한 모드: 10장을 넘기면 끝없는 퍼즐이 이어져요"
        }
    }

    static func premiumBenefitHints(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "每关提示 9 次（未解锁为 3 次）"
        case .en: return "9 hints each stage (3 before unlock)"
        case .ja: return "1ステージあたりヒント9回（未購入の場合は3回）"
        case .ko: return "스테이지마다 힌트 9번 (열기 전엔 3번)"
        }
    }

    static func premiumBenefitOnce(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "非消耗型：换机可用「恢复购买」找回"
        case .en: return "One-time purchase; use Restore on a new phone"
        case .ja: return "買い切り型です。機種変更後は「購入を復元」で復元できます"
        case .ko: return "한 번 사면 끝—새 기기에선 「구매 복원」로 찾아와요"
        }
    }

    static func premiumPricePlaceholder(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "加载价格…"
        case .en: return "Loading price…"
        case .ja: return "価格を読み込み中…"
        case .ko: return "가격 불러오는 중…"
        }
    }

    static func premiumRestore(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "恢复购买"
        case .en: return "Restore Purchases"
        case .ja: return "購入を復元"
        case .ko: return "구매 복원"
        }
    }

    static func premiumClose(_ lang: AppContentLanguage) -> String {
        cancel(lang)
    }

    static func premiumProductNotFound(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "未找到商品"
        case .en: return "Product not found"
        case .ja: return "商品が見つかりません"
        case .ko: return "상품을 찾을 수 없어요"
        }
    }

    static func premiumStoreTemporaryError(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "暂时无法连接商店，请稍后再试"
        case .en: return "Can’t reach the App Store. Try again later."
        case .ja: return "ストアに接続できませんでした。しばらくしてからもう一度お試しください"
        case .ko: return "스토어와 연결이 안 돼요. 잠시 뒤에 다시 눌러 주세요"
        }
    }

    static func premiumSectionTitle(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "会员与购买"
        case .en: return "Membership"
        case .ja: return "メンバーシップ"
        case .ko: return "멤버십"
        }
    }

    static func premiumMemberActive(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "已解锁：陪伴、无限、每关 9 次提示"
        case .en: return "Unlocked: Companion, Infinite, 9 hints per level"
        case .ja: return "アンロック済み：おとも・エンドレス・ヒント9回／ステージ"
        case .ko: return "열렸어요: 동반·무한·스테이지마다 힌트 9번"
        }
    }

    static func premiumMemberInactive(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "未解锁：主页灯泡可购买永久会员"
        case .en: return "Tap the lamp on the home screen to unlock"
        case .ja: return "未購入の場合：ホーム画面の灯から購入できます"
        case .ko: return "아직이에요: 홈의 반짝 램프를 눌러 열 수 있어요"
        }
    }

    static func premiumOpenPaywall(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "查看永久会员"
        case .en: return "View full unlock"
        case .ja: return "永久アンロックを見る"
        case .ko: return "영구 잠금 해제 보기"
        }
    }

    static func infiniteNeedChapter10Title(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "无限模式尚未开放"
        case .en: return "Endless mode is resting"
        case .ja: return "エンドレスモードはまだ解放されていません"
        case .ko: return "무한 모드는 아직 자고 있어요"
        }
    }

    static func infiniteNeedChapter10Message(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "请先通关第十章全部关卡，再解锁无限挑战。"
        case .en: return "Clear every stage in Chapter 10 to open Endless mode."
        case .ja: return "第10章のステージをすべてクリアすると、エンドレスモードが開きます。"
        case .ko: return "10장을 모두 지나가면 무한 모드가 반짝 열려요."
        }
    }

    // MARK: - Onboarding

    static func onboardingSkip(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "跳过"
        case .en: return "Skip"
        case .ja: return "スキップ"
        case .ko: return "건너뛰기"
        }
    }

    static func onboardingNext(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "下一步"
        case .en: return "Next"
        case .ja: return "次へ"
        case .ko: return "다음"
        }
    }

    static func onboardingStart(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "开始玩吧"
        case .en: return "Let’s play"
        case .ja: return "はじめる"
        case .ko: return "시작하기"
        }
    }

    static func onboardingTitles(_ lang: AppContentLanguage) -> [String] {
        switch lang {
        case .zhHans:
            return [
                "你好呀，我是话唠小灯",
                "陪你一起琢磨格子",
                "第十章的小惊喜",
            ]
        case .en:
            return [
                "Hi—I’m your little lamp",
                "Let’s puzzle together, nice and easy",
                "A small spark waits in Chapter 10",
            ]
        case .ja:
            return [
                "こんにちは、わたしは灯です",
                "マス目を、いっしょにゆっくり進めましょう",
                "第10章に、小さなプレゼントがあります",
            ]
        case .ko:
            return [
                "안녕, 나는 반짝 램프야",
                "칸놀이를 살짝 같이 해 볼까?",
                "10장 끝에 작은 반짝 선물이 기다려",
            ]
        }
    }

    static func onboardingBodies(_ lang: AppContentLanguage) -> [String] {
        switch lang {
        case .zhHans:
            return [
                "在这里，点点格子就能放灯泡，把目标格都照亮就能过关，一路解锁新章节。界面底下那个嘴巴闲不下来的，就是在下我啦～",
                "解谜这件事，急不得也丢人：灯泡能撤、棋盘能重开，我会偶尔唠叨两句帮你打气。希望这块亮堂堂的小角落，能让你轻松一点、心情也被轻轻治愈一下～",
                "主线一共有十章；全部通关之后，会有一个小小的惊喜等着你——先卖个关子，你慢慢玩就好。之后想备份进度，可以进设置里导出那一长串代码哦。",
            ]
        case .en:
            return [
                "Tap the board to place bulbs and light every goal—then new chapters drift open. The soft chatter at the bottom? That’s me.",
                "No hurry: undo, restart, breathe. I’ll hum a tiny cheer sometimes. Hope this bright corner feels a little lighter today.",
                "Ten chapters bloom ahead; clear them for a gentle surprise—I won’t spoil the glow. Later you can copy a long backup code in Settings.",
            ]
        case .ja:
            return [
                "マスをタップして電球を置き、ゴールをすべて照らすとクリアです。下のメッセージ欄は、わたしです。",
                "急がなくて大丈夫です。やり直しもできますので、ごゆっくりどうぞ。ときどき、やさしい応援をそっと置いておきますね。",
                "本編は10章です。すべてクリアすると、小さなサプライズが…具体内容は内緒です。進み具合は設定から長いコードでバックアップできます。",
            ]
        case .ko:
            return [
                "칸을 눌러 전구를 두고 목표를 다 밝히면 클리어야. 아래 살짝 떠 있는 말풍선? 그게 바로 나, 반짝 램프야.",
                "서두르지 않아도 괜찮아요. 되돌리기랑 다시 하기도 있으니까. 가끔 응원도 살포시 할게. 이 작은 빛이 위로가 되었으면 해요.",
                "이야기는 10챕터까지 있어요. 다 넘기면 작은 반짝 선물이…내용은 비밀! 나중에 설정에서 긴 코드로 진행도 간직할 수 있어요.",
            ]
        }
    }

    // MARK: - Home & chapter list

    /// 主界面导航栏、棋盘默认标题（非无限关）；随设置内语言切换。
    /// **桌面图标名**由系统语言对应的 `InfoPlist.strings` 决定，与应用内语言可能不一致（系统限制）。
    static func homeTitle(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "话唠小灯"
        case .en: return "Little Lamp"
        case .ja: return "灯"
        case .ko: return "반짝 램프"
        }
    }

    static func loadFailed(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "加载失败"
        case .en: return "Couldn’t load"
        case .ja: return "読み込みに失敗しました"
        case .ko: return "불러오지 못했어요"
        }
    }

    static func loadFailedHint(_ lang: AppContentLanguage, detail: String) -> String {
        switch lang {
        case .zhHans: return "请确认 levels_pack_01.json 已打包到工程，错误：\(detail)"
        case .en: return "Check levels_pack_01.json is bundled. \(detail)"
        case .ja: return "levels_pack_01.json が含まれているかご確認ください。\(detail)"
        case .ko: return "levels_pack_01.json이 들어 있는지 확인해 주세요. \(detail)"
        }
    }

    static func a11yCompanionMode(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "陪伴模式"
        case .en: return "Companion nook"
        case .ja: return "おともモード"
        case .ko: return "같이 노는 작은 숲"
        }
    }

    static func a11yInfiniteMode(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "无限模式"
        case .en: return "Endless mode"
        case .ja: return "エンドレス"
        case .ko: return "무한 모드"
        }
    }

    static func a11yDifficultyStars(_ lang: AppContentLanguage, tier: Int) -> String {
        switch lang {
        case .zhHans: return "难度 \(tier) 星"
        case .en: return "\(tier) stars"
        case .ja: return "難易度 \(tier)"
        case .ko: return "난이도 \(tier)성"
        }
    }

    static func closeCompanion(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "关闭陪伴模式"
        case .en: return "Close"
        case .ja: return "閉じる"
        case .ko: return "닫기"
        }
    }

    // MARK: - Infinite welcome sheet

    static func infiniteWelcomeTitle(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "无限模式"
        case .en: return "Endless"
        case .ja: return "エンドレス"
        case .ko: return "무한 모드"
        }
    }

    static func infiniteWelcomeHeadline(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "欢迎来到无限模式～"
        case .en: return "Welcome to the endless glow~"
        case .ja: return "エンドレスへようこそ"
        case .ko: return "무한 모드에 온 걸 환영해, 반짝~"
        }
    }

    static func infiniteLevelOrdinal(_ lang: AppContentLanguage, n: Int) -> String {
        switch lang {
        case .zhHans: return "第 \(n) 关"
        case .en: return "Stage \(n)"
        case .ja: return "第\(n)ステージ"
        case .ko: return "\(n)번 스테이지"
        }
    }

    static func infiniteNextOnly(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "仅支持「下一关」前进"
        case .en: return "Advance with Next only"
        case .ja: return "進むときは「次へ」だけです"
        case .ko: return "앞으로 갈 땐 「다음」만 눌러 주세요"
        }
    }

    static func infiniteEnter(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "进入挑战"
        case .en: return "Start"
        case .ja: return "はじめる"
        case .ko: return "도전 입장"
        }
    }

    static func infiniteClose(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "关闭"
        case .en: return "Close"
        case .ja: return "閉じる"
        case .ko: return "닫기"
        }
    }

    static func infiniteToolbarDone(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "完成"
        case .en: return "Done"
        case .ja: return "完了"
        case .ko: return "완료"
        }
    }

    static func infiniteLoadingLevels(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "加载关卡…"
        case .en: return "Loading…"
        case .ja: return "読み込み中…"
        case .ko: return "불러오는 중…"
        }
    }

    // MARK: - Settings

    static func settingsTitle(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "设置"
        case .en: return "Settings"
        case .ja: return "設定"
        case .ko: return "설정"
        }
    }

    static func achievementsRowTitle(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "成就栏"
        case .en: return "Achievements"
        case .ja: return "実績"
        case .ko: return "업적"
        }
    }

    static func personalSection(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "个人"
        case .en: return "Profile"
        case .ja: return "プレイヤー"
        case .ko: return "프로필"
        }
    }

    static func localPlayer(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "本地玩家"
        case .en: return "Local player"
        case .ja: return "ローカルプレイヤー"
        case .ko: return "로컬 플레이어"
        }
    }

    static func progressSummary(_ lang: AppContentLanguage, main: Int, inf: Int) -> String {
        switch lang {
        case .zhHans: return "主线 \(main) 关 · 无限已通 \(inf)"
        case .en: return "Story \(main) cleared · Endless \(inf)"
        case .ja: return "本編 \(main) クリア · エンドレス \(inf)"
        case .ko: return "본편 \(main) 클리어 · 무한 \(inf)"
        }
    }

    static func exportProgress(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "导出进度（复制一整串代码）"
        case .en: return "Export (copy code)"
        case .ja: return "エクスポート（コードをコピー）"
        case .ko: return "내보내기(코드 복사)"
        }
    }

    static func importProgress(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "导入进度（粘贴代码）"
        case .en: return "Import (paste code)"
        case .ja: return "インポート（貼り付け）"
        case .ko: return "가져오기(붙여넣기)"
        }
    }

    static func importSheetTitle(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "导入进度"
        case .en: return "Import"
        case .ja: return "インポート"
        case .ko: return "가져오기"
        }
    }

    static func importSheetHint(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "将导出时复制的那一串粘贴到下方，保存后会覆盖本机当前进度。"
        case .en: return "Paste the code you copied; saving replaces this device’s save."
        case .ja: return "エクスポートしたコードを貼り付けてください。保存すると上書きされます。"
        case .ko: return "복사한 코드를 아래에 붙여 주세요. 저장하면 이 기기 진행이 덮어씌워져요."
        }
    }

    static func importClose(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "关闭"
        case .en: return "Close"
        case .ja: return "閉じる"
        case .ko: return "닫기"
        }
    }

    static func importSave(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "写入存档"
        case .en: return "Save"
        case .ja: return "保存する"
        case .ko: return "저장"
        }
    }

    static func resetConfirmTitle(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "确认重置进度？"
        case .en: return "Reset all progress?"
        case .ja: return "進行状況をリセット？"
        case .ko: return "진행을 초기화할까?"
        }
    }

    static func resetConfirmDestructive(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "重置"
        case .en: return "Reset"
        case .ja: return "リセット"
        case .ko: return "초기화"
        }
    }

    static func cancel(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "取消"
        case .en: return "Cancel"
        case .ja: return "キャンセル"
        case .ko: return "취소"
        }
    }

    static func resetWarningMessage(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "此操作不可撤销。"
        case .en: return "This can’t be undone."
        case .ja: return "この操作は取り消せません。"
        case .ko: return "한번 지우면 되돌릴 수 없어요."
        }
    }

    static func importFailedTitle(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "导入失败"
        case .en: return "Import failed"
        case .ja: return "インポート失敗"
        case .ko: return "가져오기 실패"
        }
    }

    static func ok(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "好"
        case .en: return "OK"
        case .ja: return "OK"
        case .ko: return "확인"
        }
    }

    static func copiedToast(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "已复制到剪贴板"
        case .en: return "Copied"
        case .ja: return "コピーしました"
        case .ko: return "복사해 두었어요"
        }
    }

    static func gameSettingsSection(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "游戏设置"
        case .en: return "Gameplay"
        case .ja: return "ゲーム設定"
        case .ko: return "게임 설정"
        }
    }

    static func bgmToggle(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "背景音乐"
        case .en: return "Background music"
        case .ja: return "BGM"
        case .ko: return "배경음"
        }
    }

    static func replayOnboarding(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "重新播放开场说明"
        case .en: return "Replay intro"
        case .ja: return "イントロをもう一度"
        case .ko: return "인트로 다시 보기"
        }
    }

    static func dataSection(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "数据"
        case .en: return "Data"
        case .ja: return "データ"
        case .ko: return "데이터"
        }
    }

    static func resetAllProgress(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "重置全部进度"
        case .en: return "Reset all progress"
        case .ja: return "すべてリセット"
        case .ko: return "전체 초기화"
        }
    }

    // MARK: - Achievements screen

    static func achievementsTitle(_ lang: AppContentLanguage) -> String {
        achievementsRowTitle(lang)
    }

    static func achievementCategory(_ id: String, lang: AppContentLanguage) -> String {
        switch (id, lang) {
        case ("story", .zhHans): return "主线旅程"
        case ("story", .en): return "Story"
        case ("story", .ja): return "本編"
        case ("story", .ko): return "본편 여정"
        case ("infinite", .zhHans): return "无限挑战"
        case ("infinite", .en): return "Endless"
        case ("infinite", .ja): return "エンドレス"
        case ("infinite", .ko): return "무한 도전"
        case ("companion", .zhHans): return "陪伴小憩"
        case ("companion", .en): return "Hang-out"
        case ("companion", .ja): return "おとも時間"
        case ("companion", .ko): return "같이 쉬는 시간"
        case ("barrage", .zhHans): return "弹幕心语"
        case ("barrage", .en): return "Banter"
        case ("barrage", .ja): return "セリフ集め"
        case ("barrage", .ko): return "반짝 대사 모음"
        case ("habits", .zhHans): return "棋盘习惯"
        case ("habits", .en): return "Habits"
        case ("habits", .ja): return "クセ"
        case ("habits", .ko): return "습관"
        default: return id
        }
    }

    static func achievementTitle(_ id: String, lang: AppContentLanguage) -> String {
        achievementPair(id, lang: lang).0
    }

    static func achievementRule(_ id: String, lang: AppContentLanguage) -> String {
        achievementPair(id, lang: lang).1
    }

    private static func achievementPair(_ id: String, lang: AppContentLanguage) -> (String, String) {
        switch id {
        case "story_first":
            return pair(lang,
                        zh: ("初来乍到", "累计通关至少 1 关主线（从第一章「教学」算起）。"),
                        en: ("First steps", "Clear 1+ story stage (Chapter 1 onward)."),
                        ja: ("はじめの一歩", "本編を1ステージ以上クリア。"),
                        ko: ("첫 발짝", "스토리 스테이지 1개 이상 클리어."))
        case "story_ch3":
            return pair(lang,
                        zh: ("渐入佳境", "通关第三章「挑战」首关「镜启微芒」。"),
                        en: ("Finding rhythm", "Clear Ch.3 first stage."),
                        ja: ("のってきた", "第3章の最初をクリア。"),
                        ko: ("감 잡기", "3장 첫 스테이지 클리어."))
        case "story_ch5":
            return pair(lang,
                        zh: ("侧门与光", "通关第五章「折射」首关「缝光初晓」（折射缝玩法）。"),
                        en: ("Side paths", "Clear Ch.5 first stage (slit rules)."),
                        ja: ("横の光", "第5章の最初をクリア（すきま）。"),
                        ko: ("옆문 빛", "5장 첫 스테이지 클리어(틈 규칙)."))
        case "story_ch9boss":
            return pair(lang,
                        zh: ("暴风雨前", "通关第九章「幽渊试刃」最后一关「冕光自许」。"),
                        en: ("Before the storm", "Clear Ch.9 final stage."),
                        ja: ("嵐の前", "第9章ラストをクリア。"),
                        ko: ("폭풍 전야", "9장 마지막 클리어."))
        case "story_all_full":
            return pair(lang,
                        zh: ("基础篇毕业", "通关当前版本全部主线关卡（进度与主页一致）。"),
                        en: ("Story grad", "Clear all story in this build."),
                        ja: ("本編コンプ", "この版の本編をすべてクリア。"),
                        ko: ("본편 졸업", "이 빌드의 스토리 전부 클리어."))
        case "story_finale":
            return pair(lang,
                        zh: ("打开心门", "通关第十章「心门」关卡「话唠小灯」（终章）。"),
                        en: ("Open the door", "Clear Ch.10 finale."),
                        ja: ("心の扉", "第10章フィナーレをクリア。"),
                        ko: ("마음의 문", "10장 피날레 클리어."))
        case "inf_1":
            return pair(lang,
                        zh: ("∞ 启航", "在无限模式按顺序通关至少 1 关（无限通关进度会 +1）。"),
                        en: ("∞ Start", "Clear 1 endless stage in order."),
                        ja: ("∞ 出港", "エンドレスを順番に1つクリア。"),
                        ko: ("∞ 출항", "무한 모드 순서대로 1개 클리어."))
        case "inf_10":
            return pair(lang,
                        zh: ("热身收工", "无限模式累计通关至少 10 关。"),
                        en: ("Warm-up done", "10+ endless clears total."),
                        ja: ("ウォームアップ", "エンドレスを10以上クリア。"),
                        ko: ("웜업 끝", "무한 합계 10클 이상."))
        case "inf_50":
            return pair(lang,
                        zh: ("长腿小灯", "无限模式累计通关至少 50 关。"),
                        en: ("Long runner", "50+ endless clears."),
                        ja: ("よく走る灯", "エンドレス50以上。"),
                        ko: ("잘 도는 등", "무한 50클 이상."))
        case "inf_99":
            return pair(lang,
                        zh: ("百里挑一", "无限模式累计通关至少 99 关。"),
                        en: ("One in a hundred", "99+ endless clears."),
                        ja: ("順調に灯る", "エンドレスを99回以上クリア。"),
                        ko: ("반짝 백 번째", "무한 모드로 99번 넘게 클리어."))
        case "inf_500":
            return pair(lang,
                        zh: ("五百层楼", "无限模式累计通关至少 500 关。"),
                        en: ("500 floors", "500+ endless clears."),
                        ja: ("500階", "エンドレス500以上。"),
                        ko: ("500층", "무한 500클 이상."))
        case "inf_999":
            return pair(lang,
                        zh: ("千里灯河", "无限模式累计通关至少 999 关。"),
                        en: ("River of lights", "999+ endless clears."),
                        ja: ("灯の川", "エンドレス999以上。"),
                        ko: ("등불 강", "무한 999클 이상."))
        case "inf_9999":
            return pair(lang,
                        zh: ("万里长明", "无限模式累计通关至少 9999 关。"),
                        en: ("Everglow", "9999+ endless clears."),
                        ja: ("ずっと明るく", "エンドレス9999以上。"),
                        ko: ("길게 밝게", "무한 9999클 이상."))
        case "comp_1":
            return pair(lang,
                        zh: ("第一次见面", "从主页进入「陪伴模式」至少 1 次。"),
                        en: ("First visit", "Open Hang-out once from home."),
                        ja: ("はじめまして", "おともモードを1回開く。"),
                        ko: ("첫 만남", "홈에서 휴식 모드 1회."))
        case "comp_5":
            return pair(lang,
                        zh: ("常来坐坐", "进入陪伴模式至少 5 次。"),
                        en: ("Regular guest", "Hang-out 5+ times."),
                        ja: ("よく来るね", "おとも5回以上。"),
                        ko: ("자주 와", "휴식 5회 이상."))
        case "comp_10":
            return pair(lang,
                        zh: ("灯下常客", "进入陪伴模式至少 10 次。"),
                        en: ("Familiar face", "Hang-out 10+ times."),
                        ja: ("常連さん", "おとも10回以上。"),
                        ko: ("단골", "휴식 10회 이상."))
        case "comp_30":
            return pair(lang,
                        zh: ("黑夜里的小约定", "进入陪伴模式至少 30 次。"),
                        en: ("Quiet pact", "Hang-out 30+ times."),
                        ja: ("夜の約束", "おとも30回以上。"),
                        ko: ("밤의 약속", "휴식 30회 이상."))
        case "barr_companion_20":
            return pair(lang,
                        zh: ("虚拟里也认真高兴", "解锁陪伴模式20条特殊弹幕"),
                        en: ("Cheer for real", "Unlock 20 special Hang-out banter lines."),
                        ja: ("画面越しの喜び", "おともモードの特殊弾幕を20種解放。"),
                        ko: ("진심 응원", "휴식 모드 특수 속삭임 20개 해제."))
        case "barr_infinite_20":
            return pair(lang,
                        zh: ("无限乱想收集家", "解锁无限模式20条特殊弹幕"),
                        en: ("Endless banter fan", "Unlock 20 special Infinite mode banter lines."),
                        ja: ("無限セリフコレ", "エンドレスの特殊弾幕を20種解放。"),
                        ko: ("무한 수다 수집", "무한 모드 특수 속삭임 20개 해제."))
        case "hab_hint_1":
            return pair(lang,
                        zh: ("求助无罪", "在任意主线或无限关卡中，成功使用提示并消耗 1 次提示次数，累计满 1 次。"),
                        en: ("Hints OK", "Spend 1 hint successfully."),
                        ja: ("ヒント1回", "ヒントを1回使う。"),
                        ko: ("힌트 환영", "힌트 1회 성공."))
        case "hab_hint_30":
            return pair(lang,
                        zh: ("小抄达人", "上述「成功消耗提示」累计至少 30 次。"),
                        en: ("Hint regular", "Spend hints successfully 30+ times."),
                        ja: ("ヒント30回", "ヒントを30回以上。"),
                        ko: ("힌트 고수", "힌트 성공 30회 이상."))
        case "hab_restart_10":
            return pair(lang,
                        zh: ("再来一盘", "在棋盘顶栏点击「重开」累计至少 10 次。"),
                        en: ("One more go", "Tap Restart 10+ times."),
                        ja: ("もう一局", "リスタート10回以上。"),
                        ko: ("한 판 더", "다시하기 10회 이상."))
        case "hab_restart_50":
            return pair(lang,
                        zh: ("重整旗鼓", "「重开」累计至少 50 次。"),
                        en: ("Fresh starts", "Restart 50+ times."),
                        ja: ("立て直し", "リスタート50回以上。"),
                        ko: ("기세 재정비", "다시하기 50회 이상."))
        default:
            return ("", "")
        }
    }

    private static func pair(_ lang: AppContentLanguage, zh: (String, String), en: (String, String), ja: (String, String), ko: (String, String)) -> (String, String) {
        switch lang {
        case .zhHans: return zh
        case .en: return en
        case .ja: return ja
        case .ko: return ko
        }
    }

    // MARK: - Splash a11y

    static func splashBulbA11yLabel(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "灯泡"
        case .en: return "Little lamp"
        case .ja: return "灯"
        case .ko: return "반짝 램프"
        }
    }

    static func splashBulbA11yHint(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "轻点以点亮并进入游戏"
        case .en: return "Tap to glow and step inside"
        case .ja: return "タップで灯り、進みます"
        case .ko: return "눌러서 반짝 켜고 들어가기"
        }
    }

    // MARK: - Board & tutorial

    static func bulbCapBanner(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "灯泡数量已到上限，先移除一个再放置"
        case .en: return "Bulb limit full—take one off first"
        case .ja: return "上限です。いったん1つ外してください"
        case .ko: return "전구가 가득 찼어요. 하나 치운 뒤 다시 둘 수 있어요"
        }
    }

    static func rulesA11y(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "规则"
        case .en: return "Rules"
        case .ja: return "ルール"
        case .ko: return "규칙"
        }
    }

    static func restartA11y(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "重开"
        case .en: return "Restart"
        case .ja: return "やり直し"
        case .ko: return "다시 시작"
        }
    }

    static func undoA11y(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "撤销"
        case .en: return "Undo"
        case .ja: return "戻す"
        case .ko: return "되돌리기"
        }
    }

    static func hintA11y(_ lang: AppContentLanguage, remaining: Int) -> String {
        switch lang {
        case .zhHans: return "提示，剩余 \(remaining) 次"
        case .en: return "Hint, \(remaining) left"
        case .ja: return "ヒント あと\(remaining)回"
        case .ko: return "힌트 \(remaining)회 남음"
        }
    }

    static func navInfiniteShort(_ lang: AppContentLanguage, n: Int) -> String {
        switch lang {
        case .zhHans: return "无限 · \(n)"
        case .en: return "Endless · \(n)"
        case .ja: return "無限 · \(n)"
        case .ko: return "무한 · \(n)"
        }
    }

    static func companionStripTitle(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "话唠小灯"
        case .en: return "Little lamp"
        case .ja: return "灯"
        case .ko: return "반짝 램프"
        }
    }

    static func companionStripSubtitleNormal(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "有空唠叨两句"
        case .en: return "Soft chatter"
        case .ja: return "ひとこと、どうぞ"
        case .ko: return "살짝 속삭일게요"
        }
    }

    static func companionStripSubtitleFinale(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "终章慢慢说"
        case .en: return "Finale, gently"
        case .ja: return "終章はゆっくり"
        case .ko: return "마지막 장, 천천히"
        }
    }

    static func hudLevelOrdinal(_ lang: AppContentLanguage, g: Int) -> String {
        infiniteLevelOrdinal(lang, n: g)
    }

    static func hudLitTargets(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "已照亮标记"
        case .en: return "Goals lit"
        case .ja: return "照らした目標"
        case .ko: return "밝힌 목표"
        }
    }

    static func hudOptimalBulbs(_ lang: AppContentLanguage, max: Int) -> String {
        switch lang {
        case .zhHans: return "须恰好用完 \(max) 盏灯泡"
        case .en: return "Use exactly \(max) bulbs"
        case .ja: return "ちょうど\(max)個使ってね"
        case .ko: return "정확히 \(max)개 써야 해"
        }
    }

    static func winTargetsLit(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "目标格已全部照亮。"
        case .en: return "All goals lit."
        case .ja: return "全部照らせた。"
        case .ko: return "목표 다 밝혔어."
        }
    }

    static func winKeepViewing(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "继续查看"
        case .en: return "Stay"
        case .ja: return "このまま見る"
        case .ko: return "계속 보기"
        }
    }

    static func winNextLevel(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "下一关"
        case .en: return "Next"
        case .ja: return "次へ"
        case .ko: return "다음"
        }
    }

    static func prevLevelA11y(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "上一关"
        case .en: return "Previous"
        case .ja: return "前へ"
        case .ko: return "이전"
        }
    }

    static func nextLevelA11y(_ lang: AppContentLanguage) -> String {
        winNextLevel(lang)
    }

    /// 主页关卡卡片：未满足顺序解锁时的旁白。
    static func a11yLevelCardLocked(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "未解锁，需先通关上一关"
        case .en: return "Locked; clear the previous stage first"
        case .ja: return "未開放です。前のステージをクリアしてください"
        case .ko: return "아직이에요. 이전 스테이지를 먼저 밝혀 주세요"
        }
    }

    static func batchLoadingTitle(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "关卡加载中…"
        case .en: return "Loading stages…"
        case .ja: return "読み込み中…"
        case .ko: return "스테이지 불러오는 중…"
        }
    }

    static func batchLoadingSubtitle(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "正在准备后续关卡，请稍候"
        case .en: return "Gathering the next glimmer of stages…"
        case .ja: return "次のステージを準備しています"
        case .ko: return "다음 스테이지 반짝 묶음을 준비 중이에요"
        }
    }

    static func quotaA11y(_ lang: AppContentLanguage, placed: Int, max: Int) -> String {
        switch lang {
        case .zhHans: return "灯泡已用 \(placed) 盏，共可用 \(max) 盏"
        case .en: return "\(placed) of \(max) bulbs used"
        case .ja: return "電球 \(placed)/\(max) 使ってる"
        case .ko: return "전구 \(placed)/\(max) 사용"
        }
    }

    static func tutorialNavTitle(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "玩法说明"
        case .en: return "How to play"
        case .ja: return "遊び方"
        case .ko: return "플레이 방법"
        }
    }

    static func tutorialDone(_ lang: AppContentLanguage) -> String {
        infiniteToolbarDone(lang)
    }

    static func tutorialListTitle(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "\(homeTitle(lang))：照亮所有目标格"
        case .en: return "\(homeTitle(lang)): light every goal"
        case .ja: return "\(homeTitle(lang))：ゴールを全部照らす"
        case .ko: return "\(homeTitle(lang)): 목표를 다 밝히기"
        }
    }

    static func tutorialSteps(_ lang: AppContentLanguage) -> [String] {
        switch lang {
        case .zhHans:
            return [
                "1. 点击可放置的黑色格子可以放置/移除灯泡。",
                "2. 每个灯泡都会照亮自身与上下左右相邻格（十字形，最多 5 格），对角不相邻。",
                "3. 你必须在灯泡上限内点亮所有目标格子才能过关。",
                "4. 障碍格不可放置也不会被点亮。",
                "5. 斜面镜与折射缝镜格不可放灯；斜镜按镜面反射，缝镜仅左右贯穿到对侧一格，上下不透。",
            ]
        case .en:
            return [
                "1. Tap open cells to add or lift a bulb.",
                "2. Each bulb lights itself and a small + (up to five cells)—not diagonals.",
                "3. Light every goal before you run out of bulbs.",
                "4. Walls never hold bulbs or catch light.",
                "5. Mirrors and slits can’t hold bulbs; mirrors bend beams; slits step sideways one cell only.",
            ]
        case .ja:
            return [
                "1. 置けるマスをタップして、電球を置いたり外したりできます。",
                "2. 電球は自分のマスと上下左右（最大5マス）を照らします。斜めは照らせません。",
                "3. 電球の上限のうちで、すべてのゴールを照らすとクリアです。",
                "4. 壁のマスには置けず、光も届きません。",
                "5. 鏡・すきまのマスにも置けません。鏡は光を反射し、すきまは横に1マスだけ通ります。",
            ]
        case .ko:
            return [
                "1. 둘 수 있는 칸을 눌러 전구를 두거나 거둘 수 있어요.",
                "2. 전구는 자기 칸과 상하좌우(최대 5칸)를 밝혀요. 대각선은 안 돼요.",
                "3. 전구 개수 안에서 모든 목표 칸을 밝히면 클리어예요.",
                "4. 벽 칸에는 두지 못하고 빛도 닿지 않아요.",
                "5. 거울/틈 칸에도 둘 수 없어요. 거울은 반사하고, 틈은 옆으로 한 칸만 통과해요.",
            ]
        }
    }

    static func welcomeLineFinale(_ lang: AppContentLanguage) -> String {
        switch lang {
        case .zhHans: return "这是最后一关哦～"
        case .en: return "Last story chapter~"
        case .ja: return "最後の本編です〜"
        case .ko: return "이야기의 마지막 장이에요〜"
        }
    }

    static func welcomeLinePool(_ lang: AppContentLanguage) -> [String] {
        switch lang {
        case .zhHans:
            return [
                "新关卡悄悄上线啦，慢慢来，不急～",
                "嗒哒～这一格就拜托你点亮啦。",
                "换关啦，小灯先卖个萌，剩下的交给你。",
                "新棋盘到货，试错也超理直气壮。",
                "嘿，新地图解锁，轻轻点就好～",
                "灯灯探头：这关也请你多关照呀。",
            ]
        case .en:
            return [
                "New stage—sip it slowly.",
                "This cell is yours—tap when it feels right.",
                "Fresh board; soft tries still count.",
                "New map—little taps, big glow.",
                "Tiny lamp wave: hi, no rush.",
                "I’ll glow quietly—you steer the light.",
            ]
        case .ja:
            return [
                "新しいステージです。ごゆっくりどうぞ。",
                "このマスを、どうぞよろしくお願いします。",
                "新しい盤面です。試すことも、大切な一歩です。",
                "地図が新しくなりました。やさしいタップで。",
                "こんにちは、わたしは灯です。焦らずにどうぞ。",
                "わたしはそっと待っています。照らすのは、あなたです。",
            ]
        case .ko:
            return [
                "새 스테이지에 와 줘서 고마워, 살짝 천천히 해도 돼.",
                "이 칸은 네게 맡길게, 반짝.",
                "새 판이에요. 도전도 살포시 환영이야.",
                "지도가 바뀌었어—살짝만 눌러도 돼.",
                "반짝 램프 인사 왔어요, 급하지 않아도 괜찮아.",
                "나는 여기서 반짝, 길은 네가 밝혀 줘.",
            ]
        }
    }
}
