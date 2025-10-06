import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:study_group_front_end/providers/me_provider.dart';
import 'package:study_group_front_end/providers/personal_checklist_provider.dart';
import 'package:study_group_front_end/providers/study_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final meProvider = context.read<MeProvider>();
    final studyProvider = context.read<StudyProvider>();
    final personalChecklistProvider = context.read<PersonalChecklistProvider>();
    personalChecklistProvider.setSelectedDate(DateTime.parse("2025-10-02"));


    final isLoggedIn = await meProvider.loadCurrentMember();

    if (!isLoggedIn) {
      if (mounted) {context.go('/login');}
      return;
    }

    try {
      await Future.wait([
        studyProvider.getMyStudies(),
        personalChecklistProvider.fetchPersonalChecklists(),
      ]);

      if (mounted) {context.go('/personal');}
    } catch (e) {
      log("[Spalsh Screen] prefetch 실패: $e");
      if (mounted) {context.go('/personal');} //일단 메인 진입;
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
