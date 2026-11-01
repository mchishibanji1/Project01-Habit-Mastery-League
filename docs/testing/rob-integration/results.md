# Pixel 7 Integrated App Verification

Tester: Rob Han
Device: Pixel 7 emulator, Android 16, API 36
Entry point: lib/main.dart
Tested commit: See commit.txt

## Results

- Flutter analysis: Passed. See analyze.txt.
- Automated tests: All 6 passed. See tests.txt.
- Main navigation: Displayed Habits, History, and Settings.
- Habit creation and editing: Passed; updated name and weekly target displayed.
- Completion creation and editing: Passed; status and note updated.
- History filters: Selected habit/category returned 1 record and 1 completed.
- Incompatible filters: Returned 0 records and 0 completed with an empty-state message.
- Offline settings: Saved Last 7 days and disabled activity notes.
- Offline restart: Settings, edited habit, and completion record remained saved.
- Offline helper: Refreshed and excluded the habit completed today.
- Parent deletion: Habit and its linked completion disappeared.
- Child deletion: Cancel preserved the record; confirmed deletion removed it while preserving the parent habit.
- Whitespace validation: Rejected a whitespace-only habit name.
- Validation recovery: Corrected input saved one habit successfully.

## Test sequence note

During the first deletion attempt, the parent habit was deleted
instead of the completion record. Child deletion was subsequently
tested separately using the Delete check habit.

## Remaining checks

- Final integrated app verification on Pixel 8.
- Previously identified category compatibility and async lifecycle concerns.
- Presentation-specific evidence checks.