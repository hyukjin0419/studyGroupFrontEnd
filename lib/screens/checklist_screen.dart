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

  void _addItem(String content){
    setState(() {
      items.add(ChecklistItem(
          id: items.length+1,
          content: content,
          isCompleted: false,
          createdByUserId: 1
      ));
    });
  }

  void _showAddDialog(BuildContext context){
    final controller = TextEditingController();
    showDialog(
        context: context,
        builder: (_)=> AlertDialog(
          title: Text("새 항목 추가"),
          content: TextField(controller: controller),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('취소')),
            TextButton(
              onPressed: () {
                final content = controller.text.trim();
                if(content.isNotEmpty) _addItem(content);
                Navigator.pop(context);
              },
              child: Text('추가'),
            ),
          ],
        ),
    );
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text('${widget.study.title}의 체크리스트')),
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
      floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddDialog(context),
          child: Icon(Icons.add),
      ),
    );
  }
}