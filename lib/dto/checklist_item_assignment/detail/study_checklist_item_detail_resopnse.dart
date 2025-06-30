import 'package:study_group_front_end/dto/base_res_dto.dart';

class StudyChecklistItemDetailResponse extends BaseResDto {
  final int checklistId;
  final String content;
  final int memberId;
  final String memberName;
  final bool isCompleted;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final DateTime? assignedAt;
  final int? personalOrderIndex;
  final int? studyOrderIndex;

  StudyChecklistItemDetailResponse({
    required this.checklistId,
    required this.content,
    required this.memberId,
    required this.memberName,
    required this.isCompleted,
    this.dueDate,
    this.completedAt,
    this.assignedAt,
    this.personalOrderIndex,
    this.studyOrderIndex,
    super.createdAt,
    super.modifiedAt,
  });

  factory StudyChecklistItemDetailResponse.fromJson(Map<String, dynamic> json) {
    return StudyChecklistItemDetailResponse(
      checklistId: json['checklistId'],
      content: json['content'],
      memberId: json['memberId'],
      memberName: json['memberName'],
      isCompleted: json['isCompleted'],
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      assignedAt: json['assignedAt'] != null ? DateTime.parse(json['assignedAt']) : null,
      personalOrderIndex: json['personalOrderIndex'],
      studyOrderIndex: json['studyOrderIndex'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      modifiedAt: json['modifiedAt'] != null ? DateTime.parse(json['modifiedAt']) : null,
    );
  }
}
