import 'package:flutter/material.dart';

import '../data/database_helper.dart';
import '../models/habit.dart';

class HabitEditorScreen extends StatefulWidget {
  @override
  _HabitEditorScreenState createState() => _HabitEditorScreenState();
}

class _HabitEditorScreenState extends State<HabitEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  String _category = 'Study';
  int _targetFrequency = 1;

  void _saveHabit() async {
    if (_formKey.currentState!.validate()) {
      final newHabit = Habit(
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        category: _category,
        targetFrequency: _targetFrequency,
        createdAt: DateTime.now().toIso8601String(),
      );

      await DatabaseHelper.instance.insertHabit(newHabit);

      if (mounted) {
        Navigator.pop(
          context,
          true,
        ); // Return true to tell dashboard to refresh
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('New Habit')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Habit Name'),
              validator: (val) =>
                  val == null || val.isEmpty ? 'Name is required' : null,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              decoration: InputDecoration(labelText: 'Description (Optional)'),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: InputDecoration(labelText: 'Category'),
              items: [
                'Study',
                'Health',
                'Mindfulness',
                'Other',
              ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) => setState(() => _category = val!),
            ),
            SizedBox(height: 16),
            Text('Target Frequency: $_targetFrequency time(s) per week'),
            Slider(
              value: _targetFrequency.toDouble(),
              min: 1,
              max: 7,
              divisions: 6,
              label: _targetFrequency.toString(),
              onChanged: (val) =>
                  setState(() => _targetFrequency = val.toInt()),
            ),
            SizedBox(height: 24),
            ElevatedButton(onPressed: _saveHabit, child: Text('Save Habit')),
          ],
        ),
      ),
    );
  }
}
