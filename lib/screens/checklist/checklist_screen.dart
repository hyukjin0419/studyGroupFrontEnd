import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_group_front_end/api_service/checklist_item_api_service.dart';
import 'package:study_group_front_end/dto/checklist_item/detail/checklist_item_detail_response.dart';
import 'package:study_group_front_end/dto/member/detail/member_detail_response.dart';
import 'package:study_group_front_end/dto/study/detail/study_detail_response.dart';
import 'package:study_group_front_end/dto/study/detail/study_member_summary_response.dart';
import 'package:study_group_front_end/providers/checklist_item_provider.dart';
import 'package:study_group_front_end/screens/checklist/widget/checklists_tile/member_check_list_group_view.dart';
import 'package:study_group_front_end/screens/checklist/widget/checklists_tile/view_models/member_checklist_group_vm.dart';
import 'package:study_group_front_end/screens/checklist/widget/checklists_tile/view_models/member_checklist_item_vm.dart';
import 'package:study_group_front_end/screens/checklist/widget/study_header_card.dart';
import 'package:study_group_front_end/screens/checklist/widget/weekly_calendar.dart';

class ChecklistScreen extends StatefulWidget {
  final StudyDetailResponse study;

  const ChecklistScreen({super.key, required this.study});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  DateTime selectedDate = DateTime.now();
  List<ChecklistItemDetailResponse> items = [];
  bool isLoading = true;
  final ChecklistItemApiService checklistItemApiService = ChecklistItemApiService();

  void updateSelectedDate(DateTime newDate) {
    setState(() {
      selectedDate = newDate;
      _loadChecklists();
    });
  }

  @override
  void initState() {
    super.initState();
    _loadChecklists();
  }

  //TODO 지금은 전체 불러오고 있는데, 나중에는 targetDate로 필터링 해서 불러와야 함
  Future<void> _loadChecklists() async {
    setState(() => isLoading = true);
    try {
      final result = await checklistItemApiService.getChecklistItemsOfStudy(
          widget.study.id,
          selectedDate
      );
      setState(() {
        items = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      log("체크리스트 로딩 실패: $e");
    }
  }

  List<MemberChecklistGroupVM> _groupChecklistItemsByMember(
      List<ChecklistItemDetailResponse> items,
      List<StudyMemberSummaryResponse> studyMembers
  ) {

    final Map<int, String> memberNamesByStudyMemberId = {
      for (var sm in studyMembers) sm.studyMemberId : sm.userName
    };

    final Map<int, List<MemberChecklistItemVM>> grouped = {};

    for (final item in items) {
      final studyMemberId = item.studyMemberId;

      if(!grouped.containsKey(studyMemberId)){
        grouped[studyMemberId] = [];
      }

      grouped[studyMemberId]!.add(MemberChecklistItemVM(
        id: item.id,
        studyMemberId: studyMemberId,
        content: item.content,
        completed: item.completed,
        orderIndex: item.orderIndex,
      ));
    }

    return grouped.entries.map((entry) {
      final studyMemberId = entry.key;
      final items = entry.value;

      return MemberChecklistGroupVM(
        studyMemberId: studyMemberId,
        memberName: memberNamesByStudyMemberId[studyMemberId] ?? "Unknown (그럴 일은 없겠지만)",
        items: items,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('캡스톤시각디자인2'),
        leading: const BackButton(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StudyHeaderCard(study: widget.study),     // 🧾 스터디 카드
          WeeklyCalendar(                           // 달력
            study: widget.study,
            initialSelectedDay: DateTime.now(),
            onDaySelected: (date) {
              log("선택된 날짜: $date");
              _loadChecklists();
            },
          ),
          const SizedBox(height: 12),

          Expanded(                                 //체크리스트 부분
            child: MemberChecklistGroupView(
                study: widget.study,
                selectedDate: selectedDate,
                groups: _groupChecklistItemsByMember(items, widget.study.members),
            ),
          ),
        ],
      ),
    );
  }
}
