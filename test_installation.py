import sys
import os

def check_dependencies():
    print("--- 🔍 Checking Dependencies ---")
    try:
        import pynput
        print("✅ pynput is installed")
    except ImportError:
        print("❌ pynput is NOT installed")

    try:
        import pyperclip
        print("✅ pyperclip is installed")
    except ImportError:
        print("❌ pyperclip is NOT installed")

    try:
        import requests
        print("✅ requests is installed")
    except ImportError:
        print("❌ requests is NOT installed")

    try:
        import tkinter
        print("✅ tkinter is installed")
    except ImportError:
        print("❌ tkinter is NOT installed")

def check_translation():
    print("\n--- 🌐 Checking Translation Engine ---")
    try:
        from translator import translate_text
        result = translate_text("Hello")
        print(f"✅ Translation works: Hello -> {result}")
    except Exception as e:
        print(f"❌ Translation failed: {str(e)}")

if __name__ == "__main__":
    print(f"Python version: {sys.version}")
    check_dependencies()
    check_translation()
