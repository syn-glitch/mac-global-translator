import threading
import queue
import subprocess
from monitor import DragMonitor
from translator import translate_text

class GlobalTranslatorApp:
    def __init__(self):
        self.drag_queue = queue.Queue()
        self.running = True

    def on_drag_complete(self, text, x, y):
        self.drag_queue.put((text, x, y))

    def show_notification(self, title, message):
        """macOS 네이티브 알림"""
        escaped_msg = message.replace('"', '\\"').replace("'", "\\'")
        escaped_title = title.replace('"', '\\"')
        script = f'display notification "{escaped_msg}" with title "{escaped_title}"'
        subprocess.run(["osascript", "-e", script], capture_output=True)

    def show_dialog(self, translated, original):
        """macOS 네이티브 다이얼로그"""
        orig_short = (original[:60] + "...") if len(original) > 60 else original
        orig_short = orig_short.replace('"', '\\"').replace("'", "\\'").replace("\n", " ")
        trans_escaped = translated.replace('"', '\\"').replace("'", "\\'").replace("\n", " ")
        
        script = f'''
        display dialog "📝 원문:\\n{orig_short}\\n\\n🌐 번역:\\n{trans_escaped}" with title "Mac Translator" buttons {{"닫기", "복사"}} default button "닫기" giving up after 10
        if button returned of result is "복사" then
            set the clipboard to "{trans_escaped}"
        end if
        '''
        subprocess.run(["osascript", "-e", script], capture_output=True)

    def process_queue(self):
        while self.running:
            try:
                text, x, y = self.drag_queue.get(timeout=0.5)
                print(f"⌛ Translating: {text[:30]}...")
                
                # Show notification that translation started
                self.show_notification("🌐 Mac Translator", "번역 중...")
                
                translated = translate_text(text)
                print(f"✅ Result: {translated[:40]}...")
                
                # Show result dialog
                self.show_dialog(translated, text)
                
            except queue.Empty:
                continue
            except Exception as e:
                print(f"❌ Error: {e}")

    def run(self):
        print("🚀 Mac Global Translator is running...")
        print("💡 텍스트를 드래그하면 자동으로 번역됩니다!")

        # Start monitor in background
        monitor = DragMonitor(self.on_drag_complete)
        monitor_thread = threading.Thread(target=monitor.start, daemon=True)
        monitor_thread.start()

        # Process queue in main thread
        try:
            self.process_queue()
        except KeyboardInterrupt:
            print("\nShutting down...")
            self.running = False

if __name__ == "__main__":
    app = GlobalTranslatorApp()
    app.run()
