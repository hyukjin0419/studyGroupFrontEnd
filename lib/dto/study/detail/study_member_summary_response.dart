class StudyMemberSummaryResponse {
  final int id;
  final String userName;
  final String role;


  StudyMemberSummaryResponse({
    required this.id,
    required this.userName,
    required this.role,
    DateTime? joinedAt,
  });

  factory StudyMemberSummaryResponse.fromJson(Map<String, dynamic> json) {
    return StudyMemberSummaryResponse(
      id: json['id'],
      userName: json['userName'],
      role: json['role'],
      joinedAt: json['joinedAt'] != null ? DateTime.parse(json['joinedAt']) : null,
    );
  }
}