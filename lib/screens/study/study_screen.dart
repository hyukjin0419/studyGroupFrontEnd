import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:study_group_front_end/dto/study/create/study_create_request.dart';

import 'package:study_group_front_end/providers/me_provider.dart';
import 'package:study_group_front_end/screens/sign_up_screen.dart';
import 'package:study_group_front_end/screens/study/models/dummy_study.dart';
import 'package:study_group_front_end/screens/study/widgets/create_study_dialog.dart';
import 'package:study_group_front_end/screens/study/widgets/study_card.dart';
import 'package:study_group_front_end/service/study_api_service.dart';

class StudyScreen extends StatelessWidget {
  const StudyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final studies = dummyStudyList;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.school, color: Colors.indigo),
            SizedBox(width: 8),
            Text("Sync Mate"),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 10 / 9,
          children: studies.map((study) => StudyCard(study: study)).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const CreateStudyDialog(),
        ),
        child: const Icon(Icons.add),
      ),
      //skin
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(icon: Icon(Icons.person), label: '개인'),
          NavigationDestination(icon: Icon(Icons.groups), label: '팀'),
          NavigationDestination(icon: Icon(Icons.calendar_today), label: '시간표'),
          NavigationDestination(icon: Icon(Icons.settings), label: '설정'),
        ],
        selectedIndex: 0,
      ),
    );
  }
}
