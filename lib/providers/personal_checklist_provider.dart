import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:study_group_front_end/dto/checklist_item/create/checklist_item_create_request.dart';
import 'package:study_group_front_end/dto/checklist_item/detail/checklist_item_detail_response.dart';
import 'package:study_group_front_end/dto/study/detail/study_detail_response.dart';
import 'package:study_group_front_end/providers/checklist_item_provider.dart';
import 'package:study_group_front_end/providers/loading_notifier.dart';
import 'package:study_group_front_end/repository/checklist_item_repository.dart';
import 'package:study_group_front_end/screens/checklist/personal/view_models/personal_checklist_group_vm.dart';
import 'package:study_group_front_end/util/date_calculator.dart';

class PersonalChecklistProvider with ChangeNotifier, LoadingNotifier {
  final InMemoryChecklistItemRepository _repository;
  PersonalChecklistProvider(this._repository);
  InMemoryChecklistItemRepository get repository => _repository;

  List<StudyDetailResponse> _myStudies = [];
  void setMyStudies(List<StudyDetailResponse> studies) => (_myStudies = studies);

  int _currentMemberId = 0;
  void setCurrentMemberId(int memberId) => _currentMemberId = memberId;

  DateTime? _selectedDate = DateTime.now();
  DateTime? get selectedDate => _selectedDate;

  StreamSubscription<(bool delete, List<ChecklistItemDetailResponse> items)>? _subscription;

  List<PersonalCheckListGroupVM> _groups = [];
  List<PersonalCheckListGroupVM> get groups => _groups;

  Map<int, ChecklistItemDetailResponse> _filteredMap = {};
  List<ChecklistItemDetailResponse> get filteredItems => _filteredMap.values.toList();

  Map<int, ChecklistItemDetailResponse> _todayItemsMap = {};
  List<ChecklistItemDetailResponse> get todayItem => _todayItemsMap.values.toList();

  //--------------로딩---------------------------//
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  //=================Init======================//
  void initializeContext() async{

    _selectedDate ??= DateTime.now();

    _subscription = repository.stream.listen((event) {
      final (isDelete, newItems) = event;

      if(isDelete) {
        _filteredMap.clear();
        _todayItemsMap.clear();
      }

      log("📡 stream 데이터 수신: ${newItems.length}개", name: "ChecklistItemProvider");

      _applyFiltering(newItems);
      _setLoading(false);
    });

    _setLoading(true);
    await repository.fetchChecklistByWeek(date: _selectedDate!,memberId: _currentMemberId);
  }

  Future<void> updateSelectedDate(DateTime newDate) async {
    if (!isSameDate(_selectedDate!, newDate)) {
      _filteredMap={};
      clearGroups();
      _selectedDate = newDate;

      _setLoading(true);
      await repository.fetchChecklistByWeek(date: newDate, memberId: _currentMemberId);
    }
  }

