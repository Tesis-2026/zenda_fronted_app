import 'package:intl/intl.dart';

abstract final class AppDateFormatter {
  /// dd/MM/yyyy — used for goal completion dates, due-date pickers
  static String shortDate(DateTime dt) =>
      DateFormat('dd/MM/yyyy').format(dt.toLocal());

  /// "Jan 2025" — used for goal due-date display labels
  static String monthYear(DateTime dt) =>
      DateFormat('MMM yyyy').format(dt.toLocal());

  /// "May 3, 2025" — used in detail views
  static String longDate(DateTime dt) =>
      DateFormat('MMMM d, yyyy').format(dt.toLocal());

  /// "10:30 AM" — used in transaction rows
  static String timeOfDay(DateTime dt) =>
      DateFormat('hh:mm a').format(dt.toLocal());

  /// "May 3" — abbreviated date used in transaction lists
  static String shortMonthDay(DateTime dt) =>
      DateFormat('MMMd').format(dt.toLocal());

  /// Parses an ISO-8601 string and returns null on failure.
  static DateTime? tryParse(String? s) {
    if (s == null) return null;
    return DateTime.tryParse(s)?.toLocal();
  }
}
