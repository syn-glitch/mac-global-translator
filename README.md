# Mac Global Translator (Mac 글로벌 번역기) 🌐🐰

맥에서 **어떤 앱에서든** 텍스트를 드래그하면, 즉시 **Claude AI**가 자연스럽게 번역해주는 초경량 맥 전용 앱입니다.

<p align="center">
  <img src="icon.png" width="128" alt="MacTranslator Icon" />
</p>

## ✨ 주요 기능
- **🖱️ 드래그 앤 번역**: 텍스트를 드래그하고 🌐 버튼을 누르면 끝!
- **🤖 Claude AI 기반**: `claude-sonnet-4` 모델을 사용하여 문맥까지 고려한 고품질 번역 제공.
- **⚡️ Swift Native**: 가볍고 빠르며 배터리 소모가 적은 네이티브 앱.
- **🔐 안전한 키 관리**: API Key는 macOS Keychain에 암호화되어 저장됩니다.
- **👮‍♀️ 귀여운 아이콘**: 주디 홉스(Zootopia) 테마 적용!

## 🚀 설치 및 실행 방법

### 1. 소스 코드 빌드
터미널에서 이 프로젝트 폴더로 이동한 뒤, 빌드 스크립트를 실행합니다.

```bash
# 빌드 실행
./build_app.sh
```

### 2. 앱 설치 (응용 프로그램 폴더로 이동)
빌드가 완료되면 설치 스크립트를 실행하여 `/Applications` 폴더로 옮깁니다.

```bash
# 설치 및 Dock 추가 안내
./install_app.sh
```

### 3. 아이콘 적용 (선택 사항)
기본 아이콘을 변경하고 싶다면 아래 스크립트를 실행하세요. (이미지가 `icon.png`로 저장되어 있어야 함)

```bash
./set_icon.sh
```

## ⚠️ 중요: 권한 설정
이 앱은 화면의 텍스트를 인식하기 위해 **'접근성(Accessibility)'** 권한이 필요합니다.
앱을 처음 실행하거나 업데이트한 경우, 권한을 허용해주세요.

1. **시스템 설정** > **개인정보 보호 및 보안** > **접근성**
2. `MacTranslator` 항목 체크 (이미 체크되어 있다면 해제 후 다시 체크)

## 🛠️ 개발 환경
- macOS 12.0+ (Monterey 이상)
- Swift 5.5+
- Xcode Command Line Tools

## 📝 라이선스
MIT License
