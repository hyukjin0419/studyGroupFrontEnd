import 'dart:convert';

import 'package:study_group_front_end/api_service/base_api_service.dart';
import 'package:study_group_front_end/dto/personal_checklist/personal_checklist_detail_response.dart';

class PersonalChecklistApiService extends BaseApiService {
  final String basePath = "/personal";

  Future<List<PersonalChecklistDetailResponse>> getChecklistItemsOfStudyByWeek(DateTime startDate) async{
    final formattedDate = startDate.toIso8601String().split("T").first;

    final response = await get(
        '$basePath?startDate=$formattedDate'
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonList.map((e) => PersonalChecklistDetailResponse.fromJson(e)).toList();
    } else{
      throw Exception('[Checklist_Item_API_Service] getChecklistItemsOfStudyByWeek 실패: ${response.statusCode}');
    }
  }
}