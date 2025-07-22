import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_group_front_end/firebase_options.dart';
import 'package:study_group_front_end/notification_service/firebase_messaginig_service.dart';
import 'package:study_group_front_end/notification_service/local_notifications_service.dart';
import 'package:study_group_front_end/providers/me_provider.dart';
import 'package:study_group_front_end/providers/study_provider.dart';
import 'package:study_group_front_end/router.dart';
import 'package:study_group_front_end/service/auth_api_service.dart';
import 'package:study_group_front_end/service/me_api_service.dart';
import 'package:study_group_front_end/service/study_api_service.dart';

Future<void> main() async {
  //비동기 작업 전에 Flutter 프레임워크 초기화 보장 -> 원래는 runApp에서 자동 초기화 되는데, 그 전에 초기화 해주어야해서
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final localNotificationsService = LocalNotificationsService.instance();
  await localNotificationsService.init();

  final firebaseMessagingService = FirebaseMessagingService.instance();
  await firebaseMessagingService.init(localNotificationsService: localNotificationsService);

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
