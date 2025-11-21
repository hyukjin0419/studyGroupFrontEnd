# <img src="https://github.com/user-attachments/assets/2d9d7414-a8f1-4437-bb01-14a1d6df1089" width="50" height="50" /> Sync Mate - Flutter App

[![App Store](https://img.shields.io/badge/App_Store-Download-0D96F6?style=for-the-badge&logo=apple&logoColor=white)](https://apps.apple.com/kr/app/sync-mate/id6755131308)
![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)

[🇺🇸 English](./README.md) | [🇰🇷 한국어](./README.ko.md)

🔹 [Sync Mate – Backend](https://github.com/hyukjin0419/studyGroupBackEnd)

**"목표 달성을 위한 가장 직관적인 체크리스트, Sync Mate"**
복잡한 협업 툴의 인지적 부담을 줄이고, **즉각적인 반응성(Responsiveness)** 과 **직관적인 UX**에 집중하여 개발된 Flutter기반 모바일 애플리케이션입니다.
- 안드로이드는 출시 예정입니다.
---

<p align="center">
  <img src="https://github.com/user-attachments/assets/936a622c-fde6-4ec7-87ed-53fd04f68e51" width="230" />
  <img src="https://github.com/user-attachments/assets/e8198c59-280a-4bda-8a60-9d2bca69155c" width="230" />
  <img src="https://github.com/user-attachments/assets/757edf47-8534-4041-afb3-e68792614da8" width="230" />
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/ef4a304d-bc0e-47a6-baf8-2ef787b9b5d8" width="230" />
  <img src="https://github.com/user-attachments/assets/c55aef73-f7f6-41f0-ac45-57fdd4b9e02b" width="230" />
</p>


## 💡 Key Technical Achievements

사용자에게는 **"끊김 없는 부드러운 경험"** 을 제공하고, 내부적으로는 **"유지보수가 용이한 견고한 아키텍처"** 를 구축하는 데 집중했습니다.

### 🎨 1. UX Engineering (사용자 경험 최적화)
* **Optimistic UI (낙관적 업데이트):** 서버 응답을 기다리지 않고 UI를 **선반영(Pre-render)**하여, 네트워크 지연 시간과 관계없이 즉각적인 반응성을 제공했습니다. (실패 시 자동 롤백 구현)
* **Intelligent Prefetching:** 사용자의 행동 패턴을 예측하여, 다음 이동할 화면의 데이터를 백그라운드에서 미리 로딩함으로써 **개인화면과 팀화면 전환 시 체감 로딩 시간 0초**를 달성했습니다.
* **In-Memory Caching:** 반복적으로 호출되는 데이터(Dashboard, List 등)를 메모리에 캐싱하여 불필요한 렌더링 지연을 제거하고 앱의 퍼포먼스를 극대화했습니다.
* **Component-Driven UI:** 버튼, 카드, 입력 폼 등 재사용 가능한 **Custom Widget**을 시스템적으로 설계하여 디자인 일관성을 유지하고 코드 중복을 최소화했습니다.

### 🌐 2. Network Architecture Engineering (네트워크 설계)
* **Custom BaseApiService:** `http` 패키지를 래핑(Wrapping)한 **공통 네트워크 레이어**를 직접 설계하여, 모든 API 요청/응답 및 예외 처리 로직을 표준화했습니다.
* **Seamless Auth (JWT Auto-Refresh):** `401 Unauthorized` 에러 감지 시, 사용자 개입 없이 자동으로 **Refresh Token을 통해 Access Token을 갱신하고 실패했던 요청을 재시도**하는 로직을 구현하여 로그인 끊김 없는 경험을 제공했습니다.
* **Server-Driven Error Handling:** 백엔드의 **Custom Exception** 응답 구조를 프론트엔드 모델로 직렬화(Serialization)하여 에러 처리를 일원화했습니다. 서버에서 정의한 예외 상황을 프론트엔드에서 별도 가공 없이 즉시 식별하고 적절한 UI 가이드(Toast, Alert)로 연결하는 파이프라인을 구축했습니다.
* **Efficient API Strategy:**
    * **Cache-First Strategy:** 요청 시 캐시(Cache Hit)가 있다면 즉시 반환하고, 없을 경우(Cache Miss)에만 서버로 요청을 보내 네트워크 부하를 줄였습니다.
    * **Sync Logic:** 캐시된 데이터를 먼저 보여준 뒤, 백그라운드에서 최신 데이터로 조용히 동기화하는 하이브리드 패턴을 적용했습니다.

## 📂 Project Structure

유지보수와 확장이 용이하도록 **Layered Architecture**를 기반으로 폴더 구조를 설계했습니다.
특히 **Prefetching**과 **DTO** 패턴을 명확히 분리하여 데이터 흐름을 체계화했습니다.

```text
lib/
├── api_service/         # 네트워크 통신 공통 로직 (Custom BaseApiService)
├── customized_icon/     # 앱 전용 커스텀 아이콘 에셋
├── dto/                 # 백엔드와 통신하는 Data Transfer Object (Request/Response 모델)
├── notification_service/# FCM(Firebase Cloud Messaging) 푸시 알림 핸들링
├── providers/           # 전역 상태 관리 (State Management)
├── repository/          # 데이터 계층 (API 호출 및 데이터 가공)
├── screens/             # UI 화면 (Feature 단위 페이지 구성)
├── snack_bar/           # 공통 UI 피드백 컴포넌트 (Global Snackbar)
├── util/                # 공통 유틸리티 함수 (Date Parser, Validator 등)
├── widgets/             # 재사용 가능한 UI 컴포넌트 (Buttons, Cards, Inputs)
│
├── firebase_options.dart
├── init_prefetch.dart   # ✨ 앱 실행 시 필수 데이터를 미리 로딩하는 Prefetch 로직
├── main.dart            # 앱 진입점
├── router.dart          # 네비게이션 라우팅 설정
└── splash_screen.dart   # 초기 로딩 화면
```

## 🛠 Tech Stack

| Category | Technology |
|---------|------------|
| **Framework** | ![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white) |
| **Language** | ![Dart](https://img.shields.io/badge/Dart-Language-0175C2?style=for-the-badge&logo=dart&logoColor=white) |
| **State Management** | ![Provider](https://img.shields.io/badge/Provider-State_Management-42A5F5?style=for-the-badge&logo=flutter&logoColor=white) |
| **Routing** | ![go_router](https://img.shields.io/badge/go__router-Routing-FF7043?style=for-the-badge&logo=flutter&logoColor=white) |
| **Networking** | ![Networking](https://img.shields.io/badge/http%20%2B%20BaseApiService-Networking-26A69A?style=for-the-badge&logo=flutter&logoColor=white) |
| **Local Storage** | ![flutter_secure_storage](https://img.shields.io/badge/flutter__secure__storage-Local_Storage-6A1B9A?style=for-the-badge&logo=flutter&logoColor=white) |
| **Notifications** | ![FCM](https://img.shields.io/badge/FCM%20%2B%20Local%20Notifications-Push_Notifications-FB8C00?style=for-the-badge&logo=firebase&logoColor=white) |


---

## 📮 Developer's Note: End-to-End 개발을 통해 배운 '데이터의 흐름'

저는 본래 **백엔드 개발자**를 지향하지만, 이번 프로젝트에서 **DB 설계부터 앱 화면 구현까지 혼자 전담**하며 데이터의 전체 생애 주기를 경험했습니다.

이 과정에서 제가 얻은 가장 큰 자산은 "데이터가 조달되고 변환되는 전체 흐름을 보는 눈"입니다.

### 1. "데이터는 멈춰있지 않고 흐른다."
> 단순히 DB에 데이터를 `INSERT` 하고 끝내는 것이 아니라, 그 데이터가 **어떤 파이프라인을 거쳐 모바일 화면에 도달하는지**를 직접 설계하고 구현했습니다.
>
> 👉 **Insight:** DB의 Raw Data가 API를 통해 JSON으로 직렬화되고, 프론트엔드에서 객체로 파싱되어 최종적으로 UI 상태(State)로 변환되는 일련의 과정(Flow)을 이해하게 되었습니다.

### 2. "중간 설계가 서비스의 품질을 결정한다."
> DB 스키마와 앱의 UI 구조는 서로 다를 수밖에 없습니다. 그 간극을 메우기 위해 백엔드 로직과 API가 존재한다는 것을 체감했습니다.
>
> 👉 **Insight:** 단순히 "기능이 돌아간다"에서 멈추지 않고, "이 데이터를 화면에 그리기 위해 백엔드에서 미리 어떤 가공을 해줘야 프론트엔드의 부담이 줄어들까?"를 고민하는 습관을 가지게 되었습니다.

<br>

**결국, 저에게 백엔드 개발이란 단순히 서버를 띄우는 것이 아니라, "시스템의 가장 깊은 곳(DB)에서 사용자의 손끝(Screen)까지 데이터를 가장 안전하고 효율적으로 배달하는 과정"임을 배웠습니다.**
