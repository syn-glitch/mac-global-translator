#!/bin/bash
set -e

# ========================================
# Mac Translator - Build Script
# ========================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="MacTranslator"
APP_BUNDLE="${SCRIPT_DIR}/${APP_NAME}.app"

echo "🔨 Building Mac Translator..."
echo ""

# Step 0: Check Swift
if ! command -v swift &> /dev/null; then
    echo "❌ Swift compiler not found!"
    echo "   Please install Xcode Command Line Tools:"
    echo "   xcode-select --install"
    exit 1
fi

echo "✅ Swift: $(swift --version 2>&1 | head -1)"

# Step 1: Clean old files (Python artifacts)
echo ""
echo "🧹 Cleaning old Python files (if any)..."
cd "$SCRIPT_DIR"
rm -f main.py monitor.py translator.py ui.py test_installation.py requirements.txt MacTranslator.spec
rm -rf build/ dist/
echo "   Done."

# Step 2: Build
echo ""
echo "📦 Compiling Swift package..."
cd "$SCRIPT_DIR"
swift build -c release 2>&1

# Step 3: Create .app bundle
echo ""
echo "📁 Creating app bundle..."
rm -rf "$APP_BUNDLE"

mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"

# Copy executable
cp ".build/release/${APP_NAME}" "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}"

# Copy Info.plist
cp "${SCRIPT_DIR}/Info.plist" "${APP_BUNDLE}/Contents/Info.plist"

echo ""
echo "✅ Build successful!"
echo ""
echo "📍 App location: ${APP_BUNDLE}"
echo ""
echo "🚀 To run:"
echo "   1. Double-click '${APP_NAME}.app' in Finder"
echo "   2. Or run: open ${APP_BUNDLE}"
echo ""
echo "⚠️  First run: macOS will ask for Accessibility permission."
echo "   Go to: System Preferences > Security & Privacy > Privacy > Accessibility"
echo "   and enable '${APP_NAME}'."
echo ""

# Ask to run now
read -p "🎯 Run the app now? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    open "$APP_BUNDLE"
fi
