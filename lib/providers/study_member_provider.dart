// import 'package:flutter/material.dart';
// import 'package:study_group_front_end/dto/study/detail/study_member_summary_response.dart';
// import 'package:study_group_front_end/providers/loading_notifier.dart';
// import 'package:study_group_front_end/service/study_member_api_service.dart';
//
// class StudyMemberProvider with ChangeNotifier, LoadingNotifier {
//   final StudyMemberApiService apiService;
//
//   StudyMemberProvider({required this.apiService});
//
//   List<StudyMemberSummaryResponse> _memberList = [];
//
//   List<StudyMemberSummaryResponse> get memberList => _memberList;
//
//   Future<void> fetchMembers(List<StudyMemberSummaryResponse> serverData) async {
//     _memberList = serverData;
//     notifyListeners();
//   }
//
//   Future<void> inviteMember({
//     required int studyId,
//     required int leaderId,
//     required StudyMemberSummaryResponse request,
//   }) async {
//     await runWithLoading(() async {
//       final response = await apiService.inviteMember(studyId, leaderId, request);
//
//
//       //이 코드가 필요한가??
//       _memberList.add(StudyMemberSummaryResponse(
//         id: response.memberId,
//         userName: response.userName,
//         role: response.role,
//         joinedAt: response.joinedAt,
//       ));
//       notifyListeners();
//     });
//   }
//
//
//   Future<void> removeMember({
//     required int studyId,
//     required int leaderId,
//     required int memberId,
//   }) async {
//     await runWithLoading(() async {
//       await apiService.removeMember(studyId, leaderId, memberId);
//       _memberList.removeWhere((m) => m.id == memberId);
//       notifyListeners();
//     });
//   }
//
//   void clear() {
//     _memberList = [];
//     notifyListeners();
//   }
// }
