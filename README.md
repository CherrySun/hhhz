# hhhz

一只住在你电脑里的小泡泡，会在你用电脑太久的时候飘出来，提醒你喝口水、伸个懒腰 ꒰ᐢ. .ᐢ꒱

A little bubble that lives in your Mac. When you've been at your computer too long, it floats out and gently reminds you to drink water and stretch~

```
    ╭～～～～～～～～～～～～～～～～～╮
  ～                                   ～
～          ꒰ᐢ. .ᐢ꒱                   ～
  ～                                   ～
～    你的水杯在哭泣，它被冷落好久了      ～
  ～                                   ～
    ╰～～～～～～～～～～～～～～～～～╯
```

## 它会做什么 · What it does

```
你开始工作 you start working
    │
    ├── 持续使用电脑 25 分钟 use your Mac for 25 min
    │   └── 💭 一个粉色泡泡从屏幕角落飘出来～ a pink bubble floats out~
    │       ├── 在屏幕上悠悠地漂来漂去 drifts around your screen
    │       ├── 30 秒后自己飘走了 disappears after 30s
    │       └── 或者戳一下它也会走 or poke it to dismiss
    │
    ├── 中途离开电脑 ≥ 5 分钟 leave for ≥ 5 min
    │   └── ⏱️ 计时自动重置 timer resets
    │
    └── 继续工作... keep working...
```

## 特性 · Features

- 🫧 **会呼吸的泡泡** breathing bubble — 白粉渐变，边缘微微颤动，像真的泡泡一样
- 🌊 **自由漂浮** free floating — 多层正弦波叠加，在屏幕上游来游去
- 💗 **有节奏感** rhythmic — 大小和透明度随呼吸节奏变化
- 🎲 **不重复** never repeats — 60 个颜文字 × 30 条提醒语，最近 15 次不重复
- 🧠 **很聪明** smart — 只在你真的连续用了 25 分钟才出现（可自定义）
- 👆 **不烦人** non-intrusive — 30 秒后自己消失，或者戳它一下
- 🪶 **超级轻** ultra light — 单个文件，零依赖，<1MB 内存

## 安装 · Install

```bash
curl -fsSL https://raw.githubusercontent.com/CherrySun/hhhz/main/install.sh | sh
```

就这样！一行命令，开机自启，无需任何配置～

That's it! One command, auto-starts on boot, zero config needed~

> 从源码编译 build from source：
> ```bash
> git clone https://github.com/CherrySun/hhhz.git
> cd hhhz && make install
> ```

## 升级 · Upgrade

```bash
curl -fsSL https://raw.githubusercontent.com/CherrySun/hhhz/main/install.sh | sh
```

同一行命令～已安装时会自动升级，保留你的设置。

Same command! Auto-upgrades when already installed, keeps your settings.

## 卸载 · Uninstall

```bash
hhhz stop
```

## 命令 · Commands

| 命令 Command | 说明 Description |
|------|------|
| `hhhz` | 安装 install |
| `hhhz test` | 立刻唤一个泡泡出来看看 summon a bubble right now |
| `hhhz set <分钟>` | 设置提醒间隔 set reminder interval (e.g. `hhhz set 30`) |
| `hhhz upgrade` | 升级到最新版 upgrade to latest |
| `hhhz stop` | 卸载 uninstall |

## 泡泡会说什么 · What the bubble says

三种风格随机混合 three styles randomly mixed：

**温柔型 gentle**
> 去倒杯水吧，你值得这一小段路

**卖萌型 cute**
> 你的水杯在哭泣，它已经被冷落好久了

**文艺型 poetic**
> 代码写不完，但这杯水可以喝完

搭配 60 个随机颜文字 with 60 random kaomoji：

`(◕ᴗ◕✿)` `꒰ᐢ. .ᐢ꒱` `ʕ•ᴥ•ʔ` `(˶ᵔᵕᵔ˶)` `ฅ(•ㅅ•❀)ฅ` `૮ ˶ᵔ ᵕ ᵔ˶ ა` ...

## 技术细节 · Under the hood

- **Swift**, zero dependencies
- **CAShapeLayer + CAGradientLayer**, full GPU compositing
- **CVDisplayLink** frame-synced animation
- **48-point Catmull-Rom spline** + 4-layer sine wave perturbation for organic bubble shape
- **3-layer sine/cosine wave** floating trajectory
- **Breathing**: sine-driven scale(1.0~1.03) + alpha(0.85~1.0), period 1.1s
- **Idle detection**: `CGEventSource.secondsSinceLastEventType` (mouse/keyboard/click/scroll)
- **Anti-repeat**: last 15 usage records tracked
- **Auto-start**: LaunchAgent (`~/Library/LaunchAgents/com.hhhz.daemon.plist`)
- **Memory safe**: `Unmanaged.passRetained` prevents dangling pointers in CVDisplayLink callback
- Single binary, 5 source files, ~800 lines

## 项目结构 · Structure

```
Sources/
├── main.swift           # entry point & command routing
├── Installer.swift      # install / upgrade / uninstall LaunchAgent
├── Daemon.swift         # daemon, idle detection
├── Content.swift        # kaomoji + reminder messages + anti-repeat
└── ReminderWindow.swift # bubble rendering + CALayer animation
```

## 系统要求 · Requirements

- macOS 13.0 (Ventura)+
- Accessibility permission (for keyboard/mouse activity detection)

## License

MIT
