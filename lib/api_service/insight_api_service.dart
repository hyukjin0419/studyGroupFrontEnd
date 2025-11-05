import 'dart:convert';

import 'package:study_group_front_end/api_service/base_api_service.dart';
import 'package:study_group_front_end/dto/insight/weekly_insight_response.dart';

class InsightApiService extends BaseApiService {

  Future<WeeklyInsightResponse> getWeeklyInsight(DateTime startDate) async {
    final String start = startDate.toIso8601String().split('T').first;

    final response = await get(
      '/me/insights/weekly?startDate=$start'
    );

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(utf8.decode(response.bodyBytes));
      return WeeklyInsightResponse.fromJson(jsonBody);
    } else{
      throw Exception('[INSIGHT_API] Failed to fetch weekly insight: ${response.statusCode}');
    }
  }
}