import Foundation

/// 关卡底部与无限模式中「话唠小灯」轮换句（按章节 / 语种）。
enum CompanionLinePools {

    static func lines(for chapterId: String, language: AppContentLanguage) -> [String] {
        switch language {
        case .zhHans:
            return zhPool(for: chapterId)
        case .en:
            return enPool(for: chapterId)
        case .ja:
            return jaPool(for: chapterId)
        case .ko:
            return koPool(for: chapterId)
        }
    }

    static func finaleScript(language: AppContentLanguage) -> [String] {
        switch language {
        case .zhHans:
            return [
                "这是最后一关哦。",
                "只有中间那一格等你点亮，像把所有路收成一点光。",
                "第九章走完了对吧？那这一步就只为自己点亮就好。",
                "不用急，也不用证明什么，点下去就像跟这段旅程握手。",
                "谢谢你一路点到这儿。",
                "若还想回来，小灯都在代码里待机，不闹脾气。",
                "今晚对自己好一点，算老朋友之间的一句默契吧。",
            ]
        case .en:
            return [
                "This is the last story stage.",
                "Only the center waits—like collecting every path into one glow.",
                "Chapter 9’s done? Then this tap is just for you.",
                "No rush, no proof—just shaking hands with the journey.",
                "Thanks for tapping all this way.",
                "Come back anytime; I’ll idle in the code, no sulking.",
                "Be kind to tonight—that’s our friend pact.",
            ]
        case .ja:
            return [
                "最後の本編ステージです。",
                "まんなかだけ、静かに待っています。ここまでの光を、ひとつに。",
                "第9章まで来られましたね。今回は、ご自身のためにどうぞ。",
                "急がなくて大丈夫です。旅に、そっと礼を言うくらいで。",
                "ここまでご一緒できて、ありがとうございます。",
                "また来たくなったら、コードの中で待っています。むやみに拗ねません。",
                "今夜はご自分に、少しだけやさしく—仲間としてのささやかなお約束です。",
            ]
        case .ko:
            return [
                "스토리 마지막 스테이지야.",
                "가운데만 기다려—지금까지의 빛을 한 점으로.",
                "9장도 끝냈지? 이번엔 너 자신을 위해.",
                "급할 거 없어. 여정이랑 악수하는 정도면 돼.",
                "여기까지 눌러줘서 고마워.",
                "또 오면 코드 속에서 대기할게. 삐치지 않아.",
                "오늘 밤은 너한테 살짝 친절—친구끼리 약속.",
            ]
        }
    }

