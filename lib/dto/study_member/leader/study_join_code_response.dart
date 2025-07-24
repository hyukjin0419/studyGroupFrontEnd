class StudyJoinCodeResponse {
  final String joinCode;

  StudyJoinCodeResponse({
    required this.joinCode
  });

  factory StudyJoinCodeResponse.fromJson(Map<String, dynamic> json){
    return StudyJoinCodeResponse(
      joinCode: json['joinCode']
    );
  }
}