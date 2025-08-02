import 'dart:convert';

import 'package:study_group_front_end/api_service/base_api_service.dart';
import 'package:study_group_front_end/dto/study_member/fellower/study_join_request.dart';
import 'package:study_group_front_end/dto/study_member/leader/study_member_invitation_request.dart';

class StudyJoinApiService extends BaseApiService {
  final String basePath = "/studies";

  Future<void> join (StudyJoinRequest request) async {
    final response = await post(
      '$basePath/join',
      request.toJson()
    );

    if (response.statusCode != 200) {
      throw Exception(
          '[StudyJoin] STUDY_JOIN__API 팀에 join 실패: ${response.statusCode}'
      );
    }
  }

  Future <void> inviteMember (int studyId, List<StudyMemberInvitationRequest> requestList) async {
    final response = await post(
      '$basePath/$studyId/invite',
      requestList.map((r) => r.toJson()).toList(),
    );

    if (response.statusCode != 200) {
      throw Exception(
          '[StudyJoin] Invite Member fcm 발송 실패: ${response.statusCode}'
      );
    }
  }

  Future<int> acceptInvitation(int invitationId) async {
    final response = await post(
      '$basePath/$invitationId/accept',
      null
    );

    if (response.statusCode != 200) {
      throw Exception('[StudyJoin] Invitation 수락 실패: ${response.statusCode}');
    }

    final data = (jsonDecode(response.body));
    final studyId = (data['studyId'] as num).toInt();

    return studyId;
  }

  Future<void> declineInvitation(int invitationId) async{
    final response = await post(
        '$basePath/$invitationId/decline',
        null
    );

    if (response.statusCode != 200) {
      throw Exception('[StudyJoin] Invitation 거절 실패: ${response.statusCode}');
    }
  }
}