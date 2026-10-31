import 'package:flutter/material.dart';

// Importing the three main screens of the application
import 'screens/dashboard.dart'; // Marc's screen (Habit List)
import 'screens/history_insights_screen.dart'; // Rob's screen (History)
import 'screens/settings_screen.dart'; // Rob's screen (Settings)

void main() {
  // Entry point of the Flutter application
  runApp(const HabitMasteryApp());
}

/// The root widget of the application.
/// This sets up the overall app configuration, like the theme and title.
class HabitMasteryApp extends StatelessWidget {
  const HabitMasteryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Mastery League',
      // Define the app's visual theme (colors, fonts, etc.)
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // We set the 'home' to our MainNavigation widget, which handles the tabs.
      home: const MainNavigation(),
      // Hides the debug banner in the top right corner
      debugShowCheckedModeBanner: false,
    );
  }
}

/// This is a StatefulWidget because it needs to remember which tab
/// the user is currently looking at (_currentIndex).
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  // Tracks the currently selected tab. 0 = Habits, 1 = History, 2 = Settings
  int _currentIndex = 0;

  // A list of all the screens that the BottomNavigationBar can switch between.
  // The order of this list MUST match the order of the items in the BottomNavigationBar below.
  final List<Widget> _screens = [
    DashboardScreen(),
    const HistoryInsightsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The body dynamically changes based on the selected tab index
      body: _screens[_currentIndex],

      // The navigation bar at the bottom of the screen
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,

        // When a user taps a tab, update the state to show the new screen
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },

        // The actual buttons shown in the navigation bar
        items: const [
          // Tab 0: Marc's Habit Dashboard
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Habits'),
          // Tab 1: Rob's History & Insights
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          // Tab 2: Rob's Settings
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
