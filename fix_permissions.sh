#!/bin/bash

# App Bundle ID
BUNDLE_ID="com.syn.mac-translator"
APP_PATH="/Applications/MacTranslator.app"

echo "🛠️ MacTranslator 권한 문제 해결 스크립트 실행..."

# 1. 앱 종료
echo "🛑 실행 중인 앱 종료..."
killall MacTranslator 2>/dev/null

# 2. 접근성 권한 초기화 (가장 중요!)
# 이 명령어를 실행하면 기존 권한 설정이 삭제되어, 앱 실행 시 다시 물어보게 됩니다.
echo "🔄 접근성(Accessibility) 권한 초기화..."
tccutil reset Accessibility "$BUNDLE_ID" 2>/dev/null || echo "⚠️ 권한 초기화에 실패했습니다. (이미 권한이 없거나 권한 관리가 엄격할 수 있음)"

# 3. 격리 속성 제거 (Quarantine)
# 인터넷에서 다운로드한 앱처럼 취급되어 실행이 차단되는 것을 방지합니다.
if [ -d "$APP_PATH" ]; then
    echo "🛡️ 보안 격리 속성 제거..."
    xattr -rc "$APP_PATH" 2>/dev/null
else
    echo "❌ /Applications 폴더에 앱이 없습니다!"
    exit 1
fi

echo "✅ 복구 완료!"
echo "🚀 앱을 다시 실행합니다. '접근성 권한 요청' 창이 뜨면 [설정 열기]를 눌러 다시 허용해주세요!"
echo ""
open "$APP_PATH"