  void _applyFiltering(List<ChecklistItemDetailResponse> allItems){
    log("applying Filter! currentMemberId ${_currentMemberId}, date${_selectedDate}", name: "PersonalProvider");
    log("mystudies = ", name: "PersonalProvider");
    for(var studyId in _myStudies){
      log("ㄴ ${studyId.id}", name: "PersonalProvider");
    }
    //1차 필터링
    final filtered = allItems.where((item) {
      final sameMember = item.memberId == _currentMemberId;
      final inMyStudy = _myStudies.any((s)=>s.id == item.studyId);
      return sameMember && inMyStudy;
    }).toList();

    //personal stats 내용
    final today = DateTime.now();
    final todayItems = filtered.where((item) => isSameDate(item.targetDate, today)).toList();

    for (var item in todayItems){
      final id = item.id;
      final tempId = item.tempId;

      //임시 체크리스트 -> db 체크리스트로 교체
      if (tempId != null && _todayItemsMap.containsKey(tempId)) {
        final old = _todayItemsMap.remove(tempId)!;
        _todayItemsMap[id] = item.copyWith(orderIndex: old.orderIndex);
        continue;
      }

      //기존에 있는데 업데이트되는 경우를 위해
      if(_todayItemsMap.containsKey(item.id)){
        _todayItemsMap[item.id] = item;
        continue;
      }

      //신규 아이템
      _todayItemsMap[item.id] = item;
    }

    //UI 반영용 checklist
    final selectedDateItems =  filtered.where((item) => isSameDate(item.targetDate, _selectedDate!)).toList();

    for (var item in selectedDateItems){
      log("Today: ${item.targetDate}, studyId: ${item.studyId}, content: ${item.content}", name: "PersonalProvider");
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
    notifyListeners();
  }

  //========================== Grouping =========================
  void clearGroups(){
    final Map<int, PersonalCheckListGroupVM> groupMap = {
      for (var s in _myStudies)
        s.id : PersonalCheckListGroupVM(
          studyId: s.id,
          studyName: s.name,
          items: [],
        ),
    };

    _groups = groupMap.values.toList();
    notifyListeners();
  }

  void _updateGroups(List<ChecklistItemDetailResponse> items){
    final Map<int, PersonalCheckListGroupVM> groupMap = {
      for (var s in _myStudies)
        s.id : PersonalCheckListGroupVM(
          studyId: s.id,
          studyName: s.name,
          items: [],
        ),
    };

    for (final item in items){
      groupMap.putIfAbsent(
        item.studyId,
        ()=> PersonalCheckListGroupVM(
          studyId: item.studyId,
          studyName: item.studyName,
          items: [],
        ),
      );
        groupMap[item.studyId]!.items.add(item);
      }

    _groups = groupMap.values.toList();
    _sortGroups();
    notifyListeners();
  }

  void _sortGroups(){
    for (final group in _groups){
      group.items.sort((a,b) {
        if(a.completed == b.completed){
          return (a.orderIndex ?? 0).compareTo(b.orderIndex ?? 0);
        }
        return a.completed ? 1: -1;
      });
    }
  }

//TODO CRUD Provider
  // =============================== CRUD (Optimistic) ===========================//

  Future<void> createPersonalChecklist(int studyId, String content) async {
    final PersonalCheckListGroupVM group = _groups.firstWhere((g) => g.studyId == studyId);
    final tempId = -DateTime.now().millisecondsSinceEpoch;
    final study = _myStudies.firstWhere((s) => s.id == studyId);
    final studyMember = study.members.firstWhere((m) => m.memberId == _currentMemberId);

    final tempItem = ChecklistItemDetailResponse(
      id: tempId,
      tempId: null,
      type: "STUDY",
      studyId: studyId,
      studyName: group.studyName,
      memberId: -1,
      studyMemberId: studyMember.studyMemberId,
      content: content,
      completed: false,
      targetDate: _selectedDate!,
      orderIndex: group.totalCount,
    );

    log("createdChecklistItem시 Optimistic 하게 Item 추가", name: "PersonalChecklistProvider");
    _filteredMap[tempId] = tempItem;
    _updateGroups(_filteredMap.values.toList());
    notifyListeners();

    try{
      final request = ChecklistItemCreateRequest(
        tempId: tempId,
        content: content,
        assigneeId: studyMember.studyMemberId,
        type: "STUDY",
        targetDate: _selectedDate!,
        orderIndex: group.totalCount,
      );

      await repository.createChecklistItem(studyId: studyId, memberId: _currentMemberId, request: request, fromStudy: false);
    } catch (e, stackTrace) {
      if(_filteredMap.containsKey(tempId)) {
        _filteredMap.remove(tempId);
        _updateGroups(_filteredMap.values.toList());
        notifyListeners();
      }
      log("createdChecklistItem error $e", name: "PersonalChecklistProvider");
      log("📍 Stack trace: $stackTrace");
      rethrow;
    }
  }

  Future<void> updateChecklistItemContent(ChecklistItemDetailResponse newItem) async {
    await repository.updateContent(newItem);
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
    required int fromStudyId,
    required int fromIndex,
    required int toStudyId,
    required int toIndex,
  }) {
    final fromGroup = _groups.firstWhere((g) => g.studyId == fromStudyId);
    final toGroup   = _groups.firstWhere((g) => g.studyId == toStudyId);

    fromGroup.items.removeAt(fromIndex);

    item = item.copyWith(studyId: toStudyId);

    toGroup.items.insert(toIndex, item);

    _reorderGroup(fromGroup);
    if (fromGroup != toGroup) {
      _reorderGroup(toGroup);
    }

    _sortGroups();

    notifyListeners();
  }

  int getIndexOf(ChecklistItemDetailResponse item) {
    final group = _groups.firstWhere((g) => g.studyId == item.studyId);
    return group.items.indexWhere((it) => it.id == item.id);
  }

  void _reorderGroup(PersonalCheckListGroupVM group) {
    for (int i = 0; i < group.items.length; i++) {
      group.items[i].orderIndex = i;
    }
  }
}