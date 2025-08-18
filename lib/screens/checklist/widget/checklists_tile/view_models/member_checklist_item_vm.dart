class MemberChecklistItemVM{
  final int id;
  int studyMemberId;
  String content;
  final bool completed;
  int orderIndex;

  MemberChecklistItemVM({
    required this.id,
    required this.studyMemberId,
    required this.content,
    required this.completed,
    required this.orderIndex,
  });
}