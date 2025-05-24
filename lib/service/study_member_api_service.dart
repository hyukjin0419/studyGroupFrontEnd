import 'dart:convert';
import 'package:study_group_front_end/models/study_member.dart';
import 'package:study_group_front_end/service/base_api_service.dart';

class StudyMemberApiService extends BaseApiService {
  StudyMemberApiService({
    required super.baseUrl,
    super.client,
  });

  Future<StudyMemberInviteResDto> inviteMember(
      int studyId, int leaderId, StudyMemberInviteReqDto request) async {
    final response = await httpClient.post(
      uri('/studies/$studyId/members', ''),
      headers: {
        'Content-Type': 'application/json',
        'X-Leader-Id': leaderId.toString(),
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return StudyMemberInviteResDto.fromJson(decodeJson(response));
    } else {
      throw Exception('invite member failed: ${response.statusCode}');
    }
  }

  Future<StudyMemberRemoveResDto> removeMember(
      int studyId, int leaderId, int memberId) async {
    final response = await httpClient.delete(
      uri('/studies/$studyId/members', '/$memberId'),
      headers: {
        'X-Leader-Id': leaderId.toString(),
      },
    );

    if (response.statusCode == 200) {
      return StudyMemberRemoveResDto.fromJson(decodeJson(response));
    } else {
      throw Exception('remove member failed: ${response.statusCode}');
    }
  }
}
