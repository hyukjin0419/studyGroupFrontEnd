import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_group_front_end/providers/study_provider.dart';
import 'package:study_group_front_end/screens/study/widgets/create_study_dialog.dart';
import 'package:study_group_front_end/screens/study/widgets/study_card.dart';

class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<StudyProvider>(context, listen: false).getMyStudies());
  }

  @override
  Widget build(BuildContext context) {
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
        child: Consumer<StudyProvider> (
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final studies = provider.studies;

            return GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 10 / 9,
              children: studies.map((study) => StudyCard(study: study)).toList(),
            );
          }
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
