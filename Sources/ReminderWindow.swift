import AppKit
import QuartzCore

// MARK: - Bubble Shape

enum BubbleShape {
    static func path(center: CGPoint, radiusX: CGFloat, radiusY: CGFloat, time: Double) -> CGPath {
        let cx = center.x
        let cy = center.y
        let wobble: CGFloat = 6.5
        let n = 48

        var pts: [CGPoint] = []
        for i in 0..<n {
            let a = (CGFloat(i) / CGFloat(n)) * 2 * .pi
            let t = CGFloat(time)
            let w = sin(a * 3 + t * 1.1) * wobble * 0.45
                  + sin(a * 5 + t * 0.7 + 1.5) * wobble * 0.22
                  + cos(a * 2 + t * 1.4 + 0.7) * wobble * 0.30
                  + sin(a * 7 + t * 0.5 + 2.3) * wobble * 0.12
            pts.append(CGPoint(x: cx + (radiusX + w) * cos(a),
                               y: cy + (radiusY + w) * sin(a)))
        }

        let path = CGMutablePath()
        for i in 0..<n {
            let p0 = pts[(i - 1 + n) % n], p1 = pts[i]
            let p2 = pts[(i + 1) % n], p3 = pts[(i + 2) % n]
            if i == 0 { path.move(to: p1) }
            path.addCurve(
                to: p2,
                control1: CGPoint(x: p1.x + (p2.x - p0.x) / 6, y: p1.y + (p2.y - p0.y) / 6),
                control2: CGPoint(x: p2.x - (p3.x - p1.x) / 6, y: p2.y - (p3.y - p1.y) / 6)
            )
        }
        path.closeSubpath()
        return path
    }
}

// MARK: - Bubble View (layer-backed, no draw(_:))

class BubbleView: NSView {
    static let bubbleRX: CGFloat = 260
    static let bubbleRY: CGFloat = 100
    static let pad: CGFloat = 90
    static var viewW: CGFloat { (bubbleRX + pad) * 2 }
    static var viewH: CGFloat { (bubbleRY + pad) * 2 }

    // Layers
    private let shadowShapeLayer = CAShapeLayer()
    private let gradientLayer = CAGradientLayer()
    private let maskShapeLayer = CAShapeLayer()
    private let highlightGradient = CAGradientLayer()
    private let highlightMask = CAShapeLayer()
    private let borderLayer = CAShapeLayer()
    private let innerBorderLayer = CAShapeLayer()

    // Text via NSTextField for subpixel antialiasing
    private let kaomojiField = NSTextField(labelWithString: "")
    private let messageField = NSTextField(labelWithString: "")

    // Cache last path for hitTest
    private var lastOuterPath: CGPath?

