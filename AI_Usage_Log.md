# AI Assistance Log

## Contributor and tool

Contributor: Rob Han
Tool: ChatGPT

This log covers assistance used for Rob's work.
It does not describe Marc Chishibanji's AI usage.


## Scope of assistance

ChatGPT provided step-by-step implementation guidance and ideas (functions) for:

- SQLite database setup, table relationships, and cascade deletion.
- Habit completion model and repository CRUD operations.
- History queries, filters, summaries, and related screens.
- Completion forms and validation.
- Local settings storage and settings screen.
- Local rule-based habit helper, baseline, and explanation screen.
- Database checks and automated helper tests.
- Development preview screens used to exercise these features.

ChatGPT also helped Git commands, test cases, and erros fixing.

The assistance included brainstorming, grammar checks, or conceptual explanations.

## Student actions and verification

I referred to the SQLite and Flutter patterns taught in previous
class activities and adapted code drafts to the goals and requirements of this project.
I ran code analysis and tests and addressed observed errors.

Checks performed during development included:

- Flutter analysis.
- Android database checks for completion CRUD and cascade deletion.
- Rejection of invalid IDs, dates, statuses, and missing parents.
- Manual checks of forms, history filters, summaries, and settings.
- Five automated habit-helper tests.
- Offline completion CRUD and deletion cancellation.
- Record persistence after closing and reopening the app offline.

I performed the offline chekcs on the Pixel 7 Android emulator with airplane mode enabled and Wi-Fi disabled.

## Course references

Course SQLite materials were consulted to compare the use of
database helpers, models, repositories, foreign keys, CRUD,
and Flutter form/navigation patterns.

## Limitations and remaining work

Running the code and passing these checks does not establish
that I independently authored or fully understand every part of this project.

Further code review and study are needed so I can explain the implementation and its design decisions.

Second-device offline verification and final team integration remain pending at the time of this log.