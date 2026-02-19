# Mac Global Translator (Mac 글로벌 번역기) 🌐🐰

맥에서 **어떤 앱에서든** 텍스트를 드래그하면, 즉시 **Claude AI**가 자연스럽게 번역해주는 초경량 맥 전용 앱입니다.

<p align="center">
  <img src="icon.png" width="128" alt="MacTranslator Icon" />
</p>

## ✨ 주요 기능
- **🖱️ 드래그 앤 번역**: 텍스트를 드래그하고 🌐 버튼을 누르면 끝!
- **🤖 Claude AI 기반**: `claude-sonnet-4` 모델을 사용하여 문맥까지 고려한 고품질 번역 제공.
- **🔊 원어민 발음 (TTS)**: OpenAI TTS API를 탑재하여 매우 자연스러운 원어민 발음을 들려줍니다.
- **⚡️ Swift Native**: 가볍고 빠르며 배터리 소모가 적은 네이티브 앱.
- **🔐 안전한 키 관리**: API Key는 macOS Keychain에 암호화되어 저장됩니다.
- **👮‍♀️ 귀여운 아이콘**: 주디 홉스(Zootopia) 테마 적용! (메뉴바 아이콘 지원)

## 🚀 설치 및 실행 방법

### 1. 자동 설치 (권장)
터미널에서 아래 명령어를 한 줄씩 실행하세요.

```bash
# 실행 권한 부여
chmod +x build_app.sh install_app.sh

# 빌드 및 설치
./build_app.sh && ./install_app.sh
```

### 2. 수동 실행 (디버깅용)
앱이 정상적으로 실행되지 않을 때 로그를 확인하려면:

```bash
/Applications/MacTranslator.app/Contents/MacOS/MacTranslator
```

## ⚠️ 중요: 초기 설정
### 1. 접근성 권한 허용
이 앱은 화면의 텍스트를 인식하기 위해 **'접근성(Accessibility)'** 권한이 필요합니다.
- **시스템 설정** > **개인정보 보호 및 보안** > **접근성**
- `MacTranslator` 항목 체크 (이미 체크되어 있다면 해제 후 다시 체크)

### 2. API Key 설정
- **기본 번역**: 메뉴바 아이콘 클릭 > `🔑 Claude API Key 설정`
- **음성 듣기**: 메뉴바 아이콘 클릭 > `🔊 OpenAI API Key 설정`

## 🛠️ 개발 환경
- macOS 12.0+ (Monterey 이상)
- Swift 5.10+
- Xcode Command Line Tools

## 📝 라이선스
MIT License
