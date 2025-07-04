class StudyCreateRequest {
  final String name;
  final String description;
  final String color;
  final DateTime? dueDate;

  StudyCreateRequest({
    required this.name,
    required this.description,
    required this.color,
    this.dueDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'color': color,
      'dueDate': dueDate?.toIso8601String(),
    };
  }
}
