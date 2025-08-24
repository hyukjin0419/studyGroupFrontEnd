import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:study_group_front_end/api_service/checklist_item_api_service.dart';
import 'package:study_group_front_end/dto/checklist_item/create/checklist_item_create_request.dart';
import 'package:study_group_front_end/dto/checklist_item/detail/checklist_item_detail_response.dart';
import 'package:study_group_front_end/dto/checklist_item/update/checklist_item_content_update_request.dart';
import 'package:study_group_front_end/dto/checklist_item/update/checklist_item_reorder_request.dart';
import 'package:study_group_front_end/dto/study/detail/study_member_summary_response.dart';
import 'package:study_group_front_end/providers/loading_notifier.dart';
import 'package:study_group_front_end/screens/checklist/widget/checklists_tile/view_models/member_checklist_group_vm.dart';
import 'package:study_group_front_end/screens/checklist/widget/checklists_tile/view_models/member_checklist_item_vm.dart';

class ChecklistItemProvider with ChangeNotifier, LoadingNotifier {
  //Api 주입
  final ChecklistItemApiService checklistItemApiService;
  ChecklistItemProvider(this.checklistItemApiService);

  //변수
  List<ChecklistItemDetailResponse> _checklists = [];
  List<ChecklistItemDetailResponse> get checklists => _checklists;

  List<MemberChecklistGroupVM> _groups = [];
  List<MemberChecklistGroupVM> get groups => _groups;

  List<StudyMemberSummaryResponse> _studyMembers = [];
  void setStudyMembers(List<StudyMemberSummaryResponse> members) {
    _studyMembers = members;
  }

  int? _studyId;
  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate =>_selectedDate;

  void initializeContext(int studyId, List<StudyMemberSummaryResponse> members) {
    _studyId = studyId;
    _studyMembers = members;
    _selectedDate = DateTime.now();
    loadChecklists(_selectedDate);
  }

  void updateSelectedDate(DateTime newDate) {
    _selectedDate = newDate;
    loadChecklists(_selectedDate);
    notifyListeners();
  }


  //===============api용 Provier=================================//
  Future<void> loadChecklists(selectedDate) async {
    log("Date: $selectedDate");
    _checklists = await checklistItemApiService.getChecklistItemsOfStudy(_studyId!, selectedDate);
    updateGroups();
  }

  Future<void> createChecklistItem(ChecklistItemCreateRequest request) async {
    await runWithLoading(() async {
      await checklistItemApiService.createChecklistItemOfStudy(request, _studyId!);
    });
  }

  Future<void> updateChecklistItemContent(int checklistItemId, ChecklistItemContentUpdateRequest request) async {
    await checklistItemApiService.updateChecklistItemContent(checklistItemId, request);
  }

  Future<void> updateChecklistItemStatus(int checklistItemId) async {
    await checklistItemApiService.updateChecklistItemStatus(checklistItemId);
    await loadChecklists(_selectedDate);
  }

  Future<void> reorderChecklistItem() async {
    final List<ChecklistItemReorderRequest> request = [];

    for (final group in _groups){
      for(int i=0; i< group.items.length; i++) {
        final item = group.items[i];
        request.add(ChecklistItemReorderRequest(
          checklistItemId: item.id,
          studyMemberId: item.studyMemberId,
          orderIndex: i,
        ));
      }
    }

    await checklistItemApiService.reorderChecklistItem(request);
    loadChecklists(selectedDate);
  }

  void updateGroups(){
    final items = _checklists;
    log("여기서 부터 안 불러져 왔나? ${_checklists.length}");
    final Map<int, MemberChecklistGroupVM> groupMap = {
      for(var sm in _studyMembers)
        sm.studyMemberId: MemberChecklistGroupVM(
          studyMemberId: sm.studyMemberId,
          memberName: sm.userName,
          items: []
        )
    };

    for (final item in items) {
      final studyMemberId = item.studyMemberId;
      if (groupMap.containsKey(studyMemberId)) {
        groupMap[studyMemberId]!.items.add(MemberChecklistItemVM(
          id: item.id,
          studyMemberId: studyMemberId,
          content: item.content,
          completed: item.completed,
          orderIndex: item.orderIndex,
        ));
      }
    }

    _groups = groupMap.values.toList();

    sortChecklistGroupsByCompletedThenOrder();
    notifyListeners();
  }

  //====================hovering enum==================//
  int? _hoveredItemId;

  void setHoveredItem(int itemId) {
    _hoveredItemId = itemId;
    notifyListeners();
  }

  void clearHoveredItem(int itemId) {
    _hoveredItemId = null;
    notifyListeners();
  }

  HoverStatus getHoverStatusOfItem(int itemId) {
    return _hoveredItemId == itemId
        ? HoverStatus.hovering
        : HoverStatus.notHovering;
  }

  //====================drag & drop==================//
  void moveItem({
    required MemberChecklistItemVM item,
    required int fromMemberId,
    required int fromIndex,
    required int toMemberId,
    required int toIndex,
  }) {
    final fromGroup = _groups.firstWhere((g) => g.studyMemberId == fromMemberId);
    final toGroup   = _groups.firstWhere((g) => g.studyMemberId == toMemberId);

    // 1. 기존 위치에서 제거
    fromGroup.items.removeAt(fromIndex);

    // 2. 소속 멤버 ID 수정
    item.studyMemberId = toMemberId;

    // 3. 새로운 위치에 삽입
    toGroup.items.insert(toIndex, item);

    // 4. 정렬 인덱스 재정렬
    _reorderGroup(fromGroup);
    if (fromGroup != toGroup) {
      _reorderGroup(toGroup);
    }

    sortChecklistGroupsByCompletedThenOrder();

    // 5. 상태 갱신
    notifyListeners();
  }

  int getIndexOf(MemberChecklistItemVM item) {
    final group = _groups.firstWhere((g) => g.studyMemberId == item.studyMemberId);
    return group.items.indexWhere((it) => it.id == item.id);
  }

  void _reorderGroup(MemberChecklistGroupVM group) {
    for (int i = 0; i < group.items.length; i++) {
      group.items[i].orderIndex = i;
    }
  }

  void sortChecklistGroupsByCompletedThenOrder() {
    // log("complete로 그룹 reordre");
    for (final group in _groups) {
      group.items.sort((a, b) {
        if (a.completed == b.completed) {
          return (a.orderIndex ?? 0).compareTo(b.orderIndex ?? 0);
        }
        return a.completed ? 1 : -1;
      });
    }
  }
}

enum HoverStatus{
  hovering,
  notHovering,
}