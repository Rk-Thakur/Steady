import 'local_date.dart';

const _weekdays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// "Friday, Oct 2"
String formatDayHeader(LocalDate date) =>
    '${_weekdays[date.weekday - 1]}, ${formatShortDate(date)}';

/// "Oct 15"
String formatShortDate(LocalDate date) =>
    '${_months[date.month - 1]} ${date.day}';

/// "Morning" / "Afternoon" / "Evening" for the Today greeting.
String greetingFor(DateTime now) {
  if (now.hour < 12) return 'Morning';
  if (now.hour < 18) return 'Afternoon';
  return 'Evening';
}

/// "Sun, Oct 4"
String formatShortDay(LocalDate date) =>
    '${_weekdays[date.weekday - 1].substring(0, 3)}, ${formatShortDate(date)}';

/// "September 2026"
String formatMonthYear(LocalDate date) =>
    '${_monthNames[date.month - 1]} ${date.year}';

const _monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

/// "9:42 PM"
String formatTime(DateTime local) {
  final h = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final m = local.minute.toString().padLeft(2, '0');
  return '$h:$m ${local.hour < 12 ? 'AM' : 'PM'}';
}

/// "Thursday" for [DateTime.thursday].
String weekdayName(int weekday) => _weekdays[weekday - 1];
