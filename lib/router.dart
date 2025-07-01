import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:study_group_front_end/providers/me_provider.dart';
import 'package:study_group_front_end/screens/LoginScreen.dart';

final GoRouter router = GoRouter(
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
    // GoRoute(
    //   path: '/signup',
    //   builder: (context, state) => const LoginScreen(),
    // ),
    // GoRoute(
    //   path: '/studies',
    //   builder: (context, state) => const LoginScreen(),
    // )
  ],
);
