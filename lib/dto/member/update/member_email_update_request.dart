

class MemberEmailUpdateRequest {
  final String email;

  MemberEmailUpdateRequest({
    required this.email,
  });

  Map<String, dynamic> toJson() => {
    'email': email
  };
}