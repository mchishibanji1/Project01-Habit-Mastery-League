import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../data/completion_repository.dart';
import '../services/habit_helper.dart';
import 'completion_history_screen.dart';

class HabitHelperScreen extends StatefulWidget {
  const HabitHelperScreen({super.key});

  @override
  State<HabitHelperScreen> createState() => _HabitHelperScreenState();
}

class _HabitHelperScreenState extends State<HabitHelperScreen> {
  final repository = CompletionRepository();
  final helper = HabitHelper();

  List<Map<String, Object?>> habits = [];
  HabitSuggestion? suggestion;
  HabitSuggestion? baseline;
  bool loading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadSuggestion();
  }

  Future<void> loadSuggestion() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final db = await DatabaseHelper.instance.database;
      final habitRows = await db.query(
        'habits',
        orderBy: 'habitId ASC',
      );
      final records = await repository.getCompletions();
      final now = DateTime.now();

      final result = helper.recommend(habitRows, records, now: now);
      final baselineResult = helper.baseline(
        habitRows,
        records,
        now: now,
      );

      if (!mounted) return;

      setState(() {
        habits = habitRows;
        suggestion = result;
        baseline = baselineResult;
        loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        loading = false;
        errorMessage = 'Could not load suggestions. Please try again.';
      });
    }
  }

  Future<void> openHabit(int habitId, String habitName) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CompletionHistoryScreen(
          habitId: habitId,
          habitName: habitName,
        ),
      ),
    );

    if (!mounted) return;
    await loadSuggestion();
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (loading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (errorMessage != null) {
      content = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(errorMessage!),
            ElevatedButton(
              onPressed: loadSuggestion,
              child: const Text('Try again'),
            ),
          ],
        ),
      );
    } else {
      final activeHabits = habits.where((habit) {
        return habit['isActive'] == 1;
      }).toList();

      final current = suggestion;
      final simple = baseline;

      content = ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Next Habit Helper',
            style: TextStyle(fontSize: 22),
          ),
          const SizedBox(height: 8),
          const Text(
            'Local rule-based suggestions. You decide what to do next.',
          ),
          const SizedBox(height: 24),
          if (current == null)
            Text(
              activeHabits.isEmpty
                  ? 'No active habits. Create or activate a habit first.'
                  : 'All active habits have been completed today.',
            )
          else ...[
            Text(
              'Suggested: ${current.habitName}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(current.explanation),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => openHabit(
                current.habitId,
                current.habitName,
              ),
              child: const Text('Open suggested habit'),
            ),
          ],
          const Divider(height: 36),
          const Text(
            'Simple baseline',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            simple == null
                ? 'No eligible habit.'
                : '${simple.habitName}\n${simple.explanation}',
          ),
          const Divider(height: 36),
          const Text(
            'Choose a different habit',
            style: TextStyle(fontSize: 18),
          ),
          const Text(
            'You can ignore the suggestion and open any active habit.',
          ),
          const SizedBox(height: 8),
          for (final habit in activeHabits)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(habit['name'] as String),
              subtitle: Text(habit['category'] as String),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => openHabit(
                habit['habitId'] as int,
                habit['name'] as String,
              ),
            ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Helper'),
        actions: [
          IconButton(
            tooltip: 'Refresh suggestion',
            onPressed: loading ? null : loadSuggestion,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(child: content),
    );
  }
}