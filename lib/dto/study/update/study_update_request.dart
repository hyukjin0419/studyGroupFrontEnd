import 'package:study_group_front_end/dto/study/detail/study_detail_response.dart';

class StudyUpdateRequest {
  final int studyId;
  final String name;
  final String description;
  final String personalColor;
  final DateTime? dueDate;
  final StudyStatus status;


  StudyUpdateRequest({
    required this.studyId,
    required this.name,
    this.description = "version1",
    required this.personalColor,
    this.dueDate,
    required this.status
  });

  Map<String, dynamic> toJson() => {
    'studyId' : studyId,
    'name': name,
    'description': description,
    'personalColor': personalColor,
    'dueDate': dueDate?.toIso8601String(),
    'status': status.name,
  };
}