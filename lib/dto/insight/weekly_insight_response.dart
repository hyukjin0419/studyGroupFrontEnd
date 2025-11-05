import 'package:study_group_front_end/dto/insight/study_activity_dto.dart';

import 'daily_completion_dto.dart';

class WeeklyInsightResponse {
  final double completionRate;
  final int completedCount;
  final int totalCount;
  final int studyCount;
  final List<DailyCompletionDto> dailyChecklistCompletion;
  final List<StudyActivityDto> studyActivity;

  WeeklyInsightResponse({
    required this.completionRate,
    required this.completedCount,
    required this.totalCount,
    required this.studyCount,
    required this.dailyChecklistCompletion,
    required this.studyActivity,
  });

  factory WeeklyInsightResponse.fromJson(Map<String, dynamic> json) {
    return WeeklyInsightResponse(
      completionRate: (json['completionRate'] as num).toDouble(),
      completedCount: json['completedCount'],
      totalCount: json['totalCount'],
      studyCount: json['studyCount'],
      dailyChecklistCompletion: (json['dailyChecklistCompletion'] as List)
          .map((e) => DailyCompletionDto.fromJson(e))
          .toList(),
      studyActivity: (json['studyActivity'] as List)
          .map((e) => StudyActivityDto.fromJson(e))
          .toList(),
    );
  }
}
