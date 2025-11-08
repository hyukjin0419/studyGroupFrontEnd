import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:study_group_front_end/dto/checklist_item/detail/checklist_item_detail_response.dart';
import 'package:study_group_front_end/dto/study/detail/study_detail_response.dart';
import 'package:study_group_front_end/repository/checklist_item_repository.dart';

class StudyCardProvider with ChangeNotifier {
  final InMemoryChecklistItemRepository repository;
  StudyCardProvider(this.repository);

  StreamSubscription<(bool delete, List<ChecklistItemDetailResponse> items)>? _subscription;

  final Map<int, List<ChecklistItemDetailResponse>> _itemsByStudy = {};
  Map<int, List<ChecklistItemDetailResponse>> get itemsByStudy => _itemsByStudy;

  final Map<int, double> _progressCache = {};
  Map<int, double> get progressMap => _progressCache;

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
    return _progressCache[studyId] ?? 0.0;
  }

  void _updateProgressCache(List<ChecklistItemDetailResponse> items){
    final today = DateTime.now();
    final todayItems = items.where((i) {
      final date = i.targetDate;
      return date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
    }).toList();


    for (var item in todayItems) {
      final list = _itemsByStudy.putIfAbsent(item.studyId, () => []);
      final index = list.indexWhere((i) => i.id == item.id);
      if (index >= 0) {
        list[index] = item;
      } else {
        list.add(item);
      }
    }

    _itemsByStudy.forEach((studyId, todayItems){
      if (todayItems.isEmpty) {
        _progressCache[studyId] = 0.0;
        return;
      }

      final completed = todayItems.where((i) => i.completed).length;
      final progress = completed / todayItems.length;
      // log("     ㄴ ${studyId}: ${completed} / ${todayItems.length} = ${progress}");
      _progressCache[studyId] = progress;
    });

    notifyListeners();
  }

  void clearCache() {
    _progressCache.clear();
    _itemsByStudy.clear();
    notifyListeners();
  }

  //================= DUE DATE =================//
  String getDueDateLabel(StudyDetailResponse study) {
    final dueDate = study.dueDate;
    if (dueDate == null) return "";

    final today = DateTime.now();
    final diffDays = dueDate.difference(today).inDays;

    if (study.status == StudyStatus.DONE){
      return "DONE";
    }

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

    if (study.status == StudyStatus.DONE){
      return "완료된 프로젝트 입니다!";
    }

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
