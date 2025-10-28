

class MemberUserNameUpdateRequest {
  final String userName;

  MemberUserNameUpdateRequest({
    required this.userName,
  });

  Map<String, dynamic> toJson() => {
    'userName': userName,
  };
}