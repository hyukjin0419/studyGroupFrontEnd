import 'dart:convert';

import 'package:study_group_front_end/dto/member/login/member_login_request.dart';
import 'package:study_group_front_end/dto/member/login/member_login_response.dart';
import 'package:study_group_front_end/dto/member/signup/member_create_request.dart';
import 'package:study_group_front_end/dto/member/signup/member_create_response.dart';
import 'package:study_group_front_end/service/base_api_service.dart';

class AuthApiService extends BaseApiService {
  final String basePath = "/auth";

  Future<MemberCreateResponse> createMember(MemberCreateRequest request) async {
    final response = await post(
      basePath,
      request.toJson(),
      authRequired: false,
    );

    if (response.statusCode == 200) {
      return MemberCreateResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('회원 가입 실패: ${response.statusCode}');
    }
  }


  Future<MemberLoginResponse> login(MemberLoginRequest request) async {
    final response = await post(
      '$basePath/login',
      request.toJson(),
      authRequired: false,
    );

    if (response.statusCode == 200) {
      return MemberLoginResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('login failed: ${response.statusCode}');
    }
  }

  Future<void> logout() async {
    final response = await post(
      'auth/logout',
      null,
    );

    if (response.statusCode != 200) {
      throw Exception('logout failed: ${response.statusCode}');
    }
  }
}