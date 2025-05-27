import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_group_front_end/models/study.dart';
import 'package:study_group_front_end/providers/study_provider.dart';

class StudyDetailScreen extends StatefulWidget {
  final int studyId;

  const StudyDetailScreen({super.key, required this.studyId});

  @override
  State<StudyDetailScreen> createState() => _StudyDetailScreenState();
}

class _StudyDetailScreenState extends State<StudyDetailScreen> {
  StudyDetailResDto? _study;

  @override
  void initState() {
    super.initState();
    Future.microtask((){
      context.read<StudyProvider>().fetchStudyDetail(widget.studyId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final study = context.watch<StudyProvider>().selectedStudy;

    if (study == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("스터디 상세")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("이름: ${study.name}", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text("Description: ${study.description}"),
            const SizedBox(height: 8),
            Text("리더: ${study.leaderName}"),
            const SizedBox(height: 8),
            const Divider(height: 32),
            const Text("멤버 목록", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: study.members.length,
                itemBuilder: (context, index) {
                  final member = study.members[index];
                  return ListTile(
                    title:Text(member.userName),
                    subtitle: Text(member.role),
                  );
                }
              ),
            ),
          ],
        )
      )
    );
  }
}