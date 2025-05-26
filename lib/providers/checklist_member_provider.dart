import 'package:flutter/material.dart';
import 'package:study_group_front_end/models/checklist_member.dart';
import 'package:study_group_front_end/providers/loading_notifier.dart';
import 'package:study_group_front_end/service/checklist_member_api_service.dart';

class ChecklistMemberProvider with ChangeNotifier, LoadingNotifier{
  final ChecklistMemberApiService apiService;

  ChecklistMemberProvider({required this.apiService});

  List<ChecklistMemberResDto> _memberChecklistList = [];
  List<StudyChecklistMemberResDto> _studyChecklistList = [];

  List<ChecklistMemberResDto> get memberChecklistList => _memberChecklistList;
  List<StudyChecklistMemberResDto> get studyChecklistList => _studyChecklistList;

  Future<void> fetchChecklistsByMemberId(int memberId) async {
    await runWithLoading(() async {
      _memberChecklistList = await apiService.getChecklistsByMemberId(memberId);
    });
  }

  Future<void> fetchChecklistsByStudyId(int studyId) async {
    await runWithLoading(() async {
      _studyChecklistList = await apiService.getChecklistByStudyId(studyId);
    });
  }

  Future<void> assignChecklist(ChecklistMemberAssignReqDto request) async {
    await runWithLoading(() async {
      await apiService.assignChecklist(request);
      await fetchChecklistsByStudyId(request.studyId);
    });
  }

  Future<void> changeChecklistStatus(ChecklistMemberAssignReqDto request) async {
    await runWithLoading(() async {
      await apiService.changeChecklistStatus(request);
      await fetchChecklistsByMemberId(request.memberId);
    });
  }

  Future<void> unassignChecklist({
    required int checklistId,
    required int memberId,
    required int studyId,
  }) async {
    await runWithLoading(() async {
      await apiService.unassignChecklist(checklistId, memberId);
      await fetchChecklistsByStudyId(studyId);
    });
  }

  void clear() {
    _memberChecklistList = [];
    _studyChecklistList = [];
    notifyListeners();
  }
}