    init(kaomoji: String, message: String) {
        super.init(frame: CGRect(origin: .zero, size: CGSize(width: Self.viewW, height: Self.viewH)))
        wantsLayer = true
        layer?.masksToBounds = false

        setupLayers()
        setupText(kaomoji: kaomoji, message: message)
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupLayers() {
        guard let root = self.layer else { return }
        let c = CGPoint(x: bounds.midX, y: bounds.midY)
        let initialPath = BubbleShape.path(center: c, radiusX: Self.bubbleRX, radiusY: Self.bubbleRY, time: 0)

        // 1. Shadow layer
        shadowShapeLayer.path = initialPath
        shadowShapeLayer.fillColor = NSColor(red: 1.0, green: 0.82, blue: 0.86, alpha: 1.0).cgColor
        shadowShapeLayer.shadowColor = NSColor(red: 0.93, green: 0.50, blue: 0.60, alpha: 0.40).cgColor
        shadowShapeLayer.shadowOffset = CGSize(width: 0, height: -4)
        shadowShapeLayer.shadowRadius = 35
        shadowShapeLayer.shadowOpacity = 1.0
        shadowShapeLayer.strokeColor = nil
        root.addSublayer(shadowShapeLayer)

        // 2. Gradient fill (masked by bubble shape)
        maskShapeLayer.path = initialPath
        maskShapeLayer.fillColor = NSColor.white.cgColor

        gradientLayer.frame = bounds
        gradientLayer.colors = [
            NSColor(red: 1.0, green: 0.95, blue: 0.97, alpha: 0.96).cgColor,
            NSColor(red: 0.98, green: 0.82, blue: 0.87, alpha: 0.94).cgColor,
            NSColor(red: 0.95, green: 0.72, blue: 0.79, alpha: 0.92).cgColor,
        ]
        gradientLayer.locations = [0, 0.45, 1]
        gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.mask = maskShapeLayer
        root.addSublayer(gradientLayer)

        // 3. Highlight (top half shimmer)
        highlightMask.path = initialPath
        highlightMask.fillColor = NSColor.white.cgColor

        highlightGradient.frame = bounds
        highlightGradient.colors = [
            NSColor(white: 1, alpha: 0.40).cgColor,
            NSColor(white: 1, alpha: 0).cgColor,
        ]
        highlightGradient.locations = [0, 1]
        highlightGradient.startPoint = CGPoint(x: 0.5, y: 1)
        highlightGradient.endPoint = CGPoint(x: 0.5, y: 0.5)
        highlightGradient.mask = highlightMask
        root.addSublayer(highlightGradient)

        // 4. Outer border
        borderLayer.path = initialPath
        borderLayer.fillColor = nil
        borderLayer.strokeColor = NSColor(white: 1.0, alpha: 0.55).cgColor
        borderLayer.lineWidth = 2.0
        root.addSublayer(borderLayer)

        // 5. Inner border — derived from outer path via scale transform
        let innerScale = CGFloat(Self.bubbleRX - 4) / Self.bubbleRX
        let innerScaleY = CGFloat(Self.bubbleRY - 4) / Self.bubbleRY
        var innerXform = CGAffineTransform.identity
            .translatedBy(x: c.x, y: c.y)
            .scaledBy(x: innerScale, y: innerScaleY)
            .translatedBy(x: -c.x, y: -c.y)
        let innerPath = initialPath.copy(using: &innerXform)
        innerBorderLayer.path = innerPath
        innerBorderLayer.fillColor = nil
        innerBorderLayer.strokeColor = NSColor(white: 1.0, alpha: 0.20).cgColor
        innerBorderLayer.lineWidth = 1.0
        root.addSublayer(innerBorderLayer)

        lastOuterPath = initialPath

        // Disable implicit animations on all shape layers
        let noAnim: [String: CAAction] = ["path": NSNull(), "transform": NSNull(),
                                      "opacity": NSNull(), "position": NSNull()]
        for sl in [shadowShapeLayer, maskShapeLayer, highlightMask, borderLayer, innerBorderLayer] {
            sl.actions = noAnim
        }
        gradientLayer.actions = noAnim
        highlightGradient.actions = noAnim
        root.actions = noAnim
    }

    private func setupText(kaomoji: String, message: String) {
        let c = CGPoint(x: bounds.midX, y: bounds.midY)

        let shadow = NSShadow()
        shadow.shadowColor = NSColor(white: 1.0, alpha: 0.8)
        shadow.shadowBlurRadius = 4
        shadow.shadowOffset = NSSize(width: 0, height: -1)

        // Kaomoji
        kaomojiField.font = NSFont.systemFont(ofSize: 64, weight: .medium)
        kaomojiField.textColor = NSColor(red: 0.20, green: 0.16, blue: 0.18, alpha: 1.0)
        kaomojiField.shadow = shadow
        kaomojiField.alignment = .center
        kaomojiField.stringValue = kaomoji
        kaomojiField.backgroundColor = .clear
        kaomojiField.isBezeled = false
        kaomojiField.isEditable = false
        kaomojiField.sizeToFit()
        kaomojiField.frame = NSRect(
            x: c.x - kaomojiField.frame.width / 2,
            y: c.y - 2,
            width: kaomojiField.frame.width,
            height: kaomojiField.frame.height
        )
        addSubview(kaomojiField)

        // Message
        let msgW = Self.bubbleRX * 2 - 60
        let msgFont = NSFont(name: ".AppleSystemUIFontRounded-Medium", size: 22)
                    ?? NSFont.systemFont(ofSize: 22, weight: .medium)
        messageField.font = msgFont
        messageField.textColor = NSColor(red: 0.18, green: 0.14, blue: 0.16, alpha: 0.95)
        messageField.shadow = shadow
        messageField.alignment = .center
        messageField.stringValue = message
        messageField.backgroundColor = .clear
        messageField.isBezeled = false
        messageField.isEditable = false
        messageField.lineBreakMode = .byWordWrapping
        messageField.maximumNumberOfLines = 2
        messageField.preferredMaxLayoutWidth = msgW
        messageField.frame = NSRect(
            x: c.x - msgW / 2,
            y: c.y - 68,
            width: msgW,
            height: 60
        )
        addSubview(messageField)
    }

    /// Update bubble shape for given time — call from any thread (CALayer is thread-safe)
    func updateShape(time: Double) {
        let c = CGPoint(x: bounds.midX, y: bounds.midY)
        let bp = BubbleShape.path(center: c, radiusX: Self.bubbleRX, radiusY: Self.bubbleRY, time: time)

        // Inner border via scale transform (avoids computing a second full path)
        let innerScale = CGFloat(Self.bubbleRX - 4) / Self.bubbleRX
        let innerScaleY = CGFloat(Self.bubbleRY - 4) / Self.bubbleRY
        var innerXform = CGAffineTransform.identity
            .translatedBy(x: c.x, y: c.y)
            .scaledBy(x: innerScale, y: innerScaleY)
            .translatedBy(x: -c.x, y: -c.y)
        let ip = bp.copy(using: &innerXform)

        // Update all shape paths — no implicit animation (disabled in setup)
        shadowShapeLayer.path = bp
        maskShapeLayer.path = bp
        highlightMask.path = bp
        borderLayer.path = bp
        innerBorderLayer.path = ip
        lastOuterPath = bp
    }

    override func hitTest(_ point: NSPoint) -> NSView? {
        let local = convert(point, from: superview)
        if let p = lastOuterPath, p.contains(local) {
            return self
        }
        return nil
    }
}

// MARK: - Reminder Window

class ReminderWindow: NSWindow {
    private var displayLink: CVDisplayLink?
    private var dismissTimer: Timer?
    private var onDismiss: (() -> Void)?
    private var bubbleView: BubbleView?

