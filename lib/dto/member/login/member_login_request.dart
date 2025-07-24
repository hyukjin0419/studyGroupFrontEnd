

class MemberLoginRequest{
  final String userName;
  final String password;

  MemberLoginRequest({
    required this.userName,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'userName': userName,
    'password': password,
  };
}