import 'package:flutter/material.dart';
import '../data/settings_repository.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final repository = SettingsRepository();

  int historyDays = 0;
  bool showNotes = true;
  bool loading = true;
  bool saving = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final days = await repository.getHistoryDays();
      final notes = await repository.getShowNotes();

      if (!mounted) return;

      setState(() {
        historyDays = days;
        showNotes = notes;
        loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        loading = false;
        errorMessage = 'Could not load settings. Please try again.';
      });
    }
  }

  Future<void> saveSettings() async {
    if (saving) return;

    setState(() {
      saving = true;
    });

    try {
      await repository.saveHistoryDays(historyDays);
      await repository.saveShowNotes(showNotes);

      if (!mounted) return;

      setState(() {
        saving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved.')),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        saving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not save all settings. Please retry.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
              onPressed: loadSettings,
              child: const Text('Try again'),
            ),
          ],
        ),
      );
    } else {
      content = ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Default history period'),
          DropdownButton<int>(
            isExpanded: true,
            value: historyDays,
            items: const [
              DropdownMenuItem(
                value: 0,
                child: Text('All time'),
              ),
              DropdownMenuItem(
                value: 7,
                child: Text('Last 7 days'),
              ),
              DropdownMenuItem(
                value: 30,
                child: Text('Last 30 days'),
              ),
            ],
            onChanged: saving
                ? null
                : (value) {
                    if (value == null) return;
                    setState(() {
                      historyDays = value;
                    });
                  },
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Show activity notes'),
            subtitle: const Text(
              'Display notes in History and Insights.',
            ),
            value: showNotes,
            onChanged: saving
                ? null
                : (value) {
                    setState(() {
                      showNotes = value;
                    });
                  },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: saving ? null : saveSettings,
            child: Text(saving ? 'Saving...' : 'Save settings'),
          ),
        ],
      );
    }

    return PopScope(
      canPop: !saving,
      child: Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: SafeArea(child: content),
      ),
    );
  }
}