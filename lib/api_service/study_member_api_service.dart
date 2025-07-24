import 'dart:convert';
import 'package:study_group_front_end/dto/study_member/study_member_invite_request.dart';
import 'package:study_group_front_end/dto/study_member/study_member_invite_response.dart';
import 'package:study_group_front_end/dto/study_member/study_member_remove_response.dart';
import 'package:study_group_front_end/api_service/base_api_service.dart';

class StudyMemberApiService extends BaseApiService {
  final String basePath = "/studies";

  Future<StudyMemberInviteResponse> inviteMember(
      int studyId, StudyMemberInviteRequest request) async {
    final response = await post(
      '$basePath/$studyId/members',
      request.toJson(),
    );

    if (response.statusCode == 200) {
      return StudyMemberInviteResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('invite member failed: ${response.statusCode}');
    }
  }

  Future<StudyMemberRemoveResponse> removeMember(
      int studyId, int memberId) async {
    final response = await delete('$basePath/$studyId/members/$memberId');


    if (response.statusCode == 200) {
      return StudyMemberRemoveResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('remove member failed: ${response.statusCode}');
    }
  }
}
