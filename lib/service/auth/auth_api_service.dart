import 'dart:convert';

import 'package:study_group_front_end/dto/member/login/member_login_request.dart';
import 'package:study_group_front_end/dto/member/login/member_login_response.dart';
import 'package:study_group_front_end/dto/member/signup/member_create_request.dart';
import 'package:study_group_front_end/dto/member/signup/member_create_response.dart';
import 'package:study_group_front_end/service/base_api_service.dart';

class AuthApiService extends BaseApiService {
  final String basePath = "/auth";

  AuthApiService({required super.baseUrl});

  Future<MemberCreateResponse> createMember(MemberCreateRequest request) async {
    final response = await httpClient.post(
      uri(basePath, ''),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return MemberCreateResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('create Study failed: ${response.statusCode}');
    }
  }


  Future<MemberLoginResponse> login(MemberLoginRequest request) async {
    final response = await httpClient.post(
      uri(basePath, '/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return MemberLoginResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('login failed: ${response.statusCode}');
    }
  }
}