class MemberChecklistItemVM{
  final int id;
  final int studyMemberId;
  String content;
  final bool completed;
  final int orderIndex;

  MemberChecklistItemVM({
    required this.id,
    required this.studyMemberId,
    required this.content,
    required this.completed,
    required this.orderIndex,
  });
}