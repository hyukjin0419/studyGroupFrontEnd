//TODO 이거 detail로 바꿀껀지 그대로 갈건지?
import 'package:study_group_front_end/dto/checklist_item/detail/checklist_item_detail_response.dart';

class MemberChecklistItemVM{
  final int id;
  int studyMemberId;
  String content;
  late final bool completed;
  int orderIndex;

  MemberChecklistItemVM({
    required this.id,
    required this.studyMemberId,
    required this.content,
    required this.completed,
    required this.orderIndex,
  });

  MemberChecklistItemVM fromResponse(ChecklistItemDetailResponse item){
    return MemberChecklistItemVM(id: item.id,
        studyMemberId: item.studyMemberId,
        content: item.content,
        completed: item.completed,
        orderIndex: item.orderIndex
    );
  }
}