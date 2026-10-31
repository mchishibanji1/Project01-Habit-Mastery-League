Habit Mastery League - Screen Annotations

Screen 1: Dashboard
-Purpose: Habit overview and primary entry points.
-Entry: App launch.
-Primary Act: Tap a habit row to open Habit Details. Tap + to open Editor.
-Data: Reads from `habits` table.
-States: Default (list), Empty (No habits yet. Add one!).
-Test Case: Given the user has no habits, when they open the Dashboard, they expect to see "No habits yet. Add one!".

Screen 2: Habit Editor
-Purpose: Create a new habit or update an existing one.
-Entry: Tap + on Dashboard, or Edit on Details.
-Primary Act: Fill form and tap Save/Update.
-Data: Writes to `habits` table.
-States: Default, Validation Error (Name is required), Edit Mode (pre-filled).
-Test Case: Given the name field is empty, when the user taps Save, they expect to see "Name is required" and the habit is not saved.

Screen 3: Habit Details
-Purpose: Inspect, edit, remove, or log a habit.
-Entry: Tap a habit on the Dashboard.
-Primary Act: Edit, Delete, or Log Completion.
-Data: Reads/Deletes from `habits` (cascades to completions).
-States: Default, Delete Confirmation modal.
-Test Case: Given the user is on Details, when they tap Delete and confirm, they expect the habit to be removed and to return to the Dashboard.

Screen 4: History (Rob)
-Purpose: Review past habit activity and filter the timeline.
-Entry: Bottom Navigation.
-Primary Act: Select a filter from the dropdown.
-Data: Reads from `habit_completions`.
-States: Default list, Filtered list.
-Test Case: Given the user selects "Read every day", when the filter applies, they expect only that habit's history to show.

Steps: Ran the full app from `main.dart`. Logged a completion for a habit via the Details screen. Navigated to the History tab. Toggled a setting in the Settings tab, saved, and restarted the app.
-Expected: Completion shows in History. Setting persists after restart.
-Result: PASS. The history record appeared correctly, and the settings toggled state remained after a full app restart.

Screen 5: Settings (Rob)
Purpose: Manage user preferences for history and notes.
-Entry: Bottom Navigation.
-Primary Act: Toggle settings and save.
-Data: Writes to SharedPreferences.
-States: Default, Saving, Success.
-Test Case: Given the user toggles "Show activity notes", when they save and restart the app, the setting should persist.