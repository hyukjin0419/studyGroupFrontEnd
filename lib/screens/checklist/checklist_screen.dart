import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_group_front_end/dto/checklist_item/detail/checklist_item_detail_response.dart';
import 'package:study_group_front_end/dto/study/detail/study_detail_response.dart';
import 'package:study_group_front_end/dto/study/detail/study_member_summary_response.dart';
import 'package:study_group_front_end/providers/checklist_item_provider.dart';
import 'package:study_group_front_end/screens/checklist/widget/member_check_list_group_view.dart';
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
  late final int _studyId;
  late ChecklistItemProvider _checklistItemProvider;

  @override
  void initState() {
    super.initState();
    _studyId = widget.study.id;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checklistItemProvider = context.read<ChecklistItemProvider>();
      _checklistItemProvider.getChecklists(_studyId, selectedDate);
    });
  }

  void updateSelectedDate(DateTime newDate) {
    setState(() {
      selectedDate = newDate;
      _checklistItemProvider.getChecklists(_studyId, selectedDate);
    });
  }

  List<MemberChecklistGroupVM> _groupChecklistItemsByMember(
      List<ChecklistItemDetailResponse> items,
      List<StudyMemberSummaryResponse> studyMembers
  ) {
    final Map<int, MemberChecklistGroupVM> groupMap = {
      for (var sm in studyMembers)
        sm.studyMemberId: MemberChecklistGroupVM(
          studyMemberId: sm.studyMemberId,
          memberName: sm.userName,
          items: []
        )
    };

    for (final item in items) {
      final studyMemberId = item.studyMemberId;

      if(groupMap.containsKey(studyMemberId)) {
        groupMap[studyMemberId]!.items.add(MemberChecklistItemVM(
          id: item.id,
          studyMemberId: studyMemberId,
          content: item.content,
          completed: item.completed,
          orderIndex: item.orderIndex,
        ));
      } else {
        log("Warning: checklist item의 studyMemberId가 members에 없음: $studyMemberId");
      }
    }

    return groupMap.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChecklistItemProvider>();
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
            initialSelectedDay: selectedDate,
            onDaySelected: (date) {
              log("선택된 날짜: $date");
              updateSelectedDate(date);
            },
          ),
          const SizedBox(height: 12),

          Expanded(                                 //체크리스트 부분
            child: MemberChecklistGroupView(
              study: widget.study,
              selectedDate: selectedDate,
              groups: _groupChecklistItemsByMember(
                  provider.checklists, widget.study.members),
              onChecklistCreated: () {
                provider.getChecklists(_studyId, selectedDate);
              }
            ),
          ),
        ],
      ),
    );
  }
}
