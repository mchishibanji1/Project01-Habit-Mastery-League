import 'package:flutter/material.dart';

import '../data/database_helper.dart';
import '../data/completion_repository.dart';
import '../data/settings_repository.dart';

class HistoryInsightsScreen extends StatefulWidget {
  const HistoryInsightsScreen({super.key});

  @override
  State<HistoryInsightsScreen> createState() => _HistoryInsightsScreenState();
}

class _HistoryInsightsScreenState extends State<HistoryInsightsScreen> {
  final repository = CompletionRepository();
  final settingsRepository = SettingsRepository();
  bool showNotes = true;

  List<Map<String, Object?>> habits = [];
  List<Map<String, Object?>> records = [];
  List<String> categories = [];

  int selectedHabit = 0;
  String selectedCategory = '';
  int selectedDays = 0;

  bool loading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadPreferences();
  }

  Future<void> loadPreferences() async {
    try {
      final days = await settingsRepository.getHistoryDays();
      final notes = await settingsRepository.getShowNotes();

      if (!mounted) return;

      setState(() {
        selectedDays = days;
        showNotes = notes;
      });

      await loadHistory();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        loading = false;
        errorMessage = 'Could not load preferences. Please try again.';
      });
    }
  }

  Future<void> loadHistory() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final db = await DatabaseHelper.instance.database;

      final habitRows = await db.query(
        'habits',
        columns: ['habitId', 'name', 'category'],
        orderBy: 'name COLLATE NOCASE ASC, habitId ASC',
      );

      final List<String> categoryNames = [];

      for (final habit in habitRows) {
        final category = habit['category'] as String;
        if (!categoryNames.contains(category)) {
          categoryNames.add(category);
        }
      }

      categoryNames.sort();

      // Clear filters if their habit/category was deleted.
      int habitFilter = selectedHabit;
      String categoryFilter = selectedCategory;

      if (!habitRows.any((habit) => habit['habitId'] == habitFilter)) {
        habitFilter = 0;
      }

      if (!categoryNames.contains(categoryFilter)) {
        categoryFilter = '';
      }

      final result = await repository.getHistory(
        habitId: habitFilter == 0 ? null : habitFilter,
        category: categoryFilter.isEmpty ? null : categoryFilter,
        lastDays: selectedDays == 0 ? null : selectedDays,
      );

      if (!mounted) return;

      setState(() {
        habits = habitRows;
        categories = categoryNames;
        records = result;
        selectedHabit = habitFilter;
        selectedCategory = categoryFilter;
        loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        loading = false;
        errorMessage = 'Could not load history. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int completedCount = 0;

    for (final record in records) {
      if (record['status'] == 'completed') {
        completedCount++;
      }
    }

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
              onPressed: loadPreferences,
              child: const Text('Try again'),
            ),
          ],
        ),
      );
    } else if (records.isEmpty) {
      content = const Center(child: Text('No records match these filters.'));
    } else {
      content = ListView.builder(
        itemCount: records.length,
        itemBuilder: (context, index) {
          final record = records[index];
          final date = DateTime.parse(record['completionDate'] as String);
          final completed = record['status'] == 'completed';
          final note = record['note'] as String;

          return ListTile(
            leading: Icon(
              completed ? Icons.check_circle_outline : Icons.timelapse,
            ),
            title: Text(record['habitName'] as String),
            subtitle: Text(
              '${record['category']}'
              ' · ${date.month}/${date.day}/${date.year}'
              '\n${completed ? 'Completed' : 'In progress'}'
              '${showNotes && note.isNotEmpty ? '\n$note' : ''}',
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('History and Insights'),
        actions: [
          IconButton(
            tooltip: 'Refresh history',
            onPressed: loading ? null : loadHistory,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Keep the filters scrollable on smaller screens.
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Habit'),
                    DropdownButton<int>(
                      isExpanded: true,
                      value: selectedHabit,
                      items: [
                        const DropdownMenuItem(
                          value: 0,
                          child: Text('All habits'),
                        ),
                        for (final habit in habits)
                          DropdownMenuItem(
                            value: habit['habitId'] as int,
                            child: Text(habit['name'] as String),
                          ),
                      ],
                      onChanged: loading
                          ? null
                          : (value) {
                              if (value == null) return;
                              setState(() {
                                selectedHabit = value;
                              });
                              loadHistory();
                            },
                    ),
                    const Text('Category'),
                    DropdownButton<String>(
                      isExpanded: true,
                      value: selectedCategory,
                      items: [
                        const DropdownMenuItem(
                          value: '',
                          child: Text('All categories'),
                        ),
                        for (final category in categories)
                          DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ),
                      ],
                      onChanged: loading
                          ? null
                          : (value) {
                              if (value == null) return;
                              setState(() {
                                selectedCategory = value;
                              });
                              loadHistory();
                            },
                    ),
                    const Text('Period'),
                    DropdownButton<int>(
                      isExpanded: true,
                      value: selectedDays,
                      items: const [
                        DropdownMenuItem(value: 0, child: Text('All time')),
                        DropdownMenuItem(value: 7, child: Text('Last 7 days')),
                        DropdownMenuItem(
                          value: 30,
                          child: Text('Last 30 days'),
                        ),
                      ],
                      onChanged: loading
                          ? null
                          : (value) {
                              if (value == null) return;
                              setState(() {
                                selectedDays = value;
                              });
                              loadHistory();
                            },
                    ),
                    const SizedBox(height: 12),
                    Text(
                      loading || errorMessage != null
                          ? 'Summary unavailable'
                          : 'Matching records: ${records.length}'
                                '\nCompleted: $completedCount',
                    ),
                  ],
                ),
              ),
            ),
            Expanded(child: content),
          ],
        ),
      ),
    );
  }
}
