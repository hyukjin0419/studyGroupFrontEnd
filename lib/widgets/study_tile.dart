// import 'package:flutter/material.dart';
// import '../models/study.dart';
// import '../screens/checklist_screen.dart';
//
// class StudyTile extends StatelessWidget{
//   final Study study;
//
//   const StudyTile({required this.study, Key? key}) : super(key:key);
//
//   @override
//   Widget build(BuildContext context){
//     return ListTile(
//       title: Text(study.name),
//       onTap: (){
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//               builder: (_) => ChecklistScreen(study: study),
//           ),
//         );
//       },
//     );
//   }
// }