import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:study_group_front_end/api_service/checklist_item_api_service.dart';
import 'package:study_group_front_end/dto/checklist_item/create/checklist_item_create_request.dart';
import 'package:study_group_front_end/dto/checklist_item/detail/checklist_item_detail_response.dart';
import 'package:study_group_front_end/dto/checklist_item/update/checklist_item_content_update_request.dart';
import 'package:study_group_front_end/dto/study/detail/study_member_summary_response.dart';
import 'package:study_group_front_end/providers/loading_notifier.dart';
import 'package:study_group_front_end/screens/checklist/widget/checklists_tile/view_models/member_checklist_group_vm.dart';
import 'package:study_group_front_end/screens/checklist/widget/checklists_tile/view_models/member_checklist_item_vm.dart';

class ChecklistItemProvider with ChangeNotifier, LoadingNotifier {
  final ChecklistItemApiService checklistItemApiService;

  ChecklistItemProvider(this.checklistItemApiService);

  List<ChecklistItemDetailResponse> _checklists = [];

  List<ChecklistItemDetailResponse> get checklists => _checklists;

  List<MemberChecklistGroupVM> _groups = [];

  List<MemberChecklistGroupVM> get groups => _groups;

  List<StudyMemberSummaryResponse> _studyMembers = [];

  void setStudyMembers(List<StudyMemberSummaryResponse> members) {
    _studyMembers = members;
  }

  DateTime _selectedDate = DateTime.now();

  DateTime get selectedDate => _selectedDate;

//==================hovering boolean=============//
  // int? _hoveredItemId; //드래그 중인 아이템의 현재 위치
  //
  // int? get hoveredItemId => _hoveredItemId;
  //
  // void setHoveredItem(int itemId) {
  //   _hoveredItemId = itemId;
  //   notifyListeners();
  // }
  //
  // void clearHoveredItem() {
  //   _hoveredItemId = null;
  //   notifyListeners();
  // }
  //
  // bool isHoveringItem(int id) => _hoveredItemId == id;
//====================hovering enum==================//
  HoveredItem _hoveredItem = const HoveredItem(status: HoverStatus.notHovering);

  HoveredItem get hoveredItem => _hoveredItem;

  void setHoveredItem(int itemId) {
    _hoveredItem = HoveredItem(itemId: itemId, status: HoverStatus.hovering);
    notifyListeners();
  }

  void setOutOfBound() {
    _hoveredItem = const HoveredItem(status: HoverStatus.outOfBound);
    notifyListeners();
  }

  void clearHoveredItem() {
    _hoveredItem = const HoveredItem(status: HoverStatus.notHovering);
    notifyListeners();
  }

  HoverStatus getHoverStatusOfItem(int itemId) {
    switch (_hoveredItem.status) {
      case HoverStatus.hovering:
        return _hoveredItem.itemId == itemId
            ? HoverStatus.hovering
            : HoverStatus.notHovering;

      case HoverStatus.outOfBound:
        return HoverStatus.outOfBound;

      case HoverStatus.notHovering:
        return HoverStatus.notHovering;
    }
  }




//===============api용 Provier=================================//
  Future<void> loadChecklists(int studyId, DateTime targetDate) async {
    _selectedDate = targetDate;
    _checklists = await checklistItemApiService.getChecklistItemsOfStudy(studyId, targetDate);
    updateGroups();
  }

  Future<void> createChecklistItem(ChecklistItemCreateRequest request, studyId) async {
    await runWithLoading(() async {
      await checklistItemApiService.createChecklistItemOfStudy(request, studyId);
    });
  }

  Future<void> getChecklists(int studyId, DateTime targetDate) async {
    await runWithLoading(() async {
      log ("시작");
      _checklists = await checklistItemApiService.getChecklistItemsOfStudy(studyId, targetDate);
      log("종료 ${_checklists.length}");
    });
  }

  Future<void> updateChecklistItemContent(int checklistItemId, ChecklistItemContentUpdateRequest request) async {
    await checklistItemApiService.updateChecklistItemContent(checklistItemId, request);
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
    notifyListeners();
  }


  //Drag & Drop용 함수
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

}

enum HoverStatus{
  hovering,
  notHovering,
  outOfBound,
}

class HoveredItem {
  final int? itemId;
  final HoverStatus status;

  const HoveredItem({this.itemId, required this.status});
}
