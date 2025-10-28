import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:study_group_front_end/dto/checklist_item/create/checklist_item_create_request.dart';
import 'package:study_group_front_end/dto/checklist_item/detail/checklist_item_detail_response.dart';
import 'package:study_group_front_end/dto/study/detail/study_detail_response.dart';
import 'package:study_group_front_end/dto/study/detail/study_member_summary_response.dart';
import 'package:study_group_front_end/providers/loading_notifier.dart';
import 'package:study_group_front_end/repository/checklist_item_repository.dart';
import 'package:study_group_front_end/screens/checklist/team/view_models/member_checklist_group_vm.dart';
import 'package:study_group_front_end/util/date_calculator.dart';

class ChecklistItemProvider with ChangeNotifier, LoadingNotifier{
  final InMemoryChecklistItemRepository repository;
  ChecklistItemProvider(this.repository);

  List<MemberChecklistGroupVM> _groups = [];
  List<MemberChecklistGroupVM> get groups => _groups;

  List<StudyMemberSummaryResponse> _studyMembers = [];
  void setStudyMembers(List<StudyMemberSummaryResponse> members) => (_studyMembers = members);

  StudyDetailResponse? _study;
  StudyDetailResponse? get study => _study;
  void updateStudy(StudyDetailResponse? study) => _study = study;

  DateTime? _selectedDate = DateTime.now();
  DateTime? get selectedDate => _selectedDate;

  StreamSubscription<(bool delete, List<ChecklistItemDetailResponse> items)>? _subscription;

  //same date & in this study!
  Map<int, ChecklistItemDetailResponse> _filteredMap = {};
  List<ChecklistItemDetailResponse> get filteredItems => _filteredMap.values.toList();

  //same date
  Map<int, List<ChecklistItemDetailResponse>> _todayItems = {};

  //--------------로딩---------------------------//
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  //--------------------Init--------------------//
  //해당 Init은 특정 study화면에 들어갔을 때 실행됨
  void initializeContext(StudyDetailResponse? study, List<StudyMemberSummaryResponse> members) async {
    updateStudy(study);
    setStudyMembers(members);
    log("해당 스터디 ${_study!.id}의 members", name: "ChecklistItemProvider");
    for(var member in _studyMembers) {
      log("ㄴ ${member.userName}", name: "ChecklistItemProvider");
    }

    _selectedDate ??= DateTime.now();

    _subscription = repository.stream.listen((event) {
      final (isDelete, newItems) = event;

      if(isDelete) {
        _filteredMap.clear();
      }

      log("📡 stream 데이터 수신: ${newItems.length}개", name: "ChecklistItemProvider");

      _applyFiltering(newItems);
      _setLoading(false);
    });

    _setLoading(true);
    await repository.fetchChecklistByWeek(date: _selectedDate!,studyId: _study!.id);
  }

  Future<void> updateSelectedDate(DateTime newDate) async {
    if (!isSameDate(_selectedDate!, newDate)) {
      _filteredMap = {};
      clearGroups();
      _selectedDate = newDate;

      _setLoading(true);
      await repository.fetchChecklistByWeek(date: _selectedDate!,studyId: _study!.id);
    }
  }


  void _applyFiltering(List<ChecklistItemDetailResponse> newItems){
    log("applying Filter! studyId ${_study!.id}, date${_selectedDate!}", name: "ChecklistItemProvider");

    //study_card를 위한 stats
    final filteredByTodayDate = newItems.where((item) {
      final sameDate = isSameDate(item.targetDate, _selectedDate!);
      return sameDate;
    }).toList();

    _todayItems.clear();

    for(final item in filteredByTodayDate) {
      final studyId = item.studyId;
      _todayItems.putIfAbsent(studyId, () => <ChecklistItemDetailResponse>[]).add(item);
    }

    notifyListeners();

    //checklist_screen을 위한 stats
    final filtered = newItems.where((item) {
      final sameDate = isSameDate(item.targetDate, _selectedDate!);
      final inThisStudy = _study!.id == item.studyId;
      return sameDate && inThisStudy;
    }).toList();


    for (var item in filtered){
      log("Today: ${item.targetDate}, studyId: ${item.studyId}, checklistId: ${item.id}, content: ${item.content}", name: "ChecklistItemProvider");
      final id = item.id;
      final tempId = item.tempId;

      //임시 체크리스트 -> db 체크리스트로 교체
      if (tempId != null && _filteredMap.containsKey(tempId)) {
        final old = _filteredMap.remove(tempId)!;
        _filteredMap[id] = item.copyWith(orderIndex: old.orderIndex);
        continue;
      }

      //기존에 있는데 업데이트되는 경우를 위해
      if(_filteredMap.containsKey(item.id)){
        _filteredMap[item.id] = item;
        continue;
      }

      //신규 아이템
      _filteredMap[item.id] = item;
    }

    _updateGroups(_filteredMap.values.toList());
    _sortGroups();
    notifyListeners();
  }

