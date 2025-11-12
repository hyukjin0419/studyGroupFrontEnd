import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_group_front_end/providers/checklist_item_provider.dart';
import 'package:study_group_front_end/providers/personal_checklist_provider.dart';
import 'package:study_group_front_end/providers/personal_stats_provider.dart';
import 'package:study_group_front_end/screens/checklist/common/header/weekly_calendar.dart';
import 'package:study_group_front_end/screens/checklist/personal/header/personal_header_card.dart';
import 'package:study_group_front_end/screens/checklist/personal/view_models/personal_checklist_group_view.dart';

//여기서 부터는 디자인이 없음.. 디자이너가 자기 졸업 프로젝트 폭파되었다고 일을 안함..ㅠ
class PersonalScreen extends StatefulWidget {
  const PersonalScreen({super.key});

  @override
  State<PersonalScreen> createState() => _PersonalScreenState();
}

class _PersonalScreenState extends State<PersonalScreen> {
  late PersonalChecklistProvider _personalChecklistProvider;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async{
      _personalChecklistProvider = context.read<PersonalChecklistProvider>();
      _personalChecklistProvider.initializeContext();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChecklistItemProvider>();
    final cardProvider = context.watch<PersonalStatsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "개인 체크리스트 화면",
          style: Theme.of(context).textTheme.bodyLarge!,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final provider = context.read<PersonalChecklistProvider>();
          await provider.fetchChecklistByWeek();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PersonalStatsCard(
                completedCount: cardProvider.completedCount,
                totalCount: cardProvider.totalCount,
              ),
              WeeklyCalendar(
                initialSelectedDay: provider.selectedDate,
                onDaySelected: (date) {
                  log(" 날짜: $date", name: "PersonalScreen");
                  _personalChecklistProvider.updateSelectedDate(date);
                },
              ),
              PersonalChecklistGroupView(selectedDate: provider.selectedDate!, primaryColor: Colors.teal)
            ],
          ),
        ),
      ),
    );
  }
}
