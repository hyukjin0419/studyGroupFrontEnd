class MemberSearchResponse {
  final String uuid;
  final String userName;

  MemberSearchResponse({
    required this.uuid,
    required this.userName,
  });

  factory MemberSearchResponse.fromJson(Map<String, dynamic> json) {
    return MemberSearchResponse(
      uuid: json['uuid'],
      userName: json['userName']
    );
  }
}