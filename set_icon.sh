#!/bin/bash

# Check if icon.png exists
if [ ! -f "icon.png" ]; then
    # Try to convert jpg/jpeg
    if [ -f "icon.jpg" ]; then
        echo "🔄 icon.jpg를 발견했습니다! png로 변환합니다..."
        sips -s format png icon.jpg --out icon.png
    elif [ -f "icon.jpeg" ]; then
        echo "🔄 icon.jpeg를 발견했습니다! png로 변환합니다..."
        sips -s format png icon.jpeg --out icon.png
    else
        echo "❌ 'icon.png' (또는 jpg) 파일이 없습니다!"
        echo "   사용하려는 이미지를 'icon.png' 이름으로 이 폴더에 저장해주세요."
        exit 1
    fi
fi

echo "🎨 아이콘 생성 중..."

# Create iconset folder
rm -rf AppIcon.iconset
mkdir AppIcon.iconset

# Generate resized icons
sips -z 16 16     icon.png --out AppIcon.iconset/icon_16x16.png
sips -z 32 32     icon.png --out AppIcon.iconset/icon_16x16@2x.png
sips -z 32 32     icon.png --out AppIcon.iconset/icon_32x32.png
sips -z 64 64     icon.png --out AppIcon.iconset/icon_32x32@2x.png
sips -z 128 128   icon.png --out AppIcon.iconset/icon_128x128.png
sips -z 256 256   icon.png --out AppIcon.iconset/icon_128x128@2x.png
sips -z 256 256   icon.png --out AppIcon.iconset/icon_256x256.png
sips -z 512 512   icon.png --out AppIcon.iconset/icon_256x256@2x.png
sips -z 512 512   icon.png --out AppIcon.iconset/icon_512x512.png
sips -z 1024 1024 icon.png --out AppIcon.iconset/icon_512x512@2x.png > /dev/null

# Convert to icns
iconutil -c icns AppIcon.iconset

# Cleanup
rm -rf AppIcon.iconset

echo "✅ AppIcon.icns 생성 완료!"

# Apply to built app
if [ -d "MacTranslator.app" ]; then
    cp AppIcon.icns MacTranslator.app/Contents/Resources/
    touch MacTranslator.app
    echo "📦 MacTranslator.app에 아이콘 적용 완료"
fi

# Apply to installed app
if [ -d "/Applications/MacTranslator.app" ]; then
    echo "📂 응용 프로그램 폴더의 앱 업데이트 중..."
    cp AppIcon.icns /Applications/MacTranslator.app/Contents/Resources/
    
    # Update Info.plist if needed
    if ! grep -q "CFBundleIconFile" "/Applications/MacTranslator.app/Contents/Info.plist"; then
      plutil -insert CFBundleIconFile -string "AppIcon" "/Applications/MacTranslator.app/Contents/Info.plist"
    fi
    
    touch /Applications/MacTranslator.app
    killall Dock 2>/dev/null
    echo "✨ 적용 완료! (Dock이 깜빡일 수 있습니다)"
fi
