import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationsService {
  // private 생성자 with named constructor. 내용 없을 시 중괄호 생략 가능 -> 싱글톤 객체 생성자
  LocalNotificationsService._internal();

  //싱글톤 객체를 생성
  static final LocalNotificationsService _instance = LocalNotificationsService._internal();

  //Factory constructor to return singleton instance
  //외부에서 접근 가능
  //factory 생성자는? 생성자 함수!
  //인스턴스를 직접 생성치 않고 특정 로직을 거쳐 반환한다. -> singleton에 많이사용
  factory LocalNotificationsService.instance() => _instance;

  //Main plugin instance for handling notifications
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  /*
  | 메서드                                       | 기능                                      |
| ----------------------------------------- | --------------------------------------- |
| `initialize(...)`                         | 알림 시스템 초기화 (Android 채널 생성, iOS 권한 요청 등) |
| `show(...)`                               | **즉시 알림 표시**                            |
| `schedule(...)`                           | 특정 시간에 알림 예약                            |
| `cancel(id)`                              | 해당 ID의 알림 제거                            |
| `cancelAll()`                             | 모든 알림 제거                                |
| `getPendingNotificationRequests()`        | 예약된 알림 목록 조회                            |
| `resolvePlatformSpecificImplementation()` | Android나 iOS 전용 기능 접근 (채널 생성, 뱃지 초기화 등) |
   */

  //Android-specific initialization settings using app launcher icon
  final _androidInitializationSettings = const AndroidInitializationSettings('@mipmap/ic_launcher');

  //iOS-specific initialization settings with permission requests
  final _iosInitializationSettings = const DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  //Android notification channel configuration
  final _androidChannel = const AndroidNotificationChannel(
    'channel_id',
    'Channel name',
    description: 'Android push notification channel',
    importance: Importance.max,
  );

  //Flag to track initialization status
  bool _isFlutterLocalNotificationInitialized = false;

  //Counter for generating unique notification IDs
  //안드로이드 같은 경우 같은 ID로 보내면, 기존 알림을 덮어버린다.
  int _notificationIdCounter = 0;

  /// Initializes the local notifications plugin for Android and iOS.
  Future<void> init() async {
    // Check if already initialized to prevent redundant setup
    if (_isFlutterLocalNotificationInitialized) {
      return;
    }

    // Create plugin instance
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // Combine platform-specific settings
    final initializationSettings = InitializationSettings(
      android: _androidInitializationSettings,
      iOS: _iosInitializationSettings,
    );

    // Initialize plugin with settings and callback for notification taps
    /// onDidReceiveNotificationResponse는 하나밖에 설정 안되고 -> response.payload를 체크해서 다르게 설정해야 함!
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          // Handle notification tap in foreground
          print('Foreground notification has been tapped: ${response.payload}');
        });

    // Create Android notification channel
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);

    // Mark initialization as complete
    _isFlutterLocalNotificationInitialized = true;
  }

  /// Show a local notification with the given title, body, and payload.
  Future<void> showNotification(String? title, String? body, String? payload,
      ) async {
    // Android-specific notification details
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _androidChannel.id,
      _androidChannel.name,
      channelDescription: _androidChannel.description,
      importance: Importance.max,
      priority: Priority.high,
    );

    // iOS-specific notification details
    const iosDetails = DarwinNotificationDetails();

    // Combine platform-specific details
    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Display the notification
    await _flutterLocalNotificationsPlugin.show(
      _notificationIdCounter++,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }
}