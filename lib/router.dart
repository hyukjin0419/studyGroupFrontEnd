import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:study_group_front_end/dto/study/detail/study_detail_response.dart';
import 'package:study_group_front_end/dto/study/update/study_update_request.dart';
import 'package:study_group_front_end/screens/auth/find_username_screen.dart';
import 'package:study_group_front_end/screens/auth/login_screen.dart';
import 'package:study_group_front_end/screens/auth/reset_password_screen.dart';
import 'package:study_group_front_end/screens/auth/sign_up_screen.dart';
import 'package:study_group_front_end/screens/checklist/personal/personal_screen.dart';
import 'package:study_group_front_end/screens/checklist/team/checklist_screen.dart';
import 'package:study_group_front_end/screens/common_widgets/custom_bottom_navigation_bar.dart';
import 'package:study_group_front_end/screens/insight/InsightScreen.dart';
import 'package:study_group_front_end/screens/setting/edit_email_screen.dart';
import 'package:study_group_front_end/screens/setting/edit_user_name_screen.dart';
import 'package:study_group_front_end/screens/setting/me_screen.dart';
import 'package:study_group_front_end/screens/setting/setting_screen.dart';
import 'package:study_group_front_end/screens/study_command/study_create_screen.dart';
import 'package:study_group_front_end/screens/study_command/study_update_screen.dart';
import 'package:study_group_front_end/screens/study_query/studies_screen.dart';
import 'package:study_group_front_end/screens/study_query/study_detail_screen.dart';
import 'package:study_group_front_end/screens/study_query/study_invitation_screen.dart';
import 'package:study_group_front_end/screens/study_query/study_join_screen_with_qr.dart';
import 'package:study_group_front_end/splash_screen.dart';
import 'package:study_group_front_end/util/navigator_key.dart';

final GoRouter router = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/find-username',
      builder: (context, state) => const FindUsernameScreen(),
    ),
    GoRoute(
      path: '/reset-password',
      builder: (context, state) => const ResetPasswordScreen(),
    ),
//==========================ShellRoute START==============================//
    ShellRoute(
      builder: (context, state,child){
        return Scaffold(
          body: child,
          bottomNavigationBar: CustomBottomNavigationBar(
            selectedIndex: _calculateIndex(state.uri.toString()),
          ),
        );
      },
      routes: [
        GoRoute(
            path: '/personal',
            pageBuilder: (context,state) => NoTransitionPage(
              child: const PersonalScreen()
            ),
        ),
        GoRoute(
            path: '/studies',
            pageBuilder: (context,state) => NoTransitionPage(
            child: const StudiesScreen(),
            ),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context,state) => NoTransitionPage(
            child: const SettingScreen(),
          ),
        ),
        GoRoute(
          path: '/insight',
          pageBuilder: (context,state) => NoTransitionPage(
            child: const InsightScreen(),
          ),
        ),
      ]
    ),
//==========================ShellRoute END==============================//
    GoRoute(
      path: '/studies/join',
      builder: (context, state) => const StudyJoinScreenWithQr(),
    ),

    GoRoute(
      path: '/studies/create',
      builder: (context, state) => StudyCreateScreen(),
    ),
    GoRoute(
      path: '/studies/:id/update',
      builder: (context, state) {
        final request = state.extra as StudyUpdateRequest;
        return StudyUpdateScreen(initialData: request);
      },
    ),
    GoRoute(
      path: '/studies/:id',
      builder: (context, state) {
        final studyId = int.parse(state.pathParameters['id']!);
        return StudyDetailScreen(studyId: studyId);
      }
    ),
    GoRoute(
      path: '/studies/invitation/:id',
      builder: (context, state) {
        final studyId = int.parse(state.pathParameters['id']!);
        return StudyInvitationScreen(studyId: studyId);
      }
    ),
    GoRoute(
      path: '/studies/:id/checklists',
      builder: (context, state) {
        final study = state.extra as StudyDetailResponse;
        return ChecklistScreen(study: study);
      }
    ),
    GoRoute(
        path: '/settings/me',
        builder: (context, state) {
          return MeScreen();
        }
    ),
    GoRoute(
        path: '/settings/me/edit-displayName',
        builder: (context, state) {
          return EditDisplayNameScreen();
        }
    ),
    GoRoute(
        path: '/settings/me/edit-email',
        builder: (context, state) {
          return EditEmailScreen();
        }
    ),
  ],
);


int _calculateIndex(String location) {
  if (location.startsWith('/personal')) return 0;
  if (location.startsWith('/studies')) return 1;
  if (location.startsWith('/schedule')) return 2;
  if (location.startsWith('/settings')) return 3;
  return 0;
}