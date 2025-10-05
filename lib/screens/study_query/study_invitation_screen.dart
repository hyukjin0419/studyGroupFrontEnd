import 'dart:async';

import 'package:flutter/material.dart';
import 'package:study_group_front_end/api_service/member_api_service.dart';
import 'package:study_group_front_end/api_service/study_join_api_service.dart';
import 'package:study_group_front_end/dto/member/search/member_search_request.dart';
import 'package:study_group_front_end/dto/member/search/member_search_response.dart';
import 'package:study_group_front_end/dto/study_member/leader/study_member_invitation_request.dart';

class StudyInvitationScreen extends StatefulWidget {
  final int studyId;
  const StudyInvitationScreen({super.key, required this.studyId});

  @override
  State<StudyInvitationScreen> createState() => _StudyInvitationScreenState();
}

class _StudyInvitationScreenState extends State<StudyInvitationScreen> {
  final TextEditingController _searchController = TextEditingController();
  final MemberApiService _memberApiService = MemberApiService();
  final StudyJoinApiService _studyJoinApiService = StudyJoinApiService();

  List<MemberSearchResponse> _searchResults = [];
  Set<MemberSearchResponse> _selectedMembers = {};

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _searchMembers(_searchController.text);
    });
  }

  Future<void> _searchMembers(String keyword) async {
    if (keyword.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    final request = MemberSearchRequest(studyId: widget.studyId, keyword: keyword);
    final results = await _memberApiService.searchMembers(request);

    setState(() => _searchResults = results);
  }

  void _toggleSelection(MemberSearchResponse member) {
    setState(() {
      if (_selectedMembers.contains(member)) {
        _selectedMembers.remove(member);
      } else {
        _selectedMembers.add(member);
      }
    });
  }

  Future<void> _inviteMembers() async {
    final requests = _selectedMembers
        .map((e) => StudyMemberInvitationRequest(inviteeUuid: e.uuid))
        .toList();

    await _studyJoinApiService.inviteMember(widget.studyId, requests);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('초대 발송 메시지를 전송하였습니다.')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text("스터디 멤버 초대"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: "유저 이름 검색",
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final member = _searchResults[index];
                final selected = _selectedMembers.contains(member);

                return ListTile(
                  title: Text(member.userName),
                  trailing: selected
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.radio_button_unchecked),
                  onTap: () => _toggleSelection(member),
                );
              },
            ),
          ),
          if (_selectedMembers.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton.icon(
                onPressed: _inviteMembers,
                icon: const Icon(Icons.send),
                label: const Text("선택한 멤버 초대"),
              ),
            )
        ],
      ),
    );
  }
}


/*
화면 구성을 어떻게 해야하냐

화면 구성을 간단

일단 점점점 리스트에 추가하자
-> 초대하기 누르면
-> 검색창 생기게 하고
리스트 버튼 -> userName으로 구성 -> 이때 통신은 uuid로 한다.

문제는 검색어가 바뀔때마다 해당 uesrName가 포함된 List<memberId(mayby cryto)>가 반환되어야 함


 */