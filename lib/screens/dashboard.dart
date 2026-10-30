import 'package:flutter/material.dart';

import '../data/database_helper.dart';
import '../models/habit.dart';
import 'habit_editor.dart';
import 'habit_details.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Habit> _habits = [];

  void _loadHabits() async {
    final habits = await DatabaseHelper.instance.getHabits();
    setState(() {
      _habits = habits;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Habits')),
      body: _habits.isEmpty
          ? Center(child: Text('No habits yet. Add one!'))
          : ListView.builder(
              itemCount: _habits.length,
              itemBuilder: (context, index) {
                final habit = _habits[index];
                return ListTile(
                  title: Text(habit.name),
                  subtitle: Text(
                    '${habit.category} • ${habit.targetFrequency}x/week',
                  ),
                  trailing: Icon(Icons.chevron_right),
                  // ONTAP BLOCK BELOW
                  onTap: () async {
                    final changed = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HabitDetailsScreen(habit: habit),
                      ),
                    );
                    // If the user edited or deleted the habit, refresh the list
                    if (changed == true) {
                      _loadHabits();
                    }
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HabitEditorScreen()),
          );
          if (result == true) {
            _loadHabits(); // Refresh list if a new habit was saved
          }
        },
      ),
    );
  }
}
