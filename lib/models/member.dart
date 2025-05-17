import 'base_res_dto.dart';

class MemberCreateReqDto {
  final String userName;
  final String password;
  final String email;

  MemberCreateReqDto({
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

class MemberCreateResDto extends BaseResDto {
  final int id;

  MemberCreateResDto({
    required this.id,
    DateTime? createdAt,
    DateTime? modifiedAt,
  }) : super(createdAt: createdAt, modifiedAt: modifiedAt);

  factory MemberCreateResDto.fromJson(Map<String, dynamic> json) {
    return MemberCreateResDto(
      id: json['id'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      modifiedAt: json['modifiedAt'] != null ? DateTime.parse(
          json['modifiedAt']) : null,
    );
  }
}

class MemberLoginReqDto{
  final String userName;
  final String password;

  MemberLoginReqDto({
    required this.userName,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'userName': userName,
        'password': password,
  };
}

class MemberLoginResDto {
  final int id;
  final String userName;

  MemberLoginResDto({
    required this.id,
    required this.userName,
  });

  factory MemberLoginResDto.fromJson(Map<String, dynamic> json){
    return MemberLoginResDto(
        id: json['id'],
        userName: json['userName']
    );
  }
}

class MemberDetailResDto extends BaseResDto {
  final int id;
  final String userName;
  final String email;

  MemberDetailResDto({
    required this.id,
    required this.userName,
    required this.email,
    DateTime? createdAt,
    DateTime? modifiedAt,
  }) : super(createdAt: createdAt, modifiedAt: modifiedAt);

  factory MemberDetailResDto.fromJson(Map<String, dynamic> json){
    return MemberDetailResDto(
      id: json['id'],
      userName: json['userName'],
      email: json['email'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      modifiedAt: json['modifiedAt'] != null ? DateTime.parse(
          json['modifiedAt']) : null,
    );
  }
}

class MemberUpdateReqDto {
  final int id;
  final String userName;
  final String email;

  MemberUpdateReqDto({
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

class MemberDeleteResDto {
  final String message;

  MemberDeleteResDto({required this.message});

  factory MemberDeleteResDto.fromJson(Map<String, dynamic> json) {
    return MemberDeleteResDto(
      message: json['message'],
    );
  }
}
