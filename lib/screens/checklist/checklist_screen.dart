import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:study_group_front_end/dto/study/detail/study_detail_response.dart';
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
          // CalendarWidget(
          //   selectedDate: selectedDate,
          //   onDateChanged: updateSelectedDate,
          // ),     // 📅 날짜 선택
          const SizedBox(height: 12),
          // Expanded(
          //   child: ListView(
          //     padding: const EdgeInsets.symmetric(horizontal: 16),
          //     children: const [
          //       MemberChecklistGroupView(memberName: "최혁진"),
          //       MemberChecklistGroupView(memberName: "정재훈"),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}
