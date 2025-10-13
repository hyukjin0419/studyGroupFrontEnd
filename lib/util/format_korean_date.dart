import 'package:intl/intl.dart';

String formatKoreanDate(DateTime d) {
  // 예: 2025-08-18 (월)
  const dows = ['월','화','수','목','금','토','일'];
  final ymd = DateFormat('yyyy-MM-dd', 'ko_KR').format(d);
  return '$ymd (${dows[d.weekday-1]})';
}

String formatKoreanMonth(DateTime day) {
  return DateFormat("yyyy년 M월").format(day);
}
