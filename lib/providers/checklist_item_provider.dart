import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:study_group_front_end/dto/checklist_item/create/checklist_item_create_request.dart';
import 'package:study_group_front_end/dto/checklist_item/detail/checklist_item_detail_response.dart';
import 'package:study_group_front_end/dto/checklist_item/update/checklist_item_content_update_request.dart';
import 'package:study_group_front_end/dto/checklist_item/update/checklist_item_reorder_request.dart';
import 'package:study_group_front_end/dto/study/detail/study_member_summary_response.dart';
import 'package:study_group_front_end/providers/loading_notifier.dart';
import 'package:study_group_front_end/repository/checklist_item_repository.dart';
import 'package:study_group_front_end/screens/checklist/team/view_models/member_checklist_group_vm.dart';
import 'package:study_group_front_end/screens/checklist/team/view_models/member_checklist_item_vm.dart';

class ChecklistItemProvider with ChangeNotifier, LoadingNotifier{
  final InMemoryChecklistItemRepository repository;
  ChecklistItemProvider(this.repository);

  List<MemberChecklistGroupVM> _groups = [];
  List<MemberChecklistGroupVM> get groups => _groups;

  List<StudyMemberSummaryResponse> _studyMembers = [];
  void setStudyMembers(List<StudyMemberSummaryResponse> members) => (_studyMembers = members);

  int? _studyId;
  int? get studyId => _studyId;
  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  StreamSubscription<List<ChecklistItemDetailResponse>>? _subscription;

  //--------------------Init--------------------//
  void initializeContext(int studyId, List<StudyMemberSummaryResponse> members) async {
    _studyId = studyId;
    _studyMembers = members;
    _selectedDate = DateTime.now();

    await _subscribeToDate(_selectedDate);
  }

  Future<void> updateSelectedDate(DateTime newDate) async {
    _selectedDate = newDate;
    await _subscribeToDate(_selectedDate);
    notifyListeners();
  }

  Future<void> _subscribeToDate(DateTime date) async {
    log("_subscribeTodate 호출");
    if (_studyId == null) return;
    _groups=[];

    await _subscription?.cancel();

    final stream = repository.watchTeam(_studyId!, date);

    _subscription = stream.listen((items) {
      // log("📡 Stream 수신: ${items.length}개 아이템");
      // for (final item in items) {
      // //   log("   ↳ id=${item.id}, member=${item.studyMemberId}, done=${item.completed}, content=${item.content}");
      // }
      updateGroups(items);
      // log("✅ updateGroups 호출 후 _groups 길이: ${_groups.length}");
    });

    //listen이 watch 구독 후 초기 api 호출
    await repository.getTeamChecklist(_studyId!, date);
    // updateGroups(items);
  }

  // ================= exit =================
  void clear() {
    _studyId = null;
    _groups = [];
    _selectedDate = DateTime.now();
    notifyListeners();
  }

  // // ================= External Call =================
  // Future<void> refresh(int studyId, DateTime date) async {
  //   final items = await repository.getChecklistItems(studyId, date, force: true);
  //   updateGroups(items);
  // }





  // ================= Optimistic mutation =================
  Future<void> createChecklistItem(ChecklistItemCreateRequest request, String studyName) async {
    if (_studyId == null) return;
    await repository.create(_studyId!, request, studyName);
  }

  Future<void> updateChecklistItemContent(int checklistItemId, ChecklistItemContentUpdateRequest request) async {
    await repository.updateContent(checklistItemId, _studyId!, _selectedDate, request);
  }

  Future<void> updateChecklistItemStatus(int checklistItemId) async {
    if (_studyId == null) return;
    await repository.toggleStatus(checklistItemId, _studyId!, _selectedDate);
  }

  Future<void> softDeleteChecklistItem(int checklistItemId) async {
    if (_studyId == null) return;
    await repository.softDelete(checklistItemId, _studyId!, _selectedDate);
  }

  Future<void> reorderChecklistItem(List<ChecklistItemReorderRequest> requests) async {
    if (_studyId == null) return;
    await repository.reorder(requests, _studyId!, _selectedDate);
    notifyListeners();
  }

  List<ChecklistItemReorderRequest> buildReorderRequests() {
    return _groups.expand((group) {
      return group.items
          .asMap()
          .entries
          .map((entry) {
        final item = entry.value;

        return ChecklistItemReorderRequest(
          checklistItemId: item.id,
          studyMemberId: item.studyMemberId,
          orderIndex: item.orderIndex,
        );
      });
    }).toList();
  }

  // ================= Grouping =================
  void updateGroups(List<ChecklistItemDetailResponse> items) {
    final Map<int, MemberChecklistGroupVM> groupMap = {
      for (var sm in _studyMembers)
        sm.studyMemberId : MemberChecklistGroupVM(
          studyMemberId: sm.studyMemberId,
          memberName: sm.userName,
          items: [],
        )
    };
    for (final item in items){
      final studyMemberId = item.studyMemberId;
      if (groupMap.containsKey(studyMemberId)) {
        groupMap[studyMemberId]!.items.add(
          MemberChecklistItemVM(
              id: item.id,
              studyMemberId: studyMemberId,
              content: item.content,
              completed: item.completed,
              orderIndex: item.orderIndex,
          ),
        );
      }
    }

    _groups = groupMap.values.toList();
    _sortGroups();
    notifyListeners();
  }

  void _sortGroups() {
    for (final group in _groups){
      group.items.sort((a,b) {
        if(a.completed == b.completed) {
          return (a.orderIndex ?? 0).compareTo(b.orderIndex ?? 0);
        }
        return a.completed ? 1 : -1;
      });
    }
  }


  // ================= Drag & Drop =================
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
    log("complete로 그룹 reordre");
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





























