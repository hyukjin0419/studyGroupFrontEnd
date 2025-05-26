// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:study_group_front_end/providers/study_provider.dart';
// import 'package:study_group_front_end/screens/checklist_screen.dart';
// import 'package:study_group_front_end/widgets/study_tile.dart';
// import '../providers/study_provider.dart';
// import '../dialogs/add_study_dialog.dart';
//
// class StudyScreen extends StatelessWidget{
//
//   @override
//   Widget build(BuildContext context) {
//     final studies = context.watch<StudyProvider>().studies;
//
//     return Scaffold(
//       appBar: AppBar(title: Text("스터디 선택")),
//       body: ListView.builder(
//         itemCount: studies.length,
//         itemBuilder: (context, index) {
//           final study = studies[index];
//           return StudyTile(study: study);
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => showAddStudyDialog(context),
//         child: Icon(Icons.add),
//       ),
//     );
//   }
// }