import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  Future<Database>? _databaseFuture;

  Future<Database> get database {
    return _databaseFuture ??= _openDatabase();
  }

  Future<Database> _openDatabase() async {
    final folder = await getDatabasesPath();
    final file = p.join(folder, 'habit_mastery.db');

    return openDatabase(
      file,
      version: 1,
      onConfigure: (db) async {
        // Enforce relationships and cascading deletes.
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE habits (
            habitId INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL
              CHECK(length(trim(name)) > 0),
            description TEXT NOT NULL DEFAULT '',
            category TEXT NOT NULL
              CHECK(length(trim(category)) > 0),
            targetFrequency INTEGER NOT NULL DEFAULT 1
              CHECK(targetFrequency BETWEEN 1 AND 7),
            createdAt TEXT NOT NULL,
            isActive INTEGER NOT NULL DEFAULT 1
              CHECK(isActive IN (0, 1))
          )
        ''');

        await db.execute('''
          CREATE TABLE habit_completions (
            completionId INTEGER PRIMARY KEY AUTOINCREMENT,
            habitId INTEGER NOT NULL,
            completionDate TEXT NOT NULL,
            status TEXT NOT NULL DEFAULT 'completed'
              CHECK(status IN ('in_progress', 'completed')),
            note TEXT NOT NULL DEFAULT '',
            FOREIGN KEY (habitId)
              REFERENCES habits(habitId)
              ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE INDEX idx_completions_habit_date
          ON habit_completions(habitId, completionDate)
        ''');
      },
    );
  }
}