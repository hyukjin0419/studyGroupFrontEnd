class StudyDeleteResponse {
  final String message;

  StudyDeleteResponse({required this.message});

  factory StudyDeleteResponse.fromJson(Map<String, dynamic> json) {
    return StudyDeleteResponse(
      message: json['message'],
    );
  }
}