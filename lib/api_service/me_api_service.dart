import 'dart:convert';

import 'package:http/src/response.dart';
import 'package:study_group_front_end/api_service/base_api_service.dart';
import 'package:study_group_front_end/dto/member/delete/member_delete_response.dart';
import 'package:study_group_front_end/dto/member/detail/member_detail_response.dart';
import 'package:study_group_front_end/dto/member/update/member_email_update_request.dart';
import 'package:study_group_front_end/dto/member/update/member_user_name_update_request.dart';

class MeApiService extends BaseApiService {
  final String basePath = "/me";

  Future<MemberDetailResponse> getMyInfo() async {
    final response = await get(basePath);
    if (response.statusCode == 200) {
      return MemberDetailResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("내 정보 조회 실패");
    }
  }

  Future<MemberDetailResponse> updateDisplayName(String userName) async {
    final MemberUserDisplayNameRequest request = MemberUserDisplayNameRequest(displayName: userName);
    final response = await post("$basePath/update-user-name", request.toJson());
    if (response.statusCode == 200) {
      return MemberDetailResponse.fromJson(jsonDecode(response.body));
    } else {
      var message = extractErrorMessageFromResponse(response);
      throw Exception(message);
    }
  }

  Future<MemberDetailResponse> updateEmail(String email) async {
    final MemberEmailUpdateRequest request = MemberEmailUpdateRequest(email: email);
    final response = await post("$basePath/update-email", request.toJson());
    if (response.statusCode == 200) {
      return MemberDetailResponse.fromJson(jsonDecode(response.body));
    } else {
      var message = extractErrorMessageFromResponse(response);
      throw Exception(message);
    }
  }

  Future<MemberDeleteResponse> deleteMyAccount() async {
    final response = await delete(basePath);
    if (response.statusCode == 200) {
      return MemberDeleteResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('내 회원 탈퇴 실패');
    }
  }


  extractErrorMessageFromResponse(Response response) {
    final body = jsonDecode(response.body);
    final message = body['message'];
    return message;
  }
}