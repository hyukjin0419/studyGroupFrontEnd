import 'base_res_dto.dart';

class ChecklistCreateReqDto {
  final int? studyId;
  final String content;
  final DateTime? dueDate;

  ChecklistCreateReqDto({
    this.studyId,
    required this.content,
    this.dueDate,
  });

  Map<String, dynamic> toJson() => {
    'studyId': studyId,
    'content': content,
    'dueDate': dueDate?.toIso8601String(),
  };
}

class ChecklistCreateResDto extends BaseResDto {
  final int checklistId;

  ChecklistCreateResDto({
    required this.checklistId,
    DateTime? createdAt,
    DateTime? modifiedAt,
  }) : super(createdAt: createdAt, modifiedAt: modifiedAt);

  factory ChecklistCreateResDto.fromJson(Map<String, dynamic> json) {
    return ChecklistCreateResDto(
      checklistId: json['checklistId'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      modifiedAt: json['modifiedAt'] != null ? DateTime.parse(json['modifiedAt']) : null,
    );
  }
}

class ChecklistUpdateContentReqDto {
  final String content;

  ChecklistUpdateContentReqDto({required this.content});

  Map<String, dynamic> toJson() => {'content': content};
}

class ChecklistUpdateDueDateReqDto {
  final DateTime dueDate;

  ChecklistUpdateDueDateReqDto({required this.dueDate});

  Map<String, dynamic> toJson() => {'dueDate': dueDate.toIso8601String()};
}

class ChecklistDetailResDto extends BaseResDto {
  final int id;
  final int creatorId;
  final int? studyId;
  final String content;
  final DateTime? dueDate;

  ChecklistDetailResDto({
    required this.id,
    required this.creatorId,
    this.studyId,
    required this.content,
    this.dueDate,
    DateTime? createdAt,
    DateTime? modifiedAt,
  }) : super(createdAt: createdAt, modifiedAt: modifiedAt);

  factory ChecklistDetailResDto.fromJson(Map<String, dynamic> json) {
    return ChecklistDetailResDto(
      id: json['id'],
      creatorId: json['creatorId'],
      studyId: json['studyId'],
      content: json['content'],
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      modifiedAt: json['modifiedAt'] != null ? DateTime.parse(json['modifiedAt']) : null,
    );
  }
}

class ChecklistDeleteResDto {
  final int checklistId;
  final String message;

  ChecklistDeleteResDto({
    required this.checklistId,
    required this.message,
  });

  factory ChecklistDeleteResDto.fromJson(Map<String, dynamic> json) {
    return ChecklistDeleteResDto(
      checklistId: json['checklistId'],
      message: json['message'],
    );
  }
}
