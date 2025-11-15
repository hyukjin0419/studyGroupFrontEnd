import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:study_group_front_end/api_service/auth_api_service.dart';
import 'package:study_group_front_end/api_service/checklist_item_api_service.dart';
import 'package:study_group_front_end/api_service/insight_api_service.dart';
import 'package:study_group_front_end/api_service/me_api_service.dart';
import 'package:study_group_front_end/api_service/personal_checklist_api_service.dart';
import 'package:study_group_front_end/api_service/study_api_service.dart';
import 'package:study_group_front_end/api_service/study_join_api_service.dart';
import 'package:study_group_front_end/firebase_options.dart';
import 'package:study_group_front_end/notification_service/fcm/fcm_initializer.dart';
import 'package:study_group_front_end/notification_service/local/local_notifications_service.dart';
import 'package:study_group_front_end/providers/checklist_item_provider.dart';
import 'package:study_group_front_end/providers/insight_provider.dart';
import 'package:study_group_front_end/providers/me_provider.dart';
import 'package:study_group_front_end/providers/personal_checklist_provider.dart';
import 'package:study_group_front_end/providers/personal_stats_provider.dart';
import 'package:study_group_front_end/providers/study_card_provider.dart';
import 'package:study_group_front_end/providers/study_join_provider.dart';
import 'package:study_group_front_end/providers/study_provider.dart';
import 'package:study_group_front_end/repository/checklist_item_repository.dart';
import 'package:study_group_front_end/router.dart';

Future<void> main() async {
  //비동기 작업 전에 Flutter 프레임워크 초기화 보장 -> 원래는 runApp에서 자동 초기화 되는데, 그 전에 초기화 해주어야해서
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp],
  );

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final localNotificationsService = LocalNotificationsService.instance();
  await localNotificationsService.init();

  await FcmInitializer.init(localNotificationsService: localNotificationsService);

  await initializeDateFormatting();


  runApp(
      MultiProvider(
        providers: [
          Provider<InMemoryChecklistItemRepository>(
            create: (_) => InMemoryChecklistItemRepository(
              ChecklistItemApiService(),
              PersonalChecklistApiService()
            ),
          ),
          ChangeNotifierProvider(
            create: (_) => MeProvider(AuthApiService(), MeApiService()),
          ),
          ChangeNotifierProvider(
            create: (context) => StudyProvider(
              StudyApiService(),
              context.read<InMemoryChecklistItemRepository>(),
            ),
          ),
          ChangeNotifierProvider(
              create: (_) => StudyJoinProvider(StudyJoinApiService()),
          ),
          //TODO inmemory 수정 바람
          ChangeNotifierProvider(
            create: (context) => ChecklistItemProvider(
              context.read<InMemoryChecklistItemRepository>(),
            ),
          ),
          ChangeNotifierProxyProvider2<MeProvider, StudyProvider, PersonalChecklistProvider>(
            create: (context) => PersonalChecklistProvider(
              context.read<InMemoryChecklistItemRepository>(),
            ),
            update: (context, me, study, previous) {
              final memberId = me.currentMember?.id ?? 0;
              final studies = study.studies;

              final repo = context.read<InMemoryChecklistItemRepository>();

              // ✅ 매번 최신 memberId, study 목록 반영
              final provider = previous ?? PersonalChecklistProvider(repo);
              provider.setMyStudies(studies);
              provider.setCurrentMemberId(memberId);

              return provider;
            },
          ),
          ChangeNotifierProxyProvider<PersonalChecklistProvider, PersonalStatsProvider>(
            create: (context) => PersonalStatsProvider(
              context.read<PersonalChecklistProvider>(),
            ),
            update: (context, checklistProvider, previous)
              => previous ?? PersonalStatsProvider(checklistProvider),
          ),
          ChangeNotifierProvider(
            create: (context) => StudyCardProvider(
              context.read<InMemoryChecklistItemRepository>(),
            ),
          ),
          ChangeNotifierProvider(
            create: (_) => InsightProvider(InsightApiService()),
          ),
        ],
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: router,
          theme: ThemeData(
            useMaterial3: true,
            fontFamily: 'Pretendard',

            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
            ),

            scaffoldBackgroundColor: Colors.white,

            colorScheme: ColorScheme.fromSeed(
              seedColor: Color(0xFF73B4E3),
              brightness: Brightness.light,
            ).copyWith(
              primary: const Color(0xFF73B4E3),
            ),

            textTheme: const TextTheme(
              displayLarge: TextStyle(fontSize: 36, fontWeight: FontWeight.w400),
              displayMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
              bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              bodyMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              bodySmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
            ),
            
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
                textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),

            filledButtonTheme: FilledButtonThemeData(
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ),
        )
      )
  );
}
