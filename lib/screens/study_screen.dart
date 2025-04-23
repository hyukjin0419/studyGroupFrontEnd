import 'package:flutter/material.dart';
import 'package:study_group_front_end/screens/checklist_screen.dart';
import '../mock/mock_studies.dart';
import '../models/study.dart';

class StudyScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("스터디 선택")),
      body: ListView.builder(
        itemCount: mockStudies.length,
        itemBuilder: (context, index) {
          Study study = mockStudies[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(study.title),
              subtitle: Text('구성원: ${study.members.length}명'),
                onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context)=> ChecklistScreen(study: study),
                  ),
                );
              }
            ),
          );
        },
      ),
    );
  }
}