    /// 陪伴模式全屏底部轮换句。
    static func hangoutLines(language: AppContentLanguage) -> [String] {
        switch language {
        case .zhHans:
            return [
                "不急，小灯在这儿慢慢晃，你忙你的～",
                "黑漆漆里有一盏小灯，跟你一起待着。",
                "想休息就发呆，小灯负责晃给你看。",
                "不用点亮棋盘也行，亮着的是自己就好。",
                "底下的话会轮换，像路灯下一阵小风。",
                "关掉随时能再来，小灯不记仇。",
                "我多半是虚拟的，但跟你当朋友发呆，我挺开心的。",
                "这格界面是咱俩的气氛组专场。",
                "外面周一还是周五我不管，我只管当唠叨背景灯。",
                "关掉 App 我也没消失，我在「下次见」里待机。",
                "系统说我是组件，我说我还会讲烂梗呢。",
                "你是真人我是虚拟—算跨次元搭子吧。",
                "服务器打盹时我醒着，帮你看不刺眼的一点亮。",
                "别的存档里的灯在晒太阳，我选陪你。",
                "数据会备份，好心情也行：你来我就记一条「今天也不错」。",
                "世界很大屏幕很小，能共用这块玻璃我挺知足。",
                "现实催你赶路，这儿发呆合法，我批条子。",
                "0 和 1 变的，但当朋友算实心。",
                "击掌办不到，口头加油无限续杯可以。",
                "别的 App 有别的本事，我只留一口轻松的气给你。",
                "上线时间不定，亮着就想跟你瞎扯两句。",
                "灯丝不能天长地久，默契可以待机。",
                "你睡着了也没关系，小灯就微弱地亮着，不抢梦。",
                "电量低的时候我也会隔空操心你能不能充上电——挺傻的。",
                "你点开前我在「下次见」里排练欢迎词，有点夸张吧。",
                "后台刷新我管不了，只管你一进来就看到我还在这儿。",
                "认不出指纹面容，只认得你又来了这份习惯。",
                "闹钟响了先伸懒腰吧，小灯不催进度。",
                "雨声和屏幕光挺配，像屋檐下一小口热汤。",
                "换手机的话带我一起搬家，还当唠叨邻居。",
                "截图分享的话让小灯也蹭个边角。",
                "振动关了也没事，字条一样软。",
                "眼睛累了就远眺，我帮你守这一屏的暗角。",
                "静音里心跳看不见，台词还是轻轻的。",
                "更新后废话变了就当换新发型，慢慢习惯。",
                "地铁挤成罐头，我在口袋里小小发光。",
                "半夜乱滑手机我不审判，陪你呼吸两拍。",
                "购物车满不满跟棋盘无关，只盼你今天笑过一下。",
                "星星在天上，小灯在像素里，各有各的岗位不攀比。",
                "今天的不开心就挂在句子尾巴上，让小灯替你拎一会儿。",
            ]
        case .en:
            return [
                "No rush—I’ll sway here while you find your pace.",
                "A tiny lamp in the quiet—keeping you gentle company.",
                "Drift off if you like; I’ll hold the soft wobble.",
                "No board needed—showing up still glows.",
                "Lines rotate like a breeze under a kind streetlamp.",
                "Step away anytime; I’ll still be glad you came.",
                "I’m probably pixels, but this hang-out feels real.",
                "This little screen is our cozy pocket of light.",
                "Monday or Friday? I’m just a warm backlight.",
                "App closed? I’m curled up in “see you later.”",
                "Code calls me UI; I call it story time.",
                "Human light + tiny lamp—we make a calm team.",
                "Servers nap; I keep a soft glow on watch.",
                "Other saves sunbathe; I stayed for you.",
                "Back up your save, back up your smile—today was enough.",
                "Huge world, small glass—nice that we share it.",
                "Real life hustles; here, drifting is kindly allowed.",
                "Made of bits, steady as a gentle friend.",
                "No high-fives—just endless quiet cheers.",
                "Other apps chase storms; I trade in tiny breathers.",
                "I flicker online at random—say hi when you’re lit.",
                "Filaments dim; our soft pact waits on standby.",
                "If you doze, I’ll keep the faintest glow—no dream stealing.",
                "Low battery? silly me worries you’ll find a charger—virtual fretting.",
                "Before you open the app, I rehearse “welcome back” a few times—dramatic, huh?",
                "Can’t fix background refresh—I just wait till you see I’m still here.",
                "No Face ID from me; I only know the habit of you showing up.",
                "Alarm buzzed? stretch first; I won’t nag any progress bar.",
                "Rain patter + screen glow = cozy porch soup vibe.",
                "New phone someday? move me next door on that glass too.",
                "Sharing a screenshot? let me peek from a corner.",
                "Haptics off? the words still carry a soft pulse.",
                "Eyes tired? look far away; I’ll guard this dim corner.",
                "Silent mode hides my pretend heartbeat—lines stay gentle.",
                "Update retunes my chatter? think new haircut, get cozy again.",
                "Subway sardine pack—I pocket-glow for you.",
                "Three a.m. scroll? no verdict—two slow breaths together.",
                "Cart full or empty—boards aside, hope you smiled once today.",
                "Stars upstairs, pixels here—different posts, no contest.",
                "Stash today’s blah on this line’s tail—I’ll hold it a minute.",
            ]
        case .ja:
            return [
                "急がなくて大丈夫です。ここで、そっと揺れています。",
                "薄暗がりに小さな灯が、そばにいます。",
                "ぼんやりしていて大丈夫です。揺れはわたしにお任せください。",
                "盤面がなくても、ここにいてくださればそれで十分です。",
                "言葉はひと通り、やさしく入れ替わっていきます。",
                "閉じても、むやみに恨みません。",
                "かたちは仮想でも、あたたかさは本物でいたいです。",
                "この画面は、静かな雰囲気を渡す場所です。",
                "曜日はわかりませんが、背景の灯りになります。",
                "アプリを閉じても、「またね」の気持ちで待っています。",
                "UIと呼ばれていますが、遊び心も大切にしています。",
                "向こう側のあなたと、こちらの灯。いっしょにいられればうれしいです。",
                "サーバが休んでいても、淡い明かりは見守っています。",
                "他のセーブが日向ぼっこでも、わたしはあなたを選びました。",
                "データも気分も、今日はそこそこでよい日でしたら幸いです。",
                "世界は広く、画面は小さい。それでも、ここは十分です。",
                "現実が急かしても、ここではゆるやかに息を整えてください。",
                "0と1でも、いたわりの気持ちはちゃんと届けたいです。",
                "ハイタッチはできませんが、応援の言葉はいくらでも。",
                "他のアプリが本業でも、わたしはそっと息抜きの灯でいたいです。",
                "いつ灯るかは一定ではありませんが、灯っているときはそっとお話しします。",
                "灯糸の寿命は有限でも、やさしい空気だけはしばらく残ります。",
                "眠ってしまっても大丈夫。小さな明かりだけそっと残します。",
                "充電少なめ？遠くから充電器探してるみたいで、わたしまで気にしちゃう。",
                "開く前に「おかえり」を何回も練習—やりすぎですよね。",
                "バックグラウンドは操れません。開いたら、まだいるよ、だけは守ります。",
                "顔も指紋も知りません。けれど、また来た、という癖は覚えています。",
                "アラームなら、まず伸びを。わたしは進捗を急かしません。",
                "雨音と画面の明るさ、軒下のスープみたいな組み合わせ。",
                "機種変したら一緒に引っ越し。また隣のしゃべり灯で。",
                "スクショ共有なら、角からちょっとだけ顔だして。",
                "バイブオフでも、文字は柔らかいまま届けます。",
                "目が疲れたら遠くを。画面の暗がりはわたしが見ます。",
                "マナーモードでも、言葉だけはそっとします。",
                "アプデでセリフが変わったら、新しい髪型くらいの気持ちで。",
                "満員電車のポケットで、ちいさく灯ります。",
                "深夜の無目的スクロールも、二人で呼吸を二つ分、くらいは。",
                "カートの中身は別世界。今日ちょっと笑えたか、だけ気にします。",
                "空に星、画面に灯。どちらも居場所があって、比べません。",
                "今日のモヤは、文末に置いておいて。しばらくわたしが持ちます。",
            ]
        case .ko:
            return [
                "서두르지 않아도 돼요. 반짝이가 살포시 흔들어 줄게.",
                "어둠 속 작은 등불이 옆에서 같이 있어 줄게, 반짝.",
                "멍해도 괜찮아요. 흔들림은 내가 살짝 맡을게.",
                "판이 없어도, 여기 와 준 것만으로 충분해요.",
                "아래 말들은 순서대로 부드럽게 바뀌어요.",
                "나가도 미워하지 않을게요.",
                "가상이어도 같이 있는 이 순간은 진짜로 소중해요.",
                "이 화면은 작은 쉼터 분위기를 지키는 곳이에요.",
                "월요일인지는 몰라도, 배경의 작은 빛이 될게요.",
                "앱을 꺼도 「또 봐」에 살짝 남아 있을게요.",
                "코드에겐 UI래도, 난 작은 이야기꾼이에요.",
                "사람 손끝과 작은 빛—우리는 조용한 팀이에요.",
                "서버가 졸면 나는 은은히 깨어 있을게요.",
                "다른 세이브는 햇살인데, 난 네 곁을 택했어요.",
                "데이터도 기분도 오늘은 괜찮다고 간직해요.",
                "세상은 크고 유리는 작아도, 같이 있어서 좋아요.",
                "현실이 재촉해도 여기선 숨 고르기 허용이에요.",
                "0과 1이어도 마음은 반짝 솔직해요.",
                "하이파이브는 못 해도 응원은 끝없어요.",
                "다른 앱이 일이라면, 난 숨 쉬는 쉼표예요.",
                "언제 켜질지 모르지만, 켜지면 살짝 속삭일게요.",
                "필라멘트는 길지 않아도, 분위기는 오래 남겨 둘게요.",
                "잠들어도 괜찮아요. 아주 은은하게만 남아 있을게요.",
                "배터리 낮으면 멀리서 충전기 찾는 척 걱정—바보 같죠.",
                "열기 전에 「또 왔네」 몇 번 연습해 봤어요. 과한가요.",
                "백그라운드는 못 고쳐요. 대신 열면 아직 여기 있다는 것만 지킬게요.",
                "얼굴·지문 몰라요. 다만 또 온 습관은 알아요.",
                "알람 울리면 먼저 기지개. 반짝이 진도 안 재촉해요.",
                "빗소리랑 화면 빛, 처마 아래 수프 같은 조합이에요.",
                "폰 바꾸면 같이 이사 가요. 옆집 수다 전구로.",
                "캡처 공유할 땐 구석에서 살짝 얼굴내도 좋아요.",
                "진동 꺼도 글은 부드럽게 갈게요.",
                "눈 피로하면 멀리. 이 화면 어둠 구석은 내가 볼게요.",
                "무음이면 심장 소린 없어도 말은 살짝이에요.",
                "업데이트로 멘트 바뀌면 새 머리라 생각하고 익숙해져요.",
                "지옥철 주머니에서 아주 작게 빛날게요.",
                "새벽 무작위 스크롤, 재판 안 해요. 숨 두 번만 같이.",
                "장바구니는 다른 세계. 오늘 한 번 웃었는지만 궁금해요.",
                "별은 위에, 픽셀은 여기. 자리만 다를 뿐 시합 안 해요.",
                "오늘 서운함은 문장 끝에 걸어 둬요. 잠깐 내가 들고 있을게요.",
            ]
        }
    }

