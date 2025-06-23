import 'package:study_group_front_end/dto/base_res_dto.dart';

class MemberCreateResponse extends BaseResDto {
  final int id;

  MemberCreateResponse({
    required this.id,
    super.createdAt,
    super.modifiedAt,
  });

  factory MemberCreateResponse.fromJson(Map<String, dynamic> json) {
    return MemberCreateResponse(
      id: json['id'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      modifiedAt: json['modifiedAt'] != null ? DateTime.parse(
          json['modifiedAt']) : null,
    );
  }
}