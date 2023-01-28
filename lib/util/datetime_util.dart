import 'package:intl/intl.dart';

class DateTimeUtil {
  static int getDaysSinceEpoch(DateTime date) {
    // This applies a correction of timezone's offset
    // Because otherwise, dividing milliseconds since epoch doesn't necessarily
    // give us the number of days that have passed, in __this__ timezone.
    final ms = date.millisecondsSinceEpoch + date.timeZoneOffset.inMilliseconds;
    return (ms ~/ Duration.millisecondsPerDay);
  }

  static DateTime getDateTime(int daysSinceEpoch) =>
      DateTime.fromMillisecondsSinceEpoch(
        daysSinceEpoch * Duration.millisecondsPerDay,
      );

  static final _format = DateFormat.yMMMEd();

  static String formatDate(DateTime date) {
    return _format.format(date);
  }
}
