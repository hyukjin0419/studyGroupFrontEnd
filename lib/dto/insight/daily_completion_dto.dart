class DailyCompletionDto {
  final DateTime date;
  final int count;

  DailyCompletionDto({
    required this.date,
    required this.count,
  });

  factory DailyCompletionDto.fromJson(Map<String, dynamic> json) {
    return DailyCompletionDto(
      date: DateTime.parse(json['date']),
      count: json['count'],
    );
  }
}
