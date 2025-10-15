import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_group_front_end/dto/checklist_item/detail/checklist_item_detail_response.dart';
import 'package:study_group_front_end/providers/checklist_item_provider.dart';
import 'package:study_group_front_end/providers/personal_checklist_provider.dart';
import 'package:study_group_front_end/screens/checklist/common/header/weekly_calendar.dart';
import 'package:study_group_front_end/screens/checklist/personal/header/personal_header_card.dart';

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
    });
  }

  Future<void> updateSelectedDate(DateTime newDate) async {
    _personalChecklistProvider.updateSelectedDate(newDate);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChecklistItemProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "개인 체크리스트 화면",
          style: Theme.of(context).textTheme.bodyLarge!,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.read<ChecklistItemProvider>().clear();
            Navigator.of(context).maybePop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 일단 하드코딩, 나중에 provider에서 계산
            PersonalStatsCard(
              completedCount: 4,
              totalCount: 6,
              streakDays: 5,
            ),
            WeeklyCalendar(
              initialSelectedDay: provider.selectedDate,
              onDaySelected: (date) {
                log(" 날짜: $date");
                updateSelectedDate(date);
              },
            ),
            const SizedBox(height: 12),
            Consumer<PersonalChecklistProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (provider.personalChecklists.isEmpty) {
                  return const Center(child: Text('체크리스트가 없습니다.'));
                }

                final List<ChecklistItemDetailResponse> items = provider.personalChecklists;
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final item = items[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: Icon(
                          item.completed ? Icons.check_circle : Icons.circle_outlined,
                          color: item.completed ? Colors.green : Colors.grey,
                        ),
                        title: Text(item.content),
                        subtitle: Text(
                          '마감일: ${item.targetDate.toString().split("T").first}',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            // MemberChecklistGroupView(
            //   study: widget.study,
            //   selectedDate: provider.selectedDate,
            // ),
          ],
        ),
      ),
    );
  }
}
