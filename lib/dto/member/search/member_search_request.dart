class MemberSearchRequest{
  final int studyId;
  final String keyword;

  MemberSearchRequest({
    required this.studyId,
    required this.keyword
  });

  Map<String, dynamic> toJson() => {
    'studyId': studyId,
    'keyword': keyword
  };
}