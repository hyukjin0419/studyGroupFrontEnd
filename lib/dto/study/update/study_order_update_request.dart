class StudyOrderUpdateListRequest {
  final List<StudyOrderUpdateListRequest> orderList;

  StudyOrderUpdateListRequest({required this.orderList});

  Map<String, dynamic> toJson() {
    return {
      'orderList': orderList.map((e) => e.toJson()).toList(),
    };
  }
}