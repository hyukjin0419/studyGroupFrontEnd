

import 'package:study_group_front_end/dto/checklist_item/detail/checklist_item_detail_response.dart';
import 'package:study_group_front_end/screens/checklist/team/view_models/member_checklist_item_vm.dart';

class MemberChecklistGroupVM{
  final int studyMemberId;
  final String memberDisplayName;
  final List<ChecklistItemDetailResponse> items;

  MemberChecklistGroupVM({
    required this.studyMemberId,
    required this.memberDisplayName,
    required this.items
  });

  int get totalCount => items.length;
}