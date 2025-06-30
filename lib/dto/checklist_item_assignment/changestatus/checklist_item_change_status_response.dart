import 'package:study_group_front_end/dto/base_res_dto.dart';

class ChecklistItemChangeStatusResponse extends BaseResDto {
  final int checklistId;
  final int memberId;
  final bool isCompleted;
  final DateTime? completedAt;

  ChecklistItemChangeStatusResponse({
    required this.checklistId,
    required this.memberId,
    required this.isCompleted,
    this.completedAt,
    super.createdAt,
    super.modifiedAt,
  });

  factory ChecklistItemChangeStatusResponse.fromJson(Map<String, dynamic> json) {
    return ChecklistItemChangeStatusResponse(
      checklistId: json['checklistId'],
      memberId: json['memberId'],
      isCompleted: json['isCompleted'],
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      modifiedAt: json['modifiedAt'] != null ? DateTime.parse(json['modifiedAt']) : null,
    );
  }
}
