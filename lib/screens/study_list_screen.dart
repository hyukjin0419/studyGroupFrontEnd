import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_group_front_end/providers/study_provider.dart';
import 'package:study_group_front_end/providers/member_provider.dart';
import 'package:study_group_front_end/models/study.dart';
// import 'study_detail_screen.dart';

class StudyListScreen extends StatefulWidget {
  const StudyListScreen({super.key});

  @override
  State<StudyListScreen> createState() => _StudyListScreenState();
}

class _StudyListScreenState extends State<StudyListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final memberId = context.read<MemberProvider>().currentMember?.id;
      if(memberId != null){
        context.read<StudyProvider>().fetchStudiesByMemberId(memberId);
      }
    });
  }

  void _showCreateDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final studyProvider = context.read<StudyProvider>();
    final memberId = context.read<MemberProvider>().currentMember?.id;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("새 스터디 만들기"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "스터디 이름"),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: "스터디 설명"),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("취소"),
          ),
          ElevatedButton(
              onPressed: () async {
                if (memberId != null) {
                  final request = StudyCreateReqDto(
                      name: nameController.text,
                      description: descController.text,
                      leaderId: memberId
                  );
                  await studyProvider.createStudy(request);
                  Navigator.pop(context);
                }
              },
              child: const Text("생성"),
          ),
        ],
      )
    );
  }



  @override
  Widget build(BuildContext context) {
    final studyProvider = context.watch<StudyProvider>();
    final studies = studyProvider.studies;

    return Scaffold(
      appBar: AppBar(title: const Text("스터디 목록")),
      body: studies.isEmpty
      //여기서 멤버 id로 필터링 해야함
          ? const Center(child: Text("참여중인 스터디가 없습니다."))
          : ListView.builder(
              itemCount: studies.length,
              itemBuilder: (_, index) {
                final study = studies[index];
                return ListTile(
                  title: Text(study.name),
                  subtitle: Text(study.description),
                  onTap: (){
                    //일단 보류 -> 혹은 checklist 화면으로 이동
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //       // builder: (_) => ChecklistScreen(studyId: study.id),
                    //     )
                    // );
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      //일단 보류 -> 상세 페이지로 이동
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (_) => StudyDetailScreen(studyId: study.id),
                      //   )
                      // );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
          onPressed: () => _showCreateDialog(context),
          child: const Icon(Icons.add),
      ),
    );
  }
}