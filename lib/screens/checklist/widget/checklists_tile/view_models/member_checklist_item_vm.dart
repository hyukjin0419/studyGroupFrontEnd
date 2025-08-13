class MemberChecklistItemVM{
  final int id;
  final int studyMemberId;
  final String content;
  final bool completed;
  final int orderIndex;

  const MemberChecklistItemVM({
    required this.id,
    required this.studyMemberId,
    required this.content,
    required this.completed,
    required this.orderIndex,
  });
}