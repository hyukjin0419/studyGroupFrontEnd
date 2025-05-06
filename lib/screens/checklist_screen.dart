import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/study.dart';
import '../widgets/checklist_tile.dart';
import '../providers/checklist_provider.dart';
import '../dialogs/add_checklist_dialog.dart';

class ChecklistScreen extends StatelessWidget {
  final Study study;
  const ChecklistScreen({required this.study});

  @override
  Widget build(BuildContext context){
    final provider = context.watch<ChecklistProvider>();
    final items = provider.items;
    
    return Scaffold(
      appBar: AppBar(title: Text('${study.title}의 체크리스트')),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context,index){
          final item = items[index];
          return ChecklistTile(
            item: item,
            onChange: () => context.read<ChecklistProvider>().toggleItem(index),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddChecklistDialog(
            context,
            (content) => context.read<ChecklistProvider>().addItem(content),
        ),
        child: Icon(Icons.add),
      ),
    );
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
              if(content.isNotEmpty){
                context.read<ChecklistProvider>().addItem(content);
              }
              Navigator.pop(context);
            },
            child: Text('추가'),
          ),
        ],
      ),
    );
  }
}


