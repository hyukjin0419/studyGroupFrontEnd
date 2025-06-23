class StudyUpdateRequest {
  final String name;
  final String description;

  StudyUpdateRequest({
    required this.name,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
  };
}