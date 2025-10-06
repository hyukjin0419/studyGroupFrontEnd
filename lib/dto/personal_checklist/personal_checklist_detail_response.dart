class PersonalChecklistDetailResponse {
  final int id;
  final String type;
  final int studyId;
  final int studyMemberId;
  final String studyName;
  final String content;
  final bool completed;
  final DateTime targetDate;
  final int orderIndex;

  PersonalChecklistDetailResponse({
    required this.id,
    required this.type,
    required this.studyId,
    required this.studyMemberId,
    required this.studyName,
    required this.content,
    required this.completed,
    required this.targetDate,
    required this.orderIndex,
  });

  factory PersonalChecklistDetailResponse.fromJson(Map<String, dynamic> json) {
    return PersonalChecklistDetailResponse(
      id: json['id'],
      type: json['type'],
      studyId: json['studyId'],
      studyMemberId: json['studyMemberId'],
      studyName: json['studyName'],
      content: json['content'],
      completed: json['completed'],
      targetDate: DateTime.parse(json['targetDate']),
      orderIndex: json['orderIndex'],
    );
  }

  PersonalChecklistDetailResponse copyWith({
    int? id,
    String? type,
    int? studyId,
    int? studyMemberId,
    String? studyName,
    String? content,
    bool? completed,
    DateTime? targetDate,
    int? orderIndex,
  }) {
    return PersonalChecklistDetailResponse(
      id: id ?? this.id,
      type: type ?? this.type,
      studyId: studyId ?? this.studyId,
      studyMemberId: studyMemberId ?? this.studyMemberId,
      studyName: studyName ?? this.studyName,
      content: content ?? this.content,
      completed: completed ?? this.completed,
      targetDate: targetDate ?? this.targetDate,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }
}