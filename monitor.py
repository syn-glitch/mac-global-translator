import time
import subprocess
from pynput import mouse
from Quartz import (
    CGEventCreateKeyboardEvent,
    CGEventSetFlags,
    CGEventPost,
    kCGSessionEventTap,
    kCGEventFlagMaskCommand,
)
from translator import translate_text

class DragMonitor:
    def __init__(self, on_drag_complete):
        self.start_pos = None
        self.on_drag_complete = on_drag_complete

    def simulate_copy(self):
        """Use Quartz CGEvent to simulate Cmd+C at the system session level"""
        # Key code 8 = 'c' on Mac keyboard
        # Key down
        event_down = CGEventCreateKeyboardEvent(None, 8, True)
        CGEventSetFlags(event_down, kCGEventFlagMaskCommand)
        CGEventPost(kCGSessionEventTap, event_down)
        
        # Key up
        event_up = CGEventCreateKeyboardEvent(None, 8, False)
        CGEventSetFlags(event_up, kCGEventFlagMaskCommand)
        CGEventPost(kCGSessionEventTap, event_up)

    def get_clipboard(self):
        """Use pbpaste to get clipboard content"""
        result = subprocess.run(["pbpaste"], capture_output=True, text=True, timeout=3)
        return result.stdout

    def clear_clipboard(self):
        """Clear the clipboard before copying"""
        subprocess.run(["pbcopy"], input=b"", timeout=3)

    def on_click(self, x, y, button, pressed):
        if button == mouse.Button.left:
            if pressed:
                self.start_pos = (x, y)
            else:
                if self.start_pos:
                    end_pos = (x, y)
                    dist = ((end_pos[0] - self.start_pos[0])**2 + (end_pos[1] - self.start_pos[1])**2)**0.5
                    if dist > 10:
                        print(f"✨ Drag detected (distance: {dist:.0f})")
                        self.handle_drag_end(x, y)
                    self.start_pos = None

    def handle_drag_end(self, x, y):
        time.sleep(0.3)
        
        try:
            # Step 1: Clear clipboard
            self.clear_clipboard()
            
            # Step 2: Simulate Cmd+C via Quartz CGEvent
            print("⌨️ Copying selection (Quartz)...")
            self.simulate_copy()
            
            # Step 3: Wait and read clipboard
            time.sleep(0.5)
            new_content = self.get_clipboard()
            
            if new_content and len(new_content.strip()) > 1:
                print(f"🎯 Got text: {new_content[:40]}...")
                self.on_drag_complete(new_content.strip(), x, y)
            else:
                print(f"⚠️ No text captured. Clipboard: '{new_content}'")
        except Exception as e:
            print(f"❌ Error: {str(e)}")

    def start(self):
        print("👂 Mouse listener started...")
        with mouse.Listener(on_click=self.on_click) as listener:
            listener.join()

if __name__ == "__main__":
    def test_callback(text, x, y):
        print(f"[{x}, {y}] Translating: {text}")
        print(f"Result: {translate_text(text)}")

    monitor = DragMonitor(test_callback)
    monitor.start()
