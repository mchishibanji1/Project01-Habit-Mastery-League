#Habit Mastery League

#Project Overview
Habit Mastery League is an offline-first mobile application designed to help users build consistent daily or weekly routines. Users can create habits, log their progress, review their completion history, and receive local, data-driven suggestions on what to focus on next. The app is built with Flutter and utilizes SQLite for relational data and SharedPreferences for local settings. It operates 100% locally without any cloud backend or internet connection.

#Team Roles
This project was completed by a two-person team:
*   Marc Chishibanji: 
    *   Frontend UI (Dashboard, Habit Editor, Habit Details).
    *   Global Navigation (main.dart / BottomNavigationBar).
    *   Habit CRUD database methods.
    *   Widget testing and manual persistence testing.
*   Rob Han:
    *   SQLite database schema and setup.
    *   Completion History and Settings screens.
    *   HabitCompletion CRUD and Settings repository.
    *   Local Smart Helper implementation and evaluation.

#Features Implemented
*   Habit Management: Full CRUD (Create, Read, Update, Delete) for habits, including whitespace validation and confirmation dialogs.
*   Completion Tracking: Log activity for specific habits and view detailed completion histories.
*   History & Insights: Filter completion records by habit, category, and time period. View aggregate completion counts.
*   Settings:** Manage app preferences (e.g., toggling activity notes, default history periods) using SharedPreferences.
*   Local Smart Helper: A rule-based recommendation system that suggests a habit to focus on based on current incomplete habits and recent progress.
*   Offline-First: Full functionality without internet access. Data persists across app restarts.

#Setup & Installation
#Prerequisites
*   Flutter SDK (latest stable version)
*   Android Studio (for emulator) or a physical Android device.

 #Installation Steps
1. Clone the repository:
   ```bash
   git clone https://github.com/mchishibanji1/Project01-Habit-Mastery-League.git