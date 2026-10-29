import 'package:flutter/material.dart';

import '../data/completion_repository.dart';
import '../models/habit_completion.dart';
import 'completion_form_screen.dart';
import 'history_insights_screen.dart';

class CompletionHistoryScreen extends StatefulWidget {
  final int habitId;
  final String habitName;

  const CompletionHistoryScreen({
    super.key,
    required this.habitId,
    required this.habitName,
  });

  @override
  State<CompletionHistoryScreen> createState() =>
      _CompletionHistoryScreenState();
}

class _CompletionHistoryScreenState extends State<CompletionHistoryScreen> {
  final repository = CompletionRepository();

  List<HabitCompletion> records = [];
  bool loading = true;
  String? errorMessage;
  String selectedStatus = 'all';

  List<HabitCompletion> get filteredRecords {
    if (selectedStatus == 'all') {
      return records;
    }

    return records.where((record) {
      return record.status == selectedStatus;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    loadRecords();
  }

  Future<void> loadRecords() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final result = await repository.getCompletions(habitId: widget.habitId);

      if (!mounted) return;

      setState(() {
        records = result;
        loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        loading = false;
        errorMessage = 'Could not load records. Please try again.';
      });
    }
  }

  Future<void> openForm({HabitCompletion? record}) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CompletionFormScreen(habitId: widget.habitId, record: record),
      ),
    );

    if (!mounted) return;

    if (saved == true) {
      await loadRecords();
    }
  }

  Future<void> confirmDelete(HabitCompletion record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete activity?'),
          content: const Text(
            'This activity record will be permanently deleted.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) return;

    setState(() {
      loading = true;
    });

    try {
      final count = await repository.deleteCompletion(record.completionId!);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            count == 1 ? 'Activity deleted.' : 'The record no longer exists.',
          ),
        ),
      );

      await loadRecords();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not delete the record. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibleRecords = filteredRecords;
    final completedCount = records.where((record) {
      return record.status == 'completed';
    }).length;
    Widget content;

    if (loading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (errorMessage != null) {
      content = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(errorMessage!),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: loadRecords,
              child: const Text('Try again'),
            ),
          ],
        ),
      );
    } else if (visibleRecords.isEmpty) {
      content = Center(
        child: Text(
          records.isEmpty
              ? 'No activity records yet.'
              : 'No records match this filter.',
        ),
      );
    } else {
      content = ListView.builder(
        itemCount: visibleRecords.length,
        itemBuilder: (context, index) {
          final record = visibleRecords[index];
          final date = DateTime.parse(record.completionDate);
          final dateLabel = '${date.month}/${date.day}/${date.year}';

          return ListTile(
            onTap: () => openForm(record: record),
            leading: Icon(
              record.status == 'completed'
                  ? Icons.check_circle_outline
                  : Icons.timelapse,
            ),
            title: Text(dateLabel),
            subtitle: Text(
              '${record.status == 'completed' ? 'Completed' : 'In progress'}'
              '\n${record.note.isEmpty ? 'No note' : record.note}',
            ),
            isThreeLine: true,
            trailing: IconButton(
              tooltip: 'Delete activity',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => confirmDelete(record),
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.habitName} History'),
        actions: [
          IconButton(
            tooltip: 'All history and insights',
            icon: const Icon(Icons.bar_chart),
            onPressed: loading
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const HistoryInsightsScreen(),
                      ),
                    );
                  },
          ),
          IconButton(
            tooltip: 'Refresh records',
            onPressed: loading ? null : loadRecords,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    loading || errorMessage != null
                        ? 'Summary unavailable'
                        : 'Total records: ${records.length}'
                              '  |  Completed: $completedCount',
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Filter by status',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'all',
                        child: Text('All records'),
                      ),
                      DropdownMenuItem(
                        value: 'completed',
                        child: Text('Completed'),
                      ),
                      DropdownMenuItem(
                        value: 'in_progress',
                        child: Text('In progress'),
                      ),
                    ],
                    onChanged: loading
                        ? null
                        : (value) {
                            if (value == null) return;
                            setState(() {
                              selectedStatus = value;
                            });
                          },
                  ),
                ],
              ),
            ),
            Expanded(child: content),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add activity',
        onPressed: loading ? null : () => openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
