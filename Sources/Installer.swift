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
            print("  \u{1F331} 好好活着 已在守护你了，不用重复安装哦～")
            print("")
            return
        }

        // Copy binary to ~/.local/bin/
        let currentBinary = CommandLine.arguments[0]
        let resolvedPath = resolvePath(currentBinary)

        do {
            try FileManager.default.createDirectory(
                atPath: installDir,
                withIntermediateDirectories: true
            )

            // Remove old binary if exists
            if FileManager.default.fileExists(atPath: installPath) {
                try FileManager.default.removeItem(atPath: installPath)
            }

            try FileManager.default.copyItem(atPath: resolvedPath, toPath: installPath)

            // Make executable
            let attrs: [FileAttributeKey: Any] = [.posixPermissions: 0o755]
            try FileManager.default.setAttributes(attrs, ofItemAtPath: installPath)
        } catch {
            print("  \u{274C} 安装失败: \(error.localizedDescription)")
            return
        }

        // Generate LaunchAgent plist
        let plistContent = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
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
            <key>RunAtLoad</key>
            <true/>
            <key>KeepAlive</key>
            <true/>
            <key>StandardOutPath</key>
            <string>/tmp/hhhz.log</string>
            <key>StandardErrorPath</key>
            <string>/tmp/hhhz.err</string>
        </dict>
        </plist>
        """

        do {
            try plistContent.write(toFile: plistPath, atomically: true, encoding: .utf8)
        } catch {
            print("  \u{274C} 无法写入 LaunchAgent: \(error.localizedDescription)")
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
        print("  \u{1F331} 好好活着 已安装！每 45 分钟会温柔地提醒你休息。")
        print("  \u{2728} 从现在起，开机会自动守护你。")
        print("")
        print("  卸载: hhhz stop")
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
        print("  \u{1F44B} 好好活着 已卸载。记得自己好好休息哦。")
        print("")
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
