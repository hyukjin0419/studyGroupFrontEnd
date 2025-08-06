class ChecklistItemCreateRequest {
  final String content;
  final int assigneeId;
  final String type;

  ChecklistItemCreateRequest({
    required this.content,
    required this.assigneeId,
    required this.type
  });

  Map<String, dynamic> toJson() => {
    'content': content,
    'assigneeId': assigneeId,
    'type': type,
  };
}