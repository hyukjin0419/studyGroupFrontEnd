class StudyCreateRequest {
  final String name;
  final String description;
  final int leaderId;

  StudyCreateRequest({
    required this.name,
    required this.description,
    required this.leaderId,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'leaderId': leaderId,
  };
}