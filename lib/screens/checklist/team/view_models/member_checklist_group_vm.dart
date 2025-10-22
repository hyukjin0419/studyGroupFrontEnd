

import 'package:study_group_front_end/screens/checklist/team/view_models/member_checklist_item_vm.dart';

class MemberChecklistGroupVM{
  final int studyMemberId;
  final String memberName;
  final List<MemberChecklistItemVM> items;

  MemberChecklistGroupVM({
    required this.studyMemberId,
    required this.memberName,
    required this.items
  });

  int get totalCount => items.length;
}