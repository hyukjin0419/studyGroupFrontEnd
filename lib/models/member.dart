class Member{
  final int id;
  final String userName;
  final String email;

  Member({
    required this.id,
    required this.userName,
    required this.email,
  });

  factory Member.fromJson(Map<String, dynamic> json){
    return Member(
      id: json['id'],
      userName: json['userName'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id':id,
    'userName': userName,
    'email': email,
  };
}