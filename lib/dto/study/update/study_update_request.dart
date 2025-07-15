class StudyUpdateRequest {
  final int studyId;
  final String name;
  final String description;
  final String personalColor;
  final DateTime? dueDate;


  StudyUpdateRequest({
    required this.studyId,
    required this.name,
    required this.description,
    required this.personalColor,
    this.dueDate,
  });

  Map<String, dynamic> toJson() => {
    'studyId' : studyId,
    'name': name,
    'description': description,
    'personalColor': personalColor,
    'dueDate': dueDate?.toIso8601String(),
  };
}