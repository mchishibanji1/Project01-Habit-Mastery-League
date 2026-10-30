import 'package:flutter/material.dart';
import 'data/database_helper.dart';
import 'screens/completion_history_screen.dart';
import 'screens/settings_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final db = await DatabaseHelper.instance.database;

    final samples = [
      {'name': 'Preview habit', 'category': 'Development'},
      {'name': 'Walking test', 'category': 'Exercise'},
    ];

    final List<Map<String, Object?>> previewHabits = [];

    for (final sample in samples) {
      final rows = await db.query(
        'habits',
        where: 'name = ? AND category = ?',
        whereArgs: [sample['name'], sample['category']],
        orderBy: 'habitId ASC',
        limit: 1,
      );

      int habitId;

      if (rows.isEmpty) {
        habitId = await db.insert('habits', {
          'name': sample['name'],
          'category': sample['category'],
          'targetFrequency': 3,
          'createdAt': DateTime.now().toIso8601String(),
        });
      } else {
        habitId = rows.first['habitId'] as int;
      }

      previewHabits.add({
        'habitId': habitId,
        'name': sample['name'],
        'category': sample['category'],
      });
    }

    runApp(
      MaterialApp(
        home: PreviewHabitList(habits: previewHabits),
      ),
    );
  } catch (error) {
    runApp(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('Preview Error')),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Text('Could not open preview:\n$error'),
          ),
        ),
      ),
    );
  }
}

class PreviewHabitList extends StatelessWidget {
  final List<Map<String, Object?>> habits;

  const PreviewHabitList({
    super.key,
    required this.habits,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Development Preview'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: habits.length,
        itemBuilder: (context, index) {
          final habit = habits[index];

          return ListTile(
            title: Text(habit['name'] as String),
            subtitle: Text(habit['category'] as String),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CompletionHistoryScreen(
                    habitId: habit['habitId'] as int,
                    habitName: habit['name'] as String,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}