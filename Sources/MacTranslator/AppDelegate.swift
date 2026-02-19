import Cocoa
import ApplicationServices

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var dragMonitor: DragMonitor!
    private var isMonitoring = true
    private var toggleMenuItem: NSMenuItem!

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Force activation (bring to front/focus menu bar)
        NSApp.activate(ignoringOtherApps: true)

        // Check accessibility permission (Blocking)
        checkAccessibility()

        // Setup menu bar icon
        setupStatusBar()

        // Start drag monitor
        dragMonitor = DragMonitor { [weak self] text, point in
            self?.handleCapturedText(text, at: point)
        }
        dragMonitor.start()

        print("🚀 Mac Global Translator is running!")

        // Check for API key on first launch (with slight delay to ensure app is ready)
        if !KeychainManager.hasAPIKey {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.promptForAPIKey(isFirstLaunch: true)
            }
        } else {
            // Confirm startup if API key exists
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let alert = NSAlert()
                alert.messageText = "Mac Translator 실행됨"
                alert.informativeText = "상단 메뉴바의 🌐(지구본) 아이콘을 확인하세요.\n텍스트를 드래그하면 번역됩니다."
                alert.alertStyle = .informational
                alert.addButton(withTitle: "확인")
                alert.runModal()
            }
        }
    }

    private func checkAccessibility() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true] as CFDictionary
        let trusted = AXIsProcessTrustedWithOptions(options)
        
        if !trusted {
            // Force app to front
            NSApp.activate(ignoringOtherApps: true)
            
            let alert = NSAlert()
            alert.messageText = "접근성 권한 필요"
            alert.informativeText = "앱이 텍스트를 인식하려면 '접근성' 권한이 꼭 필요합니다.\n\n1. '설정 열기' 클릭\n2. 'MacTranslator' 체크 (이미 있다면 껐다 켜기)\n3. 앱 재실행"
            alert.alertStyle = .critical
            alert.addButton(withTitle: "설정 열기")
            alert.addButton(withTitle: "종료")
            
            let response = alert.runModal()
            if response == .alertFirstButtonReturn {
                let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
                NSWorkspace.shared.open(url)
            }
            NSApplication.shared.terminate(nil)
        }
    }

    private func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            // Use system icon if available (macOS 11+)
            if let image = NSImage(systemSymbolName: "globe", accessibilityDescription: "Mac Translator") {
                button.image = image
            } else {
                button.title = "🌐"
            }
            button.toolTip = "Mac Translator"
        }

        let menu = NSMenu()

        toggleMenuItem = NSMenuItem(title: "⏸ 일시정지", action: #selector(toggleMonitoring), keyEquivalent: "t")
        toggleMenuItem.target = self
        menu.addItem(toggleMenuItem)

        menu.addItem(NSMenuItem.separator())

        let apiKeyItem = NSMenuItem(title: "🔑 Claude API Key 설정", action: #selector(showAPIKeyDialog), keyEquivalent: "k")
        apiKeyItem.target = self
        menu.addItem(apiKeyItem)

        let openAIKeyItem = NSMenuItem(title: "🔊 OpenAI API Key 설정", action: #selector(showOpenAIKeyDialog), keyEquivalent: "o")
        openAIKeyItem.target = self
        menu.addItem(openAIKeyItem)

        menu.addItem(NSMenuItem.separator())

        let aboutItem = NSMenuItem(title: "ℹ️ Mac Translator v1.0", action: nil, keyEquivalent: "")
        aboutItem.isEnabled = false
        menu.addItem(aboutItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "종료", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    @objc private func toggleMonitoring() {
        isMonitoring.toggle()
        if isMonitoring {
            dragMonitor.start()
            toggleMenuItem.title = "⏸ 일시정지"
            statusItem.button?.title = "🌐"
        } else {
            dragMonitor.stop()
            toggleMenuItem.title = "▶️ 재개"
            statusItem.button?.title = "⏹"
        }
    }

    @objc private func showAPIKeyDialog() {
        promptForAPIKey(isFirstLaunch: false)
    }

    @objc private func showOpenAIKeyDialog() {
        promptForOpenAIKey()
    }

    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }

    private func promptForAPIKey(isFirstLaunch: Bool) {
        // Force app to foreground (needed for LSUIElement menu bar apps)
        NSApp.activate(ignoringOtherApps: true)

        let alert = NSAlert()
        alert.messageText = isFirstLaunch ? "🔑 Claude API Key 설정" : "🔑 API Key 변경"
        alert.informativeText = isFirstLaunch
            ? "Claude AI 번역을 사용하려면 API Key를 입력해주세요.\nKey는 macOS Keychain에 안전하게 저장됩니다."
            : "새로운 API Key를 입력해주세요.\nKey는 macOS Keychain에 안전하게 저장됩니다."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "저장")
        alert.addButton(withTitle: "취소")

        let inputField = NSTextField(frame: NSRect(x: 0, y: 0, width: 340, height: 24))
        inputField.placeholderString = "sk-ant-api..."
        inputField.font = NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)

        // If key exists, show masked hint
        if let existingKey = KeychainManager.getAPIKey() {
            let masked = String(existingKey.prefix(12)) + "..." + String(existingKey.suffix(4))
            inputField.placeholderString = masked
        }

        alert.accessoryView = inputField
        alert.window.initialFirstResponder = inputField

        let response = alert.runModal()

        if response == .alertFirstButtonReturn {
            let key = inputField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            if !key.isEmpty {
                // Save Claude API Key
                if KeychainManager.saveAPIKey(key) {
                    print("✅ Claude API Key saved")
                    showNotification(title: "✅ Claude API Key 저장 완료", message: "Claude AI 번역이 활성화되었습니다.")
                } else {
                    print("❌ Failed to save Claude API Key")
                    showNotification(title: "❌ 저장 실패", message: "API Key 저장에 실패했습니다.")
                }
            }
        }
    }

    private func promptForOpenAIKey() {
        // Force app to foreground
        NSApp.activate(ignoringOtherApps: true)

        let alert = NSAlert()
        alert.messageText = "🔊 OpenAI API Key 설정"
        alert.informativeText = "고품질 TTS를 사용하려면 OpenAI API Key를 입력해주세요.\nKey는 macOS Keychain에 안전하게 저장됩니다."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "저장")
        alert.addButton(withTitle: "취소")

        let inputField = NSTextField(frame: NSRect(x: 0, y: 0, width: 340, height: 24))
        inputField.placeholderString = "sk-proj-..."
        inputField.font = NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)

        // Pre-fill existing key (masked)
        if let existingKey = KeychainManager.getOpenAIKey() {
            let masked = String(existingKey.prefix(12)) + "..." + String(existingKey.suffix(4))
            inputField.placeholderString = masked
        }

        alert.accessoryView = inputField
        alert.window.initialFirstResponder = inputField

        let response = alert.runModal()

        if response == .alertFirstButtonReturn {
            let key = inputField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            if !key.isEmpty {
                if KeychainManager.saveOpenAIKey(key) {
                    print("✅ OpenAI API Key saved")
                    showNotification(title: "✅ OpenAI API Key 저장 완료", message: "고품질 TTS 기능이 활성화되었습니다.")
                } else {
                    showNotification(title: "❌ 저장 실패", message: "API Key 저장에 실패했습니다.")
                }
            }
        }
    }

    private func showNotification(title: String, message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .informational
        alert.addButton(withTitle: "확인")
        alert.runModal()
    }

    private func handleCapturedText(_ text: String, at point: NSPoint) {
        // Check API key first
        guard KeychainManager.hasAPIKey else {
            print("⚠️ No API key set")
            DispatchQueue.main.async { [weak self] in
                self?.promptForAPIKey(isFirstLaunch: true)
            }
            return
        }

        print("📝 Text captured: \(String(text.prefix(40)))...")
        TranslationPopup.showTranslateButton(text: text, near: point)
    }
}
