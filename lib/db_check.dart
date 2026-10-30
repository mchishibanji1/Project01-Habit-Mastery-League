import 'package:flutter/material.dart';

import 'data/database_helper.dart';
import 'data/completion_repository.dart';
import 'models/habit_completion.dart';

import 'package:sqflite/sqflite.dart';

void check(bool condition, String message) {
  if (!condition) {
    throw StateError(message);
  }
}

Future<String> testDatabase() async {
  final db = await DatabaseHelper.instance.database;
  final repository = CompletionRepository();
  final results = <String>[];

  // Create a separate parent record just for this test.
  final habitId = await db.insert('habits', {
    'name': 'Database test habit',
    'category': 'Test',
    'targetFrequency': 3,
    'createdAt': DateTime.now().toIso8601String(),
  });

  try {
    results.add('PASS: Database and habit created');

    final date = DateTime.now().toIso8601String();

    final id = await repository.addCompletion(
      HabitCompletion(
        habitId: habitId,
        completionDate: date,
        note: 'Original note',
      ),
    );

    var records = await repository.getCompletions(habitId: habitId);
    check(records.length == 1, 'Record count should be 1');
    check(records.first.completionId == id, 'Record ID mismatch');
    check(records.first.note == 'Original note', 'Saved note mismatch');
    results.add('PASS: Add and read completion');

    final updated = await repository.updateCompletion(
      HabitCompletion(
        completionId: id,
        habitId: habitId,
        completionDate: date,
        note: 'Updated note',
      ),
    );

    records = await repository.getCompletions(habitId: habitId);
    check(updated == 1, 'Update should affect 1 row');
    check(records.first.note == 'Updated note', 'Note did not update');
    results.add('PASS: Update completion');

    final deleted = await repository.deleteCompletion(id);
    records = await repository.getCompletions(habitId: habitId);
    check(deleted == 1 && records.isEmpty, 'Delete failed');
    results.add('PASS: Delete completion');

    await repository.addCompletion(
      HabitCompletion(habitId: habitId, completionDate: date),
    );

    await db.delete('habits', where: 'habitId = ?', whereArgs: [habitId]);

    records = await repository.getCompletions(habitId: habitId);
    check(records.isEmpty, 'Related records were not deleted');
    results.add('PASS: Parent deletion removes child records');

    final beforeCount = (await repository.getCompletions()).length;

    final invalidRecords = [
      HabitCompletion(habitId: 0, completionDate: date),
      HabitCompletion(habitId: habitId, completionDate: 'not-a-date'),
      HabitCompletion(
        habitId: habitId,
        completionDate: date,
        status: 'invalid-status',
      ),
    ];

    final labels = [
      'Invalid habit ID rejected',
      'Invalid date rejected',
      'Invalid status rejected',
    ];

    for (int i = 0; i < invalidRecords.length; i++) {
      bool rejected = false;

      try {
        await repository.addCompletion(invalidRecords[i]);
      } on ArgumentError {
        rejected = true;
      }

      check(rejected, labels[i]);
      results.add('PASS: ${labels[i]}');
    }

    // The earlier cascade test deleted this habit.
    // A new child record must not reference its deleted ID.
    bool missingParentRejected = false;

    try {
      await repository.addCompletion(
        HabitCompletion(habitId: habitId, completionDate: date),
      );
    } on DatabaseException catch (error) {
      if (!error.toString().contains('FOREIGN KEY constraint failed')) {
        rethrow;
      }
      missingParentRejected = true;
    }

    check(missingParentRejected, 'Missing parent was accepted');
    results.add('PASS: Missing parent rejected by foreign key');

    final afterCount = (await repository.getCompletions()).length;
    check(beforeCount == afterCount, 'Invalid input changed record count');
    results.add('PASS: Invalid attempts leave record count unchanged');

    return results.join('\n\n');
  } finally {
    // Clean up only this test's habit and its related records.
    await db.delete('habits', where: 'habitId = ?', whereArgs: [habitId]);
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String result;

  try {
    result = await testDatabase();
  } catch (error) {
    result = 'FAIL: $error';
  }

  runApp(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Database Check')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Text(result, style: const TextStyle(fontSize: 18)),
        ),
      ),
    ),
  );
}
