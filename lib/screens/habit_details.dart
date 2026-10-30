import 'package:flutter/material.dart';

import '../data/database_helper.dart';
import '../models/habit.dart';
import 'habit_editor.dart';

class HabitDetailsScreen extends StatelessWidget {
  final Habit habit;

  HabitDetailsScreen({required this.habit});

  void _deleteHabit(BuildContext context) async {
    // 1. Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Habit?'),
        content: Text(
          'This will also delete all completion history for this habit.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    // 2. If confirmed, delete from DB and go back to Dashboard
    if (confirm == true) {
      await DatabaseHelper.instance.deleteHabit(habit.habitId!);
      if (context.mounted) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(habit.name),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HabitEditorScreen(habit: habit),
                ),
              );
              if (updated == true && context.mounted)
                Navigator.pop(context, true); // Refresh dashboard
            },
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteHabit(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category: ${habit.category}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text(
              'Target: ${habit.targetFrequency}x per week',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              habit.description.isEmpty
                  ? 'No description provided.'
                  : habit.description,
            ),
            Spacer(),
            // Placeholder for Rob's completion screen integration
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Link to Rob's completion history screen later
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Completion logs coming soon!')),
                );
              },
              icon: Icon(Icons.check_circle),
              label: Text('View Activity / Log Completion'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
