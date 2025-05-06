import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/study_provider.dart';
import '../models/study.dart';
import '../widgets/add_study_form.dart';

void showAddStudyDialog(BuildContext context){
  final titleController = TextEditingController();

  showDialog(
      context: context,
      builder:(_) => AlertDialog(
        title: Text("스터디 추가"),
        content: AddStudyForm(
          titleController: titleController,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("취소"),
          ),
          TextButton(
            onPressed: () {
              final title = titleController.text.trim();

              if(title.isNotEmpty){
                final newStudy = Study(
                  id: DateTime.now().millisecondsSinceEpoch,
                  title: title,
                  members: [
                    User(id: 4, userName: "나는 임시야", email: "E@E.com"),
                  ]
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