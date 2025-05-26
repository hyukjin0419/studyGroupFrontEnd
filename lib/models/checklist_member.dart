import 'base_res_dto.dart';

class ChecklistMemberAssignReqDto {
  final int checklistId;
  final int memberId;
  final int studyId;

  ChecklistMemberAssignReqDto({
    required this.checklistId,
    required this.memberId,
    required this.studyId,
  });

  Map<String, dynamic> toJson() => {
    'checklistId': checklistId,
    'memberId': memberId,
  };
}

class ChecklistMemberAssignResDto extends BaseResDto {
  final int checklistId;
  final int memberId;
  final DateTime assignedAt;

  ChecklistMemberAssignResDto({
    required this.checklistId,
    required this.memberId,
    required this.assignedAt,
    DateTime? createdAt,
    DateTime? modifiedAt,
  }) : super(createdAt: createdAt, modifiedAt: modifiedAt);

  factory ChecklistMemberAssignResDto.fromJson(Map<String, dynamic> json) {
    return ChecklistMemberAssignResDto(
      checklistId: json['checklistId'],
      memberId: json['memberId'],
      assignedAt: DateTime.parse(json['assignedAt']),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      modifiedAt: json['modifiedAt'] != null ? DateTime.parse(json['modifiedAt']) : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'checklistId': checklistId,
    'memberId': memberId,
    'assignedAt': assignedAt.toIso8601String(),
    'createdAt': createdAt?.toIso8601String(),
    'modifiedAt': modifiedAt?.toIso8601String(),
  };

}

class ChecklistMemberChangeStatusReqDto {
  final int checklistId;
  final int memberId;

  ChecklistMemberChangeStatusReqDto({
    required this.checklistId,
    required this.memberId,
  });

  Map<String, dynamic> toJson() => {
    'checklistId': checklistId,
    'memberId': memberId,
  };
}

class ChecklistMemberChangeStatusResDto extends BaseResDto {
  final int checklistId;
  final int memberId;
  final bool isCompleted;
  final DateTime? completedAt;

  ChecklistMemberChangeStatusResDto({
    required this.checklistId,
    required this.memberId,
    required this.isCompleted,
    this.completedAt,
    DateTime? createdAt,
    DateTime? modifiedAt,
  }) : super(createdAt: createdAt, modifiedAt: modifiedAt);

  factory ChecklistMemberChangeStatusResDto.fromJson(Map<String, dynamic> json) {
    return ChecklistMemberChangeStatusResDto(
      checklistId: json['checklistId'],
      memberId: json['memberId'],
      isCompleted: json['isCompleted'],
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      modifiedAt: json['modifiedAt'] != null ? DateTime.parse(json['modifiedAt']) : null,
    );
  }
  @override
  Map<String, dynamic> toJson() => {
    'checklistId': checklistId,
    'memberId': memberId,
    'isCompleted': isCompleted,
    'completedAt': completedAt?.toIso8601String(),
    'createdAt': createdAt?.toIso8601String(),
    'modifiedAt': modifiedAt?.toIso8601String(),
  };
}

class ChecklistMemberResDto extends BaseResDto {
  final int checklistId;
  final String content;
  final bool isCompleted;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final DateTime? assignedAt;
  final int? personalOrderIndex;
  final int? studyOrderIndex;

  ChecklistMemberResDto({
    required this.checklistId,
    required this.content,
    required this.isCompleted,
    this.dueDate,
    this.completedAt,
    this.assignedAt,
    this.personalOrderIndex,
    this.studyOrderIndex,
    DateTime? createdAt,
    DateTime? modifiedAt,
  }) : super(createdAt: createdAt, modifiedAt: modifiedAt);

  factory ChecklistMemberResDto.fromJson(Map<String, dynamic> json) {
    return ChecklistMemberResDto(
      checklistId: json['checklistId'],
      content: json['content'],
      isCompleted: json['isCompleted'],
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      assignedAt: json['assignedAt'] != null ? DateTime.parse(json['assignedAt']) : null,
      personalOrderIndex: json['personalOrderIndex'],
      studyOrderIndex: json['studyOrderIndex'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      modifiedAt: json['modifiedAt'] != null ? DateTime.parse(json['modifiedAt']) : null,
    );
  }
  @override
  Map<String, dynamic> toJson() => {
    'checklistId': checklistId,
    'content': content,
    'isCompleted': isCompleted,
    'dueDate': dueDate?.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'assignedAt': assignedAt?.toIso8601String(),
    'personalOrderIndex': personalOrderIndex,
    'studyOrderIndex': studyOrderIndex,
    'createdAt': createdAt?.toIso8601String(),
    'modifiedAt': modifiedAt?.toIso8601String(),
  };
}

class StudyChecklistMemberResDto extends BaseResDto {
  final int checklistId;
  final String content;
  final int memberId;
  final String memberName;
  final bool isCompleted;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final DateTime? assignedAt;
  final int? studyOrderIndex;

  StudyChecklistMemberResDto({
    required this.checklistId,
    required this.content,
    required this.memberId,
    required this.memberName,
    required this.isCompleted,
    this.dueDate,
    this.completedAt,
    this.assignedAt,
    this.studyOrderIndex,
    DateTime? createdAt,
    DateTime? modifiedAt,
  }) : super(createdAt: createdAt, modifiedAt: modifiedAt);

  factory StudyChecklistMemberResDto.fromJson(Map<String, dynamic> json) {
    return StudyChecklistMemberResDto(
      checklistId: json['checklistId'],
      content: json['content'],
      memberId: json['memberId'],
      memberName: json['memberName'],
      isCompleted: json['isCompleted'],
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      assignedAt: json['assignedAt'] != null ? DateTime.parse(json['assignedAt']) : null,
      studyOrderIndex: json['studyOrderIndex'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      modifiedAt: json['modifiedAt'] != null ? DateTime.parse(json['modifiedAt']) : null,
    );
  }
  @override
  Map<String, dynamic> toJson() => {
    'checklistId': checklistId,
    'content': content,
    'memberId': memberId,
    'memberName': memberName,
    'isCompleted': isCompleted,
    'dueDate': dueDate?.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'assignedAt': assignedAt?.toIso8601String(),
    'studyOrderIndex': studyOrderIndex,
    'createdAt': createdAt?.toIso8601String(),
    'modifiedAt': modifiedAt?.toIso8601String(),
  };
}

class ChecklistMemberUnassignResDto {
  final int checklistId;
  final int memberId;
  final String message;

  ChecklistMemberUnassignResDto({
    required this.checklistId,
    required this.memberId,
    required this.message,
  });

  factory ChecklistMemberUnassignResDto.fromJson(Map<String, dynamic> json) {
    return ChecklistMemberUnassignResDto(
      checklistId: json['checklistId'],
      memberId: json['memberId'],
      message: json['message'],
    );
  }
}