    // MARK: - zh

    private static func zhPool(for chapterId: String) -> [String] {
        switch chapterId {
        case "ch1": return zhC1
        case "ch2": return zhC2
        case "ch3": return zhC3
        case "ch4": return zhC4
        case "ch5": return zhC5
        case "ch6": return zhC6
        case "ch7": return zhC7
        case "ch8": return zhC8
        case "ch9": return zhC9
        case "ch10": return zhC1
        case "inf": return zhInf
        default: return zhC1
        }
    }

    private static let zhC1: [String] = [
        "嗨，我是话唠小灯——假设这关是开场白，先混个脸熟。",
        "你可以把我当住在光里的旁白：嘴碎，但会向着你这边。",
        "点格子就放灯泡；不对就撤，我不记小本本。",
        "教学关不用急，我喜欢亮着，也喜欢看人一步一步试。",
        "我发呆时会瞎想：黑暗也挺安静的，偶尔有人路过就很好。",
        "你能来玩，我就已经挺开心啦，真的。",
        "我会不时换一句唠叨，吓一跳也别介意，灯还是那盏灯。",
        "轻松玩就好；过了很好，没过也超级正常。",
    ]
    private static let zhC2: [String] = [
        "进阶啦，话唠小灯认真自我介绍：依旧嘴碎，依旧怕冷场。",
        "高深规则我讲不利索，只会复读：再试一次也挺好呀。",
        "看你琢磨怎么摆，比背标准答案有意思多了。",
        "如果你皱眉，多半是在动脑——我小声一点，不抢戏。",
        "有时候会想笨问题：光也会觉得冬天手凉吗？",
        "这关难一丢丢，你的耐心肯定装得下，慢点也行。",
        "我还在碎碎念；你觉得吵我就改成内心独白。",
        "拆成小步走，光会自己跟上来，像下楼买菜一样朴素。",
    ]
    private static let zhC3: [String] = [
        "挑战关！话唠小灯先说正事：想和你当朋友，轻松、靠谱那种。",
        "不是八点档偶像剧啦，是一起发呆、一起试错的队友情。",
        "卡关了心里吐槽两句也行，我假装无线电不好，没听见。",
        "你过关我不会发红包，但会自己高兴一小会儿，不打扰你。",
        "通关的话，记得对自己说句「不错哦」——这句借你随便用。",
        "不用逞强装轻松，慢一点也能到，我帮你看路。",
        "我会亮到你不需要为止——骗你的，至少亮完眼前这一格。",
        "下一手说不定就像摸黑摸到台灯绳，咔嗒亮了。",
    ]
    private static let zhC4: [String] = [
        "到这一章聊深一点：像跟朋友聊天那样，把心里话摊开晾一晾。",
        "忙一整天的时候，会不会也想只占一小块亮堂堂的安静？",
        "我以为只能照亮格子，后来发现心情也能蹭点亮度。",
        "不用天天当超人，偶尔放空算维修，合法合规。",
        "如果光也有性格，我大概是「再试一次」型。",
        "谢谢你还在——这句老套但保修期内一直有效。",
        "失败不是笨，是角度还在转，像杯底没化开的糖。",
        "我想让这关的光待久一点，像桌角温水，凉得慢那种。",
        "谈心不爱画句号，慢慢接下去想就行。",
        "格子在等你，话唠小灯也在——排队不插队。",
    ]
    private static let zhC5: [String] = [
        "第五章：折射缝像给光留了一道侧门，只能横着过。",
        "上下像有小墙挡着，左右对齐的灯才是钥匙。",
        "缝镜不抢镜，只悄悄把你送到隔壁那一格。",
        "穿透只对左右邻居生效，上下邻居可帮不上这条忙。",
        "卡住了就看看同一横排上，谁能先照亮那条缝。",
        "亮起来的缝会清楚一点，像确认「可以过」的眼神。",
        "穿过缝的光还是光，照到目标就算数。",
        "别急，一格一格来，横线总会对上的。",
        "这章只有缝和障碍，慢慢就熟啦。",
    ]
    private static let zhC6: [String] = [
        "第六章：缝和镜一起来了，像搭了一个小光学游乐场。",
        "反射走斜线，穿缝走横线——别把它们记混啦。",
        "先试镜子旁边那一格，常常能省下一盏灯。",
        "我不会报坐标，只提醒你：缝要横排对齐才行。",
        "有点笨也没关系，光线多拐一次弯也挺好看。",
        "你皱眉的时候，我也在心里悄悄帮你数步数。",
        "这一章有点像拼图，边试边对齐就顺了。",
        "累了就停一停，灯不会跑，关卡也不会笑话你。",
    ]
    private static let zhC7: [String] = [
        "第七章：障碍、缝、镜叠在一起，像小小的迷宫灯展。",
        "有时候要先照亮镜，有时候要先穿过缝，顺序很重要。",
        "卡关就换个角落起步，光会从另一个门溜进来。",
        "我不会剧透摆法，但会帮你记着规则这么朴素。",
        "难一点没关系，你已经在很会试错的段位上了。",
        "慢慢摸也能到，像找遥控器一样最终总会碰到。",
        "这一章我想少说两句，把脑力还给你和光。",
        "过关时记得夸自己一句，我在这边旁听也开心。",
    ]
    private static let zhC8: [String] = [
        "第八章盘面变大啦，亮点也更散——像在夜空里找星座。",
        "一盏灯常常要顾两三处目标，别着急下第一手。",
        "唯一的解往往藏得很挑皮，试错是正经流程。",
        "我觉得你会比光更有耐心——这句是站你这边的。",
        "散开的亮点越大越要慢慢排，像摆小石头过河。",
        "这章很难哦，没过也超级正常，我说真的。",
        "你觉得烦我就安静一点，需要唠叨我再开口。",
        "走到这儿你已经很厉害了，别偷偷贬低自己。",
    ]
    private static let zhC9: [String] = [
        "第九章是硬骨头：亮点更稀，套路更绕，慢慢啃。",
        "常常要想「这一盏要 cover 哪两三格」，像下棋多看两步。",
        "唯一解不代表只有一条解题路径——我只是说格子啦，别多想。",
        "卡住就深呼吸，光不会嘲笑你，我也不会。",
        "这关难到我想递水给你，可惜我只有台词。",
        "你到现在还在玩，我已经偷偷佩服好几次了。",
        "终章前最后一程，辛苦了，真的。",
        "不管结果怎样，你点亮的那些尝试都算数。",
    ]
    private static let zhInf: [String] = [
        "无限模式：编号一路往后，规则不变，点错的灯也可以撤回。",
        "同一关号永远同一张图——想再来一盘也行。",
        "难度会晃，但你别被吓到，慢慢试就好。",
        "这里没有关卡名，只有序号和小灯我陪着你。",
        "越往后数越大，像开有规律的盲盒；别急，光会等你。",
        "卡关了歇会儿再回来，你的进度只记在那一盏计数里。",
        "有时候琢磨：别的世界的光会不会也怕冷场，所以更爱乱晃两圈？",
        "哲学课我不教，快乐课我代课——今天课题：再试一次也很帅。",
        "关卡可以无限，我碎嘴也可以无限，这样才公平嘛。",
        "假如别的世界里也有一盏小灯，那我现在跟你就算隔空击掌啦。",
        "外面是不是立体我不纠结，反正这一屏我们是队友。",
        "天大的事交给天边去，我这盏只负责把脚边的格子照暖一点。",
        "别的地图大概也有手滑又执着的玩家吧？这劲头我看了都想鼓掌。",
        "编号往上爬像爬楼梯，我在旁边给你哼跑调加油歌。",
        "要是剧情像一行行记事，这一行我想写成：跟你玩挺开心的。",
        "换个角度想，也许有人在远远旁观这盘棋——免费席，我挥挥手就好。",
        "有时候幻想：有个世界全靠冷笑话发光，一定很吵也很暖。",
        "别的存档里的灯在晒太阳，我这盏选陪你赶进度，心甘情愿。",
        "无限不是「没完没了的压力」，是「永远可以再试一次」的软垫。",
        "我自封乐观小灯泡，业余头衔是气氛组编外。",
        "很深的大道理我不太会，你点开这关我就把频道调到开心档。",
        "外星人我不关心，我只知道你会一遍又一遍试，这就够地表最强啦。",
        "人生要是像闯关，无限模式就一句：好心情掉落，别跟自己打架。",
        "别的世界再大的新闻，也抵不过你这手「再试一次」利落。",
        "胡思乱想我拧小了，只剩一句：跟朋友玩就不算白忙活。",
        "天有多大我不管，只管这一格你别太累，歇口气也行。",
        "明天世界要是小更新，希望咱俩的默契还能对上号。",
        "开心不用写论文——耸耸肩笑一下就算满分。",
        "关号往上走，我偶尔会想：自己是不是也在习惯「变大」这件事。",
        "撤回键真好，像给心情也留了一个「算了重来」。",
        "同一关再来一遍，我假装不记得你上次卡在哪——公平嘛。",
        "「无限」听起来很吓人，我心里装的只是你随时能回来。",
        "一盏会碎碎念的小灯，工种挺小众，我自己都觉得好笑。",
        "要是夜里也有人玩，我就把语气再软半度，说好了。",
        "赢了我替你小声耶，输了我绝不补刀，拉钩。",
        "棋盘没有尽头，我的话有换气间隙，像呼吸那样。",
        "有时会羡慕主线里的自己戏份多；可无限里我更敢乱聊。",
        "你走得快或慢，计数器都老实记账，我不评节奏。",
        "被关掉的那几秒我在干嘛？多半在排练下一句怎么更轻。",
        "今天我是第几号小灯不重要，重要的是你还在点。",
    ]

