import Cocoa

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
print("🚀 Main started")
print("📂 Bundle path: \(Bundle.main.bundlePath)")
app.run()
