import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_group_front_end/models/study.dart';
import 'package:study_group_front_end/models/study_member.dart';
import 'package:study_group_front_end/providers/member_provider.dart';
import 'package:study_group_front_end/providers/study_member_provider.dart';
import 'package:study_group_front_end/providers/study_provider.dart';

class StudyDetailScreen extends StatefulWidget {
  final int studyId;

  const StudyDetailScreen({super.key, required this.studyId});

  @override
  State<StudyDetailScreen> createState() => _StudyDetailScreenState();
}

class _StudyDetailScreenState extends State<StudyDetailScreen> {
  final TextEditingController _inviteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask((){
      context.read<StudyProvider>().fetchStudyDetail(widget.studyId);
    });
  }

  // void showEditStudyDialog(BuildContext context, StudyDetailResDto study){
  //   final nameController = TextEditingController(text: study.name);
  //   final descController = TextEditingController(text:study.description);
  //
  //   showDialog(
  //       context: context,
  //       builder: (_) => AlertDialog(
  //         title: const Text("스터디 수정"),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             TextField(
  //               controller: nameController,
  //               decoration: const InputDecoration(labelText: "스터디 이름"),
  //             ),
  //             const SizedBox(height: 8),
  //             TextField(
  //               controller: descController,
  //               decoration: const InputDecoration(labelText: "스터디 설명"),
  //             ),
  //           ],
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(context),
  //             child: const Text("취소"),
  //           ),
  //           ElevatedButton(
  //             onPressed: () async {
  //               final updateName = nameController.text.trim();
  //               final updateDesc = descController.text.trim();
  //
  //               if (updateName.isEmpty || updateDesc.isEmpty) {
  //                 ScaffoldMessenger.of(context).showSnackBar(
  //                   const SnackBar(content: Text("스터디 이름과 설명을 모두 입력해주세요.")),
  //                 );
  //                 return;
  //               }
  //
  //               final updateRequest = StudyUpdateReqDto(
  //                   name: updateName,
  //                   description: updateDesc
  //               );
  //
  //               await context.read<StudyProvider>().updateStudy(study.id, updateRequest);
  //
  //               Navigator.pop(context);
  //             },
  //             child: const Text("수정 완료"),
  //           )
  //         ]
  //       )
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final study = context.watch<StudyProvider>().selectedStudy;
    final currentUserId = context.watch<MemberProvider>().currentMember?.id;

    if (study == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isLeader = currentUserId == study.leaderId;

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
            if (isLeader) ...[
              Text("멤버 초대", style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              TextField(
                controller: _inviteController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "초대할 멤버 이메일",
                  prefixIcon: Icon(Icons.mail),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height:12),
              FilledButton.icon(
                onPressed: () async {
                    final email = _inviteController.text.trim();
                    if (email.isEmpty || !email.contains('@')){
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("올바른 이메일을 입력해주세요.")),
                      );
                      return;
                    }

                  final request = StudyMemberInviteReqDto(email: email);
                  await context.read<StudyMemberProvider>().inviteMember(
                    studyId: study.id,
                    leaderId: study.leaderId,
                    request: request
                  );
                  await context.read<StudyProvider>().fetchStudyDetail(study.id);

                  _inviteController.clear();
                },
                icon:const Icon(Icons.send),
                label: const Text("초대"),
              ),
            ],

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

            if (isLeader) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FilledButton.icon(
                      onPressed: () {
                        // showEditStudyDialog(context, study);
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text("수정")
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final confiremd = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                              title: const Text("스터디 삭제"),
                              content: const Text("정말 삭제하시겠습니까?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text("취소"),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text("삭제"),
                                )
                              ]
                          )
                      );
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text("삭제"),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                  )
                ],
              ),
            ],
          ],
        )
      )
    );
  }
}