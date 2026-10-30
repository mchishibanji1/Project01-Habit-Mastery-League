import 'package:flutter_test/flutter_test.dart';
import 'package:habit_mastery_league/models/habit_completion.dart';
import 'package:habit_mastery_league/services/habit_helper.dart';

void main() {
  final helper = HabitHelper();
  final now = DateTime(2026, 10, 30, 12);

  final List<Map<String, Object?>> habits = [
    {'habitId': 1, 'name': 'Reading', 'isActive': 1},
    {'habitId': 2, 'name': 'Walking', 'isActive': 1},
  ];

  test('Helper selects fewer recent completions than baseline', () {
    final records = [
      HabitCompletion(
        habitId: 1,
        completionDate: '2026-10-29T10:00:00',
      ),
      HabitCompletion(
        habitId: 1,
        completionDate: '2026-10-28T10:00:00',
      ),
    ];

    final result = helper.recommend(habits, records, now: now);
    final baseline = helper.baseline(habits, records, now: now);

    expect(result?.habitId, 2);
    expect(baseline?.habitId, 1);
    expect(result?.explanation, contains('0 completed records'));
  });

  test('Equal counts select the lower ID regardless of list order', () {
    final reversedHabits = habits.reversed.toList();
    final records = <HabitCompletion>[];

    final result = helper.recommend(
      reversedHabits,
      records,
      now: now,
    );
    final baseline = helper.baseline(
      reversedHabits,
      records,
      now: now,
    );

    expect(result?.habitId, 1);
    expect(baseline?.habitId, 1);
  });

  test('No habits return no suggestion', () {
    final emptyHabits = <Map<String, Object?>>[];
    final records = <HabitCompletion>[];

    expect(helper.recommend(emptyHabits, records, now: now), isNull);
    expect(helper.baseline(emptyHabits, records, now: now), isNull);
  });

  test('Habits completed today are excluded', () {
    final records = [
      HabitCompletion(
        habitId: 1,
        completionDate: '2026-10-30T09:00:00',
      ),
      HabitCompletion(
        habitId: 2,
        completionDate: '2026-10-30T10:00:00',
      ),
    ];

    expect(helper.recommend(habits, records, now: now), isNull);
    expect(helper.baseline(habits, records, now: now), isNull);
  });

  test('Malformed completion date raises a clear parsing failure', () {
    final records = [
      HabitCompletion(
        habitId: 1,
        completionDate: 'not-a-date',
      ),
    ];

    expect(
      () => helper.recommend(habits, records, now: now),
      throwsFormatException,
    );
    expect(
      () => helper.baseline(habits, records, now: now),
      throwsFormatException,
    );
  });
}