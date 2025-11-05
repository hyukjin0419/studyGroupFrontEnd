class StudyActivityDto {
  final int studyId;
  final String studyName;
  final double activityRate;

  StudyActivityDto({
    required this.studyId,
    required this.studyName,
    required this.activityRate,
  });

  factory StudyActivityDto.fromJson(Map<String, dynamic> json) {
    return StudyActivityDto(
      studyId: json['studyId'],
      studyName: json['studyName'],
      activityRate: (json['activityRate'] as num).toDouble(),
    );
  }
}
