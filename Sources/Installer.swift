import Foundation

enum Installer {
    static let plistLabel = "com.hhhz.daemon"
    static let plistPath = NSHomeDirectory() + "/Library/LaunchAgents/\(plistLabel).plist"
    static let installDir = NSHomeDirectory() + "/.local/bin"
    static let installPath = installDir + "/hhhz"

    static func install() {
        // Check if already installed (both plist AND binary must exist)
        if FileManager.default.fileExists(atPath: plistPath)
            && FileManager.default.fileExists(atPath: installPath) {
            print("")
            print("  \u{1F331} hhhz is already watching over you~")
            print("")
            return
        }

        // Copy binary to ~/.local/bin/ (skip if already running from there)
        let currentBinary = CommandLine.arguments[0]
        let resolvedPath = resolvePath(currentBinary)

        do {
            try FileManager.default.createDirectory(
                atPath: installDir,
                withIntermediateDirectories: true
            )

            if resolvedPath != installPath {
                // Remove old binary if exists
                if FileManager.default.fileExists(atPath: installPath) {
                    try FileManager.default.removeItem(atPath: installPath)
                }

                try FileManager.default.copyItem(atPath: resolvedPath, toPath: installPath)

                // Make executable
                let attrs: [FileAttributeKey: Any] = [.posixPermissions: 0o755]
                try FileManager.default.setAttributes(attrs, ofItemAtPath: installPath)
            }
        } catch {
            print("  \u{274C} Install failed: \(error.localizedDescription)")
            return
        }

        // Generate LaunchAgent plist
        let plistContent = Self.generatePlist()

        do {
            try plistContent.write(toFile: plistPath, atomically: true, encoding: .utf8)
        } catch {
            print("  \u{274C} Failed to write LaunchAgent: \(error.localizedDescription)")
            return
        }

        // Load the LaunchAgent using modern launchctl API
        let uid = getuid()
        let task = Process()
        task.launchPath = "/bin/launchctl"
        task.arguments = ["bootstrap", "gui/\(uid)", plistPath]
        task.launch()
        task.waitUntilExit()

        // Fallback to legacy load if bootstrap fails (older macOS)
        if task.terminationStatus != 0 {
            let fallback = Process()
            fallback.launchPath = "/bin/launchctl"
            fallback.arguments = ["load", plistPath]
            fallback.launch()
            fallback.waitUntilExit()
        }

        print("")
        print("  \u{1F331} hhhz installed! A cute bubble will remind you to rest~")
        print("  \u{2728} Auto-starts on boot. Take care of yourself!")
        print("")
        print("  Set interval: hhhz set <minutes>")
        print("  Uninstall:    hhhz stop")
        print("")
    }

    static func setInterval(minutes: Int) {
        guard FileManager.default.fileExists(atPath: plistPath) else {
            print("")
            print("  \u{274C} Not installed yet. Run `hhhz` to install first")
            print("")
            return
        }

        guard minutes > 0 else {
            print("")
            print("  \u{274C} Interval must be greater than 0 minutes")
            print("")
            return
        }

        // Rewrite plist with new interval
        let plistContent = generatePlist(intervalMinutes: minutes)
        do {
            try plistContent.write(toFile: plistPath, atomically: true, encoding: .utf8)
        } catch {
            print("  \u{274C} Failed to write: \(error.localizedDescription)")
            return
        }

        reloadDaemon()

        print("")
        print("  \u{2728} Reminder interval set to \(minutes) minutes~")
        print("")
    }

    static func upgrade() {
        guard FileManager.default.fileExists(atPath: plistPath),
              FileManager.default.fileExists(atPath: installPath) else {
            print("")
            print("  \u{274C} Not installed yet. Run `hhhz` to install first")
            print("")
            return
        }

        let currentBinary = CommandLine.arguments[0]
        let resolvedPath = resolvePath(currentBinary)

        // Must be run from a different path (e.g. newly downloaded binary)
        guard resolvedPath != installPath else {
            print("")
            print("  \u{274C} Please run upgrade from a newly downloaded binary")
            print("  \u{1F4A1} Upgrade: curl -fsSL https://raw.githubusercontent.com/CherrySun/hhhz/main/install.sh | sh")
            print("")
            return
        }

        // Preserve current interval setting
        let interval = currentInterval()

        do {
            // Replace binary
            if FileManager.default.fileExists(atPath: installPath) {
                try FileManager.default.removeItem(atPath: installPath)
            }
            try FileManager.default.copyItem(atPath: resolvedPath, toPath: installPath)

            let attrs: [FileAttributeKey: Any] = [.posixPermissions: 0o755]
            try FileManager.default.setAttributes(attrs, ofItemAtPath: installPath)
        } catch {
            print("  \u{274C} Upgrade failed: \(error.localizedDescription)")
            return
        }

        // Rewrite plist (preserving interval) and reload
        let plistContent = generatePlist(intervalMinutes: interval)
        do {
            try plistContent.write(toFile: plistPath, atomically: true, encoding: .utf8)
        } catch {
            print("  \u{274C} Failed to write plist: \(error.localizedDescription)")
            return
        }

        reloadDaemon()

        print("")
        print("  \u{2728} hhhz upgraded! Your settings are preserved~")
        print("")
    }

