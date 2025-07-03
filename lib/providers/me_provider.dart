import 'package:flutter/material.dart';
import 'package:study_group_front_end/dto/member/detail/member_detail_response.dart';
import 'package:study_group_front_end/dto/member/login/member_login_request.dart';
import 'package:study_group_front_end/dto/member/signup/member_create_request.dart';
import 'package:study_group_front_end/dto/member/update/member_update_request.dart';
import 'package:study_group_front_end/providers/loading_notifier.dart';
import 'package:study_group_front_end/service/auth_api_service.dart';
import 'package:study_group_front_end/service/Auth/token_manager.dart';
import 'package:study_group_front_end/service/me_api_service.dart';


class MeProvider with ChangeNotifier,LoadingNotifier {
  final AuthApiService authApiService;
  final MeApiService meApiService;

  MeProvider(this.authApiService, this.meApiService);

  MemberDetailResponse? _currentMember;
  // List<MemberDetailResponse> _memberList = [];

  MemberDetailResponse? get currentMember => _currentMember;
  // List<MemberDetailResponse> get memberList => _memberList;

  Future<void> login(MemberLoginRequest request) async {
    await runWithLoading(() async {
      final response = await authApiService.login(request);

      await TokenManager.setTokens(
        response.accessToken,
        response.refreshToken,
      );

      _currentMember = await meApiService.getMyInfo();
      notifyListeners();
    });
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
      await authApiService.logout();
      await TokenManager.clearTokens();
      _currentMember = null;
      notifyListeners();
    });
  }
}