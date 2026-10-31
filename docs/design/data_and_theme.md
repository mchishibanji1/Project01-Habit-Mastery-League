Local Data Sketch (SQLite)
-Table 1: `habits` (habitId PK, name, description, category, targetFrequency, createdAt, isActive)
-Table 2: `habit_completions` (completionId PK, habitId FK, completionDate, status, note)
-Relationship: One-to-Many.
-Deletion Policy: `ON DELETE CASCADE` (deleting a habit removes all its completions).

Theme Tokens
-Primary: Blue (Material default)
-Surface: White background
-Error: Red (used in delete confirmations and validation)
-Typography: Roboto (Flutter default)
-Spacing: 16px padding on screens, 8px vertical spacing between form fields.