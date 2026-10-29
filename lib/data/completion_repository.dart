import '../models/habit_completion.dart';
import 'database_helper.dart';

class CompletionRepository {
  // Validate and prepare the values before saving.
  Map<String, Object?> _prepareData(HabitCompletion record) {
    if (record.habitId <= 0) {
      throw ArgumentError('Select a valid habit.');
    }

    final date = DateTime.tryParse(record.completionDate);

    if (date == null) {
      throw ArgumentError('Enter a valid completion date.');
    }

    if (record.status != 'in_progress' && record.status != 'completed') {
      throw ArgumentError('Invalid completion status.');
    }

    final data = record.toMap();

    // IDs are generated on insert and used in WHERE on update.
    data.remove('completionId');
    data['completionDate'] = date.toIso8601String();
    data['note'] = record.note.trim();

    return data;
  }

  Future<int> addCompletion(HabitCompletion record) async {
    final data = _prepareData(record);
    final db = await DatabaseHelper.instance.database;

    return db.insert('habit_completions', data);
  }

  Future<List<HabitCompletion>> getCompletions({int? habitId}) async {
    final db = await DatabaseHelper.instance.database;

    final rows = await db.query(
      'habit_completions',
      where: habitId == null ? null : 'habitId = ?',
      whereArgs: habitId == null ? null : [habitId],
      orderBy: 'completionDate DESC, completionId DESC',
    );

    final List<HabitCompletion> records = [];

    for (final row in rows) {
      records.add(HabitCompletion.fromMap(row));
    }

    return records;
  }

  Future<int> updateCompletion(HabitCompletion record) async {
    final id = record.completionId;

    if (id == null || id <= 0) {
      throw ArgumentError('A valid completion ID is required.');
    }

    final data = _prepareData(record);
    final db = await DatabaseHelper.instance.database;

    return db.update(
      'habit_completions',
      data,
      where: 'completionId = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteCompletion(int completionId) async {
    if (completionId <= 0) {
      throw ArgumentError('A valid completion ID is required.');
    }

    final db = await DatabaseHelper.instance.database;

    return db.delete(
      'habit_completions',
      where: 'completionId = ?',
      whereArgs: [completionId],
    );
  }

  Future<List<Map<String, Object?>>> getHistory({
    int? habitId,
    String? category,
    int? lastDays,
  }) async {
    if (lastDays != null && lastDays < 1) {
      throw ArgumentError('The number of days must be positive.');
    }

    final db = await DatabaseHelper.instance.database;
    final List<String> conditions = [];
    final List<Object?> arguments = [];

    if (habitId != null) {
      conditions.add('h.habitId = ?');
      arguments.add(habitId);
    }

    if (category != null) {
      conditions.add('h.category = ?');
      arguments.add(category);
    }

    if (lastDays != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Include today and the previous lastDays - 1 calendar days.
      final start = DateTime(today.year, today.month, today.day - lastDays + 1);

      final end = DateTime(today.year, today.month, today.day + 1);

      conditions.add('c.completionDate >= ?');
      arguments.add(start.toIso8601String());

      conditions.add('c.completionDate < ?');
      arguments.add(end.toIso8601String());
    }

    String whereClause = '';

    if (conditions.isNotEmpty) {
      whereClause = 'WHERE ${conditions.join(' AND ')}';
    }

    return db.rawQuery('''
      SELECT
        c.completionId,
        c.habitId,
        c.completionDate,
        c.status,
        c.note,
        h.name AS habitName,
        h.category
      FROM habit_completions AS c
      INNER JOIN habits AS h ON c.habitId = h.habitId
      $whereClause
      ORDER BY c.completionDate DESC, c.completionId DESC
    ''', arguments);
  }
}
