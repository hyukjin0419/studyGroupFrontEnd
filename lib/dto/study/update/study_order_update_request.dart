class StudyOrderUpdateRequest {
  final int studyId;
  final int personalOrderIndex;

  StudyOrderUpdateRequest({
    required this.studyId,
    required this.personalOrderIndex,
  });

  Map<String, dynamic> toJson() {
    return {
      'studyId': studyId,
      'personalOrderIndex': personalOrderIndex,
    };
  }
}