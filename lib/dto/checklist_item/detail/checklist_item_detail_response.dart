class ChecklistItemDetailResponse {
  final int id;
  final String type; // ChecklistItemType enum as String
  int studyId;
  int memberId;
  final int? tempId;
  int studyMemberId;
  final String? studyName;
  final String content;
  final bool completed;
  final DateTime targetDate;
  int orderIndex;

  ChecklistItemDetailResponse({
    required this.id,
    required this.type,
    required this.studyId,
    required this.memberId,
    required this.tempId,
    required this.studyName,
    required this.studyMemberId,
    required this.content,
    required this.completed,
    required this.targetDate,
    required this.orderIndex,
  });

  factory ChecklistItemDetailResponse.fromJson(Map<String, dynamic> json) {
    return ChecklistItemDetailResponse(
      id: json['id'],
      type: json['type'],
      studyId: json['studyId'],
      memberId: json['memberId'],
      tempId: json['tempId'],
      studyMemberId: json['studyMemberId'],
      studyName: json['studyName'],
      content: json['content'],
      completed: json['completed'],
      targetDate: DateTime.parse(json['targetDate']),
      orderIndex: json['orderIndex'],
    );
  }

  ChecklistItemDetailResponse copyWith({
    int? id,
    String? type,
    int? studyId,
    int? studyMemberId,
    int? memberId,
    int? tempId,
    String? studyName,
    String? content,
    bool? completed,
    DateTime? targetDate,
    int? orderIndex,
  }) {
    return ChecklistItemDetailResponse(
      id: id ?? this.id,
      type: type ?? this.type,
      studyId: studyId ?? this.studyId,
      memberId: memberId ?? this.memberId,
      tempId: tempId ?? this.tempId,
      studyMemberId: studyMemberId ?? this.studyMemberId,
      studyName: studyName ?? this.studyName,
      content: content ?? this.content,
      completed: completed ?? this.completed,
      targetDate: targetDate ?? this.targetDate,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }
}