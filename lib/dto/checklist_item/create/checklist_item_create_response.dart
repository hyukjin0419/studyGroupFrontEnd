import 'package:study_group_front_end/dto/base_res_dto.dart';

class ChecklistItemCreateResponse extends BaseResDto {
  final int checklistItemId;

  ChecklistItemCreateResponse({
    required this.checklistItemId,
    super.createdAt,
    super.modifiedAt,
  });

  factory ChecklistItemCreateResponse.fromJson(Map<String, dynamic> json) {
    return ChecklistItemCreateResponse(
      checklistItemId: json['checklistItemId'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      modifiedAt: json['modifiedAt'] != null ? DateTime.parse(json['modifiedAt']) : null,
    );
  }
}