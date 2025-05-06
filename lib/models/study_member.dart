class StudyMember{
  final int id;
  final String userName;
  final String role;

  StudyMember({
    required this.id,
    required this.userName,
    required this.role,
  });

  factory StudyMember.fromJson(Map<String, dynamic> json){
    return StudyMember(
      id: json['id'],
      userName: json['userName'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'id': id,
      'userName': userName,
      'role': role,
    };
  }
}