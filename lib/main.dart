import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:study_group_front_end/api_service/auth_api_service.dart';
import 'package:study_group_front_end/api_service/me_api_service.dart';
import 'package:study_group_front_end/api_service/study_api_service.dart';
import 'package:study_group_front_end/api_service/study_join_api_service.dart';
import 'package:study_group_front_end/firebase_options.dart';
import 'package:study_group_front_end/notification_service/fcm/fcm_initializer.dart';
import 'package:study_group_front_end/notification_service/local/local_notifications_service.dart';
import 'package:study_group_front_end/providers/me_provider.dart';
import 'package:study_group_front_end/providers/study_join_provider.dart';
import 'package:study_group_front_end/providers/study_provider.dart';
import 'package:study_group_front_end/router.dart';

Future<void> main() async {
  //비동기 작업 전에 Flutter 프레임워크 초기화 보장 -> 원래는 runApp에서 자동 초기화 되는데, 그 전에 초기화 해주어야해서
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final localNotificationsService = LocalNotificationsService.instance();
  await localNotificationsService.init();

  await FcmInitializer.init(localNotificationsService: localNotificationsService);

  await initializeDateFormatting();


  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => MeProvider(AuthApiService(), MeApiService()),
          ),
          ChangeNotifierProvider(
            create: (_) => StudyProvider(StudyApiService()),
          ),
          ChangeNotifierProvider(
              create: (_) => StudyJoinProvider(StudyJoinApiService()),
          )
        ],
        child: MaterialApp.router(
          routerConfig: router,
          theme: ThemeData(
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
            ),
            scaffoldBackgroundColor: Colors.white,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Color(0xFF73B4E3),
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
        )
      )
  );
}
