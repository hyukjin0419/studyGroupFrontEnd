# <img src="https://github.com/user-attachments/assets/2d9d7414-a8f1-4437-bb01-14a1d6df1089" width="50" height="50" /> Sync Mate – Flutter App

[![App Store](https://img.shields.io/badge/App_Store-Download-0D96F6?style=for-the-badge&logo=apple&logoColor=white)](https://apps.apple.com/kr/app/sync-mate/id6755131308)
![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)

[🇺🇸 English](./README.md) | [🇰🇷 한국어](./README.ko.md)

🔹 [Sync Mate – Backend](https://github.com/hyukjin0419/studyGroupBackEnd)

**“The most intuitive checklist for achieving your goals — Sync Mate.”**  
Built with Flutter, Sync Mate focuses on reducing the cognitive load of complex collaboration tools and delivering a **highly responsive** and **intuitively designed** user experience.
- Android version is coming soon.

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

---

## 💡 Key Technical Achievements

Sync Mate is engineered to offer users a **smooth, interruption-free experience**, while maintaining a **maintainable, scalable, and well-structured architecture** internally.

---

### 🎨 1. UX Engineering (User Experience Optimization)

- **Optimistic UI:**  
  UI updates are reflected **immediately before server responses**, ensuring high responsiveness regardless of network latency. Automatic rollback is applied on failures.

- **Intelligent Prefetching:**  
  Predicts the user's next action and **preloads future screen data in the background**, achieving **near-zero perceived loading time** when switching between personal and team views.

- **In-Memory Caching:**  
  Frequently accessed data (Dashboard, Lists, etc.) is cached to eliminate redundant render delays and maximize performance.

- **Component-Driven UI:**  
  Reusable **Custom Widgets** (buttons, cards, input fields) enforce design consistency and reduce UI code duplication across the app.

---

### 🌐 2. Network Architecture Engineering

- **Custom BaseApiService:**  
  A fully custom abstraction layer wrapping the `http` package.  
  Standardizes all API requests, responses, and exception handling across the app.

- **Seamless Authentication (JWT Auto-Refresh):**  
  When a `401 Unauthorized` occurs, the app automatically refreshes the Access Token using the Refresh Token and replays the failed request — no user interaction required.

- **Server-Driven Error Handling:**  
  Backend-defined **Custom Exception Models** are directly deserialized on the frontend, enabling consistent UI responses (Toast, Alerts) without additional mapping.

- **Efficient API Strategy:**
  - **Cache-First:** Return cached data on hit; on miss, send network request.
  - **Sync Logic:** Display cached data immediately while quietly syncing the latest backend data in the background.

---

## 📂 Project Structure

Designed with **Layered Architecture** to maximize maintainability and extensibility.  
Prefetching logic and DTO structures are clearly separated for clean and predictable data flow.

```text
lib/
├── api_service/          # Common network layer (custom BaseApiService)
├── customized_icon/      # Custom icons used throughout the app
├── dto/                  # DTOs for Request/Response mapping with backend
├── notification_service/ # FCM push notification handling (foreground/background/terminated)
├── providers/            # Global state management (Provider)
├── repository/           # Data layer: API communication + local processing
├── screens/              # Feature-based pages and UI screens
├── snack_bar/            # Global snackbar UI components
├── util/                 # Utility helpers (date parser, validators, etc.)
├── widgets/              # Reusable UI components (buttons, cards, inputs)
│
├── firebase_options.dart
├── init_prefetch.dart    # ✨ Prefetch logic executed at app startup
├── main.dart             # Main entry point
├── router.dart           # App navigation (go_router)
└── splash_screen.dart    # Initial splash/loading screen
