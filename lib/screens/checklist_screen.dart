import 'package:flutter/material.dart';
import '../models/checklist_item.dart';
import '../mock/mock_checklists.dart';
import '../models/study.dart';
import '../widgets/checklist_tile.dart';

class ChecklistScreen extends StatefulWidget {
  final Study study;
  const ChecklistScreen({required this.study});

  @override
  _ChecklistScreenState createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen>{
  late List<ChecklistItem> items;

  @override
  void initState(){
    super.initState();
    items = List.from(mockChecklistItems);
  }

  void toggleItem(int index){
    setState(() {
      final item = items[index];
      items[index] = ChecklistItem(
          id: item.id,
          content: item.content,
          isCompleted: !item.isCompleted,
          createdByUserId: item.createdByUserId,
      );
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text('팀 체크리스트')),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context,index){
          final item = items[index];
          return ChecklistTile(
              item: item,
              onChange: () => toggleItem(index),
          );
        },
      ),
    );
  }
}