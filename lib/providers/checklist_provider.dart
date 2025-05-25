import 'package:flutter/material.dart';
import 'package:study_group_front_end/models/checklist.dart';
import 'package:study_group_front_end/providers/loading_notifier.dart';
import 'package:study_group_front_end/service/checklist_api_service.dart';

class ChecklistProvider with ChangeNotifier, LoadingNotifier {
  final ChecklistApiService apiService;

  ChecklistProvider({required this.apiService});

  ChecklistDetailResDto? _selectedChecklist;
  ChecklistDetailResDto? get selectedChecklist => _selectedChecklist;

  Future<void> createChecklist(int creatorId, ChecklistCreateReqDto req) async {
    await runWithLoading(() async {
      final res = await apiService.createChecklist(creatorId, req);
      _selectedChecklist = await apiService.getChecklistDetail(res.id);
    });
  }

  Future<void> fetchChecklistDetail(int checklistId) async {
    await runWithLoading(() async {
      _selectedChecklist = await apiService.getChecklistDetail(checklistId);
    });
  }

  Future<void> updateContent(int checklistId, String content) async {
    await runWithLoading(() async {
      await apiService.updateContent(checklistId, content);
      _selectedChecklist = await apiService.getChecklistDetail(checklistId);
    });
  }

  Future<void> updateDueDate(int checklistId, DateTime dueDate) async {
    await runWithLoading(() async {
      await apiService.updateDueDate(checklistId, dueDate);
      _selectedChecklist = await apiService.getChecklistDetail(checklistId);
    });
  }

  Future<void> deleteChecklist(int checklistId) async {
    await runWithLoading(() async {
      await apiService.deleteChecklist(checklistId);
      _selectedChecklist = null;
    });
  }

  void clearSelectedChecklist() {
    _selectedChecklist = null;
    notifyListeners();
  }
}
