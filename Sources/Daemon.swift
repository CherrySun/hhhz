import AppKit

// MARK: - Daemon Delegate

class DaemonDelegate: NSObject, NSApplicationDelegate {
    private var idleTimer: Timer?
    private var activeSeconds: Double = 0
    private var lastCheckTime: CFTimeInterval = 0
    private var reminderWindow: ReminderWindow?

    // 45 minutes of continuous use triggers reminder
    private let triggerThreshold: Double = 45 * 60
    // 5 minutes idle resets the counter
    private let idleResetThreshold: Double = 5 * 60
    // Check interval
    private let checkInterval: TimeInterval = 30

    func applicationDidFinishLaunching(_ notification: Notification) {
        lastCheckTime = CACurrentMediaTime()
        startMonitoring()
    }

    private func startMonitoring() {
        idleTimer = Timer.scheduledTimer(withTimeInterval: checkInterval, repeats: true) { [weak self] _ in
            self?.checkIdleState()
        }
        RunLoop.current.add(idleTimer!, forMode: .common)
    }

    private func checkIdleState() {
        let now = CACurrentMediaTime()
        let elapsed = now - lastCheckTime
        lastCheckTime = now

        // Check multiple event types for accurate idle detection
        let mouseIdle = CGEventSource.secondsSinceLastEventType(
            .combinedSessionState, eventType: .mouseMoved)
        let keyIdle = CGEventSource.secondsSinceLastEventType(
            .combinedSessionState, eventType: .keyDown)
        let clickIdle = CGEventSource.secondsSinceLastEventType(
            .combinedSessionState, eventType: .leftMouseDown)
        let rightClickIdle = CGEventSource.secondsSinceLastEventType(
            .combinedSessionState, eventType: .rightMouseDown)
        let scrollIdle = CGEventSource.secondsSinceLastEventType(
            .combinedSessionState, eventType: .scrollWheel)

        let actualIdle = min(mouseIdle, keyIdle, clickIdle, rightClickIdle, scrollIdle)

        if actualIdle > idleResetThreshold {
            // User has been away, reset counter
            activeSeconds = 0
            return
        }

        if actualIdle < checkInterval {
            // User is active — add actual elapsed time, not fixed interval
            activeSeconds += elapsed
        }

        if activeSeconds >= triggerThreshold {
            showReminder()
            activeSeconds = 0
        }
    }

    private func showReminder() {
        guard reminderWindow == nil else { return }

        DispatchQueue.main.async { [weak self] in
            let window = ReminderWindow()
            self?.reminderWindow = window
            window.show { [weak self] in
                self?.reminderWindow = nil
            }
        }
    }
}
