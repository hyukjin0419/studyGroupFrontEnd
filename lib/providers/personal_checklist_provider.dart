import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:study_group_front_end/api_service/checklist_item_api_service.dart';
import 'package:study_group_front_end/api_service/personal_checklist_api_service.dart';
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



  // =============================== 데이터 로드 ===========================//
  Future<void> initialize() async{
    await getMyChecklists();
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













}