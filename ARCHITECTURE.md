#App Architecture

Our app is built using Flutter and follows a simple structure to keep the code organized. Since the app is completely offline, all the data is stored locally on the device using SQLite and SharedPreferences.

#Folder Structure
Here is how we organized the lib folder:

*   main.dart: The starting point of the app. It sets up the theme and the BottomNavigationBar so the user can switch between the Dashboard, History, and Settings screens.
*   models/: Contains the data classes (Habit and HabitCompletion). These are simple classes that map our Dart objects to SQLite tables using toMap() and fromMap().
*   data/: Handles the database. 
    *  database_helper.dart creates the tables and contains the SQL queries (CRUD). It uses a Singleton pattern so we only ever have one database connection open.
    *  completion_repository.dart and settings_repository.dart act as middlemen to fetch and save data for Rob's history and settings screens.
*   screens/: Contains all the UI pages. We split the work here, with Marc building the Dashboard, Editor, and Details, and Rob building History, Settings, and the Helper.

#State Management
We didn't use complex state management libraries like Provider or BLoC. We used Flutter's built-in setState() because it was enough for the scope of this project. 
*   For example, in the Habit Editor, the slider and text fields update their values locally using setState. 
*   We also made sure to dispose of our text controllers in the dispose() method to prevent memory leaks.

#Database Design
We used SQLite for the main data and SharedPreferences for simple settings (like toggling notes on/off).

For SQLite, we have two tables:
1.  habits: Stores the habit name, category, frequency, etc.
2.  habit_completions: Stores the history of when a habit was completed.

-Data Integrity: 
We linked the two tables using a foreign key (habitId). We also turned on PRAGMA foreign_keys = ON and used ON DELETE CASCADE. This means if a user deletes a habit from the Dashboard, SQLite automatically deletes all the completion history for that habit so we don't have random leftover data.

#Smart Helper
The smart helper is fully local and doesn't use any internet or external APIs. It just looks at the active habits in the SQLite database and uses a simple rule-based scoring system to recommend what the user should focus on next. The logic is completely separate from the UI code.