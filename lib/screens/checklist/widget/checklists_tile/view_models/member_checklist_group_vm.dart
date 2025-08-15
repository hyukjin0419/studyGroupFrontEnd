import 'package:study_group_front_end/screens/checklist/widget/checklists_tile/view_models/member_checklist_item_vm.dart';

class MemberChecklistGroupVM{
  final int studyMemberId;
  final String memberName;
  final List<MemberChecklistItemVM> items;

  MemberChecklistGroupVM({
    required this.studyMemberId,
    required this.memberName,
    required this.items
  });
}