import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:study_group_front_end/dto/study/detail/study_detail_response.dart';
import 'package:study_group_front_end/providers/me_provider.dart';
import 'package:study_group_front_end/screens/checklist/checklist_screen.dart';
import 'package:study_group_front_end/screens/login_screen.dart';
import 'package:study_group_front_end/screens/sign_up_screen.dart';
import 'package:study_group_front_end/screens/study_query/studies_screen.dart';
import 'package:study_group_front_end/screens/study_query/study_detail_screen.dart';
import 'package:study_group_front_end/screens/study_query/study_invitation_screen.dart';
import 'package:study_group_front_end/screens/study_query/study_join_screen_with_qr.dart';
import 'package:study_group_front_end/screens/study_command/study_create_screen.dart';
import 'package:study_group_front_end/util/navigator_key.dart';

final GoRouter router = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: '/login',

  redirect: (BuildContext context, GoRouterState state) {
    final meProvider = context.read<MeProvider>();
    final loggedIn = meProvider.currentMember != null;

    final loggingIn = state.uri.toString() == '/login' || state.uri.toString() == '/signup';

    if (!loggedIn && !loggingIn) {
      return '/login';
    }

    // if (loggedIn && loggingIn) {
    //   return '/studies';
    // }

    return null;
  }, routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/studies/join',
      builder: (context, state) => const StudyJoinScreenWithQr(),
    ),
    GoRoute(
      path: '/studies',
      builder: (context, state) => const StudiesScreen(),
    ),
  GoRoute(
    path: '/studies/create',
    builder: (context, state) => CreateStudyScreen(),
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
  ],
);