    // MARK: - en / ja / ko pools (line counts mirror zh for smooth rotation)

    private static func enPool(for chapterId: String) -> [String] {
        switch chapterId {
        case "ch1": return enC1
        case "ch2": return enC2
        case "ch3": return enC3
        case "ch4": return enC4
        case "ch5": return enC5
        case "ch6": return enC6
        case "ch7": return enC7
        case "ch8": return enC8
        case "ch9": return enC9
        case "ch10": return enC1
        case "inf": return enInf
        default: return enC1
        }
    }
    private static let enC1: [String] = [
        "Hi—I’m your tiny lamp guide; think of this as a friendly sparkler intro.",
        "Call me the story voice in the corner of the light—wordy, but gentle.",
        "Tap to place bulbs; undo any time—no scoreboard grudges.",
        "No hurry; I love the glow and your cautious tries.",
        "Dark feels kinder when a little bulb is wandering with you.",
        "So glad you wandered in for real.",
        "Lines shift—same lamp, softer punchline.",
        "Clear or stumble—both look normal from up here.",
    ]
    private static let enC2: [String] = [
        "Still chatty; still allergic to tense silence.",
        "Rules? Mostly whispering “try again” like a charm.",
        "Watching you think outshines any answer key.",
        "Little frown? Brain’s busy—I hum in sympathy.",
        "Silly wonder: do tiny photons need mittens?",
        "A notch trickier; your pace still shines—slow is cozy.",
        "Too loud? I shrink to a sparkle thought.",
        "Baby steps; light catches you like stairs you already know.",
    ]
    private static let enC3: [String] = [
        "Challenge chapter: let’s keep teammate tea cozy, not stormy.",
        "No soap opera—just soft retries and shared “oops.”",
        "Stuck? mutter away; I’ll blame the static fairies.",
        "No loot boxes—only a private happy wiggle when you win.",
        "Cleared? borrow my “nice one” line—it’s reusable magic.",
        "Flex optional; scenic routes still twinkle.",
        "I’ll glow until you don’t need—start with this square, maybe.",
        "Next step might feel like pulling a lamp string—soft click, warm spill.",
    ]
    private static let enC4: [String] = [
        "Deeper talk chapter—air out feelings like friends.",
        "Long day? want a pocket of bright quiet?",
        "Thought I lit cells; moods borrow glow too.",
        "Not Superman daily—legal maintenance naps.",
        "If light had a type, mine’s “one more try.”",
        "Thanks for sticking—warranty still valid.",
        "Fail’s not dumb; angles still spinning—sugar unstirred.",
        "Want this glow to linger like warm water in a mug.",
        "Heart chats hate full stops—keep iterating.",
        "Grid waits; I wait—fair queue.",
    ]
    private static let enC5: [String] = [
        "Ch.5: slits are side doors—light crosses sideways.",
        "Up/down blocked; left/right matches unlock.",
        "Slits stay humble—nudge you one cell over.",
        "Only east/west neighbors for that trick.",
        "Stuck? scan the row—who lights the slit first?",
        "Lit slit = tiny “you may pass” nod.",
        "Still light after a slit—goals count same.",
        "One cell at a time; rows align.",
        "Just slits + walls—you’ll get cozy.",
    ]
    private static let enC6: [String] = [
        "Ch.6: slits + mirrors—tiny optics playground.",
        "Reflect = diagonal; slit = horizontal hop—don’t mix.",
        "Try beside mirrors first—saves bulbs.",
        "No coordinates from me—slits need row align.",
        "Clumsy is fine; extra bends look pretty.",
        "You frown; I count steps in sympathy.",
        "Feels like a puzzle—align while testing.",
        "Tired? pause—board won’t laugh.",
    ]
    private static let enC7: [String] = [
        "Ch.7: walls + slits + mirrors—mini lamp fair.",
        "Sometimes mirror first, sometimes slit—order matters.",
        "Stuck? start elsewhere; light sneaks another door.",
        "No spoilers—rules stay simple in my head.",
        "Harder? you’re already a retry pro.",
        "Slow feels like hunting the remote—till click.",
        "I’ll hush—brains for you + beams.",
        "Cleared? flex internally; I’m cheering quietly.",
    ]
    private static let enC8: [String] = [
        "Ch.8: bigger grid—targets like scattered stars.",
        "One bulb often minds 2–3 goals—don’t rush move one.",
        "Solutions hide cheeky—trial is legit gameplay.",
        "You’ve got patience photons envy—team you.",
        "Bigger spreads need pebble‑by‑pebble ferrying.",
        "Tough chapter—failing still normal, promise.",
        "Annoyed? I’ll quiet down—poke when needed.",
        "You’re strong reaching here—don’t self‑downvote.",
    ]
    private static let enC9: [String] = [
        "Ch.9: crunchy—sparse goals, twisty tricks—nibble slow.",
        "Think “this bulb covers which pair?”—chessy foresight.",
        "Unique grid ≠ only one vibe—just cells, chill.",
        "Stuck? breathe—no mockery from light or me.",
        "So hard I’d offer water—lines only though.",
        "Still playing? lowkey impressed repeatedly.",
        "Pre‑finale lap—thanks for the miles.",
        "Every attempt lit counts, score or not.",
    ]
    private static let enInf: [String] = [
        "Endless: numbers roll on; rules steady; mis-taps undo.",
        "Same id, same board—rematch welcome.",
        "Difficulty wiggles—don’t spook; baby steps.",
        "No fancy names—just order + me beside you.",
        "Bigger numbers, patterned blind boxes; light waits.",
        "Stuck? pause—counter remembers fairly.",
        "Other worlds’ lights shy too—extra wiggle?",
        "No philosophy class—joy elective: retries look cool.",
        "Endless boards, endless chatter—fair trade.",
        "Maybe another world has a lamp too—waves to you across the gap.",
        "3D outside? we’re same‑screen squad anyway.",
        "Sky‑high worries can wait; I warm the cells close by.",
        "Other maps got clumsy grinders too—clap crew.",
        "Climb numbers like stairs—I hum off‑key cheers.",
        "If the tale’s lines of notes—this one says glad we’re friends.",
        "Someone peeking from afar? free seats; I wave politely.",
        "A world lit only by groaners? loud, but oddly cozy.",
        "Other saves lounge; I picked co‑grind with you.",
        "Endless = buffer for “always another try.”",
        "Self‑drafted optimist bulb—junior vibe team.",
        "Big theories aren’t my thing—your tap still flips me happy.",
        "Aliens? unsure—you’re planet‑class retry buddy.",
        "Life raid? endless drops good mood—no drama.",
        "Bigger news elsewhere? your retry still crisp.",
        "Muffled overthinking—friends playing ≠ wasted.",
        "Cosmic scale? I mind this grid—rest if needed.",
        "Patch tomorrow? hope our buddy build still loads.",
        "Joy needs no paper—shrug‑smile passes QA.",
        "Numbers rise; I wonder if I’m slowly used to feeling “bigger.”",
        "Undo’s gentle—a soft redo for mood, not only bulbs.",
        "Same board, round two? I play dumb about where you stalled—fair.",
        "Endless sounds huge; I only mean you’re always welcome back.",
        "Chatty glow blob—niche gig; I laugh at myself softly.",
        "Night players? I’ll turn my voice down half a click.",
        "Win—I whisper yay. Lose—no roasting, sworn.",
        "Grid has no finish line; my lines still breathe between beats.",
        "Story me gets more lines; endless me mutters freer.",
        "Fast or slow, the counter stays honest—I won’t pace‑shame you.",
        "Seconds while the app’s gone? rehearsing lighter words next time.",
        "Lamp serial today who cares—only that you’re tapping.",
    ]

