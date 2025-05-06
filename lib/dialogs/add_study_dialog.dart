import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/member.dart';
import '../providers/study_provider.dart';
import '../models/study.dart';
import '../widgets/add_study_form.dart';

void showAddStudyDialog(BuildContext context){
  final nameController = TextEditingController();

  showDialog(
      context: context,
      builder:(_) => AlertDialog(
        title: Text("스터디 추가"),
        content: AddStudyForm(
          nameController: nameController,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("취소"),
          ),
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();

              if(name.isNotEmpty){
                final newStudy = Study(
                  id: DateTime.now().millisecondsSinceEpoch,
                  name: name,
                  members: [
                    Member(id: 4, userName: "나는 임시야", email: "E@E.com"),
                  ], description: 'test', leaderId: 1
                );

                context.read<StudyProvider>().addStudy(newStudy);

                Navigator.pop(context);
              }
            },
            child: Text("추가"),
          )
        ]
      )
  );
}