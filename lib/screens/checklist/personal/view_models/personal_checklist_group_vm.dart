import 'package:study_group_front_end/dto/checklist_item/detail/checklist_item_detail_response.dart';

class PersonalCheckListGroupVM{
  final int studyId;
  final String? studyName;
  final List<ChecklistItemDetailResponse> items;

  PersonalCheckListGroupVM({
    required this.studyId,
    required this.studyName,
    required this.items,
  });

  // int get totalCount => incomplete.length + completed.length;
  // int get completedCount => completed.length;
  // double get progress => totalCount > 0 ? completedCount / totalCount : 0.0;
}