  // ================= Grouping =================
  void clearGroups(){
    final Map<int, MemberChecklistGroupVM> groupMap = {
      for (var sm in _studyMembers)
        sm.studyMemberId : MemberChecklistGroupVM(
          studyMemberId: sm.studyMemberId,
          memberDisplayName: sm.displayName,
          items: [],
        )
    };
    _groups = groupMap.values.toList();
    notifyListeners();
  }

  void _updateGroups(List<ChecklistItemDetailResponse> items) {
    final Map<int, MemberChecklistGroupVM> groupMap = {
      for (var sm in _studyMembers)
        sm.studyMemberId : MemberChecklistGroupVM(
          studyMemberId: sm.studyMemberId,
          memberDisplayName: sm.displayName,
          items: [],
        )
    };
    for (final item in items){
      final studyMemberId = item.studyMemberId;
      if (groupMap.containsKey(studyMemberId)) {
        groupMap[studyMemberId]!.items.add(item);
      }
    }

    _sortGroups();
    _groups = groupMap.values.toList();
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

  // ================= Optimistic mutation =================
  Future<void> createChecklistItem(int studyMemberId, String content) async {
    final MemberChecklistGroupVM group = _groups.firstWhere((g) => g.studyMemberId == studyMemberId);
    final tempId = -DateTime.now().millisecondsSinceEpoch;

    final tempItem = ChecklistItemDetailResponse(
        id: tempId,
        tempId: null,
        type: "STUDY",
        studyId: _study!.id,
        studyName: _study!.name,
        memberId: -1,
        studyMemberId: studyMemberId,
        content: content,
        completed:false,
        targetDate: _selectedDate!,
        orderIndex: group.totalCount
    );

    log("createdChecklistItem시 Optimistic 하게 Item 추가", name: "ChecklistItemProvider");
    _filteredMap[tempId] = tempItem;
    _updateGroups(_filteredMap.values.toList());
    _sortGroups();
    notifyListeners();

    try{
      final request = ChecklistItemCreateRequest(
        tempId: tempId,
        content: content,
        assigneeId: studyMemberId,
        type: "STUDY",
        targetDate: _selectedDate!,
        orderIndex: group.totalCount,
      );

      await repository.createChecklistItem(studyId: study!.id, request: request, fromStudy: true);
    } catch (e, stackTrace) {
      //TODO 여기도 filteredItem에서 삭제
      if (_filteredMap.containsKey(tempId)) {
        _filteredMap.remove(tempId);
        _updateGroups(_filteredMap.values.toList());
        notifyListeners();
      }
      log("createdChecklistItem error $e", name: "ChecklistItemProvider");
      log("📍 Stack trace: $stackTrace");
      rethrow;
    }
  }

  Future<void> updateChecklistItemContent(ChecklistItemDetailResponse newItem) async {
    await repository.updateContent(newItem);
  }

  Future<void> updateChecklistItemStatus(ChecklistItemDetailResponse item) async {
    await repository.toggleStatus(item);
  }

  Future<void> softDeleteChecklistItem(ChecklistItemDetailResponse item) async {
    await repository.softDelete(item);
  }

  Future<void> reorderChecklistItem(List<ChecklistItemDetailResponse> requests) async {
    await repository.reorder(requests, _selectedDate!);
    notifyListeners();
  }

  List<ChecklistItemDetailResponse> buildReorderRequests() {
    return _groups.expand((group) {
      return group.items
          .asMap()
          .entries
          .map((entry) {
        final item = entry.value;

        return item;
      });
    }).toList();
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
    required ChecklistItemDetailResponse item,
    required int fromMemberId,
    required int fromIndex,
    required int toMemberId,
    required int toIndex,
  }) {
    final fromGroup = _groups.firstWhere((g) => g.studyMemberId == fromMemberId);
    final toGroup   = _groups.firstWhere((g) => g.studyMemberId == toMemberId);

    fromGroup.items.removeAt(fromIndex);

    item = item.copyWith(studyMemberId: toMemberId);

    toGroup.items.insert(toIndex, item);

    _reorderGroup(fromGroup);
    if (fromGroup != toGroup) {
      _reorderGroup(toGroup);
    }

    _sortGroups();

    notifyListeners();
  }

  int getIndexOf(ChecklistItemDetailResponse item) {
    final group = _groups.firstWhere((g) => g.studyMemberId == item.studyMemberId);
    return group.items.indexWhere((it) => it.id == item.id);
  }

  void _reorderGroup(MemberChecklistGroupVM group) {
    for (int i = 0; i < group.items.length; i++) {
      group.items[i].orderIndex = i;
    }
  }

  //============= Study Progress ==============
  double getProgress(int studyId){
    final items = _todayItems[studyId] ?? [];
    if (items.isEmpty) return 0.0;
    final completed = items.where((i) => i.completed).length;
    return completed / items.length;
  }

  Map<int, double> getProgressMap() {
    final Map<int, double> map = {};
    _todayItems.forEach((studyId, items){
      if (items.isEmpty) return;
      final completed = items.where((i) => i.completed).length;
      map[studyId] = completed / items.length;
    });
    return map;
  }
}

enum HoverStatus{
  hovering,
  notHovering,
}





























