import 'package:study_group_front_end/dto/base_res_dto.dart';

class MyStudyListResponse extends BaseResDto{
  final int studyId;
  final String name;
  final String description;
  final int personalOrderIndex;

  MyStudyListResponse({
    required this.studyId,
    required this.name,
    required this.description,
    required this.personalOrderIndex,
    super.createdAt,
    super.modifiedAt,
  });

  factory MyStudyListResponse.fromJson(Map<String, dynamic> json) {
    return MyStudyListResponse(
      studyId: json['studyId'],
      name: json['name'],
      description: json['description'],
      personalOrderIndex: json['personalOrderIndex'],
      createdAt: DateTime.parse(json['createdAt']),
      modifiedAt: DateTime.parse(json['modifiedAt']),
    );
  }
}
