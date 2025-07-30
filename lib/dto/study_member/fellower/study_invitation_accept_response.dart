class StudyInvitationAcceptResponse {
  final int studyId;

  StudyInvitationAcceptResponse({
    required this.studyId
  });

  factory StudyInvitationAcceptResponse.fromJson(Map<String, dynamic> json){
    return StudyInvitationAcceptResponse(
        studyId: json['studyId']
    );
  }
}