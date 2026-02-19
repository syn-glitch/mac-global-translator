import Cocoa
import Carbon.HIToolbox

class DragMonitor {
    typealias TextCapturedHandler = (String, NSPoint) -> Void

    private let onTextCaptured: TextCapturedHandler
    private var mouseDownLocation: NSPoint?
    private var localMonitor: Any?
    private var globalMonitor: Any?
    private var isRunning = false

    init(onTextCaptured: @escaping TextCapturedHandler) {
        self.onTextCaptured = onTextCaptured
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true

        print("🔵 Attempting to start DragMonitor...")

        // Monitor global mouse events (outside our app)
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .leftMouseUp]) { [weak self] event in
            // print("🖱 Global mouse event: \(event.type)")
            self?.handleMouseEvent(event)
        }

        // Also monitor local events (inside our app, if any window)
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .leftMouseUp]) { [weak self] event in
            // print("🖱 Local mouse event: \(event.type)")
            self?.handleMouseEvent(event)
            return event
        }

        if globalMonitor != nil {
            print("✅ Global monitor registered")
        } else {
            print("❌ Failed to register global monitor (Check Accessibility Permissions)")
        }

        print("👂 DragMonitor started")
    }

    func stop() {
        if let global = globalMonitor {
            NSEvent.removeMonitor(global)
            globalMonitor = nil
        }
        if let local = localMonitor {
            NSEvent.removeMonitor(local)
            localMonitor = nil
        }
        isRunning = false
        print("⏹ DragMonitor stopped")
    }

    private func handleMouseEvent(_ event: NSEvent) {
        switch event.type {
        case .leftMouseDown:
            mouseDownLocation = NSEvent.mouseLocation
            // print("⬇️ Mouse Down at \(String(describing: mouseDownLocation))")

        case .leftMouseUp:
            guard let startLocation = mouseDownLocation else { return }
            let endLocation = NSEvent.mouseLocation
            mouseDownLocation = nil
            // print("⬆️ Mouse Up at \(endLocation)")

            // Calculate drag distance
            let dx = endLocation.x - startLocation.x
            let dy = endLocation.y - startLocation.y
            let distance = sqrt(dx * dx + dy * dy)

            // Only trigger if drag distance > 10px
            if distance > 10 {
                print("✨ Drag detected (distance: \(Int(distance)))")
                handleDragEnd(at: endLocation)
            } else {
                // print("Pass: Click only (distance: \(Int(distance)))")
            }

        default:
            break
        }
    }

    private func handleDragEnd(at point: NSPoint) {
        // Wait a bit for the selection to settle
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.captureSelectedText(at: point)
        }
    }

    private func captureSelectedText(at point: NSPoint) {
        // Step 1: Clear clipboard
        NSPasteboard.general.clearContents()

        // Step 2: Simulate Cmd+C using CGEvent
        simulateCopy()

        // Step 3: Wait and read clipboard
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.5) { [weak self] in
            let clipboard = NSPasteboard.general.string(forType: .string) ?? ""

            if clipboard.trimmingCharacters(in: .whitespacesAndNewlines).count > 1 {
                print("🎯 Got text: \(String(clipboard.prefix(40)))...")
                DispatchQueue.main.async {
                    self?.onTextCaptured(clipboard.trimmingCharacters(in: .whitespacesAndNewlines), point)
                }
            } else {
                print("⚠️ No text captured from drag")
            }
        }
    }

    private func simulateCopy() {
        // Key code 8 = 'C' on Mac keyboard
        let keyDown = CGEvent(keyboardEventSource: nil, virtualKey: 8, keyDown: true)
        keyDown?.flags = .maskCommand
        keyDown?.post(tap: .cgSessionEventTap)

        let keyUp = CGEvent(keyboardEventSource: nil, virtualKey: 8, keyDown: false)
        keyUp?.flags = .maskCommand
        keyUp?.post(tap: .cgSessionEventTap)
    }

    deinit {
        stop()
    }
}
