import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  Future<int> getHistoryDays() async {
    final preferences = await SharedPreferences.getInstance();
    final days = preferences.getInt('history_days') ?? 0;

    if (days != 0 && days != 7 && days != 30) {
      return 0;
    }

    return days;
  }

  Future<void> saveHistoryDays(int days) async {
    if (days != 0 && days != 7 && days != 30) {
      throw ArgumentError('Select a supported history period.');
    }

    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setInt('history_days', days);

    if (!saved) {
      throw StateError('Could not save the history period.');
    }
  }

  Future<bool> getShowNotes() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool('show_notes') ?? true;
  }

  Future<void> saveShowNotes(bool showNotes) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setBool('show_notes', showNotes);

    if (!saved) {
      throw StateError('Could not save the note preference.');
    }
  }
}