

class MemberCreateRequest {
  final String userName;
  final String password;
  final String email;

  MemberCreateRequest({
    required this.userName,
    required this.password,
    required this.email,
  });

  Map<String, dynamic> toJson() => {
    'userName': userName,
    'password': password,
    'email': email,
  };
}