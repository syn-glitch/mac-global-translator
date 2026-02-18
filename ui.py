import tkinter as tk
from tkinter import font as tkfont
import threading

class TranslationPopup:
    def __init__(self):
        self.root = None
        self.timer = None

    def show(self, text, original, x, y):
        # Run UI in main thread if needed, but since we call this from monitor thread,
        # we need to be careful. For simplicity, we create a new window each time or reuse.
        if self.root:
            self.root.destroy()
            
        self.root = tk.Tk()
        self.root.overrideredirect(True)  # No window decorations
        self.root.attributes("-topmost", True)  # Always on top
        self.root.attributes("-alpha", 0.95)   # Slight transparency
        
        # Design
        bg_color = "#12141c"
        text_color = "#e8eaf0"
        accent_color = "#6c5ce7"
        
        self.root.configure(bg=bg_color, padx=2, pady=2)
        
        container = tk.Frame(self.root, bg=bg_color, padx=15, pady=12)
        container.pack()
        
        # Header/Title
        header_font = tkfont.Font(family="Inter", size=10, weight="bold")
        header = tk.Label(container, text="🌐 AI Translation", font=header_font, fg=accent_color, bg=bg_color)
        header.pack(anchor="w")
        
        # Original (small, muted)
        orig_font = tkfont.Font(family="Inter", size=9, slant="italic")
        orig_limit = 50
        orig_text = (original[:orig_limit] + "...") if len(original) > orig_limit else original
        orig_label = tk.Label(container, text=orig_text, font=orig_font, fg="#9498a8", bg=bg_color, wraplength=250, justify="left")
        orig_label.pack(anchor="w", pady=(2, 8))
        
        # Result
        res_font = tkfont.Font(family="Inter", size=11)
        res_label = tk.Label(container, text=text, font=res_font, fg=text_color, bg=bg_color, wraplength=280, justify="left")
        res_label.pack(anchor="w")
        
        # Position (adjust so it's not directly under the mouse)
        # We place it centered horizontally at x, and slightly above y
        self.root.update_idletasks()
        width = self.root.winfo_width()
        height = self.root.winfo_height()
        
        pos_x = x - width // 2
        pos_y = y - height - 10
        
        # Boundary check (screen edges)
        screen_width = self.root.winfo_screenwidth()
        if pos_x < 10: pos_x = 10
        if pos_x + width > screen_width - 10: pos_x = screen_width - width - 10
        if pos_y < 10: pos_y = y + 20 # Show below if too high
        
        self.root.geometry(f"+{int(pos_x)}+{int(pos_y)}")
        
        # Auto-close after 5 seconds
        if self.timer:
            self.timer.cancel()
        self.root.after(5000, self.root.destroy)
        
        # Close on click
        self.root.bind("<Button-1>", lambda e: self.root.destroy())
        
        self.root.mainloop()

if __name__ == "__main__":
    # Test
    popup = TranslationPopup()
    popup.show("안녕하세요 세상", "Hello world", 500, 500)
