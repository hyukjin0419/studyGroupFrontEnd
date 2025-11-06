import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:study_group_front_end/dto/checklist_item/detail/checklist_item_detail_response.dart';
import 'package:study_group_front_end/dto/study/detail/study_detail_response.dart';
import 'package:study_group_front_end/providers/checklist_item_provider.dart';
import 'package:study_group_front_end/repository/checklist_item_repository.dart';

class StudyCardProvider with ChangeNotifier {
  final InMemoryChecklistItemRepository repository;
  StudyCardProvider(this.repository);

  StreamSubscription<(bool delete, List<ChecklistItemDetailResponse> items)>? _subscription;

  final Map<int, List<ChecklistItemDetailResponse>> _itemsByStudy = {};
  Map<int, List<ChecklistItemDetailResponse>> get itemsByStudy => _itemsByStudy;

  final Map<int, double> _progressCache = {};
  Map<int, double> get progressMap => _progressCache;

  //init은 어디서 호출? 앱 진입시 호출!
    //init에서 구독 시작
    //strea.linsten에서
    //<int studyId, List<ChecklistItemResponse>>로 ?? 아니면 바로 _progressCache 작성..? -> 바로 작성하는 게 좋기는 하다
      //-> 위 과정이 updateAllProgress를 대치
    //나머지는 동일


  void init(){
    log("init study card provider");
    _subscription = repository.stream.listen((event){
      final (isDelete, newItems) = event;

      if(isDelete) {
        clearCache();
      }

      _updateProgressCache(newItems);
    });
  }


//================= Progress =================//


  double getProgress(int studyId) {
    return _progressCache[studyId]!;
  }

  void _updateProgressCache(List<ChecklistItemDetailResponse> items){
    log("update Progress Cache. 들어온 아이템");
    for (var item in items) {
      _itemsByStudy.putIfAbsent(item.studyId, () => []).add(item);
      log("     ㄴ ${item.studyId}");
    }

    _itemsByStudy.forEach((studyId, items){
      final completed = items.where((i) => i.completed).length;
      final progress = completed / items.length;
      log("studyId: $studyId -> progress: $progress");
      _progressCache[studyId] = progress;
    });
  }

  void clearCache() {
    _progressCache.clear();
    notifyListeners();
  }

  //================= DUE DATE =================//
  String getDueDateLabel(StudyDetailResponse study) {
    final dueDate = study.dueDate;
    if (dueDate == null) return "";

    final today = DateTime.now();
    final diffDays = dueDate.difference(today).inDays;

    if (diffDays > 0) {
      return "D-$diffDays";
    } else if (diffDays == 0) {
      return "D-Day";
    } else {
      return "D+${diffDays.abs()}";
    }
  }

  String getProgressStatus(StudyDetailResponse study) {
    // final progress = getProgress(study.id);
    final dueDate = study.dueDate;

    if (getProgress(study.id) == 1.0) {
      return "오늘 할 일 완료!";
    }

    if (dueDate == null) return "진행 중";

    final now = DateTime.now();
    final diff = dueDate.difference(now).inDays;

    if (diff < 0) return "Progressing";
    if (diff == 0) return "D-Day";
    if (diff <= 3) return "In Three Days";

    return "진행 중";
  }
}
