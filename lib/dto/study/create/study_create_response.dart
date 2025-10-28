import 'package:study_group_front_end/dto/base_res_dto.dart';

class StudyCreateResponse extends BaseResDto {
  final int id;
  final String name;
  final String description;
  final int leaderId;
  final String leaderName;
  final String personalColor;
  final DateTime dueDate;
  final String status;

  StudyCreateResponse({
    required this.id,
    required this.name,
    required this.description,
    required this.leaderId,
    required this.leaderName,
    required this.personalColor,
    required this.dueDate,
    required this.status,
    super.createdAt,
    super.modifiedAt,
  });

  factory StudyCreateResponse.fromJson(Map<String, dynamic> json) {
    return StudyCreateResponse(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      leaderId: json['leaderId'],
      leaderName: json['leaderName'],
      personalColor: json['personalColor'],
      dueDate: DateTime.parse(json['dueDate']),
      status: json['status'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      modifiedAt: json['modifiedAt'] != null ? DateTime.parse(json['modifiedAt']) : null,
    );
  }
}