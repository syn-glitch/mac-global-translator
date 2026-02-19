import Cocoa

class TranslationPopup {
    private static var currentWindow: NSWindow?
    private static var closeTimer: Timer?

    // ============================================================
    // STEP 1: Show translate button after drag
    // ============================================================
    static func showTranslateButton(text: String, near point: NSPoint) {
        dismiss()

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 50, height: 50),
            styleMask: [.nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true

        let contentView = NSView(frame: NSRect(x: 0, y: 0, width: 50, height: 50))
        contentView.wantsLayer = true
        contentView.layer?.backgroundColor = NSColor(red: 0.07, green: 0.08, blue: 0.11, alpha: 0.95).cgColor
        contentView.layer?.cornerRadius = 25

        // Translate button
        let translateButton = NSButton(frame: NSRect(x: 0, y: 0, width: 50, height: 50))
        translateButton.title = "🌐"
        translateButton.font = NSFont.systemFont(ofSize: 24)
        translateButton.isBordered = false
        translateButton.target = PopupActionHandler.shared
        translateButton.action = #selector(PopupActionHandler.translateText)
        contentView.addSubview(translateButton)

        panel.contentView = contentView

        // Position near mouse cursor
        let buttonSize: CGFloat = 50
        var windowX = point.x - buttonSize / 2
        let windowY = point.y + 10

        // Screen boundary check
        if let screen = NSScreen.main {
            let screenFrame = screen.visibleFrame
            if windowX < screenFrame.minX + 5 { windowX = screenFrame.minX + 5 }
            if windowX + buttonSize > screenFrame.maxX - 5 { windowX = screenFrame.maxX - buttonSize - 5 }
        }

        panel.setContentSize(NSSize(width: buttonSize, height: buttonSize))
        panel.setFrameOrigin(NSPoint(x: windowX, y: windowY))
        panel.orderFrontRegardless()

        currentWindow = panel
        PopupActionHandler.shared.window = panel
        PopupActionHandler.shared.originalText = text
        PopupActionHandler.shared.cursorPoint = point

        // Auto-dismiss after 5 seconds if not clicked
        closeTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { _ in
            dismiss()
        }
    }

    // ============================================================
    // STEP 2: Show translation result after button click
    // ============================================================
    static func showResult(original: String, translated: String, near point: NSPoint) {
        dismiss()

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 340, height: 10),
            styleMask: [.nonactivatingPanel, .titled, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.isMovableByWindowBackground = true
        panel.backgroundColor = NSColor(red: 0.07, green: 0.08, blue: 0.11, alpha: 0.95)
        panel.hasShadow = true

        // Content view
        let contentView = NSView()
        contentView.wantsLayer = true
        contentView.layer?.backgroundColor = NSColor(red: 0.07, green: 0.08, blue: 0.11, alpha: 1.0).cgColor
        contentView.layer?.cornerRadius = 12

        // Header
        let header = NSTextField(labelWithString: "🌐 Mac Translator")
        header.font = NSFont.systemFont(ofSize: 12, weight: .bold)
        header.textColor = NSColor(red: 0.42, green: 0.36, blue: 0.91, alpha: 1.0)
        header.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(header)

        // Original text (truncated)
        let origLimit = 80
        let origText = original.count > origLimit ? String(original.prefix(origLimit)) + "..." : original
        let originalLabel = NSTextField(wrappingLabelWithString: "📝 \(origText)")
        originalLabel.font = NSFont.systemFont(ofSize: 10)
        originalLabel.textColor = NSColor(red: 0.58, green: 0.60, blue: 0.66, alpha: 1.0)
        originalLabel.preferredMaxLayoutWidth = 300
        originalLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(originalLabel)

        // Separator
        let separator = NSBox()
        separator.boxType = .separator
        separator.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(separator)

        // Translated text
        let translatedLabel = NSTextField(wrappingLabelWithString: translated)
        translatedLabel.font = NSFont.systemFont(ofSize: 13, weight: .medium)
        translatedLabel.textColor = NSColor(red: 0.91, green: 0.92, blue: 0.94, alpha: 1.0)
        translatedLabel.preferredMaxLayoutWidth = 300
        translatedLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(translatedLabel)

        // Copy button
        let copyButton = NSButton(title: "📋 복사", target: nil, action: nil)
        copyButton.bezelStyle = .rounded
        copyButton.font = NSFont.systemFont(ofSize: 11, weight: .medium)
        copyButton.translatesAutoresizingMaskIntoConstraints = false
        copyButton.target = PopupActionHandler.shared
        copyButton.action = #selector(PopupActionHandler.copyText(_:))
        PopupActionHandler.shared.translatedText = translated
        contentView.addSubview(copyButton)

        // Bottom Close button
        let actionCloseButton = NSButton(title: "닫기", target: nil, action: nil)
        actionCloseButton.bezelStyle = .rounded
        actionCloseButton.font = NSFont.systemFont(ofSize: 11, weight: .medium)
        actionCloseButton.translatesAutoresizingMaskIntoConstraints = false
        actionCloseButton.target = PopupActionHandler.shared
        actionCloseButton.action = #selector(PopupActionHandler.closePopup)
        contentView.addSubview(actionCloseButton)

        // Close button (Top Right "X")
        let closeButton = NSButton(title: "✕", target: nil, action: nil)
        closeButton.bezelStyle = .rounded
        closeButton.font = NSFont.systemFont(ofSize: 10)
        closeButton.isBordered = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.target = PopupActionHandler.shared
        closeButton.action = #selector(PopupActionHandler.closePopup)
        contentView.addSubview(closeButton)

        // Layout constraints
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            closeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),

