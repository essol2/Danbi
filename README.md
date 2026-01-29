# 🌱 단비 (Danbi)

> 나의 반려식물에게 내리는 단비

반려식물의 물주기를 관리하고 건강하게 키울 수 있도록 도와주는 iOS 앱입니다.

<br>

## 📱 주요 기능

### 🪴 식물 관리
- 반려식물 등록 및 관리
- 식물별 사진, 이름, 종류 설정
- 물주기 주기 커스터마이징 (1~30일)
- 스와이프로 간편한 식물 삭제

### 💧 물주기 알림
- 식물별 물주기 진행률 표시
- 물 줄 시간이 되면 로컬 푸시 알림 (매일 오전 9시)
- 물주기 버튼으로 간편한 기록
- 자동 카운트다운 시스템

### 📸 사진 관리
- 카메라로 식물 사진 촬영
- 갤러리에서 사진 선택
- 식물 카드에 사진 표시

### ⚙️ 설정
- 물주기 알림 켜기/끄기
- 다크 모드 지원 (예정)
- 개발자에게 의견 보내기
- 앱 정보 및 버전 확인

<br>

## 🛠 기술 스택

### 프레임워크
- **SwiftUI**: 선언적 UI 프레임워크
- **SwiftData**: 로컬 데이터 영구 저장
- **UserNotifications**: 로컬 푸시 알림

### 아키텍처
- MVVM 패턴
- SwiftData 기반 데이터 관리
- 싱글톤 패턴 (NotificationManager)

### 주요 기술
- `@Model`: SwiftData 데이터 모델
- `@Query`: 실시간 데이터 조회
- `@Environment`: 환경 객체 주입
- `@AppStorage`: UserDefaults 래퍼
- Timer Publisher: 자동 UI 업데이트
- UIImagePickerController: 카메라/갤러리 접근

<br>

## 📂 프로젝트 구조

```
danbi/
├── danbiApp.swift              # 앱 진입점
├── Model/
│   ├── Plant.swift             # 식물 데이터 모델
│   └── SampleData.swift        # 샘플 데이터
├── UI/
│   ├── ContentView.swift       # 메인 화면
│   ├── AddPlantView.swift      # 식물 추가 화면
│   ├── PlantCardView.swift     # 식물 카드 컴포넌트
│   ├── NoDataView.swift        # 빈 상태 화면
│   ├── SettingsView.swift      # 설정 화면
│   └── ImagePicker.swift       # 이미지 선택 유틸
├── NotificationManager.swift   # 알림 관리자
├── Assets.xcassets/            # 이미지 리소스
│   └── defaultImage.imageset   # 기본 식물 이미지
├── Fonts/
│   └── MemomentKkukkukk.ttf   # 커스텀 폰트
└── Info.plist                  # 앱 설정
```

<br>

## 🎨 디자인 특징

### 컬러 팔레트
- **Primary Green**: `Color(red: 0.55, green: 0.65, blue: 0.55)` - 메인 브랜드 컬러
- **Background**: `Color(red: 0.95, green: 0.95, blue: 0.93)` - 따뜻한 배경색
- **Text Gray**: `Color(red: 0.5, green: 0.5, blue: 0.5)` - 부드러운 회색

### 타이포그래피
- **커스텀 폰트**: MemomentKkukkukkR
- 헤더: 36pt, 감성적인 브랜드 느낌
- 본문: 16-18pt, 가독성 최적화

### UI/UX
- 미니멀한 디자인
- 직관적인 인터랙션
- 부드러운 애니메이션
- 일관된 여백과 라운딩

<br>

## 💾 데이터 모델

### Plant
```swift
@Model
final class Plant {
    var id: UUID                    // 고유 식별자
    var name: String                // 식물 이름
    var scientificName: String      // 식물 종류/설명
    var lastWatered: Date           // 마지막 물 준 날짜
    var wateringInterval: Int       // 물주기 주기 (일)
    var imageData: Data?            // 식물 사진
    
    // 계산된 속성
    var needsWater: Bool            // 물 줄 시간인지
    var daysSinceWatered: Int       // 마지막 물주기로부터 경과 일수
    var daysUntilWatering: Int      // 다음 물주기까지 남은 일수
    var wateringProgress: Double    // 진행률 (0.0 ~ 1.0)
}
```

<br>

## 🔔 알림 시스템

### 동작 방식
1. 식물 추가 시 자동으로 알림 예약
2. 물주기 시 알림 재예약
3. 식물 삭제 시 알림 자동 취소
4. 앱 재실행 시 알림 복구

### 알림 예약 로직
- 다음 물주기 날짜 = 마지막 물준 날짜 + 물주기 주기
- 매일 오전 9시에 발송
- 최대 64개까지 예약 가능 (iOS 제한)

### 권한 관리
- 앱 최초 실행 시 권한 요청
- 설정에서 알림 켜기/끄기 가능
- 시스템 설정과 연동

<br>

## 🚀 시작하기

### 요구사항
- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

### 설치 방법
1. 저장소 클론
```bash
git clone https://github.com/yourusername/danbi.git
cd danbi
```

2. Xcode에서 프로젝트 열기
```bash
open danbi.xcodeproj
```

3. 폰트 파일 추가
- `Fonts/MemomentKkukkukk.ttf` 파일을 Xcode 프로젝트에 추가
- Target Membership 확인

4. 빌드 및 실행
- 시뮬레이터 또는 실제 기기 선택
- `Cmd + R` 실행

<br>

## 📝 주요 기능 사용법

### 식물 추가하기
1. 메인 화면 하단 "반려식물 추가하기" 버튼 클릭
2. 사진 추가 (선택사항)
   - 카메라로 촬영 또는 갤러리에서 선택
3. 식물 이름 입력 (예: 나의 첫 몬스테라)
4. 식물 종류 입력 (예: Monstera Deliciosa)
5. 물주기 주기 설정 (슬라이더로 1~30일)
6. "추가" 버튼 클릭

### 물주기
1. 식물 카드 우측 상단의 물방울 버튼 클릭
2. 자동으로 날짜 기록 및 알림 재예약

### 식물 삭제
1. 식물 카드를 왼쪽으로 스와이프
2. "삭제" 버튼 클릭

### 알림 설정
1. 우측 상단 메뉴 버튼 (⋮) 클릭
2. "물주기 알림" 토글로 켜기/끄기

<br>

## 🐛 알려진 이슈

- [ ] 다크 모드 미지원 (개발 예정)
- [ ] 사용자 커스텀 알림 시간 설정 미지원
- [ ] 식물 편집 기능 미지원

<br>

## 🗓 로드맵

### v1.1
- [ ] 식물 정보 수정 기능
- [ ] 물주기 히스토리 확인
- [ ] 다크 모드 완전 지원

### v1.2
- [ ] 위젯 지원
- [ ] 사용자 커스텀 알림 시간
- [ ] 식물 카테고리 및 필터링

### v2.0
- [ ] 식물 케어 팁
- [ ] 커뮤니티 기능
- [ ] 클라우드 동기화

<br>

## 👥 기여하기

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<br>

## 📄 라이선스

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

<br>

## 👤 개발자

**Danbi Team**
- Email: contact@danbi.app
- Made with 🌱 by Danbi Team

<br>

## 🙏 감사의 말

- 커스텀 폰트: MemomentKkukkukk
- 기본 이미지: Pexels
- 아이콘: SF Symbols

<br>

---

<p align="center">
  <i>반려식물과 함께하는 행복한 하루를 응원합니다 🌿</i>
</p>
