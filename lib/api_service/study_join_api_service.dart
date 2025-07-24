import 'dart:convert';

import 'package:study_group_front_end/api_service/base_api_service.dart';
import 'package:study_group_front_end/dto/study_member/fellower/study_join_request.dart';
import 'package:study_group_front_end/dto/study_member/leader/study_join_code_response.dart';

class StudyJoinApiService extends BaseApiService {
  final String basePath = "/studies";

  Future<StudyJoinCodeResponse> getStudyJoinCode(int studyId) async{
    final response = await get(
      '$basePath/$studyId'
    );

    if(response.statusCode == 200) {
      return StudyJoinCodeResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('[StudyJoin] STUDY_JOIN_CODE_API 팀의 join code 조회 실패: ${response.statusCode}');
    }
  }

  Future<void> join (StudyJoinRequest request) async{
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
}