class User{
  final int id;
  final String userName;
  final String email;

  User({
    required this.id,
    required this.userName,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json){
    return User(
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