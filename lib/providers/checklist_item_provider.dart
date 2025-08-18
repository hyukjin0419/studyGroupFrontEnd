import 'dart:async';
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
//====================hovering enum==================//
  HoveredItem _hoveredItem = const HoveredItem(status: HoverStatus.notHovering);
  Timer? _outOfBoundTimer;

  HoveredItem get hoveredItem => _hoveredItem;

  void setHoveredItem(int itemId) {
    log("count 시작");
    _outOfBoundTimer?.cancel();
    if (_hoveredItem.itemId == itemId && _hoveredItem.status == HoverStatus.hovering) return;
    _hoveredItem = HoveredItem(itemId: itemId, status: HoverStatus.hovering);
    notifyListeners();
  }

  void clearHoveredItemAndResetTimer(int itemId) {
    log("리셋!");
    _hoveredItem = HoveredItem(itemId: itemId , status: HoverStatus.notHovering);
    notifyListeners();

    _outOfBoundTimer?.cancel();
  }

  // void clearHoveredItemAndStartTimer(int itemId) {
  //   log("hovering Item ID: ${_hoveredItem.itemId}");
  //   log("parameter itemID: $itemId");
  //
  //   _outOfBoundTimer?.cancel();
  //   _outOfBoundTimer = Timer(const Duration(milliseconds: 0), () {
  //     // 아직도 hover 중이 아니고, 이 아이템이 대상이 아닐 경우에만
  //     // log("끝!");
  //     if (_hoveredItem.status == HoverStatus.notHovering && _hoveredItem.itemId == itemId) {
  //       log("what???");
  //       // 렌더링 쪽에서 이 조건만 보고 안 보이게 할 수 있음
  //       _hoveredItem = HoveredItem(itemId: itemId, status: HoverStatus.outOfBound);
  //       notifyListeners();
  //     }
  //   });
  // }


  @override
  void dispose(){
    _outOfBoundTimer?.cancel();
    super.dispose();
  }

  HoverStatus getHoverStatusOfItem(int itemId) {
    if (_hoveredItem.status == HoverStatus.hovering && _hoveredItem.itemId == itemId) {
      return HoverStatus.hovering;
    }
    return HoverStatus.notHovering;
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
}

class HoveredItem {
  final int? itemId;
  final HoverStatus status;

  const HoveredItem({this.itemId, required this.status});
}
