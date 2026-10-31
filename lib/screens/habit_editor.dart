import 'package:flutter/material.dart';

import '../data/database_helper.dart';
import '../models/habit.dart';

class HabitEditorScreen extends StatefulWidget {
  final Habit? habit;

  const HabitEditorScreen({super.key, this.habit});

  @override
  State<HabitEditorScreen> createState() => _HabitEditorScreenState();
}

class _HabitEditorScreenState extends State<HabitEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late String _category;
  late int _targetFrequency;

  bool _isSaving = false; // Prevents duplicate saves

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.habit?.name ?? '');
    _descController = TextEditingController(
      text: widget.habit?.description ?? '',
    );
    _category = widget.habit?.category ?? 'Study';
    _targetFrequency = widget.habit?.targetFrequency ?? 1;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _saveHabit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true); // Disable button while saving

      try {
        final newHabit = Habit(
          habitId: widget.habit?.habitId,
          name: _nameController.text.trim(),
          description: _descController.text.trim(),
          category: _category,
          targetFrequency: _targetFrequency,
          createdAt:
              widget.habit?.createdAt ?? DateTime.now().toIso8601String(),
          isActive: widget.habit?.isActive ?? true,
        );

        if (widget.habit == null) {
          await DatabaseHelper.instance.insertHabit(newHabit);
        } else {
          await DatabaseHelper.instance.updateHabit(newHabit);
        }

        if (mounted) Navigator.pop(context, true);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Error saving habit: $e')));
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
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
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Habit Name'),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Name is required and cannot be empty';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: [
                'Study',
                'Health',
                'Mindfulness',
                'Other',
              ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) => setState(() => _category = val!),
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSaving ? null : _saveHabit, // Disable if saving
              child: _isSaving
                  ? const CircularProgressIndicator()
                  : Text(widget.habit == null ? 'Save Habit' : 'Update Habit'),
            ),
          ],
        ),
      ),
    );
  }
}
