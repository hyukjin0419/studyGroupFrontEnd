import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_group_front_end/dto/study/detail/study_detail_response.dart';
import 'package:study_group_front_end/providers/checklist_item_provider.dart';
import 'package:study_group_front_end/screens/checklist/widget/member_check_list_group_view.dart';
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
  late ChecklistItemProvider _checklistItemProvider;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async{
      _checklistItemProvider = context.read<ChecklistItemProvider>();
      _checklistItemProvider.initializeContext(widget.study.id, widget.study.members);
      // _checklistItemProvider.setStudyMembers(widget.study.members);
      // _checklistItemProvider.loadChecklists(_studyId, selectedDate);
    });
  }

  Future<void> updateSelectedDate(DateTime newDate) async {
    _checklistItemProvider.loadChecklists(newDate);

    setState(() {
      selectedDate = newDate;
    });
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
              log(" 날짜: $date");
              updateSelectedDate(date);
            },
          ),
          const SizedBox(height: 12),
          Expanded(                                 //체크리스트 부분
            child: MemberChecklistGroupView(
              study: widget.study,
              selectedDate: selectedDate,
              onChecklistCreated: () async {
                provider.loadChecklists(selectedDate);
              }
            ),
          ),
        ],
      ),
    );
  }
}
