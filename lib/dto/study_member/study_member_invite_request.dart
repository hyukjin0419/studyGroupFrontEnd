class StudyMemberInviteRequest {
  final String email;

  StudyMemberInviteRequest({required this.email});

  Map<String, dynamic> toJson() => {
    'email': email,
  };
}