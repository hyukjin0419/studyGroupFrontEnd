import 'package:study_group_front_end/dto/base_res_dto.dart';
import 'package:study_group_front_end/dto/study/detail/study_member_summary_response.dart';
enum StudyStatus{DONE, PROGRESSING}

class StudyDetailResponse extends BaseResDto {
  final int id;
  final String name;
  final String description;
  final int leaderId;
  final String leaderName;
  final String joinCode;
  final String personalColor;
  final DateTime? dueDate;
  final StudyStatus status;
  final List<StudyMemberSummaryResponse> members;

  StudyDetailResponse({
    required this.id,
    required this.name,
    required this.description,
    required this.leaderId,
    required this.leaderName,
    required this.joinCode,
    required this.personalColor,
    this.dueDate,
    required this.status,
    required this.members,
    super.createdAt,
    super.modifiedAt,
  });

  factory StudyDetailResponse.fromJson(Map<String, dynamic> json) {
    return StudyDetailResponse(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      leaderId: json['leaderId'],
      leaderName: json['leaderName'],
      joinCode: json['joinCode'],
      personalColor: json['personalColor'],
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      status: StudyStatus.values.firstWhere((e) => e.name == json['status'],
        orElse: () => StudyStatus.PROGRESSING,
      ),
      members: (json['members'] as List)
          .map((m) => StudyMemberSummaryResponse.fromJson(m))
          .toList(),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      modifiedAt: json['modifiedAt'] != null ? DateTime.parse(json['modifiedAt']) : null,
    );
  }
}