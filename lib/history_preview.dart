import 'package:flutter/material.dart';
import 'data/database_helper.dart';
import 'screens/completion_history_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final db = await DatabaseHelper.instance.database;

    // Reuse this preview habit so records survive app restarts.
    final rows = await db.query(
      'habits',
      where: 'name = ? AND category = ?',
      whereArgs: ['Preview habit', 'Development'],
      orderBy: 'habitId ASC',
      limit: 1,
    );

    int habitId;

    if (rows.isEmpty) {
      habitId = await db.insert('habits', {
        'name': 'Preview habit',
        'category': 'Development',
        'targetFrequency': 3,
        'createdAt': DateTime.now().toIso8601String(),
      });
    } else {
      habitId = rows.first['habitId'] as int;
    }

    runApp(
      MaterialApp(
        home: CompletionHistoryScreen(
          habitId: habitId,
          habitName: 'Preview habit',
        ),
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