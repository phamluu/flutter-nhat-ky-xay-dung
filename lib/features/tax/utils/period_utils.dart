class PeriodUtils {
  static DateTime startOfQuarter(int year, int quarter) {
    return DateTime(year, (quarter - 1) * 3 + 1, 1);
  }

  static DateTime endOfQuarter(int year, int quarter) {
    return DateTime(year, quarter * 3 + 1, 0);
  }

  static bool inQuarter(DateTime date, int year, int quarter) {
    final start = startOfQuarter(year, quarter);
    final end = endOfQuarter(year, quarter);

    return date.isAfter(start.subtract(Duration(days: 1))) &&
        date.isBefore(end.add(Duration(days: 1)));
  }
}