DateTime getMondayOfWeek(DateTime date) {
  return date.subtract(Duration(days: date.weekday - 1));
}

DateTime getSundayOfWeek(DateTime date) {
  return date.subtract(Duration(days: date.weekday % 7));
}

bool isSameDate(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
