import 'base_res_dto.dart';

class StudyCreateReqDto {
  final String name;
  final String description;
  final int leaderId;

  StudyCreateReqDto({
    required this.name,
    required this.description,
    required this.leaderId,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'leaderId': leaderId,
  };
}

class StudyCreateResDto extends BaseResDto {
  final int id;
  final String name;
  final String description;
  final int leaderId;
  final String leaderName;

  StudyCreateResDto({
    required this.id,
    required this.name,
    required this.description,
    required this.leaderId,
    required this.leaderName,
    super.createdAt,
    super.modifiedAt,
  });

  factory StudyCreateResDto.fromJson(Map<String, dynamic> json) {
    return StudyCreateResDto(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      leaderId: json['leaderId'],
      leaderName: json['leaderName'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      modifiedAt: json['modifiedAt'] != null ? DateTime.parse(json['modifiedAt']) : null,
    );
  }
}

class StudyMemberResDto {
  final int id;
  final String userName;
  final String role;


  StudyMemberResDto({
    required this.id,
    required this.userName,
    required this.role,
    DateTime? joinedAt,
  });

  factory StudyMemberResDto.fromJson(Map<String, dynamic> json) {
    return StudyMemberResDto(
      id: json['id'],
      userName: json['userName'],
      role: json['role'],
      joinedAt: json['joinedAt'] != null ? DateTime.parse(json['joinedAt']) : null,
    );
  }
}

class StudyDetailResDto extends BaseResDto {
  final int id;
  final String name;
  final String description;
  final int leaderId;
  final String leaderName;
  final List<StudyMemberResDto> members;

  StudyDetailResDto({
    required this.id,
    required this.name,
    required this.description,
    required this.leaderId,
    required this.leaderName,
    required this.members,
    DateTime? createdAt,
    DateTime? modifiedAt,
  }) : super(createdAt: createdAt, modifiedAt: modifiedAt);

  factory StudyDetailResDto.fromJson(Map<String, dynamic> json) {
    return StudyDetailResDto(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      leaderId: json['leaderId'],
      leaderName: json['leaderName'],
      members: (json['members'] as List)
          .map((m) => StudyMemberResDto.fromJson(m))
          .toList(),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      modifiedAt: json['modifiedAt'] != null ? DateTime.parse(json['modifiedAt']) : null,
    );
  }
}

class StudyListResDto extends BaseResDto {
  final int id;
  final String name;
  final String description;
  // final int leaderId;

  StudyListResDto({
    required this.id,
    required this.name,
    required this.description,
    // required this.leaderId,
    super.createdAt,
    super.modifiedAt,
  });

  factory StudyListResDto.fromJson(Map<String, dynamic> json) {
    return StudyListResDto(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      // leaderId: json['leaderId'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      modifiedAt: json['modifiedAt'] != null ? DateTime.parse(json['modifiedAt']) : null,
    );
  }
}

class StudyUpdateReqDto {
  final String name;
  final String description;

  StudyUpdateReqDto({
    required this.name,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
  };
}


class StudyUpdateResDto extends StudyCreateResDto {
  StudyUpdateResDto({
    required super.id,
    required super.name,
    required super.description,
    required super.leaderId,
    required super.leaderName,
    super.createdAt,
    super.modifiedAt,
  });

  factory StudyUpdateResDto.fromJson(Map<String, dynamic> json) {
    return StudyUpdateResDto(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      leaderId: json['leaderId'],
      leaderName: json['leaderName'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      modifiedAt: json['modifiedAt'] != null ? DateTime.parse(json['modifiedAt']) : null,
    );
  }
}
class StudyDeleteResDto {
  final String message;

  StudyDeleteResDto({required this.message});

  factory StudyDeleteResDto.fromJson(Map<String, dynamic> json) {
    return StudyDeleteResDto(
      message: json['message'],
    );
  }
}
