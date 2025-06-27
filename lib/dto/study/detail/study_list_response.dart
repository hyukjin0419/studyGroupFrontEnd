import 'package:study_group_front_end/dto/base_res_dto.dart';

class StudyListResponse extends BaseResDto {
  final int id;
  final String name;
  final String description;

  StudyListResponse({
    required this.id,
    required this.name,
    required this.description,
    super.createdAt,
    super.modifiedAt,
  });

  factory StudyListResponse.fromJson(Map<String, dynamic> json) {
    return StudyListResponse(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      modifiedAt: json['modifiedAt'] != null ? DateTime.parse(json['modifiedAt']) : null,
    );
  }
}