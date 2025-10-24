class StudyMemberSummaryResponse {
  final int id;
  final int memberId;
  final int studyMemberId;
  final String userName;
  final String role;
  final String personalColor;

  StudyMemberSummaryResponse({
    required this.id,
    required this.memberId,
    required this.studyMemberId,
    required this.userName,
    required this.role,
    required this.personalColor,
    DateTime? joinedAt,
  });

  factory StudyMemberSummaryResponse.fromJson(Map<String, dynamic> json) {
    return StudyMemberSummaryResponse(
      id: json['id'],
      memberId: json['memberId'],
      studyMemberId: json['studyMemberId'],
      userName: json['userName'],
      role: json['role'],
      personalColor: json['personalColor'],
      joinedAt: json['joinedAt'] != null ? DateTime.parse(json['joinedAt']) : null,
    );
  }
}