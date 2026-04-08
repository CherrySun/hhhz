import AppKit

// MARK: - Entry Point

@main
struct HhhzApp {
    static func main() {
        let args = CommandLine.arguments

        // hhhz stop → uninstall
        if args.count > 1 && args[1] == "stop" {
            Installer.uninstall()
            return
        }

        // hhhz set <N> → set interval
        if args.count > 2 && args[1] == "set" {
            if let minutes = Int(args[2]) {
                Installer.setInterval(minutes: minutes)
            } else {
                print("")
                print("  ❌ 请输入有效的分钟数，例如: hhhz set 30")
                print("")
            }
            return
        }

        // hhhz --daemon → run as background daemon (internal use)
        if args.count > 1 && args[1] == "--daemon" {
            runDaemon()
            return
        }

        // hhhz --show → show reminder immediately (internal testing)
        if args.count > 1 && args[1] == "--show" {
            showReminder()
            return
        }

        // hhhz → install
        Installer.install()
    }

    static func runDaemon() {
        let app = NSApplication.shared
        app.setActivationPolicy(.accessory) // no dock icon
        let delegate = DaemonDelegate()
        app.delegate = delegate
        app.run()
    }

    static func showReminder() {
        let app = NSApplication.shared
        app.setActivationPolicy(.accessory)
        let delegate = ShowOnceDelegate()
        app.delegate = delegate
        app.run()
    }
}

// MARK: - Show Once Delegate (for --show testing)

class ShowOnceDelegate: NSObject, NSApplicationDelegate {
    private var reminderWindow: ReminderWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        reminderWindow = ReminderWindow()
        reminderWindow?.show {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                NSApplication.shared.terminate(nil)
            }
        }
    }
}
