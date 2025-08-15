import 'package:flutter/material.dart';
import 'package:study_group_front_end/api_service/checklist_item_api_service.dart';
import 'package:study_group_front_end/dto/checklist_item/create/checklist_item_create_request.dart';
import 'package:study_group_front_end/dto/checklist_item/detail/checklist_item_detail_response.dart';
import 'package:study_group_front_end/dto/checklist_item/update/checklist_item_content_update_request.dart';
import 'package:study_group_front_end/providers/loading_notifier.dart';

class ChecklistItemProvider with ChangeNotifier, LoadingNotifier {
  final ChecklistItemApiService checklistItemApiService;

  ChecklistItemProvider(this.checklistItemApiService);

  List<ChecklistItemDetailResponse> _checklists = [];

  List<ChecklistItemDetailResponse> get checklists => _checklists;


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

  Future<void> updateChecklistItemContent(int checklistItemId, ChecklistItemContentUpdateRequest request) async {
    await checklistItemApiService.updateChecklistItemContent(checklistItemId, request);
  }

  void clearItems() {
    _checklists = [];
    notifyListeners();
  }
}