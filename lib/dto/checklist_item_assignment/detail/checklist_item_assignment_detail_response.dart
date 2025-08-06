import 'package:study_group_front_end/dto/base_res_dto.dart';

class ChecklistItemAssignmentDetailResponse extends BaseResDto {
  final int checklistId;
  final String content;
  final bool completed;
  final int memberId;
  final String memberName;
  final int? personalOrderIndex;
  final int? studyOrderIndex;

  ChecklistItemAssignmentDetailResponse({
    required this.checklistId,
    required this.content,
    required this.completed,
    required this.memberId,
    required this.memberName,
    this.personalOrderIndex,
    this.studyOrderIndex,
    super.createdAt,
    super.modifiedAt,
  });

  factory ChecklistItemAssignmentDetailResponse.fromJson(Map<String, dynamic> json) {
    return ChecklistItemAssignmentDetailResponse(
      checklistId: json['checklistId'],
      content: json['content'],
      completed: json['completed'],
      memberId: json['memberId'],
      memberName: json['assignedAt'],
      personalOrderIndex: json['personalOrderIndex'],
      studyOrderIndex: json['studyOrderIndex'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      modifiedAt: json['modifiedAt'] != null ? DateTime.parse(json['modifiedAt']) : null,
    );
  }
}