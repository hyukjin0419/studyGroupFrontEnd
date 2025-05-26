import 'package:flutter/material.dart';
import 'package:study_group_front_end/models/study_member.dart';
import 'package:study_group_front_end/models/study.dart';
import 'package:study_group_front_end/providers/loading_notifier.dart';
import 'package:study_group_front_end/service/study_member_api_service.dart';

class StudyMemberProvider with ChangeNotifier, LoadingNotifier {
  final StudyMemberApiService apiService;

  StudyMemberProvider({required this.apiService});

  List<StudyMemberResDto> _memberList = [];

  List<StudyMemberResDto> get memberList => _memberList;

  Future<void> fetchMembers(List<StudyMemberResDto> serverData) async {
    _memberList = serverData;
    notifyListeners();
  }

  Future<void> inviteMember({
    required int studyId,
    required int leaderId,
    required StudyMemberInviteReqDto request,
  }) async {
    await runWithLoading(() async {
      final response = await apiService.inviteMember(studyId, leaderId, request);

      _memberList.add(StudyMemberResDto(
        id: response.memberId,
        userName: response.userName,
        role: response.role,
        joinedAt: response.joinedAt,
      ));
      notifyListeners();
    });
  }


  Future<void> removeMember({
    required int studyId,
    required int leaderId,
    required int memberId,
  }) async {
    await runWithLoading(() async {
      await apiService.removeMember(studyId, leaderId, memberId);
      _memberList.removeWhere((m) => m.id == memberId);
      notifyListeners();
    });
  }

  void clear() {
    _memberList = [];
    notifyListeners();
  }
}