    static func uninstall() {
        // Unload LaunchAgent using modern launchctl API
        if FileManager.default.fileExists(atPath: plistPath) {
            let uid = getuid()
            let task = Process()
            task.launchPath = "/bin/launchctl"
            task.arguments = ["bootout", "gui/\(uid)/\(plistLabel)"]
            task.launch()
            task.waitUntilExit()

            // Fallback to legacy unload if bootout fails
            if task.terminationStatus != 0 {
                let fallback = Process()
                fallback.launchPath = "/bin/launchctl"
                fallback.arguments = ["unload", plistPath]
                fallback.launch()
                fallback.waitUntilExit()
            }

            try? FileManager.default.removeItem(atPath: plistPath)
        }

        // Remove binary
        if FileManager.default.fileExists(atPath: installPath) {
            try? FileManager.default.removeItem(atPath: installPath)
        }

        print("")
        print("  \u{1F44B} hhhz uninstalled. Remember to take care of yourself~")
        print("")
    }

    // MARK: - Helpers

    /// Generate LaunchAgent plist XML with optional interval override
    static func generatePlist(intervalMinutes: Int = 25) -> String {
        return """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" \
        "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
            <key>Label</key>
            <string>\(plistLabel)</string>
            <key>ProgramArguments</key>
            <array>
                <string>\(installPath)</string>
                <string>--daemon</string>
            </array>
            <key>EnvironmentVariables</key>
            <dict>
                <key>HHHZ_INTERVAL</key>
                <string>\(intervalMinutes)</string>
            </dict>
            <key>RunAtLoad</key>
            <true/>
            <key>KeepAlive</key>
            <true/>
        </dict>
        </plist>
        """
    }

    /// Reload the LaunchAgent daemon (bootout + bootstrap)
    static func reloadDaemon() {
        let uid = getuid()

        // Bootout (stop)
        let stop = Process()
        stop.launchPath = "/bin/launchctl"
        stop.arguments = ["bootout", "gui/\(uid)/\(plistLabel)"]
        stop.launch()
        stop.waitUntilExit()

        // Bootstrap (start)
        let start = Process()
        start.launchPath = "/bin/launchctl"
        start.arguments = ["bootstrap", "gui/\(uid)", plistPath]
        start.launch()
        start.waitUntilExit()

        // Fallback to legacy if bootstrap fails
        if start.terminationStatus != 0 {
            let fallback = Process()
            fallback.launchPath = "/bin/launchctl"
            fallback.arguments = ["load", plistPath]
            fallback.launch()
            fallback.waitUntilExit()
        }
    }

    /// Read current interval from plist, default 25
    static func currentInterval() -> Int {
        guard let data = FileManager.default.contents(atPath: plistPath),
              let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
              let env = plist["EnvironmentVariables"] as? [String: String],
              let val = env["HHHZ_INTERVAL"],
              let mins = Int(val), mins > 0 else {
            return 25
        }
        return mins
    }

    /// Resolve the path to an absolute, normalized path (handles relative paths and symlinks)
    private static func resolvePath(_ path: String) -> String {
        let url: URL
        if path.hasPrefix("/") {
            url = URL(fileURLWithPath: path)
        } else {
            let cwd = FileManager.default.currentDirectoryPath
            url = URL(fileURLWithPath: path, relativeTo: URL(fileURLWithPath: cwd))
        }
        // .standardized resolves ".." and "." components
        let standardized = url.standardizedFileURL.path
        // Try to resolve symlink, fall back to standardized path
        return (try? FileManager.default.destinationOfSymbolicLink(atPath: standardized)) ?? standardized
    }
}
