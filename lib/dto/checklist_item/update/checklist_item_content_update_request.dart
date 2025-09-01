class ChecklistItemContentUpdateRequest {
  final String content;

  ChecklistItemContentUpdateRequest({
    required this.content
  });


  Map<String,dynamic> toJson() => {
    'content' : content
  };
}