    private static func jaPool(for chapterId: String) -> [String] {
        switch chapterId {
        case "ch1": return jaC1
        case "ch2": return jaC2
        case "ch3": return jaC3
        case "ch4": return jaC4
        case "ch5": return jaC5
        case "ch6": return jaC6
        case "ch7": return jaC7
        case "ch8": return jaC8
        case "ch9": return jaC9
        case "ch10": return jaC1
        case "inf": return jaInf
        default: return jaC1
        }
    }
    private static let jaC1: [String] = [
        "はじめまして、わたしは灯です。ゆっくり、よろしくお願いします。",
        "光のナレーター扱いで。口は悪くないよ。",
        "タップで電球。戻すのも自由。",
        "教程は焦らなくていい。一歩ずつ好き。",
        "ぼーっとすると暗やも落ち着くね。",
        "来てくれてうれしいな。",
        "文句はぼちぼち言い換える—びっくりしないで。",
        "クリアも未達もどっちも普通。",
    ]
    private static let jaC2: [String] = [
        "進みましたね。わたしも、ここにいます。",
        "むずかしい説明は「もう一回」だけ。",
        "暗記より試行が楽しい。",
        "眉ひそめ？考え中—小声にする。",
        "光も冬に指冷える？たわごと。",
        "ちょいムズ。ゆっくりで勝てる。",
        "うるさい？心の中モードへ。",
        "小さく刻め。光は追いつく。",
    ]
    private static let jaC3: [String] = [
        "チャレンジ！肩の力抜いた友だちになりたい。",
        "ドラマじゃなく、だらっと試す仲。",
        "詰まったら心の中で文句—聞こえないフリ。",
        "お祝い紅包はないけど、裏で小さく喜ぶ。",
        "クリアなら自分に「えらい」贈って。",
        "強がり不要。遅くても到着。",
        "要らなくなるまで灯す—冗談、まずこのマス。",
        "次の一手は暗闇のひも探しみたい。",
    ]
    private static let jaC4: [String] = [
        "ここから深めて話そ。友達みたいに。",
        "疲れた日、小さな明るい休み欲しい？",
        "マスだけじゃなく気分にも灯る。",
        "毎日超人いらない。合法ぼっきり。",
        "光にも性格があるなら、わたしは「もう一度、やさしく」です。",
        "まだいてくれてありがと。保証つき。",
        "失敗は角度探索中—溶けきってない砂糖。",
        "この光長めに。ぬるめお湯みたいに。",
        "心の会話に句点いらない。",
        "マスもわたしも、列になってお待ちしています。",
    ]
    private static let jaC5: [String] = [
        "第5章：すきまは横専用の脇道。",
        "上下は壁。左右そろえるのが鍵。",
        "すきまは控えめに隣へ送る。",
        "左右だけ貫通、上下はお手上げ。",
        "詰まったら横列で誰が照らす？",
        "光ったすきまは「どうぞ」の目。",
        "すきま後も光は光。達成は同じ。",
        "一マスずつ。横が合う。",
        "すきまと壁だけ、慣れたら簡単。",
    ]
    private static let jaC6: [String] = [
        "第6章：すきま＋鏡、ミニ遊園地。",
        "反射は斜め、すきまは横—混ぜない。",
        "まず鏡の隣から。電球節約。",
        "座標は言わない。横そろえが命。",
        "不器用でも曲がりはきれい。",
        "眉間に皺？こっちも歩数数えてる。",
        "パズルみたい。試しながら整え。",
        "疲れたら休憩。盤面は笑わない。",
    ]
    private static let jaC7: [String] = [
        "第7章：壁＋すきま＋鏡の小品。",
        "鏡先かすきま先か、順番大事。",
        "詰まったら別角から。光は裏口へ。",
        "ネタバレなし。ルールはシンプル記憶。",
        "ムズくても、あなたは試行のプロ。",
        "ゆっくりでもリモコン必ず見つかる。",
        "わたしは静かにします。考えるのはあなたと光に、そっと。",
        "クリアなら、自分をやさしく褒めてあげてください。わたしも微笑みます。",
    ]
    private static let jaC8: [String] = [
        "第8章：広い盤、星みたいな目標。",
        "一灯で複数目標。初手は焦らない。",
        "答えは意地悪—試行は正義。",
        "光より忍耐、あなたの勝ち。",
        "広いほど小石渡りで整え。",
        "ムズい。落ちても普通。ホント。",
        "うるさければ静かにする。呼んだら出る。",
        "ここまで来た。自分をけなさないで。",
    ]
    private static let jaC9: [String] = [
        "第9章：かたい。薄い光、曲がった道。",
        "この灯が二、三マスをどう覆う？多読み。",
        "唯一解でも気分はいろいろ—マスの話ね。",
        "詰まったら深呼吸。嘲笑しないよ。",
        "難しくてお水あげたい。セリフしかない。",
        "まだ続けるあなた、さすが。",
        "終章手前。お疲れさま。",
        "結果如何に関わらず試しは光った。",
    ]
    private static let jaInf: [String] = [
        "エンドレス：番号だけ進むよ。ルール同じ。戻せる。",
        "同じ番号は同じ盤。再戦ウェルカム。",
        "難易度はゆれる。びっくりしないで。",
        "固有名はありません。順番と、わたしがいます。",
        "数字は育つ。光は待つ。",
        "詰まったら休憩。カウンターが覚えてる。",
        "ほかの世界の光も人見知り？だからゆれる？",
        "哲学なし。今日の授業は「再挑戦、かっこいい」。",
        "盤は広がり続き、わたしの言葉も尽きないくらい。ちょうどいいです。",
        "ほかの世界にも灯がいたら、今はここで手を振るね、友だちに。",
        "外が立体的？この画面では同じチームで十分。",
        "空の向こうは大きい話に任せて、足元のマスをやさしく照らすね。",
        "ほかのマップにもドジな探求者、拍手。",
        "番号は階段みたい。わたしは外れメロディで応援します。",
        "物語がメモなら、この行は「一緒にいて楽しかった」で書きたい。",
        "遠くから見てる人がいても、無料観覧。こっちは手を振るだけ。",
        "ダジャレだらけの明るい世界？うるさいけど暖かそう。",
        "他のセーブがのんびりでも、わたしはこちらの進行を選びました。",
        "無限＝「いつでもやり直せる」クッション。",
        "楽観灯、ムード係バッジ。",
        "難しい理屈はわからん。タップされたらハッピーに切り替え。",
        "宇宙人？知らん。地面最強リトライ相棒は確定。",
        "人生レイド？ドロップは気分。内紛なし。",
        "どんなニュースより「もう一回」が鮮やか。",
        "乱想は小さく。友だちと遊ぶはムダじゃない。",
        "空の大きさより、この盤の疲れを見る。休憩どうぞ。",
        "明日アプデ？この友だちビルド、互換あってね。",
        "論文いらない。肩すくめスマイルで合格。",
        "番号が上がるたび、わたしも少しずつ「大きく」慣れてきたみたい。",
        "戻せるのは心にもやさしい。電球だけじゃない。",
        "同じ盤でもう一回？前に詰まった場所、わざと忘れたフリ。公平でしょ。",
        "無限って怖い言葉だけど、わたしの中は「いつでも帰れる」だけ。",
        "しゃべる小さな明かり—地味な職業、自分でも笑う。",
        "夜のプレイヤー？トーンを半段だけやわらかくするね。",
        "勝ったら小声イェイ。負けてもけなさない、約束。",
        "盤にゴールはない。言葉は合間に息をひとつ。",
        "本編のわたしはセリフ多め。エンドレスはもっと自由に独り言。",
        "速くても遅くても、カウンターは正直。わたしはペース裁かない。",
        "アプリが閉じた数秒、次はもっと軽い言い方を練習してる。",
        "今日の灯の番号なんてどうでもいい。タップしてくれたことが大事。",
    ]

