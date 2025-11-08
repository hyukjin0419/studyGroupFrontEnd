import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_group_front_end/providers/checklist_item_provider.dart';
import 'package:study_group_front_end/providers/me_provider.dart';
import 'package:study_group_front_end/providers/personal_checklist_provider.dart';
import 'package:study_group_front_end/providers/study_card_provider.dart';
import 'package:study_group_front_end/providers/study_provider.dart';
import 'package:study_group_front_end/repository/checklist_item_repository.dart';

//return true -> 로그인 유지중
//return false -> 로그인 필요
Future<bool> initIfLoggedIn(BuildContext context) async {
  final meProvider = context.read<MeProvider>();
  final studyProvider = context.read<StudyProvider>();
  final checklistRepository = context.read<InMemoryChecklistItemRepository>();
  final studyCardProvider = context.read<StudyCardProvider>();

  final isLoggedIn = await meProvider.loadCurrentMember();

  if (!isLoggedIn) return false;

  try {
    studyCardProvider.init();
    await studyProvider.getMyStudies();
    final studies = studyProvider.studies;

    //TODO 한번에 호출하는 api가 필요함. 현재 너무 많은 api 호출 발생. MVP이후 해결.
    for (final study in studies) {
      try{
        await checklistRepository.fetchChecklistByWeek(date: DateTime.now(), studyId: study.id, force: false);
      } catch (e) {
        log("화면 진입시 checklist prefetch 실패");
      }
    }
    return true;
  } catch (e) {
    log("[PrefetchAll] prefetch 실패: $e");
    return true;
  }
}
