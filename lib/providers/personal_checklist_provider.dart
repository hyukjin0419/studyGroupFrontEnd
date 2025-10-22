import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:study_group_front_end/dto/checklist_item/detail/checklist_item_detail_response.dart';
import 'package:study_group_front_end/dto/study/detail/study_detail_response.dart';
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

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  StreamSubscription<List<ChecklistItemDetailResponse>>? _subscription;

  List<ChecklistItemDetailResponse> _filteredItems = [];
  List<ChecklistItemDetailResponse> get filteredItems => _filteredItems;

  List<PersonalCheckListGroupVM> _groups = [];
  List<PersonalCheckListGroupVM> get groups => _groups;

  //=================Init======================//
  void initializeContext() async{
    _selectedDate = DateTime.now();
    _subscription = repository.stream.listen((allItems) {
      log("📡 [PersonalProvider] stream 데이터 수신: ${allItems.length}개");
      _applyFiltering(allItems);
    });

    await repository.fetchChecklistByWeek(date: _selectedDate,memberId: _currentMemberId);
  }

  Future<void> updateSelectedDate(DateTime newDate) async {
    if (!isSameDate(_selectedDate, newDate)) {
      clearGroups();
      _selectedDate = newDate;

      await repository.fetchChecklistByWeek(date: newDate, memberId: _currentMemberId);
    }
  }

  void _applyFiltering(List<ChecklistItemDetailResponse> allItems){
    log("applying Filter! currentMemberId ${_currentMemberId}, date${_selectedDate}");
    log("mystudies = ");
    for(var studyId in _myStudies){
      log("ㄴ ${studyId.id}");
    }
    final filtered = allItems.where((item) {
      final sameMember = item.memberId == _currentMemberId;
      final sameDate = isSameDate(item.targetDate, _selectedDate);
      final inMyStudy = _myStudies.any((s)=>s.id == item.studyId);
      return sameMember && sameDate && inMyStudy;
    }).toList();

    for (var item in filtered){
      log("Today: ${item.targetDate}, studyId: ${item.studyId}, content: ${item.content}");
    }

    _filteredItems = filtered;
    _groupByStudy(filtered);

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

  void _groupByStudy(List<ChecklistItemDetailResponse> items){
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

  // Future<void> createPersonalChecklist({
  //   required String content,
  //   required DateTime targetDate,
  //   required int studyId
  // }) async {
  //   final group = groupByStudy[studyId];
  //
  //   final tempItem = ChecklistItemDetailResponse(
  //     id: -DateTime.now().millisecondsSinceEpoch, //임시 ID
  //     studyId: studyId,
  //     type: "STUDY",
  //     studyMemberId:group!.studyMemberId,
  //     studyName: group.studyName,
  //     content: content,
  //     targetDate: targetDate,
  //     completed: false,
  //     orderIndex: group.totalCount,
  //   );
  //
  //   _personalChecklists.add(tempItem);
  //   notifyListeners();
  //
  //   try{
  //     final request = ChecklistItemCreateRequest(
  //       content: content,
  //       assigneeId: group.studyMemberId,
  //       type: "STUDY",
  //       targetDate: targetDate,
  //       orderIndex: group.totalCount,
  //     );
  //
  //     final created = await checklistItemApiService.createChecklistItemOfStudy(request, studyId);
  //
  //     final index= _personalChecklists.indexWhere((e) => e.id == tempItem.id);
  //     if(index >= 0){
  //        _personalChecklists[index] = created;
  //        notifyListeners();
  //     }
  //
  //   } catch (e) {
  //     _personalChecklists.removeWhere((e) => e.id == tempItem.id);
  //     notifyListeners();
  //     rethrow;
  //   }
  // }

  //버튼 에러 해결될때까지 일단 보류
  /*Future<void> updateContent (int checklistItemId, String content) async {
    final index = _personalChecklists.indexWhere((e) => e.id == checklistItemId);
    if (index < 0) return;

    final oldItem = _personalChecklists[index];
    _personalChecklists[index] = oldItem.copyWith(content: content);
    notifyListeners();

    try {
      await repository.updateContent(checklistItemId, oldItem.targetDate, content);
    } catch (e) {
      _personalChecklists[index] = oldItem;
      notifyListeners();
      rethrow;
    }
  }*/

  // Future<void> updateChecklistItemStatus(int checklistItemId, int studyId) async {
  //   await repository.toggleStatus(checklistItemId, _selectedDate);
  //   // repository.clearDateCache(_selectedDate);
  // }


  // =====================================================================================//
  // void sortPersonalChecklistsByCompletedThenOrder() {
  //   _personalChecklists.sort((a, b) {
  //     if (a.studyId != b.studyId) return a.studyId.compareTo(b.studyId);
  //     if (a.completed != b.completed) return a.completed ? 1 : -1;
  //     return (a.orderIndex ?? 0).compareTo(b.orderIndex ?? 0);
  //   });
  //
  //   notifyListeners();
  // }
}