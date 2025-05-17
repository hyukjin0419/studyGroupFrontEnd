import 'package:flutter/material.dart';
import '../models/checklist.dart';
import '../mock/mock_checklists.dart';

class ChecklistProvider extends ChangeNotifier{
  final List<ChecklistItem> _items = [...mockChecklistItems];

  List<ChecklistItem> get items => _items;

  void toggleItem(int index){
    final item = _items[index];
    _items[index] = ChecklistItem(
        id: item.id,
        content: item.content,
        isCompleted: !item.isCompleted,
        createdByUserId: item.createdByUserId
    );
    notifyListeners();
  }

  void addItem(String content){
    final newItem = ChecklistItem(id: _items.length+1,
        content: content,
        isCompleted: false,
        createdByUserId: 1);
    _items.add(newItem);
    notifyListeners();
  }
}
