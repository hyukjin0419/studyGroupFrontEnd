import 'package:flutter/foundation.dart';
import 'package:study_group_front_end/dto/checklist_item/detail/checklist_item_detail_response.dart';
import 'package:study_group_front_end/dto/study/detail/study_detail_response.dart';
import 'package:study_group_front_end/providers/checklist_item_provider.dart';

class StudyCardProvider with ChangeNotifier {
  final ChecklistItemProvider checklistItemProvider;
  StudyCardProvider(this.checklistItemProvider){
    checklistItemProvider.addListener(updateAllProgress);
    updateAllProgress();
  }


//================= Progress =================//
  Map<int, double> _progressCache = {};
  Map<int, double> get progressMap => _progressCache;

  double getProgress(int studyId) {
    if (_progressCache.containsKey(studyId)) {
      return _progressCache[studyId]!;
    }

    final progress = checklistItemProvider.getProgress(studyId);
    _progressCache[studyId] = progress;
    return progress;
  }

  void updateAllProgress() {
    _progressCache = checklistItemProvider.getProgressMap();
    notifyListeners();
  }

  void updateProgressForStudy(int studyId) {
    _progressCache[studyId] = checklistItemProvider.getProgress(studyId);
    notifyListeners();
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
    final progress = getProgress(study.id);
    final dueDate = study.dueDate;

    if (progress == 1.0) {
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
