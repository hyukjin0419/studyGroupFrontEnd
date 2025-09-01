DateTime getMondayOfWeek(DateTime date) {
  return date.subtract(Duration(days: date.weekday - 1));
}

DateTime getSundayOfWeek(DateTime date) {
  return date.add(Duration(days: 7 - date.weekday));
}
