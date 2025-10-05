import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:study_group_front_end/dto/member/detail/member_detail_response.dart';
import 'package:study_group_front_end/dto/member/login/member_login_request.dart';
import 'package:study_group_front_end/dto/member/signup/member_create_request.dart';
import 'package:study_group_front_end/dto/member/update/member_update_request.dart';
import 'package:study_group_front_end/providers/loading_notifier.dart';
import 'package:study_group_front_end/api_service/auth_api_service.dart';
import 'package:study_group_front_end/api_service/Auth/token_manager.dart';
import 'package:study_group_front_end/api_service/me_api_service.dart';


class MeProvider with ChangeNotifier,LoadingNotifier {
  final AuthApiService authApiService;
  final MeApiService meApiService;

  MeProvider(this.authApiService, this.meApiService);

  MemberDetailResponse? _currentMember;

  MemberDetailResponse? get currentMember => _currentMember;

  Future<void> login(MemberLoginRequest request) async {
    await runWithLoading(() async {
      final response = await authApiService.login(request);

      await TokenManager.setTokens(
        response.accessToken,
        response.refreshToken,
      );

      log("accesstoken = ${await TokenManager.getAccessToken()}", name: "me_provider");
      log("refreshtoken = ${await TokenManager.getRefreshToken()}", name: "me_provider");


      _currentMember = await meApiService.getMyInfo();
      notifyListeners();
    });
  }

  Future<bool> loadCurrentMember() async {
    final token = await TokenManager.getAccessToken();
    if (token == null) return false;

    try {
      _currentMember = await meApiService.getMyInfo();
      notifyListeners();
      return true;
    } catch (e) {
      // 토큰 만료 or 서버 오류 → 토큰 제거
      await TokenManager.clearTokens();
      _currentMember = null;
      return false;
    }
  }


  Future<void> create(MemberCreateRequest request) async {
    await runWithLoading(() async {
      await authApiService.createMember(request);
      notifyListeners();
    });
  }

  Future<void> update(MemberUpdateRequest request) async {
    await runWithLoading(() async {
      _currentMember = await meApiService.updateMyInfo(request);
       notifyListeners();
    });
  }

  Future<void> delete(int id) async {
    await runWithLoading(() async {
      await meApiService.deleteMyAccount();
      _currentMember = null;
      notifyListeners();
    });
  }

  Future<void> logout() async {
    await runWithLoading(() async{
      final fcmToken = await TokenManager.getFcmToken(); // ✅ await 필요
      if (fcmToken == null) {
        throw Exception("로그아웃 실패: FCM 토큰 없음");
      }
      await authApiService.logout(fcmToken);
      await TokenManager.clearTokens();
      _currentMember = null;
      notifyListeners();
    });
  }
}