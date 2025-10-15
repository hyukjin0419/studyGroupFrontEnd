import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_group_front_end/providers/me_provider.dart';
import 'package:study_group_front_end/providers/personal_checklist_provider.dart';
import 'package:study_group_front_end/providers/study_provider.dart';

//return true -> 로그인 유지중
//return false -> 로그인 필요
Future<bool> prefetchAll(BuildContext context) async {
  final meProvider = context.read<MeProvider>();
  final studyProvider = context.read<StudyProvider>();
  final personalChecklistProvider = context.read<PersonalChecklistProvider>();

  final isLoggedIn = await meProvider.loadCurrentMember();

  if (!isLoggedIn) {
    return false;
  }

  try {
    await Future.wait([
      studyProvider.getMyStudies(),
      personalChecklistProvider.fetchPersonalChecklists(),
    ]);
    return true;
  } catch (e) {
    log("[PrefetchAll] prefetch 실패: $e");
    return true;
  }
}
