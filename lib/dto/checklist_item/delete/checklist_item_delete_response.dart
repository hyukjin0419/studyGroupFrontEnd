class ChecklistItemDeleteResponse {
  final int checklistItemId;
  final String message;

  ChecklistItemDeleteResponse({
    required this.checklistItemId,
    required this.message,
  });

  factory ChecklistItemDeleteResponse.fromJson(Map<String, dynamic> json) {
    return ChecklistItemDeleteResponse(
      checklistItemId: json['checklistItemId'],
      message: json['message'],
    );
  }
}
