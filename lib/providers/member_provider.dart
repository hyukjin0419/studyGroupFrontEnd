import 'package:flutter/material.dart';
import 'package:study_group_front_end/models/member.dart';
import 'package:study_group_front_end/providers/loading_notifier.dart';
import 'package:study_group_front_end/service/member_api_service.dart';

class MemberProvider with ChangeNotifier,LoadingNotifier {
  final MemberApiService apiService;

  MemberProvider({required this.apiService});

  MemberDetailResDto? _currentMember;
  List<MemberDetailResDto> _memberList = [];

  MemberDetailResDto? get currentMember => _currentMember;
  List<MemberDetailResDto> get memberList => _memberList;


  //오리지널
  // Future<void> login(MemberLoginReqDto request) async {
  //   _setLoading(true);
  //   try{
  //     final loginRes = await apiService.login(request);
  //     final member = await apiService.getMemberById(loginRes.id);
  //     _currentMember = member;
  //   } catch (e) {
  //     rethrow;
  //   } finally {
  //     _setLoading(false);
  //   }
  // }

  Future<void> login(MemberLoginReqDto request) async {
    await runWithLoading(() async {
      final loginRes = await apiService.login(request);
      final member = await apiService.getMemberById(loginRes.id);
      _currentMember = member;
    });
  }

  Future<void> create(MemberCreateReqDto request) async {
    await runWithLoading(() async {
      final created = await apiService.createMember(request);
      final member = await apiService.getMemberById(created.id);
      _currentMember = member;
    });
  }

  Future<MemberDetailResDto> getMemberById(int id) async {
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


  Future<void> update(MemberUpdateReqDto request) async {
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