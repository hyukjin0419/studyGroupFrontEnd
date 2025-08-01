class StudyMemberInvitationRequest {
  final String inviteeUuid;

  StudyMemberInvitationRequest({
    required this.inviteeUuid,
  });

  Map<String, dynamic> toJson() {
    return{
      'inviteeUuid': inviteeUuid,
    };
  }
}
