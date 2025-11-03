import 'dart:convert';
import 'dart:developer';

import 'package:http/src/response.dart';
import 'package:study_group_front_end/api_service/Auth/token_manager.dart';
import 'package:study_group_front_end/dto/member/login/member_login_request.dart';
import 'package:study_group_front_end/dto/member/login/member_login_response.dart';
import 'package:study_group_front_end/dto/member/signup/member_create_request.dart';
import 'package:study_group_front_end/dto/member/signup/member_create_response.dart';
import 'package:study_group_front_end/api_service/base_api_service.dart';

class AuthApiService extends BaseApiService {
  final String basePath = "/auth";

  Future<MemberCreateResponse> createMember(MemberCreateRequest request) async {
    final response = await post(
      '$basePath/create_member',
      request.toJson(),
      authRequired: false,
    );

    if (response.statusCode == 200) {
      return MemberCreateResponse.fromJson(jsonDecode(response.body));
    } else {
      var message = extractErrorMessageFromResponse(response);
      throw Exception(message);
    }
  }

  extractErrorMessageFromResponse(Response response) {
    final body = jsonDecode(response.body);
    final message = body['message'];
    return message;
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
      var message = extractErrorMessageFromResponse(response);
      throw Exception(message);
    }
  }

  Future<void> logout(String deviceToken) async {
    final response = await post(
      '$basePath/logout',
      {
        "deviceToken": deviceToken,
      },
      authRequired: true,
    );

    if (response.statusCode != 200) {
      throw Exception('logout failed: ${response.statusCode}');
    }
  }

  Future<void> sendEmailVerification(String email) async {
    final response = await post(
        '$basePath/email/send-verification-email?email=$email',
        null
    );
    if (response.statusCode == 200) {
      return;
    } else {
      var message = extractErrorMessageFromResponse(response);
      throw Exception(message);
    }
  }

  Future<void> sendIdRemainderEmail(String email) async {
    final response = await post(
        '$basePath/email/find-username?email=$email',
        null
    );
    if (response.statusCode == 200) {
      return;
    } else {
      var message = extractErrorMessageFromResponse(response);
      throw Exception(message);
    }
  }
}