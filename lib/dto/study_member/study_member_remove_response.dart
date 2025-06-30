class StudyMemberRemoveResponse {
  final int studyId;
  final int memberId;
  final String message;

  StudyMemberRemoveResponse({
    required this.studyId,
    required this.memberId,
    required this.message,
  });

  factory StudyMemberRemoveResponse.fromJson(Map<String, dynamic> json) {
    return StudyMemberRemoveResponse(
      studyId: json['studyId'],
      memberId: json['memberId'],
      message: json['message'],
    );
  }
}
