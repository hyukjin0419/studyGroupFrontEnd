import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:study_group_front_end/dto/member/delete/member_delete_response.dart';
import 'package:study_group_front_end/dto/member/detail/member_detail_response.dart';
import 'package:study_group_front_end/dto/member/update/member_update_request.dart';
import 'package:study_group_front_end/dto/study/detail/my_study_list_response.dart';
import 'package:study_group_front_end/dto/study/update/study_order_update_request.dart';
import 'package:study_group_front_end/service/base_api_service.dart';

class MeApiService extends BaseApiService {
  final String basePath = "/me";

  Future<MemberDetailResponse> getMyInfo() async {
    final response = await get(basePath);
    if (response.statusCode == 200) {
      debugPrint("1");
      return MemberDetailResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("내 정보 조회 실패");
    }
  }

  Future<MemberDetailResponse> updateMyInfo(MemberUpdateRequest request) async {
    final response = await post(basePath, request.toJson);
    if (response.statusCode == 200) {
      return MemberDetailResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("내 정보 업데이트 실패");
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

  Future<List<MyStudyListResponse>> getMyStudyList() async {
    final response = await get('$basePath/my-studies');
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonList.map((e) => MyStudyListResponse.fromJson(e)).toList();
    } else {
      throw Exception("내 스터디 목록 조회 실패");
    }
  }

  Future<void> updateMyStudyOrder(StudyOrderUpdateListRequest request) async {
    final response = await post(
      '$basePath/my-studies/order-update',
      request.toJson(),
    );
    if (response.statusCode != 200) {
      throw Exception('내 스터디 순서 변경 실패');
    }
  }
}