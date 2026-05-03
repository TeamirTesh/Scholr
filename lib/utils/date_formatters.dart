import 'package:intl/intl.dart';

/// Deadlines and task detail: MM/DD/YYYY hh:mm AM/PM
final DateFormat scholrDeadlineFormat = DateFormat('MM/dd/yyyy hh:mm a');

/// Study plan block line: weekday, date, plus preset slot label (e.g. 9:00 AM).
final DateFormat scholrStudyBlockDayFormat = DateFormat('EEE MM/dd');

String formatStudyBlockLine(DateTime day, String timeSlotLabel) {
  return '${scholrStudyBlockDayFormat.format(day)} $timeSlotLabel';
}

/// Chat: time only
final DateFormat scholrChatTimeFormat = DateFormat('hh:mm a');

/// Chat: full date for non-today
final DateFormat scholrChatDateFormat = DateFormat('MM/dd/yyyy');

String formatChatTimestamp(DateTime ts, DateTime now) {
  final sameDay = ts.year == now.year && ts.month == now.month && ts.day == now.day;
  if (sameDay) {
    return scholrChatTimeFormat.format(ts);
  }
  return scholrChatDateFormat.format(ts);
}
