# hhhz

一只住在你电脑里的小泡泡，会在你用电脑太久的时候飘出来，轻轻叫一声，提醒你喝口水、伸个懒腰 ꒰ᐢ. .ᐢ꒱

```
    ╭～～～～～～～～～～～～～～～～～╮
  ～                                   ～
～          ꒰ᐢ. .ᐢ꒱                   ～
  ～                                   ～
～    你的水杯在哭泣，它被冷落好久了      ～
  ～                                   ～
    ╰～～～～～～～～～～～～～～～～～╯
```

## 它会做什么

```
你开始工作
    │
    ├── 持续使用电脑 25 分钟
    │   └── 💭 一个粉色泡泡从屏幕角落飘出来～
    │       ├── 发出一声轻轻的小叫声
    │       ├── 在屏幕上悠悠地漂来漂去
    │       ├── 30 秒后自己飘走了
    │       └── 或者戳一下它也会走
    │
    ├── 中途离开电脑 ≥ 5 分钟
    │   └── ⏱️ 计时自动重置
    │
    └── 继续工作...
```

## 特性

- 🫧 **会呼吸的泡泡** — 白粉渐变，边缘随呼吸颤动，膨胀时边框变亮变粗
- 🔊 **随机小音效** — 猫叫、冒泡、叮咚、boop，每次随机一种，轻轻的
- 🌊 **自由漂浮** — 多层正弦波叠加，在屏幕上游来游去
- 🎲 **不重复** — 60 个颜文字 × 30 条提醒语，最近 15 次不重复
- 🧠 **很聪明** — 只在你真的连续用了 25 分钟才出现（可自定义）
- 👆 **不烦人** — 30 秒后自己消失，或者戳它一下
- 🪶 **超级轻** — 单个文件，零依赖，<1MB 内存

## 安装

```bash
curl -fsSL https://raw.githubusercontent.com/CherrySun/hhhz/main/install.sh | sh
```

就这样！一行命令，开机自启，无需任何配置～

> 从源码编译：
> ```bash
> git clone https://github.com/CherrySun/hhhz.git
> cd hhhz && make install
> ```

## 升级

```bash
curl -fsSL https://raw.githubusercontent.com/CherrySun/hhhz/main/install.sh | sh
```

同一行命令～已安装时会自动升级，保留你的设置。

## 卸载

```bash
hhhz stop
```

## 命令

| 命令 | 说明 |
|------|------|
| `hhhz` | 安装 |
| `hhhz test` | 立刻唤一个泡泡出来看看 |
| `hhhz set <分钟>` | 设置提醒间隔（如 `hhhz set 30`） |
| `hhhz upgrade` | 升级到最新版 |
| `hhhz stop` | 卸载 |

## 泡泡会说什么

三种风格随机混合：

**温柔型** — 去倒杯水吧，你值得这一小段路

**卖萌型** — 你的水杯在哭泣，它已经被冷落好久了

**文艺型** — 代码写不完，但这杯水可以喝完

搭配 60 个随机颜文字：`(◕ᴗ◕✿)` `꒰ᐢ. .ᐢ꒱` `ʕ•ᴥ•ʔ` `(˶ᵔᵕᵔ˶)` `ฅ(•ㅅ•❀)ฅ` `૮ ˶ᵔ ᵕ ᵔ˶ ა` ...

---

# English

A little bubble that lives in your Mac. When you've been at your computer too long, it floats out with a tiny sound and gently reminds you to drink water and stretch~

## What it does

```
you start working
    │
    ├── use your Mac for 25 min
    │   └── 💭 a pink bubble floats out from the corner~
    │       ├── makes a soft little sound
    │       ├── drifts around your screen
    │       ├── disappears after 30s
    │       └── or poke it to dismiss
    │
    ├── leave for ≥ 5 min
    │   └── ⏱️ timer resets
    │
    └── keep working...
```

## Features

- 🫧 **Breathing bubble** — white-pink gradient, edges wobble with breathing rhythm, border pulses brighter
- 🔊 **Cute sounds** — meow, bubble pop, twinkle, boop — a random one each time, very gentle
- 🌊 **Free floating** — multi-layer sine wave trajectory, drifts across your screen
- 🎲 **Never repeats** — 60 kaomoji × 30 messages, no repeats within last 15
- 🧠 **Smart** — only appears after 25 min of continuous use (customizable)
- 👆 **Non-intrusive** — auto-disappears after 30s, or click to dismiss
- 🪶 **Ultra light** — single binary, zero dependencies, <1MB memory

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/CherrySun/hhhz/main/install.sh | sh
```

That's it! One command, auto-starts on boot, zero config~

> Build from source:
> ```bash
> git clone https://github.com/CherrySun/hhhz.git
> cd hhhz && make install
> ```

## Upgrade

```bash
curl -fsSL https://raw.githubusercontent.com/CherrySun/hhhz/main/install.sh | sh
```

Same command! Auto-upgrades when already installed, keeps your settings.

## Uninstall

```bash
hhhz stop
```

## Commands

| Command | Description |
|---------|-------------|
| `hhhz` | Install and start |
| `hhhz test` | Summon a bubble right now |
| `hhhz set <min>` | Set reminder interval (e.g. `hhhz set 30`) |
| `hhhz upgrade` | Upgrade to latest version |
| `hhhz stop` | Uninstall |

## What the bubble says

Three styles randomly mixed:

**Gentle** — Go pour yourself some water, you deserve that little walk

**Cute** — Your water cup is crying, it's been neglected for too long

**Poetic** — You can't finish all the code, but you can finish this glass of water

Paired with 60 random kaomoji: `(◕ᴗ◕✿)` `꒰ᐢ. .ᐢ꒱` `ʕ•ᴥ•ʔ` `(˶ᵔᵕᵔ˶)` `ฅ(•ㅅ•❀)ฅ` `૮ ˶ᵔ ᵕ ᵔ˶ ა` ...

---

## Under the hood

- **Swift**, zero dependencies
- **CAShapeLayer + CAGradientLayer**, full GPU compositing
- **CVDisplayLink** frame-synced animation
- **48-point Catmull-Rom spline** + 4-layer sine perturbation for organic bubble shape
- **Breathing**: wobble amplitude (6.5→11.5) + border width/opacity + scale(1.0→1.06) + alpha(0.82→1.0), period 1.1s
- **Sound**: `AVAudioEngine` synthesized PCM — four cute sounds generated from sine waves, zero audio files
- **Idle detection**: `CGEventSource.secondsSinceLastEventType` (mouse/keyboard/click/scroll)
- **Anti-repeat**: last 15 usage records tracked
- **Auto-start**: LaunchAgent (`~/Library/LaunchAgents/com.hhhz.daemon.plist`)
- **Memory safe**: `Unmanaged.passRetained` prevents dangling pointers in CVDisplayLink callback
- Single binary, 6 source files, ~1000 lines

## Structure

```
Sources/
├── main.swift           # entry point & command routing
├── Installer.swift      # install / upgrade / uninstall LaunchAgent
├── Daemon.swift         # daemon, idle detection
├── Content.swift        # kaomoji + reminder messages + anti-repeat
├── CuteSound.swift      # synthesized cute sound effects
└── ReminderWindow.swift # bubble rendering + CALayer animation
```

## Requirements

- macOS 13.0 (Ventura)+
- Accessibility permission (for keyboard/mouse activity detection)

## License

MIT
