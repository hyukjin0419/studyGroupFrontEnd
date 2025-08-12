import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:study_group_front_end/dto/study/detail/study_detail_response.dart';
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

  void updateSelectedDate(DateTime newDate) {
    setState(() {
      selectedDate = newDate;
    });
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
          WeeklyCalendar(
            study: widget.study,
            initialSelectedDay: DateTime.now(),
            onDaySelected: (date) {
              log("선택된 날짜: $date");
            },
          ),
          const SizedBox(height: 12),
          Expanded(
            child: MemberChecklistGroupView(
                study: widget.study,
                groups: [
              MemberChecklistGroupVM(
                memberName: '최혁진',
                items: const [
                  MemberChecklistItemVM(title: '사용자 관련 자료조사사용자 관련 자료조사사용자 관련 자료조사사용자 관련 자료조사사용자 관련 자료조사', completed: true),
                  MemberChecklistItemVM(title: '로그 수집 포맷 정의', completed: false),
                ],
              ),
              MemberChecklistGroupVM(
                memberName: '정재윤',
                items: const [
                  MemberChecklistItemVM(title: '온보딩 체크리스트 정리', completed: false),
                  MemberChecklistItemVM(title: '캘린더 스크롤 최적화', completed: false),
                ],
              ),
            ]),
          )
        ],
      ),
    );
  }
}
