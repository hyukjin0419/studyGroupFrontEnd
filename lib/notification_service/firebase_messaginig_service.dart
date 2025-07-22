import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:study_group_front_end/notification_service/local_notifications_service.dart';

class FirebaseMessagingService {
  // Private constructor for singleton pattern
  FirebaseMessagingService._internal();

  // Singleton instance
  static final FirebaseMessagingService _instance = FirebaseMessagingService._internal();

  // Factory constructor to provide singleton instance
  factory FirebaseMessagingService.instance() => _instance;

  // Reference to local notifications service for displaying notifications
  LocalNotificationsService? _localNotificationsService;



  /// Retrieves and manages the FCM token for push notifications
  Future<void> _handlePushNotificationsToken() async {
    // Get the FCM token for the device
    final token = await FirebaseMessaging.instance.getToken();
    print('Push notifications token: $token');
    // TODO: 토큰 발행시 여기서 서버에 저장

    // Listen for token refresh events
    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      print('FCM token refreshed: $fcmToken');
      // TODO: 여기서 갱신된 토큰을 서버에 업데ㅣ트
    }).onError((error) {
      // Handle errors during token refresh
      print('Error refreshing FCM token: $error');
    });
  }

  /// Requests notification permission from the user (iOS)
  Future<void> _requestPermission() async {
    // Request permission for alerts, badges, and sounds
    final result = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Log the user's permission decision
    print('User granted permission: ${result.authorizationStatus}');
  }

  /// Handles messages received while the app is in the foreground
  //RemoteMessage는 push 알림 전체 데이터를 담은 객체
  void _onForegroundMessage(RemoteMessage message) {
    print('Foreground message received: ${message.data.toString()}');
    final notificationData = message.notification;
    if (notificationData != null) {
      // Display a local notification using the service
      _localNotificationsService?.showNotification(
          notificationData.title, notificationData.body, message.data.toString());
    }
  }

  /// Handles notification taps when app is opened from the background or terminated state
  void _onMessageOpenedApp(RemoteMessage message) {
    print('Notification caused the app to open: ${message.data.toString()}');
    // TODO: Add navigation or specific handling based on message data
  }

  /// Background message handler (must be top-level function or static)
  /// Handles messages when the app is fully terminated
  @pragma('vm:entry-point')
  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print('Background message received: ${message.data.toString()}');
  }

  /// Initialize Firebase Messaging and sets up all message listeners
  Future<void> init({required LocalNotificationsService localNotificationsService}) async {
    // Init local notifications service
    _localNotificationsService = localNotificationsService;

    //여기서 FCM을 발급받고 Handle -> 서버에 저장하든가 할 수 있음
    _handlePushNotificationsToken();

    // Request user permission for notifications
    _requestPermission();

    // Listen for messages when the app is in foreground
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // Listen for notification taps when the app is in background but not terminated
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    // Register handler for background messages (app terminated)
    //이건 fcm에서 호출
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Check for initial message that opened the app from terminated state
    //이건 사용자가 호출
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _onMessageOpenedApp(initialMessage);
    }
  }
}