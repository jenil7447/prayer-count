import 'package:flutter_test/flutter_test.dart';
import 'package:prayercount/utils/streak_calculator.dart';

void main() {
  group('calculateCurrentStreak', () {
    final today = DateTime(2026, 10, 12);

    test('preserves the previous streak when today has no chant yet', () {
      final logs = <String, int>{
        dailyLogDateKey(DateTime(2026, 10, 10)): 12,
        dailyLogDateKey(DateTime(2026, 10, 11)): 8,
      };

      final result = calculateCurrentStreak(
        now: today,
        todayCount: 0,
        dailyCountForDate: (key) => logs[key] ?? 0,
      );

      expect(result, 2);
    });

    test('includes today after the first chant and extends the streak', () {
      final logs = <String, int>{
        dailyLogDateKey(DateTime(2026, 10, 10)): 12,
        dailyLogDateKey(DateTime(2026, 10, 11)): 8,
        dailyLogDateKey(DateTime(2026, 10, 12)): 1,
      };

      final result = calculateCurrentStreak(
        now: today,
        todayCount: 1,
        dailyCountForDate: (key) => logs[key] ?? 0,
      );

      expect(result, 3);
    });

    test('returns zero when yesterday was inactive and today is not active', () {
      final logs = <String, int>{
        dailyLogDateKey(DateTime(2026, 10, 9)): 12,
        dailyLogDateKey(DateTime(2026, 10, 10)): 8,
      };

      final result = calculateCurrentStreak(
        now: today,
        todayCount: 0,
        dailyCountForDate: (key) => logs[key] ?? 0,
      );

      expect(result, 0);
    });

    test('starts a new one-day streak after a gap', () {
      final logs = <String, int>{
        dailyLogDateKey(DateTime(2026, 10, 10)): 8,
        dailyLogDateKey(DateTime(2026, 10, 12)): 1,
      };

      final result = calculateCurrentStreak(
        now: today,
        todayCount: 1,
        dailyCountForDate: (key) => logs[key] ?? 0,
      );

      expect(result, 1);
    });
  });
}
