import 'package:study_group_front_end/dto/checklist_item/detail/checklist_item_detail_response.dart';
import 'package:study_group_front_end/screens/checklist/team/view_models/member_checklist_item_vm.dart';

class ChecklistItemReorderRequest {
  final int checklistItemId;
  final int studyId;
  final int studyMemberId;
  final int orderIndex;

  ChecklistItemReorderRequest({
    required this.checklistItemId,
    required this.studyId,
    required this.studyMemberId,
    required this.orderIndex,
  });

  factory ChecklistItemReorderRequest.fromDetail(ChecklistItemDetailResponse dto) {
    return ChecklistItemReorderRequest(
      checklistItemId: dto.id,
      studyId: dto.studyId,
      studyMemberId: dto.studyMemberId,
      orderIndex: dto.orderIndex ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'checklistItemId': checklistItemId,
      'studyId': studyId,
      'studyMemberId': studyMemberId,
      'orderIndex': orderIndex,
    };
  }
}
