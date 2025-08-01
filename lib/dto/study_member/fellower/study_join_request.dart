class StudyJoinRequest {
  final String joinCode;

  StudyJoinRequest({
    required this.joinCode
  });


  Map<String, dynamic> toJson() {
    return{
      'joinCode': joinCode
    };
  }
}