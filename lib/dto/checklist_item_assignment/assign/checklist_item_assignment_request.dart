class ChecklistItemAssignRequest {
  final int checklistId;
  final int memberId;
  final int studyId;

  ChecklistItemAssignRequest({
    required this.checklistId,
    required this.memberId,
    required this.studyId,
  });

  Map<String, dynamic> toJson() => {
    'checklistId': checklistId,
    'memberId': memberId,
    'studyId' : studyId,
  };
}