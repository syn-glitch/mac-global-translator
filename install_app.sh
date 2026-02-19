#!/bin/bash

APP_NAME="MacTranslator.app"
SRC_DIR="/Users/syn/Documents/dev/토이프로젝트_번역/mac-global-translator"
DEST_DIR="/Applications"

echo "🚀 Installing $APP_NAME to $DEST_DIR..."

# Check if source exists
if [ ! -d "$SRC_DIR/$APP_NAME" ]; then
    echo "❌ Source app not found. Please build it first."
    exit 1
fi

# Remove existing app in Applications
if [ -d "$DEST_DIR/$APP_NAME" ]; then
    echo "🗑️  Removing old version in Applications..."
    rm -rf "$DEST_DIR/$APP_NAME"
fi

# Copy app (using copy so dev version remains)
echo "📋 Copying to Applications..."
cp -r "$SRC_DIR/$APP_NAME" "$DEST_DIR/"

if [ -d "$DEST_DIR/$APP_NAME" ]; then
    echo "✅ Install Success!"
    echo "📂 Opening Applications folder..."
    open -R "$DEST_DIR/$APP_NAME"
    
    echo "--------------------------------------------------------"
    echo "👉 Dock에 추가하려면: 열린 폴더에서 앱을 Dock으로 드래그하세요."
    echo "👉 로그인 시 자동 실행하려면: 시스템 설정 > 일반 > 로그인 항목에 추가하세요."
    echo "--------------------------------------------------------"
else
    echo "❌ Failed to install. You may need admin permissions."
    echo "Try running: sudo cp -r \"$SRC_DIR/$APP_NAME\" \"$DEST_DIR/\""
    exit 1
fi
