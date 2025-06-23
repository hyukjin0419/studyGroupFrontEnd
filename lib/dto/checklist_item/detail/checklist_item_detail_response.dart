import 'package:study_group_front_end/dto/base_res_dto.dart';

class ChecklistItemDetailResponse extends BaseResDto {
  final int id;
  final int creatorId;
  final int? studyId;
  final String content;
  final DateTime? dueDate;

  ChecklistItemDetailResponse({
    required this.id,
    required this.creatorId,
    this.studyId,
    required this.content,
    this.dueDate,
    super.createdAt,
    super.modifiedAt,
  });

  factory ChecklistItemDetailResponse.fromJson(Map<String, dynamic> json) {
    return ChecklistItemDetailResponse(
      id: json['id'],
      creatorId: json['creatorId'],
      studyId: json['studyId'],
      content: json['content'],
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      modifiedAt: json['modifiedAt'] != null ? DateTime.parse(json['modifiedAt']) : null,
    );
  }
}