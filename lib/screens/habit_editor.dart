import 'package:flutter/material.dart';

import '../data/database_helper.dart';
import '../models/habit.dart';

class HabitEditorScreen extends StatefulWidget {
  final Habit? habit; // Add this to accept an existing habit

  HabitEditorScreen({this.habit}); // Update constructor

  @override
  _HabitEditorScreenState createState() => _HabitEditorScreenState();
}

class _HabitEditorScreenState extends State<HabitEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late String _category;
  late int _targetFrequency;

  @override
  void initState() {
    super.initState();
    // If we are editing, pre-fill the fields. Otherwise, use defaults.
    _nameController = TextEditingController(text: widget.habit?.name ?? '');
    _descController = TextEditingController(
      text: widget.habit?.description ?? '',
    );
    _category = widget.habit?.category ?? 'Study';
    _targetFrequency = widget.habit?.targetFrequency ?? 1;
  }

  void _saveHabit() async {
    if (_formKey.currentState!.validate()) {
      final newHabit = Habit(
        habitId: widget.habit?.habitId, // Keep ID if editing
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        category: _category,
        targetFrequency: _targetFrequency,
        createdAt:
            widget.habit?.createdAt ??
            DateTime.now().toIso8601String(), // Keep original date
        isActive: widget.habit?.isActive ?? true,
      );

      if (widget.habit == null) {
        await DatabaseHelper.instance.insertHabit(newHabit);
      } else {
        await DatabaseHelper.instance.updateHabit(newHabit);
      }

      if (mounted) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habit == null ? 'New Habit' : 'Edit Habit'),
      ),
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
            ElevatedButton(
              onPressed: _saveHabit,
              child: Text(widget.habit == null ? 'Save Habit' : 'Update Habit'),
            ),
          ],
        ),
      ),
    );
  }
}
