import 'package:intl/intl.dart';

String _isoDate(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

String toIsoDate(DateTime date) => _isoDate(date);

extension DateTimeExtensions on DateTime {
  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  String toIsoDate() => _isoDate(this);

  DateTime get startOfMonth => DateTime(year, month);

  DateTime get endOfMonth => DateTime(year, month + 1, 0);

  DateTime addMonths(int months) => DateTime(year, month + months, day);

  String get formattedDate => DateFormat.yMMMd().format(this);

  String get formattedMonthYear => DateFormat.yMMMM().format(this);

  String timeAgo() {
    final difference = DateTime.now().difference(this);
    if (difference.inMinutes < 1) {
      return 'just now';
    }
    if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    }
    if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    }
    if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    }
    return formattedDate;
  }
}
