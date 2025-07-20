import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_group_front_end/firebase_options.dart';
import 'package:study_group_front_end/providers/me_provider.dart';
import 'package:study_group_front_end/providers/study_provider.dart';
import 'package:study_group_front_end/router.dart';
import 'package:study_group_front_end/service/auth_api_service.dart';
import 'package:study_group_front_end/service/me_api_service.dart';
import 'package:study_group_front_end/service/study_api_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('백그라운드 메시지 수신: ${message.messageId}');
}


void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  NotificationSettings settings = await FirebaseMessaging.instance.requestPermission();
  print('알림 권한 상태: ${settings.authorizationStatus}');

  // FCM 토큰 요청
  String? token = await FirebaseMessaging.instance.getToken();
  print('📮 FCM 토큰: $token');

  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => MeProvider(AuthApiService(), MeApiService()),
          ),
          ChangeNotifierProvider(
            create: (_) => StudyProvider(StudyApiService()),
          ),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          theme: ThemeData(useMaterial3: true),
        )
      )
  );
}
