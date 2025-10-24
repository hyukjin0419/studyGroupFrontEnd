import 'package:study_group_front_end/dto/checklist_item/detail/checklist_item_detail_response.dart';

class ChecklistItemContentUpdateRequest {
  final String content;

  ChecklistItemContentUpdateRequest({
    required this.content
  });


  Map<String,dynamic> toJson() => {
    'content' : content
  };

  factory ChecklistItemContentUpdateRequest.fromDetail(ChecklistItemDetailResponse item){
    return ChecklistItemContentUpdateRequest(content: item.content);
  }
}