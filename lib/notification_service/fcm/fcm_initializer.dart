import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:study_group_front_end/api_service/Auth/token_manager.dart';
import 'package:study_group_front_end/notification_service/fcm/fcm_handler.dart';
import 'package:study_group_front_end/notification_service/local/local_notifications_service.dart';

class FcmInitializer
{
  static Future<void> init ({required LocalNotificationsService localNotificationsService}) async {
    //1. 토큰 처리
    await _handleFcmToken();

    //2. 알림 권한 요청
    await _requestPermission();

    //3. 로컬 알림 서비스 주입
    FcmHandler.localNotificationsService = localNotificationsService;

    //4. 메시지 수신 핸들러 등록
    FirebaseMessaging.onMessage.listen(FcmHandler.onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(FcmHandler.onMessageOpenedApp);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    //5. 앱 종료 상태에서의 메시지 처리
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if(initialMessage != null) {
      FcmHandler.onMessageOpenedApp(initialMessage);
    }
  }

  static Future<void> _handleFcmToken() async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    log('FCM token: $fcmToken');

    if (fcmToken != null) {
      await TokenManager.setFcmToken(fcmToken);
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      log('FCM token refreshed: $token');
      await TokenManager.setFcmToken(token);
    });
  }

  static Future<void> _requestPermission() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    log('Notification permission status: ${settings.authorizationStatus}');
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log('Background message received: ${message.data.toString()}');
}