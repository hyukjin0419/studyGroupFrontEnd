//TODO 이거 detail로 바꿀껀지 그대로 갈건지?
class MemberChecklistItemVM{
  final int id;
  int studyMemberId;
  String content;
  late final bool completed;
  int orderIndex;

  MemberChecklistItemVM({
    required this.id,
    required this.studyMemberId,
    required this.content,
    required this.completed,
    required this.orderIndex,
  });
}