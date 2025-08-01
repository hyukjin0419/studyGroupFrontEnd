

class MemberLoginRequest{
  final String userName;
  final String password;
  final String? deviceToken;
  final String? deviceType;

  MemberLoginRequest({
    required this.userName,
    required this.password,
    this.deviceToken,
    this.deviceType,
  });

  Map<String, dynamic> toJson() => {
    'userName': userName,
    'password': password,
    if(deviceToken != null) 'deviceToken': deviceToken,
  };
}