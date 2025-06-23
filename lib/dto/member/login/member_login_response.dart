import 'package:study_group_front_end/dto/base_res_dto.dart';

enum Role {USER,ADMIN}

class MemberLoginResponse {
  final int id;
  final String userName;
  final Role role;
  final String accessToken;
  final String refreshToken;

  MemberLoginResponse({
    required this.id,
    required this.userName,
    required this.role,
    required this.accessToken,
    required this.refreshToken
  });

  factory MemberLoginResponse.fromJson(Map<String,dynamic> json) {
    return MemberLoginResponse(
      id: json['id'],
      userName: json['userName'],
      role: _parseRole(json['role']),
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
    );
  }

  static Role _parseRole(String roleStr) {
    switch (roleStr) {
      case 'ADMIN':
        return Role.ADMIN;
      case 'USER':
      default:
        return Role.USER;
    }
  }



}
