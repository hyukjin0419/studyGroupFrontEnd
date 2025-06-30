class ChecklistItemUpdateRequest {
  final String content;
  final DateTime dueDate;

  ChecklistItemUpdateRequest({
    required this.content,
    required this.dueDate,
  });

  Map<String, dynamic> toJson() => {
    'content': content,
    'dueDate': dueDate.toIso8601String()
  };
}