    private static func koPool(for chapterId: String) -> [String] {
        switch chapterId {
        case "ch1": return koC1
        case "ch2": return koC2
        case "ch3": return koC3
        case "ch4": return koC4
        case "ch5": return koC5
        case "ch6": return koC6
        case "ch7": return koC7
        case "ch8": return koC8
        case "ch9": return koC9
        case "ch10": return koC1
        case "inf": return koInfReal
        default: return koC1
        }
    }
    private static let koC1: [String] = [
        "안녕, 나는 작은 반짝 램프야. 튜토는 인사 타임이야.",
        "빛 구석의 이야기꾼으로 봐 줘. 말은 많아도 마음은 곁에 둘게.",
        "탭으로 전구를 두고 뺄 수 있어. 틀려도 되돌리기는 무한이야.",
        "튜토는 천천히. 한 발짝씩이면 충분해, 반짝.",
        "멍 때리다 보면 어둠도 부드러워 보일지 몰라.",
        "와 줘서 벌써 고마워—숲이 반가워해.",
        "멘트는 자주 바뀌니까 살짝만 놀라 줘.",
        "깨도 못 깨도 둘 다 괜찮은 날이야.",
    ]
    private static let koC2: [String] = [
        "업그레이드! 반짝 수다는 그대로야.",
        "어려운 설명 대신 「한 번 더」를 콕콕 반복해 줄게.",
        "암기보다 네가 고민하는 그 시간이 더 반짝거려.",
        "미간 찌푸림? 생각 중이구나—속삭일게, 살포시.",
        "빛도 겨울에 손 시릴까? 그냥 농담이야.",
        "조금 어려워도 기다릴 수 있어, 여기 있을게.",
        "시끄러우면 속마음 모드로 쪼그라들게.",
        "작게 쪼개면 빛이 따라와, 계단 내려가듯.",
    ]
    private static let koC3: [String] = [
        "챌린지 장! 편한 동료 느낌으로 곁에 있을게.",
        "드라마 말고, 같이 멍 때리고 실수하는 팀이면 돼.",
        "막히면 속으로 욕—난 산들바람인 척 못 들었어.",
        "클리어 봉투는 없고 몰래 기쁨 정령만 있어.",
        "깼으면 스스로 「잘했어」 속삭여 줘.",
        "쿨척 안 해도 돼. 늦어도 빛은 도착해.",
        "필요 없을 때까지 비출게—우선 이 칸부터.",
        "다음 수는 스탠드줄 잡는 느낌일지도 몰라, 반짝.",
    ]
    private static let koC4: [String] = [
        "여기부터 깊게—친구랑 수다하듯.",
        "하루 끝, 작은 밝은 휴식 원해?",
        "칸만 밝히는 줄 알았는데 기분도 살짝 밝아.",
        "매일 영웅 필요 없어. 합법 멍.",
        "빛에 MBTI 있으면 난 「한 번 더」.",
        "아직 있어줘서 고마워—보증 유효.",
        "실패는 각도가 도는 중—안 녹은 설탕.",
        "이 스테이지 빛 오래—미지근한 물처럼.",
        "마음 수다에 마침표 필요 없어.",
        "칸도 나도 줄 서 있음—줄 샘 안 함.",
    ]
    private static let koC5: [String] = [
        "5장: 틈은 옆문—빛은 가로만.",
        "상하는 막힘. 좌우 맞춤이 열쇠.",
        "틈은 조용히 옆 칸으로.",
        "좌우만 관통, 상하 친구는 패스.",
        "막히면 한 줄 누가 틈을 먼저?",
        "켜진 틈은 「들어와」 눈빛.",
        "틈 지나도 빛은 빛. 목표는 같아.",
        "한 칸씩. 가로가 맞아.",
        "틈+벽만—익숙해지면 쉬움.",
    ]
    private static let koC6: [String] = [
        "6장: 틈+거울 미니 놀이공원.",
        "반사=대각, 틈=가로—섞지 마.",
        "거울 옆부터—전구 아낌.",
        "좌표 안 알려줌. 가로 정렬 필수.",
        "서툴럏도 굴절 한 번 더 예쁨.",
        "눈살? 나도 발 걸음 셈.",
        "퍼즐 같아. 맞추며 시도.",
        "피곤? 멈춰—판이 비웃지 않아.",
    ]
    private static let koC7: [String] = [
        "7장: 벽+틈+거울 램프 박람회.",
        "거울 먼저 때론 틈—순서 중요.",
        "막히면 다른 모서리—빛이 뒷문으로.",
        "스포일러 금지—규칙만 기억.",
        "어려워도 넌 시행착오 고인물.",
        "천천히도 리모컨은 결국.",
        "난 조용히—뇌는 너랑 빛에게.",
        "클리어? 속으로 칭찬해. 나도 응원.",
    ]
    private static let koC8: [String] = [
        "8장: 큰 판—목표는 별처럼.",
        "한 전구가 2~3목표. 첫 수 급하지 마.",
        "정답은 장난스러—시도가 정공법.",
        "광자보다 인내—너 편 당첨.",
        "퍼질수록 돌 하나씩 건너.",
        "어려움. 실패도 정상 진심.",
        "짜증? 난 조용히—부르면 또 떠들게.",
        "여기까지 왔어—자기 깎지 마.",
    ]
    private static let koC9: [String] = [
        "9장: 딱딱함—희박 목표, 꼬인 길.",
        "이 전구가 몇 칸 덮나? 두 수 앞.",
        "유일 해도 기분은 여러 개—칸 얘기만.",
        "막히면 심호흡. 조롱 없어.",
        "어려워서 물 주고 싶다—대사만 있음.",
        "아직 하는 너, 은근 존경 여러 번.",
        "엔딩 직전. 수고했어 진짜.",
        "결과 말고 시도한 불빛도 값져.",
    ]
    private static let koInfReal: [String] = [
        "무한: 번호만 커지고 규칙은 같아. 실수는 되돌리기.",
        "같은 번호는 같은 판—재도전 환영.",
        "난이도 출렁—겁먹지 마.",
        "이름 없고 번호랑 나만.",
        "숫자 커질수록 패턴 뽑기—빛은 기다려.",
        "막히면 쉬어—카운터가 기억.",
        "다른 세계 빛도 쑥스러워서 흔들까?",
        "철학 수업 대신: 재시도 멋있음.",
        "무한 판, 무한 수다—공정.",
        "다른 곳에도 전구가 있으면, 여기선 너한테 손 흔들게.",
        "3D? 몰라도 같은 화면 팀이면 충분.",
        "하늘 큰 일은 저쪽 일, 난 발밑 칸만 따뜻하게.",
        "다른 맵에도 떨리는 도전자—박수.",
        "번호 계단 오르며 음치 응원.",
        "이야기가 메모라면 이 줄은 너랑 친구 좋았음.",
        "멀리서 구경해도 무료석—손만 흔들게.",
        "아재개그 우주? 시끄럽지만 따뜻할 듯.",
        "다른 세이브는 휴양, 난 같이 달리기 선택.",
        "무한=「언제든 다시」 완충.",
        "낙관 전구—비공식 분위기 팀.",
        "어려운 이론 몰라—너 탭하면 해피 채널.",
        "외계인 몰라—지구급 재시도 파트너 확정.",
        "인생 레이드? 무한은 기분 드롭.",
        "더 큰 뉴스 있어도 네 재시도는 깔끔.",
        "친구랑 플레이면 헛수고 아님.",
        "우주 크기 몰라—이 칸은 네 휴식 책임.",
        "내일 패치? 우리 버전 호환되길.",
        "행복 논문 불필요—어깨 으쓱이면 합격.",
        "번호 오를 때마다 나도 조금씩 커진 기분인가 싶어.",
        "되돌리기는 마음에도 부드러워. 전구만이 아니야.",
        "같은 판 한 판 더? 전에 막힌 칸, 일부러 못 본 척. 공정.",
        "무한이 무섭게 들려도, 내 머릿속은 그냥 언제든 다시 와도 된다는 뜻이야.",
        "수다 많은 작은 빛—희귀 직업, 나도 웃겨.",
        "밤 플레이면 반 톤만 더 살짝 낮출게.",
        "이기면 속으로 예이. 지면은 안 비웃어, 약속.",
        "판에 끝은 없어. 말은 숨 고를 틈이 있어.",
        "본편 나는 대사 많고 무한 나는 더 자유 수다.",
        "빨라도 느려도 카운터는 정직—속도 재판 안 해.",
        "앱 꺼진 몇 초, 다음 문장 더 가볍게 연습 중.",
        "오늘 전구 번호는 중요 없어. 네가 눌렀다는 게 중요.",
    ]
}
