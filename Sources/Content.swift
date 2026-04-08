import Foundation

enum ReminderContent {
    // Cute kaomoji faces — 60 unique faces for maximum variety
    static let kaomoji: [String] = [
        // Original set
        "(◕ᴗ◕✿)",
        "꒰ᐢ. .ᐢ꒱",
        "(´･ω･`)",
        "₍ᐢ..ᐢ₎",
        "(˶ᵔᵕᵔ˶)",
        "꒰˶• ༝ •˶꒱",
        "(ᵔ◡ᵔ)",
        "ʕ•ᴥ•ʔ",
        "(=^・ω・^=)",
        "( ˘ᵕ˘ )",
        "꒰ ꒡⌓꒡꒱",
        "(๑>◡<๑)",
        "(っ˘ω˘ς)",
        "꒰⑅ᵕ༚ᵕ꒱˖♡",
        "˶ᵔ ᵕ ᵔ˶",
        "(ノ◕ヮ◕)ノ",
        "ʕ·ᴥ·ʔ",
        "( ◜‿◝ )",
        "꒰ᐢ⸝⸝•༝•⸝⸝ᐢ꒱",
        "(⁰▿⁰)",
        "( ˶ˆᗜˆ˵ )",
        "ʕ •̀ o •́ ʔ",
        "( ᴜ ω ᴜ )",
        "꒰ ˶• ˕ •˶ ꒱",
        "( ◠‿◠ )",
        "₍ᐢ._.ᐢ₎",
        "(◕‿◕✿)",
        "( ˘︹˘ )",
        "ʕ￫ᴥ￩ʔ",
        "(=`ω´=)",

        // Cute cats
        "(=^･ｪ･^=)",
        "(＾• ω •＾)",
        "ฅ(•ㅅ•❀)ฅ",
        "ฅ(• ɪ •)ฅ",
        "(^˵◕ω◕˵^)",
        "( Φ ω Φ )",
        "(=^‥^=)",

        // Cute bears
        "ʕ ᵔᴥᵔ ʔ",
        "⊂(´(ェ)ˋ)⊃",
        "ʕ •̀ ω •́ ʔ",

        // Cute rabbits
        "／(≧ x ≦)＼",
        "／(˃ᆺ˂)＼",
        "૮ ˶ᵔ ᵕ ᵔ˶ ა",
        "૮₍ ˶• ༝ •˶ ₎ა",

        // Cute dogs
        "U・ᴥ・U",
        "V●ᴥ●V",

        // Happy / joyful faces
        "╰(*´︶`*)╯",
        "٩(◕‿◕｡)۶",
        "(o˘◡˘o)",
        "(´｡• ᵕ •｡`)",
        "(✧ω✧)",
        "(.❛ ᴗ ❛.)",
        "⸜( *ˊᵕˋ* )⸝",
        "(„• ᴗ •„)",
        "o( ❛ᴗ❛ )o",

        // Shy / sleepy
        "(*ﾉωﾉ)",
        "(⁄ ⁄•⁄ω⁄•⁄ ⁄)",
        "(∪｡∪)｡｡｡zzZ",

        // Sparkle / huggy
        "ଘ(੭ˊᵕˋ)੭* ੈ✩‧₊˚",
        "(っ ᵔ◡ᵔ)っ",
        "(っ╹ᆺ╹)っ",
    ]

    // Reminder messages - three styles mixed
    static let messages: [String] = [
        // 温柔关怀
        "去倒杯水吧，你值得这一小段路",
        "站起来伸个懒腰，骨头会感谢你的",
        "看看窗外，眼睛想念远方了",
        "深呼吸三次，把新鲜空气请进来",
        "转转脖子，它已经僵了好一会儿了",
        "去洗把脸吧，凉水会让你清醒",
        "起来走几步，血液需要流动一下",
        "闭上眼睛十秒钟，黑暗也是一种休息",
        "摸摸自己的肩膀，它辛苦了",
        "手腕转一转，它一直在默默工作",

        // 可爱卖萌
        "你的水杯在哭泣，它已经被冷落好久了",
        "椅子说它累了，让它也歇一会儿吧",
        "你的肩膀正在写投诉信",
        "眼睛提交了一份休假申请，请批准",
        "你的腿已经忘记自己是腿了",
        "脊椎发来一条消息：想直起来",
        "手指开了个小会，决定罢工五分钟",
        "你的身体发起了一个拉伸请求",
        "久坐警告⚠️ 屁股已经和椅子融为一体了",
        "你的膝盖正在策划一场起义",

        // 文艺哲学
        "世界在屏幕之外等你",
        "代码写不完，但这杯水可以喝完",
        "让血液流动起来，灵感会跟着来",
        "远处的风景不会自己跑到眼前",
        "身体是灵魂的容器，别忘了保养它",
        "暂停是为了更好的继续",
        "每一次休息都是对自己的温柔",
        "窗外的云不会为你停留",
        "给身体一点时间，它一直在等你",
        "起身的那一刻，世界会大一点",
    ]

    // Track recently used indices to avoid repeats
    private static var recentKaomojiIndices: [Int] = []
    private static var recentMessageIndices: [Int] = []
    private static let noRepeatCount = 15  // won't repeat within last 15

    static func random() -> (kaomoji: String, message: String) {
        let faceIdx = pickIndex(from: kaomoji.count, avoiding: &recentKaomojiIndices)
        let msgIdx = pickIndex(from: messages.count, avoiding: &recentMessageIndices)
        return (kaomoji[faceIdx], messages[msgIdx])
    }

    private static func pickIndex(from count: Int, avoiding recent: inout [Int]) -> Int {
        var idx: Int
        var attempts = 0
        repeat {
            idx = Int.random(in: 0..<count)
            attempts += 1
        } while recent.contains(idx) && attempts < 20

        recent.append(idx)
        if recent.count > noRepeatCount {
            recent.removeFirst()
        }
        return idx
    }
}
