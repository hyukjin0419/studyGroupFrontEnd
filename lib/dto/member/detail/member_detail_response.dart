import 'package:study_group_front_end/dto/base_res_dto.dart';

class MemberDetailResponse extends BaseResDto {
  final int id;
  final String userName;
  final String displayName;
  final String email;

  MemberDetailResponse({
    required this.id,
    required this.userName,
    required this.displayName,
    required this.email,
    super.createdAt,
    super.modifiedAt,
  });

  factory MemberDetailResponse.fromJson(Map<String, dynamic> json){
    return MemberDetailResponse(
      id: json['id'],
      userName: json['userName'],
      displayName: json['displayName'],
      email: json['email'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      modifiedAt: json['modifiedAt'] != null ? DateTime.parse(
          json['modifiedAt']) : null,
    );
  }
}