            header.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            header.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            originalLabel.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 6),
            originalLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            originalLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            separator.topAnchor.constraint(equalTo: originalLabel.bottomAnchor, constant: 8),
            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            translatedLabel.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 8),
            translatedLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            translatedLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            copyButton.topAnchor.constraint(equalTo: translatedLabel.bottomAnchor, constant: 10),
            copyButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            copyButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),

            actionCloseButton.centerYAnchor.constraint(equalTo: copyButton.centerYAnchor),
            actionCloseButton.trailingAnchor.constraint(equalTo: copyButton.leadingAnchor, constant: -8),
        ])

        panel.contentView = contentView

        // Calculate position near mouse
        contentView.layoutSubtreeIfNeeded()
        let windowSize = contentView.fittingSize
        let windowWidth = max(windowSize.width, 340)
        let windowHeight = max(windowSize.height, 100)

        var windowX = point.x - windowWidth / 2
        let windowY = point.y + 15

        if let screen = NSScreen.main {
            let screenFrame = screen.visibleFrame
            if windowX < screenFrame.minX + 10 { windowX = screenFrame.minX + 10 }
            if windowX + windowWidth > screenFrame.maxX - 10 { windowX = screenFrame.maxX - windowWidth - 10 }
        }

        panel.setContentSize(NSSize(width: windowWidth, height: windowHeight))
        panel.setFrameOrigin(NSPoint(x: windowX, y: windowY))
        panel.orderFrontRegardless()

        currentWindow = panel
        PopupActionHandler.shared.window = panel

        // Auto-close after 10 seconds
        closeTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { _ in
            dismiss()
        }
    }

    // ============================================================
    // Show loading state while translating
    // ============================================================
    static func showLoading(near point: NSPoint) {
        dismiss()

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 120, height: 40),
            styleMask: [.nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true

        let contentView = NSView(frame: NSRect(x: 0, y: 0, width: 120, height: 40))
        contentView.wantsLayer = true
        contentView.layer?.backgroundColor = NSColor(red: 0.07, green: 0.08, blue: 0.11, alpha: 0.95).cgColor
        contentView.layer?.cornerRadius = 20

        let label = NSTextField(labelWithString: "⏳ 번역 중...")
        label.font = NSFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = NSColor(red: 0.91, green: 0.92, blue: 0.94, alpha: 1.0)
        label.frame = NSRect(x: 15, y: 10, width: 100, height: 20)
        contentView.addSubview(label)

        panel.contentView = contentView

        var windowX = point.x - 60
        let windowY = point.y + 10

        if let screen = NSScreen.main {
            let screenFrame = screen.visibleFrame
            if windowX < screenFrame.minX + 5 { windowX = screenFrame.minX + 5 }
            if windowX + 120 > screenFrame.maxX - 5 { windowX = screenFrame.maxX - 125 }
        }

        panel.setContentSize(NSSize(width: 120, height: 40))
        panel.setFrameOrigin(NSPoint(x: windowX, y: windowY))
        panel.orderFrontRegardless()

        currentWindow = panel
    }

    static func dismiss() {
        closeTimer?.invalidate()
        closeTimer = nil
        currentWindow?.close()
        currentWindow = nil
    }
}

// Helper class for button actions
class PopupActionHandler: NSObject {
    static let shared = PopupActionHandler()
    var translatedText: String = ""
    var originalText: String = ""
    var cursorPoint: NSPoint = .zero
    weak var window: NSWindow?

    @objc func translateText() {
        let text = originalText
        let point = cursorPoint

        print("⌛ Translating: \(String(text.prefix(40)))...")

        // Show loading indicator
        TranslationPopup.showLoading(near: point)

        // Perform translation
        TranslationService.translate(text: text) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let translated):
                    print("✅ Result: \(String(translated.prefix(40)))...")
                    TranslationPopup.showResult(
                        original: text,
                        translated: translated,
                        near: point
                    )
                case .failure(let error):
                    print("❌ Translation error: \(error.localizedDescription)")
                    TranslationPopup.showResult(
                        original: text,
                        translated: "번역 오류: \(error.localizedDescription)",
                        near: point
                    )
                }
            }
        }
    }

    @objc func copyText(_ sender: Any?) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(translatedText, forType: .string)

        if let button = sender as? NSButton {
            let original = button.title
            button.title = "✅ 복사됨!"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                button.title = original
            }
        }
    }

    @objc func closePopup() {
        TranslationPopup.dismiss()
    }
}
