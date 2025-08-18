class ChecklistItemDetailResponse {
  final int id;
  final String type; // ChecklistItemType enum as String
  final int studyId;
  final int studyMemberId;
  final String content;
  final bool completed;
  int orderIndex;

  ChecklistItemDetailResponse({
    required this.id,
    required this.type,
    required this.studyId,
    required this.studyMemberId,
    required this.content,
    required this.completed,
    required this.orderIndex,
  });

  factory ChecklistItemDetailResponse.fromJson(Map<String, dynamic> json) {
    return ChecklistItemDetailResponse(
      id: json['id'],
      type: json['type'],
      studyId: json['studyId'],
      studyMemberId: json['studyMemberId'],
      content: json['content'],
      completed: json['completed'],
      orderIndex: json['orderIndex'],
    );
  }
}