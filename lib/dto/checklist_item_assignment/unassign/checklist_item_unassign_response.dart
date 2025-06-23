class ChecklistItemUnassignResponse {
  final int checklistId;
  final int memberId;
  final String message;

  ChecklistItemUnassignResponse({
    required this.checklistId,
    required this.memberId,
    required this.message,
  });

  factory ChecklistItemUnassignResponse.fromJson(Map<String, dynamic> json) {
    return ChecklistItemUnassignResponse(
      checklistId: json['checklistId'],
      memberId: json['memberId'],
      message: json['message'],
    );
  }
}
