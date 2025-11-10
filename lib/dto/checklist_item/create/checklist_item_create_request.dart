class ChecklistItemCreateRequest {
  final int tempId;
  final String content;
  final int assigneeId;
  // final String type;
  final DateTime targetDate;
  final int orderIndex;

  ChecklistItemCreateRequest({
    required this.tempId,
    required this.content,
    required this.assigneeId,
    // required this.type,
    required this.targetDate,
    required this.orderIndex,
  });

  Map<String, dynamic> toJson() => {
    'tempId': tempId,
    'content': content,
    'assigneeId': assigneeId,
    // 'type': type,
    'targetDate': targetDate.toIso8601String(),
    'orderIndex': orderIndex,
  };
}