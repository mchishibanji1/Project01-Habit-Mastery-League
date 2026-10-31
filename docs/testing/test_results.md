Local Storage & Persistence Test Results

Tester: Marc Chishibanji  
Date: October 31, 2026  
Device: Android Emulator (Pixel 7, API 34)  

Test 1: Habit Creation Persistence
-Steps: Created a new habit ("Test Persistence"). Took a screenshot. Killed the app completely via the recent apps menu. Relaunched the app.
-Expected: The habit should still appear on the dashboard.
-Result: PASS. The habit persisted after a complete app restart. (See Screenshots 1 & 2)

Test 2: Habit Edit Persistence
-Steps: Edited the habit name to "Test Persistence EDITED". Took a screenshot. Killed the app completely. Relaunched the app.
-Expected: The updated name should appear on the dashboard.
-Result: PASS. The edited name persisted after a complete app restart. (See Screenshots 3 & 4)

Test 3: Habit Deletion Persistence
-Steps: Deleted the habit from the Details screen and confirmed the action. Took a screenshot. Killed the app completely. Relaunched the app.
-Expected: The dashboard should be empty, and the deleted habit should not reappear.
-Result: PASS. The deletion persisted; the dashboard remained empty after restart. (See Screenshots 5 & 6)

Test 4: Cross-Screen Data Flow (Integration)
-Steps: Logged a completion for a habit. Navigated to the History tab. Toggled a setting in the Settings tab, saved, and restarted the app.
-Expected: Completion shows in History. Setting persists after restart.
-Result: PASS. The history record appeared correctly, and the settings toggled state remained after a full app restart.