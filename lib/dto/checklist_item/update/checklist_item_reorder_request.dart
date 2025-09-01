class ChecklistItemReorderRequest {
  final int checklistItemId;
  final int studyMemberId;
  final int orderIndex;

  ChecklistItemReorderRequest({
    required this.checklistItemId,
    required this.studyMemberId,
    required this.orderIndex,
  });

  Map<String, dynamic> toJson() {
    return {
      'checklistItemId': checklistItemId,
      'studyMemberId': studyMemberId,
      'orderIndex': orderIndex,
    };
  }
}
