import 'package:intl/intl.dart';

/// Formats dates exactly like keys used by the persisted daily logs.
String dailyLogDateKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

/// Calculates the current consecutive-day streak from persisted daily counts.
///
/// If the user has not chanted today, yesterday is the latest day that can
/// keep a streak alive. Once there is a chant today, today is included.
int calculateCurrentStreak({
  required DateTime now,
  required int todayCount,
  required int Function(String dateKey) dailyCountForDate,
}) {
  final today = DateTime(now.year, now.month, now.day);
  var date = todayCount > 0
      ? today
      : today.subtract(const Duration(days: 1));

  var currentStreak = 0;

  while (true) {
    final count = dailyCountForDate(dailyLogDateKey(date));
    if (count <= 0) {
      break;
    }

    currentStreak++;
    date = date.subtract(const Duration(days: 1));
  }

  return currentStreak;
}
