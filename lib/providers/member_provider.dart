import 'package:flutter/material.dart';
import 'package:study_group_front_end/models/member.dart';
import 'package:study_group_front_end/service/member_api_service.dart';

class MemberProvider with ChangeNotifier {
  final MemberApiService apiService;

  MemberProvider({required this.apiService});

  MemberDetailResDto? _currentMember;
  bool _isLoading = false;

  MemberDetailResDto? get currentMember => _currentMember;
  bool get isLoading => _isLoading;

  Future<void> login(MemberLoginReqDto request) async {
    _setLoading(true);
    try{
      final loginRes = await apiService.login(request);
      final member = await apiService.getMemberById(loginRes.id);
      _currentMember = member;
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> create(MemberCreateReqDto request) async {
    _setLoading(true);
    try {
      final created = await apiService.createMember(request);
      final member = await apiService.getMemberById(created.id);
      _currentMember = member;
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void logout() {
    _currentMember = null;
    notifyListeners();
  }

  void _setLoading(bool value){
    _isLoading = value;
    notifyListeners();
  }
}