    private var startTime: CFTimeInterval = 0
    private var baseOrigin: CGPoint = .zero

    // Entry
    private var isEntering = true
    private var entryStartX: CGFloat = 0
    private var entryTargetX: CGFloat = 0

    // Drift phase offset
    private var driftPhaseOffset: Double = 0

    // Retained self for CVDisplayLink safety
    private var retainedSelf: Unmanaged<ReminderWindow>?

    // Skip frame flag — prevents main.async backlog on high-refresh displays
    private var pendingFrame = false
    private let frameLock = NSLock()

    init() {
        let scr = (NSScreen.main ?? NSScreen.screens[0]).visibleFrame
        let w = BubbleView.viewW, h = BubbleView.viewH
        let tx = scr.maxX - w - 10
        let ty = scr.maxY - h - 40

        super.init(contentRect: NSRect(x: tx, y: ty, width: w, height: h),
                   styleMask: .borderless, backing: .buffered, defer: false)

        isOpaque = false
        backgroundColor = .clear
        level = .floating
        collectionBehavior = [.canJoinAllSpaces, .stationary]
        hasShadow = false
        ignoresMouseEvents = false
        isMovableByWindowBackground = false

        baseOrigin = CGPoint(x: tx, y: ty)
        entryTargetX = tx
        entryStartX = scr.maxX + 20

        setupContent()
    }

    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }

