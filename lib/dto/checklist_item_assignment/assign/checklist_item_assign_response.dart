import 'package:study_group_front_end/dto/base_res_dto.dart';

class ChecklistItemAssignResponse extends BaseResDto {
  final int checklistId;
  final int memberId;
  final DateTime assignedAt;

  ChecklistItemAssignResponse({
    required this.checklistId,
    required this.memberId,
    required this.assignedAt,
    super.createdAt,
    super.modifiedAt,
  });

  factory ChecklistItemAssignResponse.fromJson(Map<String, dynamic> json) {
    return ChecklistItemAssignResponse(
      checklistId: json['checklistId'],
      memberId: json['memberId'],
      assignedAt: DateTime.parse(json['assignedAt']),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      modifiedAt: json['modifiedAt'] != null ? DateTime.parse(json['modifiedAt']) : null,
    );
  }
}