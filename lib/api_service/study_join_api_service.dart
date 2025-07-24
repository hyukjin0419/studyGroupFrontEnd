import 'package:study_group_front_end/api_service/base_api_service.dart';
import 'package:study_group_front_end/dto/study_member/fellower/study_join_request.dart';

class StudyJoinApiService extends BaseApiService {
  final String basePath = "/studies";

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