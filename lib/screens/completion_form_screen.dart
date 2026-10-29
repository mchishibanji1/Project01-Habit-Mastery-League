import 'package:flutter/material.dart';
import '../data/completion_repository.dart';
import '../models/habit_completion.dart';

class CompletionFormScreen extends StatefulWidget {
  final int habitId;
  final HabitCompletion? record;

  const CompletionFormScreen({
    super.key,
    required this.habitId,
    this.record,
  });

  @override
  State<CompletionFormScreen> createState() =>
      _CompletionFormScreenState();
}

class _CompletionFormScreenState extends State<CompletionFormScreen> {
  final repository = CompletionRepository();
  final formKey = GlobalKey<FormState>();
  final noteController = TextEditingController();

  DateTime selectedDate = DateUtils.dateOnly(DateTime.now());
  String status = 'completed';
  bool saving = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    final record = widget.record;
    if (record != null) {
      selectedDate = DateUtils.dateOnly(
        DateTime.parse(record.completionDate),
      );
      status = record.status;
      noteController.text = record.note;
    }
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  Future<void> selectDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final firstDate = selectedDate.isBefore(DateTime(2000))
        ? selectedDate
        : DateTime(2000);
    final lastDate = selectedDate.isAfter(today) ? selectedDate : today;

    final result = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (!mounted || result == null) return;

    setState(() {
      selectedDate = result;
    });
  }

  Future<void> saveRecord() async {
    if (saving || !formKey.currentState!.validate()) return;

    setState(() {
      saving = true;
      errorMessage = null;
    });

    try {
      if (selectedDate.isAfter(DateUtils.dateOnly(DateTime.now()))) {
        throw ArgumentError('Future dates are not allowed.');
      }

      final record = HabitCompletion(
        completionId: widget.record?.completionId,
        habitId: widget.habitId,
        completionDate: selectedDate.toIso8601String(),
        status: status,
        note: noteController.text,
      );

      if (widget.record == null) {
        await repository.addCompletion(record);
      } else {
        final count = await repository.updateCompletion(record);
        if (count != 1) {
          throw StateError('The record no longer exists.');
        }
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        saving = false;
        errorMessage = 'Could not save the record. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel =
        '${selectedDate.month}/${selectedDate.day}/${selectedDate.year}';

    return PopScope(
      canPop: !saving,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.record == null ? 'Add activity' : 'Edit activity',
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OutlinedButton.icon(
                  onPressed: saving ? null : selectDate,
                  icon: const Icon(Icons.calendar_today),
                  label: Text('Activity date: $dateLabel'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: status,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'in_progress',
                      child: Text('In progress'),
                    ),
                    DropdownMenuItem(
                      value: 'completed',
                      child: Text('Completed'),
                    ),
                  ],
                  onChanged: saving
                      ? null
                      : (value) {
                          setState(() {
                            status = value!;
                          });
                        },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: noteController,
                  enabled: !saving,
                  maxLines: 3,
                  maxLength: 300,
                  decoration: const InputDecoration(
                    labelText: 'Note (optional)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if ((value ?? '').trim().length > 300) {
                      return 'Use 300 characters or fewer.';
                    }
                    return null;
                  },
                ),
                if (errorMessage != null) ...[
                  Text(
                    errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                ElevatedButton(
                  onPressed: saving ? null : saveRecord,
                  child: Text(saving ? 'Saving...' : 'Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}