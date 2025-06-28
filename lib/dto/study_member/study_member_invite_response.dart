import 'package:study_group_front_end/dto/base_res_dto.dart';

class StudyMemberInviteResponse extends BaseResDto {
  final int studyId;
  final int memberId;
  final String userName;
  final String role;
  final DateTime joinedAt;

  StudyMemberInviteResponse({
    required this.studyId,
    required this.memberId,
    required this.userName,
    required this.role,
    required this.joinedAt,
    super.createdAt,
    super.modifiedAt,
  });

  factory StudyMemberInviteResponse.fromJson(Map<String, dynamic> json) {
    return StudyMemberInviteResponse(
      studyId: json['studyId'],
      memberId: json['memberId'],
      userName: json['userName'],
      role: json['role'],
      joinedAt: DateTime.parse(json['joinedAt']),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      modifiedAt: json['modifiedAt'] != null ? DateTime.parse(json['modifiedAt']) : null,
    );
  }
}

