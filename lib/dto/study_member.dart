import 'base_res_dto.dart';

class StudyMemberInviteReqDto {
  final String email;

  StudyMemberInviteReqDto({required this.email});

  Map<String, dynamic> toJson() => {
    'email': email,
  };
}

class StudyMemberInviteResDto extends BaseResDto {
  final int studyId;
  final int memberId;
  final String userName;
  final String role;
  final DateTime joinedAt;

  StudyMemberInviteResDto({
    required this.studyId,
    required this.memberId,
    required this.userName,
    required this.role,
    required this.joinedAt,
    super.createdAt,
    super.modifiedAt,
  });

  factory StudyMemberInviteResDto.fromJson(Map<String, dynamic> json) {
    return StudyMemberInviteResDto(
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

class StudyMemberRemoveResDto {
  final int studyId;
  final int memberId;
  final String message;

  StudyMemberRemoveResDto({
    required this.studyId,
    required this.memberId,
    required this.message,
  });

  factory StudyMemberRemoveResDto.fromJson(Map<String, dynamic> json) {
    return StudyMemberRemoveResDto(
      studyId: json['studyId'],
      memberId: json['memberId'],
      message: json['message'],
    );
  }
}
