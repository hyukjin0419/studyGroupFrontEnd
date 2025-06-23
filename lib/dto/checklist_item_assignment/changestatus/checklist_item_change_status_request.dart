class ChecklistItemChangeStatusRequest {
  final int checklistId;
  final int memberId;

  ChecklistItemChangeStatusRequest({
    required this.checklistId,
    required this.memberId,
  });

  Map<String, dynamic> toJson() => {
    'checklistId': checklistId,
    'memberId': memberId,
  };
}
