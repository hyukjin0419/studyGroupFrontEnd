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

  ChecklistItemDetailResponse copyWith({
    int? id,
    String? type,
    int? studyId,
    int? studyMemberId,
    String? content,
    bool? completed,
    int? orderIndex,
  }) {
    return ChecklistItemDetailResponse(
      id: id ?? this.id,
      type: type ?? this.type,
      studyId: studyId ?? this.studyId,
      studyMemberId: studyMemberId ?? this.studyMemberId,
      content: content ?? this.content,
      completed: completed ?? this.completed,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }
}