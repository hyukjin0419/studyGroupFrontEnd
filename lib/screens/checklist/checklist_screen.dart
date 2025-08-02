import 'package:flutter/material.dart';

class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key});

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
        title: const Text('캡스톤시각디자인1'),
        leading: const BackButton(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StudyHeaderCard(),     // 🧾 스터디 카드
          CalendarWidget(
            selectedDate: selectedDate,
            onDateChanged: updateSelectedDate,
          ),     // 📅 날짜 선택
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: const [
                MemberChecklistGroupView(memberName: "최혁진"),
                MemberChecklistGroupView(memberName: "정재훈"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
