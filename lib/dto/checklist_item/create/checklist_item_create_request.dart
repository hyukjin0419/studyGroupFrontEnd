class ChecklistItemCreateRequest {
  final int? studyId;
  final String content;
  final DateTime? dueDate;

  ChecklistItemCreateRequest({
    this.studyId,
    required this.content,
    this.dueDate,
  });

  Map<String, dynamic> toJson() => {
    'studyId': studyId,
    'content': content,
    'dueDate': dueDate?.toIso8601String(),
  };
}