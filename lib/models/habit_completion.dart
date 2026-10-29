class HabitCompletion {
  final int? completionId;
  final int habitId;
  final String completionDate;
  final String status;
  final String note;

  HabitCompletion({
    this.completionId,
    required this.habitId,
    required this.completionDate,
    this.status = 'completed',
    this.note = '',
  });

  // Convert this object into a row for SQLite.
  Map<String, Object?> toMap() {
    final Map<String, Object?> data = {
      'habitId': habitId,
      'completionDate': completionDate,
      'status': status,
      'note': note,
    };

    // New records let SQLite generate the ID.
    if (completionId != null) {
      data['completionId'] = completionId;
    }

    return data;
  }

  // Convert a SQLite row into a Dart object.
  static HabitCompletion fromMap(Map<String, Object?> data) {
    return HabitCompletion(
      completionId: data['completionId'] as int,
      habitId: data['habitId'] as int,
      completionDate: data['completionDate'] as String,
      status: data['status'] as String,
      note: data['note'] as String,
    );
  }
}