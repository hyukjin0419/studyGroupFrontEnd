import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:study_group_front_end/dto/checklist_item/detail/checklist_item_detail_response.dart';
import 'package:study_group_front_end/dto/study/detail/study_detail_response.dart';
import 'package:study_group_front_end/providers/loading_notifier.dart';
import 'package:study_group_front_end/repository/checklist_item_repository.dart';
import 'package:study_group_front_end/screens/checklist/personal/view_models/personal_checklist_group_vm.dart';

class PersonalChecklistProvider with ChangeNotifier, LoadingNotifier {
  late InMemoryChecklistItemRepository _repository;
  PersonalChecklistProvider(this._repository);
  InMemoryChecklistItemRepository get repository => _repository;

  List<PersonalCheckListGroupVM> _groups = [];
  List<PersonalCheckListGroupVM> get groups => _groups;

  List<StudyDetailResponse> _myStudies = [];
  void setMyStudies(List<StudyDetailResponse> studies) => (_myStudies = studies);

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;


  StreamSubscription<List<ChecklistItemDetailResponse>>? _subscription;

  //=================Init======================//
  void initializeContext() async{
    _selectedDate = DateTime.now();
    await _subscribeToDate(selectedDate);
  }

  Future<void> updateSelectedDate(DateTime newDate) async {
    _selectedDate = newDate;
    await _subscribeToDate(_selectedDate);
    notifyListeners();
  }

  Future<void> _subscribeToDate(DateTime date) async{
    log("_subscribeTodate 호출");
    _groups=[];

    await _subscription?.cancel();

    final stream = repository.watchPersonal(date,_myStudies);

    _subscription = stream.listen((items) {
      log("📡 Personal Stream 수신: ${items.length}개 아이템");
      for (final item in items) {
        log("   ㄴitem: studyId = ${item.studyId}, checklistItemId = ${item.id}, content = ${item.content}");
      }
      updateGroups(items);
      log("✅ updateGroups 호출 후 _groups 길이: ${_groups.length}");
    });

    await repository.getPersonalChecklist(date);
  }

  //완료 상태별 분리
  // List<ChecklistItemDetailResponse> get incompleteItems =>
  //     _personalChecklists.where((item) => !item.completed).toList();
  //
  // List<ChecklistItemDetailResponse> get completeItems =>
  //     _personalChecklists.where((item) => item.completed).toList();
  //
  // //통계 (PersonalStatus Card용)
  // int get completedCount => completeItems.length;
  // int get totalCount => _personalChecklists.length;
  // double get progress => totalCount > 0 ? completedCount / totalCount : 0.0;
  //
  // //스터디별 그룹화 (완료 상태 분리)
  // Map<int, PersonalCheckListGroupVM> get groupByStudy {
  //   final grouped = <int, PersonalCheckListGroupVM> {};
  //
  //   for (final item in _personalChecklists){
  //     grouped.putIfAbsent(item.studyId,() => PersonalCheckListGroupVM(
  //         studyId: item.studyId,
  //         studyMemberId: item.studyMemberId,
  //         studyName: item.studyName,
  //         incomplete: [],
  //         completed: []
  //     ));
  //
  //     if (item.completed){
  //       grouped[item.studyId]!.completed.add(item);
  //     } else {
  //       grouped[item.studyId]!.incomplete.add(item);
  //     }
  //   }
  //   return grouped;
  // }

  //========================== Grouping =========================
  void updateGroups(List<ChecklistItemDetailResponse> items){
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