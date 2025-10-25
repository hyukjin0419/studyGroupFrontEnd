import 'package:flutter/material.dart';
import 'package:study_group_front_end/providers/personal_checklist_provider.dart';

class PersonalStatsProvider extends ChangeNotifier {
  final PersonalChecklistProvider checklistProvider;

  int _completedCount = 0;
  int _totalCount = 0;

  int get completedCount => _completedCount;
  int get totalCount => _totalCount;

  PersonalStatsProvider(this.checklistProvider) {
    checklistProvider.addListener(_updateFromChecklist);
    _updateFromChecklist();
  }

  void _updateFromChecklist() {
    final today = DateTime.now();
    final items = checklistProvider.todayItem.where((i) {
      final date = i.targetDate;
      return date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
    }).toList();

    _totalCount = items.length;
    _completedCount = items.where((i) => i.completed).length;

    notifyListeners();
  }

  @override
  void dispose() {
    checklistProvider.removeListener(_updateFromChecklist);
    super.dispose();
  }
}
