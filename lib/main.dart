import 'package:flutter/material.dart';
import 'package:study_group_front_end/providers/me_provider.dart';
import 'package:study_group_front_end/providers/study_provider.dart';
import 'package:provider/provider.dart';
import 'package:study_group_front_end/router.dart';
import 'package:study_group_front_end/screens/LoginScreen.dart';
import 'package:study_group_front_end/service/auth_api_service.dart';
import 'package:study_group_front_end/service/me_api_service.dart';
import 'package:study_group_front_end/service/member_api_service.dart';
import 'package:study_group_front_end/service/study_api_service.dart';

void main() {
  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => MeProvider(AuthApiService(), MeApiService()),
            )
        ],
        child: MaterialApp.router(
          routerConfig: router,
          theme: ThemeData(useMaterial3: true),
        )
      )
  );
}
