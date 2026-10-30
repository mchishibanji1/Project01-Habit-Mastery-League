import '../models/habit_completion.dart';

class HabitSuggestion {
  final int habitId;
  final String habitName;
  final String explanation;

  HabitSuggestion({
    required this.habitId,
    required this.habitName,
    required this.explanation,
  });
}

class HabitHelper {
  List<Map<String, Object?>> _eligibleHabits(
    List<Map<String, Object?>> habits,
    List<HabitCompletion> records,
    DateTime today,
  ) {
    final List<Map<String, Object?>> eligible = [];

    for (final habit in habits) {
      if (habit['isActive'] != 1) continue;

      final habitId = habit['habitId'] as int;
      bool completedToday = false;

      for (final record in records) {
        if (record.habitId != habitId ||
            record.status != 'completed') {
          continue;
        }

        final date = DateTime.parse(record.completionDate).toLocal();

        if (date.year == today.year &&
            date.month == today.month &&
            date.day == today.day) {
          completedToday = true;
          break;
        }
      }

      if (!completedToday) {
        eligible.add(habit);
      }
    }

    eligible.sort((a, b) {
      return (a['habitId'] as int).compareTo(b['habitId'] as int);
    });

    return eligible;
  }

  HabitSuggestion? baseline(
    List<Map<String, Object?>> habits,
    List<HabitCompletion> records, {
    DateTime? now,
  }) {
    final today = (now ?? DateTime.now()).toLocal();
    final eligible = _eligibleHabits(habits, records, today);

    if (eligible.isEmpty) return null;

    final habit = eligible.first;

    return HabitSuggestion(
      habitId: habit['habitId'] as int,
      habitName: habit['name'] as String,
      explanation: 'First eligible habit in ID order.',
    );
  }

  HabitSuggestion? recommend(
    List<Map<String, Object?>> habits,
    List<HabitCompletion> records, {
    DateTime? now,
  }) {
    final today = (now ?? DateTime.now()).toLocal();
    final eligible = _eligibleHabits(habits, records, today);

    if (eligible.isEmpty) return null;

    final start = DateTime(
      today.year,
      today.month,
      today.day - 6,
    );
    final end = DateTime(
      today.year,
      today.month,
      today.day + 1,
    );

    Map<String, Object?> selected = eligible.first;
    int lowestCount = -1;

    for (final habit in eligible) {
      final habitId = habit['habitId'] as int;
      int count = 0;

      for (final record in records) {
        if (record.habitId != habitId ||
            record.status != 'completed') {
          continue;
        }

        final date = DateTime.parse(record.completionDate).toLocal();

        if (!date.isBefore(start) && date.isBefore(end)) {
          count++;
        }
      }

      // ID ordering keeps the smaller ID when counts are tied.
      if (lowestCount == -1 || count < lowestCount) {
        selected = habit;
        lowestCount = count;
      }
    }

    return HabitSuggestion(
      habitId: selected['habitId'] as int,
      habitName: selected['name'] as String,
      explanation: 'Not completed today, with $lowestCount completed '
          'records in the last 7 days. Lowest habit ID breaks ties.',
    );
  }
}