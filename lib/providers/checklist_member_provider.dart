import 'package:flutter/material.dart';
import 'package:study_group_front_end/models/checklist_member.dart';
import 'package:study_group_front_end/providers/loading_notifier.dart';
import 'package:study_group_front_end/service/checklist_api_service.dart';

class ChecklistMemberProvider with ChangeNotifier, LoadingNotifier{
  final ChecklistApiService apiService;

  ChecklistMemberProvider({required this.apiService});

  List<ChecklistMemberResDto> _memberChecklists = [];
  List<StudyChecklistMemberResDto> _studyChecklists = [];

  List<ChecklistMemberResDto> get memberChecklists => _memberChecklists;
  List<StudyChecklistMemberResDto> get studyChecklists => _studyChecklists;

  Future<void> fetchChecklistsByMemberId(int memberId) async {
    await runWithLoading(() async {
      _memberChecklists = await apiService.getChecklistsByMemberId(memberId);
    });
  }

  Future<void> fetchChecklistsByStudyId(int studyId) async {
    await runWithLoading(() async {
      _studyChecklists = await apiService.getChecklistByStudyId(studyId);
    });
  }

  Future<void> assignChecklist(ChecklistMemberAssignReqDto req) async {
    await runWithLoading(() async {
      await apiService.assignChecklist(req);
      await fetchChecklistsByStudyId(req.studyId); // 데이터 최신화
    });
  }

  Future<void> changeStatus(ChecklistMemberAssignReqDto req) async {
    await runWithLoading(() async {
      await apiService.changeChecklistStatus(req);
      await fetchChecklistsByMemberId(req.memberId); // 개인 목록 갱신
    });
  }

  Future<void> unassignChecklist(int checklistId, int memberId, int studyId) async {
    await runWithLoading(() async {
      await apiService.unassignChecklist(checklistId, memberId);
      await fetchChecklistsByStudyId(studyId); // 공용 화면 갱신
    });
  }

  void clear() {
    _memberChecklists = [];
    _studyChecklists = [];
    notifyListeners();
  }
}
