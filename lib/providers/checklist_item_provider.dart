import 'package:flutter/material.dart';
import 'package:study_group_front_end/api_service/checklist_item_api_service.dart';
import 'package:study_group_front_end/dto/checklist_item/create/checklist_item_create_request.dart';
import 'package:study_group_front_end/dto/checklist_item/detail/checklist_item_detail_response.dart';
import 'package:study_group_front_end/providers/loading_notifier.dart';

class ChecklistItemProvider with ChangeNotifier, LoadingNotifier {
  final ChecklistItemApiService checklistItemApiService;

  ChecklistItemProvider(this.checklistItemApiService);

  List<ChecklistItemDetailResponse> _checklists = [];
  ChecklistItemDetailResponse? _selectedChecklistItem;

  List<ChecklistItemDetailResponse> get checklists => _checklists;
  ChecklistItemDetailResponse? get selectedChecklistItem => _selectedChecklistItem;


  Future<void> createChecklistItem(ChecklistItemCreateRequest request, studyId) async {
    await runWithLoading(() async {
      await checklistItemApiService.createChecklistItemOfStudy(request, studyId);
    });
  }

  Future<void> getChecklists(int studyId, DateTime targetDate) async {
    await runWithLoading(() async {
      _checklists = await checklistItemApiService.getChecklistItemsOfStudy(studyId, targetDate);
    });
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