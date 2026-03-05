# Contributing to medicine_alarm

이 프로젝트에 기여해 주셔서 감사합니다. 이 문서는 현재 저장소(Flutter 앱) 기준의 개발/협업 가이드입니다.

## 1. 개발 환경

### 필수 요구사항

- Flutter SDK (stable)
- Dart SDK (Flutter에 포함)
- Xcode (iOS 개발 시, macOS)
- Android Studio 또는 Android SDK (Android 개발 시)

### 설치 및 실행

1. 저장소 클론

   ```bash
   git clone <repository-url>
   cd medicine-alarm
   ```

2. 의존성 설치

   ```bash
   flutter pub get
   ```

3. 로컬 실행

   ```bash
   flutter run
   ```

4. 웹 실행

   ```bash
   flutter run -d chrome
   ```

5. 웹 빌드

   ```bash
   flutter build web
   ```

## 2. 코드 스타일 및 개발 규칙

### Dart / Flutter

- 모든 신규 코드는 Null Safety 기반으로 작성
- `dynamic` 사용 지양 (불가피할 경우 이유를 주석으로 명시)
- 파일명은 `snake_case`, 클래스명은 `UpperCamelCase`, 멤버는 `lowerCamelCase`
- 공통 UI/로직은 재사용 가능한 위젯/함수로 분리

### 정적 분석 및 포맷팅

- 커밋 전 아래 명령 실행 권장

  ```bash
  dart format .
  flutter analyze
  flutter test
  ```

- 프로젝트는 `analysis_options.yaml`의 `flutter_lints` 규칙을 따릅니다.

## 3. 프로젝트 구조

- 앱 코드: `lib/`
- 화면(Page): `lib/pages/`
- 테스트: `test/`
- 에셋(폰트 등): `assets/`
- 웹 리소스: `web/`
- 플랫폼별 설정: `android/`, `ios/`, `macos/`, `linux/`, `windows/`

## 4. 브랜치 전략

### 기본 브랜치

- `main`

### 작업 브랜치 이름 예시

- `feature/add-reminder-edit`
- `fix/dashboard-section-visibility`
- `chore/update-dependencies`

## 5. 커밋 메시지 규칙

**Conventional Commits** 형식을 권장합니다.

### 형식

모든 커밋 메시지는 반드시 다음 형식을 따라야 합니다.
Copilot으로 자동 생성 시에도 동일하게 적용합니다.

```
<emoji> <type>(<scope(optional)>): <한글 subject>

<body(optional)>

<footer(optional)>
```

### 필수 규칙

- 제목은 반드시 **한국어**
- 제목 앞에 **이모지 1개 필수**
- 제목은 **50자 이내**
- Conventional Commit 타입 사용
- 관련 이슈는 footer에 명시 (예: Closes WMSD-5504)

### 이모지 & Type

| Type     | Emoji | 사용 기준                       |
| -------- | ----- | ------------------------------- |
| feat     | ✨    | 기능 추가                       |
| fix      | 🐛    | 버그 수정                       |
| refactor | ♻️    | 구조 개선 (동작 변경 없음)      |
| perf     | ⚡    | 성능 개선                       |
| docs     | 📝    | 문서 변경                       |
| style    | 💄    | UI 스타일 수정 (로직 변경 없음) |
| test     | ✅    | 테스트 코드 추가/수정           |
| chore    | 🔧    | 설정, 빌드, 의존성              |
| ci       | 👷    | CI/CD 설정                      |
| revert   | ⏪    | 이전 커밋 되돌림                |
| security | 🔐    | 권한, 인증, 토큰 관련           |
| hotfix   | 🚑    | 긴급 수정                       |
| db       | 🗄️    | API 스펙/데이터 구조 변경       |
| remove   | 🔥    | 기능 제거                       |

### Scope

- 변경 영역을 명시 (예: `auth`, `inventory`, `shipping`)

### 예시

```
✨ feat(auth): 이메일 OTP 인증 기능 추가

- 로그인 시 이메일 OTP 검증 로직 구현
- 인증 실패 시 에러 메시지 개선

Closes WMSD-5504
```

## 6. Pull Request 가이드

PR 생성 전에 아래를 확인해 주세요.

- [ ] `main` 최신 내용으로 동기화했는가?
- [ ] `flutter analyze`가 통과하는가?
- [ ] `flutter test`가 통과하는가?
- [ ] 변경 내용에 맞는 테스트를 추가했는가?
- [ ] UI/동작 변경 사항을 PR 설명에 명확히 작성했는가?

## 7. 테스트

### 실행

```bash
flutter test
```

### 작성 기준

- 상태 변화/시간 계산/저장 로직 등 핵심 비즈니스 로직은 테스트 우선
- 화면 동작 변경 시 위젯 테스트 추가 권장

---

가이드는 프로젝트 상황에 맞게 지속적으로 업데이트됩니다.
