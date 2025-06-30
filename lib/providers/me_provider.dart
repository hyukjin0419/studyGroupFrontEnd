import 'package:flutter/material.dart';
import 'package:study_group_front_end/dto/member/detail/member_detail_response.dart';
import 'package:study_group_front_end/dto/member/login/member_login_request.dart';
import 'package:study_group_front_end/dto/member/signup/member_create_request.dart';
import 'package:study_group_front_end/dto/member/update/member_update_request.dart';

import 'package:study_group_front_end/providers/loading_notifier.dart';
import 'package:study_group_front_end/service/member_api_service.dart';

class MemberProvider with ChangeNotifier,LoadingNotifier {
  final MemberApiService apiService;

  MemberProvider({required this.apiService});

  MemberDetailResponse? _currentMember;
  List<MemberDetailResponse> _memberList = [];

  MemberDetailResponse? get currentMember => _currentMember;
  List<MemberDetailResponse> get memberList => _memberList;

  Future<void> login(MemberLoginRequest request) async {
    await runWithLoading(() async {
      final loginRes = await apiService.login(request);
      final member = await apiService.getMemberById(loginRes.id);
      _currentMember = member;
    });
  }

  Future<void> create(MemberCreateRequest request) async {
    await runWithLoading(() async {
      final created = await apiService.createMember(request);
      final member = await apiService.getMemberById(created.id);
      _currentMember = member;
    });
  }

  Future<MemberDetailResponse> getMemberById(int id) async {
    return await runWithLoading(() async {
      final member = await apiService.getMemberById(id);
      return member;
    });
  }

  Future<void> getAllMembers() async {
    await runWithLoading(() async {
      _memberList = await apiService.getAllMembers();
      notifyListeners();
    });
  }


  Future<void> update(MemberUpdateRequest request) async {
    await runWithLoading(() async {
      final updated = await apiService.updateMember(request);
      _currentMember = updated;
    });
  }

  Future<void> delete(int id) async {
    await runWithLoading(() async {
      await apiService.deleteMember(id);
      _currentMember = null;
    });
  }

  void logout() {
    _currentMember = null;
    notifyListeners();
  }
}