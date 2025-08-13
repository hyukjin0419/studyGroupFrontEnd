import 'package:flutter/material.dart';
import 'package:study_group_front_end/api_service/checklist_item_api_service.dart';
import 'package:study_group_front_end/providers/loading_notifier.dart';

class ChecklistProvider with ChangeNotifier, LoadingNotifier {
  final ChecklistItemApiService _checklistItemApiService = ChecklistItemApiService();
  // final ChecklistItemAssignmentApiService _checklistItemAssignmentApiService = ChecklistItemAssignmentApiService();

  Future<void> loadChecklists(int studyId) async {
  //
  }

}

/*
import 'package:flutter/material.dart';
import 'package:study_group_front_end/dto/checklist/checklist_item_assignment.dart';
import 'package:study_group_front_end/services/api/checklist_item_api_service.dart';

class ChecklistProvider with ChangeNotifier {
  final ChecklistApiService _apiService = ChecklistApiService();

  List<ChecklistItemAssignment> _checklists = [];
  bool _isLoading = false;

  List<ChecklistItemAssignment> get checklists => _checklists;
  bool get isLoading => _isLoading;

  Future<void> loadChecklists(int studyId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _checklists = await _apiService.getChecklists(studyId);
    } catch (e) {
      debugPrint("Checklist 로드 실패: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addChecklist(String content, int assigneeId, String type) async {
    try {
      await _apiService.createChecklist(content: content, assigneeId: assigneeId, type: type);
      // 체크리스트 새로고침
      await loadChecklistsByAssignee(assigneeId);
    } catch (e) {
      debugPrint("Checklist 추가 실패: $e");
    }
  }

  Future<void> toggleChecklist(int checklistId) async {
    try {
      final index = _checklists.indexWhere((c) => c.checklistId == checklistId);
      if (index == -1) return;

      final item = _checklists[index];
      final updated = await _apiService.toggleChecklistStatus(item);

      _checklists[index] = updated;
      notifyListeners();
    } catch (e) {
      debugPrint("체크 상태 변경 실패: $e");
    }
  }

  // 멤버별 그룹핑
  Map<int, List<ChecklistItemAssignment>> get groupedByMember {
    final Map<int, List<ChecklistItemAssignment>> grouped = {};
    for (var item in _checklists) {
      grouped.putIfAbsent(item.memberId, () => []).add(item);
    }
    return grouped;
  }

  Future<void> loadChecklistsByAssignee(int memberId) async {
    try {
      _checklists = await _apiService.getChecklistsByMember(memberId);
      notifyListeners();
    } catch (e) {
      debugPrint("멤버별 Checklist 조회 실패: $e");
    }
  }

  void clear() {
    _checklists = [];
    notifyListeners();
  }
}

 */