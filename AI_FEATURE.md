# Next Habit Helper

## Purpose and method

The Next Habit Helper suggests an active habit that the user has
not completed today. It aims to draw attention to habits with fewer
recent completion records.

This is a local rule-based feature, not a trained machine-learning
model. It uses SQLite data and does not call an online AI service.

Implementation: Rob Han
Team review and final integration: pending with Marc Chishibanji.

## Inputs

- Habit ID: integer identifier.
- Habit name: text displayed to the user.
- Active status: 1 for active, 0 for inactive.
- Completion date: ISO-8601 timestamp, interpreted in local time.
- Completion status: completed or in_progress.
- Current local date: determines today and the seven-day window.

The seven-day window includes today and the previous six calendar
days. The score is a count of completed records, not a percentage,
streak, or count of unique completed days.

## Recommendation rules

1. Exclude inactive habits.
2. Exclude habits with a completed record dated today.
3. Count completed records in the seven-day window for each
   remaining habit.
4. Recommend the habit with the lowest count.
5. Break ties using the lowest habit ID.

Return no suggestion when no eligible habit remains.

## Simple baseline

The baseline uses the same eligibility rules but selects the
eligible habit with the lowest ID, without comparing recent counts.

Using ID order makes the baseline deterministic.

## Explanation and user control

The screen displays the suggested habit, recent completed-record
count, and tie-breaking rule.

The user can open the suggestion, choose another active habit,
or leave without taking action. Viewing a suggestion does not
automatically create or modify a completion record.

Returning from a habit screen reloads the data and recommendation.

## Alternative considered

An alternative is to prioritize the habit furthest below its
weekly target.

The current count-based method was selected because its behavior
is simple to explain and test. However, it does not account for
different target frequencies, effort, or personal priority.
A target-aware method could be evaluated in a future revision.

## Automated evaluation

Test file: test/habit_helper_test.dart

Command:
flutter test test/habit_helper_test.dart

The five tests passed in the local development environment.
The fixed evaluation date was October 30, 2026, at 12:00 local time.

| Case | Expected helper | Expected baseline | Observed |
| --- | --- | --- | --- |
| Reading ID 1 has two recent completions; Walking ID 2 has none; neither completed today | Walking, count 0 | Reading | Passed |
| No records, equal counts, reversed input order | ID 1 | ID 1 | Passed |
| No habits | No suggestion | No suggestion | Passed |
| Both habits completed today | No suggestion | No suggestion | Passed |
| Malformed completion date | FormatException | FormatException | Passed |

These results verify the selected rules. They do not establish
that the helper improves habit consistency or user satisfaction.

## Manual checks

Verified on the Pixel 7 Android emulator:

- The helper screen displays a suggestion, explanation, and baseline.
- Choosing another habit opens its activity screen.
- Opening the suggested habit works.
- After recording a completion for today and returning, the helper
  refreshes and excludes that habit from the recommendation.

## Counterexample and limitation

Consider two eligible habits:

- Reading: weekly target 1, with 1 recent completed record.
- Walking: weekly target 7, with 2 recent completed records.

The current helper recommends Reading because 1 is less than 2.
However, Reading has already reached its weekly target while
Walking remains below its target.

This is a reasoned counterexample, not a separate executed test.
It shows why fewer records do not always mean greater need.

Multiple completed records on the same date also increase the
score. The helper does not currently normalize by unique days.

## Invalid data and error feedback

Malformed completion dates cause parsing to fail.
The helper screen catches failures and displays a retry message
instead of presenting a recommendation as successful.

The automated malformed-date test verifies the parsing failure.
An injected invalid-data test of the screen itself is pending.

## Revision and follow-up

The current version includes an explanation and manual choice
so users can override a suggestion that does not fit their needs.

A possible future revision would rank habits by progress toward
their weekly targets. Compare it with the current method using
the counterexample above and cases with different targets.
No such improvement is claimed as implemented.

## Offline verification

The implementation uses local SQLite reads and Dart rules.
No cloud inference or network request is used by the helper.

Offline test completed on October 30, 2026, using the Pixel 7
Android emulator with airplane mode enabled and Wi-Fi disabled.

The helper screen refreshed without a network error.
Completion records could be created, read, updated, and deleted
offline. Canceling deletion preserved the record.
A saved record remained after closing and reopening the app.

Second-device/emulator verification: pending.

## Source locations

- lib/services/habit_helper.dart
- lib/screens/habit_helper_screen.dart
- lib/data/completion_repository.dart
- test/habit_helper_test.dart