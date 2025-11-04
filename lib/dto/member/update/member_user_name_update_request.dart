

class MemberUserDisplayNameRequest {
  final String displayName;

  MemberUserDisplayNameRequest({
    required this.displayName,
  });

  Map<String, dynamic> toJson() => {
    'displayName': displayName,
  };
}