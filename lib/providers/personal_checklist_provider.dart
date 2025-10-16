import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:study_group_front_end/api_service/checklist_item_api_service.dart';
import 'package:study_group_front_end/api_service/personal_checklist_api_service.dart';
import 'package:study_group_front_end/dto/checklist_item/create/checklist_item_create_request.dart';
import 'package:study_group_front_end/dto/checklist_item/detail/checklist_item_detail_response.dart';
import 'package:study_group_front_end/providers/loading_notifier.dart';
import 'package:study_group_front_end/repository/personal_checklist_repository.dart';
import 'package:study_group_front_end/screens/checklist/personal/view_models/personal_checklist_group_vm.dart';

class PersonalChecklistProvider with ChangeNotifier, LoadingNotifier {
  final PersonalChecklistApiService personalChecklistApiService;
  final ChecklistItemApiService checklistItemApiService;
  final PersonalChecklistRepository repository;

  PersonalChecklistProvider(
      this.personalChecklistApiService,
      this.checklistItemApiService,
      this.repository
  );

  //State
  DateTime _selectedDate = DateTime.now();
  List<ChecklistItemDetailResponse> _personalChecklists = [];

  //Getters
  DateTime get selectedDate => _selectedDate;
  List<ChecklistItemDetailResponse> get personalChecklists => _personalChecklists;

  //Stream 구독
  StreamSubscription? _subscription;

  //변경 감지 및 상태 추적
  Set<int> _modifiedStudyIds = {};
  Set<int> get modifiedStudyIds => _modifiedStudyIds;




  Future<void> _subscribeToDate(DateTime date) async{
    await _subscription?.cancel();

    final stream = repository.watch(date);

    _subscription = stream.listen((items) {
      _personalChecklists = items;
      sortPersonalChecklistsByCompletedThenOrder();
      notifyListeners();
    });

    // 초기 데이터 로드
    final items = await repository.getMyChecklistsOfDay(date);
    _personalChecklists = items;
    sortPersonalChecklistsByCompletedThenOrder();
    notifyListeners();
  }

  //완료 상태별 분리
  List<ChecklistItemDetailResponse> get incompleteItems =>
      _personalChecklists.where((item) => !item.completed).toList();

  List<ChecklistItemDetailResponse> get completeItems =>
      _personalChecklists.where((item) => item.completed).toList();

  //통계 (PersonalStatus Card용)
  int get completedCount => completeItems.length;
  int get totalCount => _personalChecklists.length;
  double get progress => totalCount > 0 ? completedCount / totalCount : 0.0;

  //스터디별 그룹화 (완료 상태 분리)
  Map<int, PersonalCheckListGroupVM> get groupByStudy {
    final grouped = <int, PersonalCheckListGroupVM> {};

    for (final item in _personalChecklists){
      grouped.putIfAbsent(item.studyId,() => PersonalCheckListGroupVM(
          studyId: item.studyId,
          studyMemberId: item.studyMemberId,
          studyName: item.studyName,
          incomplete: [],
          completed: []
      ));

      if (item.completed){
        grouped[item.studyId]!.completed.add(item);
      } else {
        grouped[item.studyId]!.incomplete.add(item);
      }
    }
    return grouped;
  }

  // =============================== 외부 호출 ===========================//
  Future<void> refresh() async {
    await runWithLoading(() async{
      _personalChecklists = await repository.getMyChecklistsOfDay(_selectedDate, force: true);
    });
  }


  // =============================== 데이터 로드 ===========================//
  Future<void> initialize() async {
    await _subscribeToDate(_selectedDate);
  }

  void updateSelectedDate(DateTime newDate) {
    _selectedDate = newDate;
    getMyChecklists();
    notifyListeners();
  }

  //우선 -> repo에서 캐시 확인 -> 캐시 미스시 api 호출
  Future<void> getMyChecklists() async {
    await runWithLoading(() async{
      _personalChecklists = await repository.getMyChecklistsOfDay(_selectedDate);
    });
  }


//TODO CRUD Provider
  // =============================== CRUD (Optimistic) ===========================//

  Future<void> createPersonalChecklist({
    required String content,
    required DateTime targetDate,
    required int studyId
  }) async {
    final group = groupByStudy[studyId];

    final tempItem = ChecklistItemDetailResponse(
      id: -DateTime.now().millisecondsSinceEpoch, //임시 ID
      studyId: studyId,
      type: "STUDY",
      studyMemberId:group!.studyMemberId,
      studyName: group.studyName,
      content: content,
      targetDate: targetDate,
      completed: false,
      orderIndex: group.totalCount,
    );

    _personalChecklists.add(tempItem);
    notifyListeners();

    try{
      final request = ChecklistItemCreateRequest(
        content: content,
        assigneeId: group.studyMemberId,
        type: "STUDY",
        targetDate: targetDate,
        orderIndex: group.totalCount,
      );

      final created = await checklistItemApiService.createChecklistItemOfStudy(request, studyId);

      final index= _personalChecklists.indexWhere((e) => e.id == tempItem.id);
      if(index >= 0){
         _personalChecklists[index] = created;
         notifyListeners();
      }

      _modifiedStudyIds.add(studyId);
    } catch (e) {
      _personalChecklists.removeWhere((e) => e.id == tempItem.id);
      notifyListeners();
      rethrow;
    }
  }

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

  Future<void> updateChecklistItemStatus(int checklistItemId, int studyId) async {
    await repository.toggleStatus(checklistItemId, _selectedDate);
    _modifiedStudyIds.add(studyId);
    // repository.clearDateCache(_selectedDate);
  }


  // =====================================================================================//
  void sortPersonalChecklistsByCompletedThenOrder() {
    _personalChecklists.sort((a, b) {
      if (a.studyId != b.studyId) return a.studyId.compareTo(b.studyId);
      if (a.completed != b.completed) return a.completed ? 1 : -1;
      return (a.orderIndex ?? 0).compareTo(b.orderIndex ?? 0);
    });

    notifyListeners();
  }

  void clearModifiedTracking(){
    _modifiedStudyIds.clear();
  }
}