    private func setupContent() {
        let content = ReminderContent.random()
        let bubble = BubbleView(kaomoji: content.kaomoji, message: content.message)
        bubbleView = bubble

        let container = NSView(frame: NSRect(x: 0, y: 0, width: BubbleView.viewW, height: BubbleView.viewH))
        container.wantsLayer = true
        container.addSubview(bubble)
        self.contentView = container

        // Set layer anchor point to center for proper scale transforms
        if let l = container.layer {
            l.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            l.position = CGPoint(x: BubbleView.viewW / 2, y: BubbleView.viewH / 2)
        }

        let click = NSClickGestureRecognizer(target: self, action: #selector(handleClick))
        bubble.addGestureRecognizer(click)
    }

    @objc private func handleClick() { dismiss() }

    // MARK: - Show

    func show(onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
        var f = self.frame
        f.origin.x = entryStartX
        setFrame(f, display: false)
        alphaValue = 0
        orderFront(nil)

        isEntering = true
        driftPhaseOffset = 0

        startDisplayLink()
        startDismissTimer()
    }

    // MARK: - CVDisplayLink

    private func startDisplayLink() {
        startTime = CACurrentMediaTime()

        retainedSelf = Unmanaged.passRetained(self)

        var dl: CVDisplayLink?
        CVDisplayLinkCreateWithActiveCGDisplays(&dl)
        guard let link = dl else { retainedSelf?.release(); retainedSelf = nil; return }

        let ptr = retainedSelf!.toOpaque()
        CVDisplayLinkSetOutputCallback(link, { (_, _, _, _, _, ctx) -> CVReturn in
            guard let ctx = ctx else { return kCVReturnSuccess }
            let win = Unmanaged<ReminderWindow>.fromOpaque(ctx).takeUnretainedValue()
            win.tick()
            return kCVReturnSuccess
        }, ptr)

        CVDisplayLinkStart(link)
        displayLink = link
    }

    private func stopDisplayLink() {
        if let dl = displayLink {
            CVDisplayLinkStop(dl)
            displayLink = nil
        }
        retainedSelf?.release()
        retainedSelf = nil
    }

    // MARK: - Tick (called on CVDisplayLink thread)

    private func tick() {
        let total = CACurrentMediaTime() - startTime

        // 1. Update bubble shape directly (CALayer is thread-safe for property sets)
        bubbleView?.updateShape(time: total)

        // 2. Breath — fast period (1.1s), GPU-composited via layer transform
        let breathT = (sin(total * 2 * .pi / 1.1) + 1) / 2
        let scale = 1.0 + CGFloat(breathT) * 0.03
        let alpha = 0.85 + CGFloat(breathT) * 0.15

        // 3. Drift — large amplitude for visible floating movement
        let driftT = total - driftPhaseOffset
        let driftX = CGFloat(
            sin(driftT * 0.18) * 300
          + sin(driftT * 0.42 + 1.2) * 150
          + sin(driftT * 0.09 + 2.7) * 100
        )
        let driftY = CGFloat(
            cos(driftT * 0.15) * 220
          + cos(driftT * 0.38 + 0.8) * 120
          + cos(driftT * 0.11 + 1.9) * 80
        )

        // 4. Skip if previous main.async hasn't finished (prevents backlog on 120Hz+)
        frameLock.lock()
        if pendingFrame { frameLock.unlock(); return }
        pendingFrame = true
        frameLock.unlock()

        // 5. Window position + alpha must be set on main thread
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            defer {
                self.frameLock.lock()
                self.pendingFrame = false
                self.frameLock.unlock()
            }

            // Breath scale via layer transform (GPU, no draw call)
            self.contentView?.layer?.setAffineTransform(
                CGAffineTransform(scaleX: scale, y: scale))

            // Use fresh screen geometry in case resolution changed
            let scr = (NSScreen.main ?? NSScreen.screens[0]).visibleFrame
            var f = self.frame
            let m: CGFloat = 20

            if self.isEntering {
                let elapsed = CGFloat(total)
                let duration: CGFloat = 1.0
                var t = min(elapsed / duration, 1.0)
                if t >= 1.0 {
                    t = 1.0
                    self.isEntering = false
                    self.driftPhaseOffset = total
                    // Rebase origin to screen center area for better drift range
                    self.baseOrigin = CGPoint(
                        x: scr.midX - f.width / 2,
                        y: scr.midY - f.height / 2
                    )
                }
                let eased = 1.0 - (1.0 - t) * (1.0 - t) * (1.0 - t)

                f.origin.x = self.entryStartX + (self.entryTargetX - self.entryStartX) * eased
                let entryDriftY = CGFloat(cos(total * 0.15) * 220 + cos(total * 0.38 + 0.8) * 120)
                f.origin.y = self.baseOrigin.y + entryDriftY
                f.origin.y = max(scr.minY + m, min(f.origin.y, scr.maxY - f.height - m))
                self.setFrame(f, display: false)
                self.alphaValue = min(1.0, CGFloat(total) / 0.6)
            } else {
                var tx = self.baseOrigin.x + driftX
                var ty = self.baseOrigin.y + driftY
                tx = max(scr.minX + m, min(tx, scr.maxX - f.width - m))
                ty = max(scr.minY + m, min(ty, scr.maxY - f.height - m))
                f.origin.x = tx
                f.origin.y = ty
                self.setFrame(f, display: false)
                self.alphaValue = alpha
            }
        }
    }

    // MARK: - Dismiss

    private func startDismissTimer() {
        dismissTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: false) { [weak self] in
            _ = $0; self?.dismiss()
        }
        RunLoop.current.add(dismissTimer!, forMode: .common)
    }

    func dismiss() {
        dismissTimer?.invalidate(); dismissTimer = nil
        stopDisplayLink()

        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.8
            ctx.timingFunction = CAMediaTimingFunction(name: .easeIn)
            ctx.allowsImplicitAnimation = true
            self.animator().alphaValue = 0
            var f = self.frame
            f.origin.y += 30
            self.animator().setFrame(f, display: true)
            // Scale-down with proper CA animation
            self.contentView?.layer?.setAffineTransform(
                CGAffineTransform(scaleX: 0.85, y: 0.85))
        }) { [weak self] in
            self?.orderOut(nil)
            self?.onDismiss?()
        }
    }

    deinit { stopDisplayLink() }
}
