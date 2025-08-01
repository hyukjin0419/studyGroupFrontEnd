

class MemberUpdateRequest {
  final int id;
  final String userName;
  final String email;

  MemberUpdateRequest({
    required this.id,
    required this.userName,
    required this.email,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userName': userName,
    'email': email,
  };
}