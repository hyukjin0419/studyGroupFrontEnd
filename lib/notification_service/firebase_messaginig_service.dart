// import 'dart:developer';
//
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:study_group_front_end/api_service/Auth/token_manager.dart';
// import 'package:study_group_front_end/notification_service/local_notifications_service.dart';
// import 'package:study_group_front_end/screens/study/widgets/study_invitation_dialog.dart';
// import 'package:study_group_front_end/util/navigator_key.dart';
//
// class FirebaseMessagingService {
//   FirebaseMessagingService._internal();
//   static final FirebaseMessagingService _instance = FirebaseMessagingService._internal();
//   factory FirebaseMessagingService.instance() => _instance;
//
//   LocalNotificationsService? _localNotificationsService;
//
//
//   Future<void> _handlePushNotificationsToken() async {
//     final fcmToken = await FirebaseMessaging.instance.getToken();
//
//     log('Push notifications token: $fcmToken', name: "_handlePushNotificationsToken");
//
//     if(fcmToken != null){
//       await TokenManager.setFcmToken(fcmToken);
//     }
//
//     // Listen for token refresh events
//     FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) async {
//       log('FCM token refreshed: $fcmToken', name: "_handlePushNotificationsToken");
//       await TokenManager.setFcmToken(fcmToken);
//     }).onError((error) {
//       // Handle errors during token refresh
//       log('Error refreshing FCM token: $error', name: "FirebaseMessaging.instance.onTokenRefresh.listen");
//     });
//   }
//
//   /// Requests notification permission from the user (iOS)
//   Future<void> _requestPermission() async {
//     // Request permission for alerts, badges, and sounds
//     final result = await FirebaseMessaging.instance.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//
//     // Log the user's permission decision
//     log('User granted permission: ${result.authorizationStatus}', name: "_requestPermission");
//   }
//
//   /// Handles messages received while the app is in the foreground
//   //RemoteMessage는 push 알림 전체 데이터를 담은 객체
//   void _onForegroundMessage(RemoteMessage message) {
//     _handleFcmMessage(message);
//
//     final notificationData = message.notification;
//     if (notificationData != null) {
//       // Display a local notification using the service
//       _localNotificationsService?.showNotification(
//           notificationData.title, notificationData.body, message.data.toString());
//     }
//   }
//
//   /// Handles notification taps when app is opened from the background or terminated state
//   void _onMessageOpenedApp(RemoteMessage message) {
//     _handleFcmMessage(message);
//   }
//
//   void _handleFcmMessage(RemoteMessage message) {
//     final data = message.data;
//     final type = data['type'];
//
//     log(data.toString(), name: "Data in RemoteMessage");
//
//     switch(type) {
//       case 'STUDY_INVITATION':
//         _handleInvitationMessage(data);
//         break;
//
//       default:
//         log("알 수 없는 FCM message type", name: "_handleFcmMessgae");
//     }
//   }
//
//   void _handleInvitationMessage(Map<String, dynamic> data) {
//     try {
//       final invitationId = int.parse(data['invitationId']);
//       final title = data['title'];
//       final body = data['body'];
//
//       final context = navigatorKey.currentState?.overlay?.context;
//
//       if (context == null) {
//         log("context가 null입니다. Dialog를 띄울 수 없습니다.");
//         return;
//       }
//
//       if (ModalRoute
//           .of(context)
//           ?.isCurrent == false) {
//         log("중복 Dialog 생성 방지");
//         return;
//       }
//
//       showDialog(
//           context: context,
//           barrierDismissible: false,
//           builder: (_) =>
//               InvitationDialog(
//                 invitationId: invitationId,
//                 title: title,
//                 body: body,
//               )
//       );
//     } catch (e) {
//       log("handleInvitationMessage 처리 중 오류: $e");
//     }
//   }
//
//   /// Initialize Firebase Messaging and sets up all message listeners
//   Future<void> init({required LocalNotificationsService localNotificationsService}) async {
//     // Init local notifications service
//     _localNotificationsService = localNotificationsService;
//
//     //여기서 FCM을 발급받고 Handle -> 서버에 저장하든가 할 수 있음
//     _handlePushNotificationsToken();
//
//     // Request user permission for notifications
//     _requestPermission();
//
//     // Listen for messages when the app is in foreground
//     FirebaseMessaging.onMessage.listen(_onForegroundMessage);
//
//     // Listen for notification taps when the app is in background but not terminated
//     FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);
//
//     // Register handler for background messages (app terminated)
//     //이건 fcm에서 호출
//         FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//
//     // Check for initial message that opened the app from terminated state
//     //이건 사용자가 호출
//     final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
//     if (initialMessage != null) {
//       _onMessageOpenedApp(initialMessage);
//     }
//   }
// }
//
// /// Background message handler (must be top-level function or static)
// /// Handles messages when the app is fully terminated
// /// Tree Shaking으로 인한 컴파일 대상에서 제외되는 것을 막아줌
// /// 즉 네이티브로 컴파일 되어 바로 사용 가능할 수 있게 컴파일에 포함시키라는 설정
// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   print('Background message received: ${message.data.toString()}');
// }