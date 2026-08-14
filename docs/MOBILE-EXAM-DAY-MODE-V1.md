# MDC-003 — Mobile Exam-Day Mode v1

## Purpose

Exam-Day Mode is a phone-local preparation and logistics aid for one active exam target. It does not create or alter canonical exams, attempts, scores, results, entitlements, rankings or analytics.

## Student capabilities

- Save one active exam name and future exam date/time.
- Optionally save a reporting time and venue note.
- See a countdown that changes guidance by time remaining.
- Maintain a private checklist with built-in and custom items.
- Use quick links to 5-minute revision, Daily Companion and Tests.
- Opt into inexact local notifications about 24 hours and 2 hours before the saved reporting time, or exam time when no reporting time is supplied.
- Open Exam-Day Mode from Android launcher shortcuts and protected deep links.

## Authority boundaries

- All exam date/time, reporting time and venue details are entered by the student.
- The official exam notice/admit card remains authoritative for logistics and rules.
- Checklist completion is explicitly not presented as academic readiness.
- The scheduled start time reaching zero does not imply that ExamTree knows whether the exam started, ended or was rescheduled.

## Privacy and lifecycle

- Target and checklist data are stored locally in SQLite and keyed by Firebase user ID.
- Exam reminders are canceled on logout.
- Enabled reminders are restored for the same user on sign-in.
- If notification permission has been revoked, the stored reminder flag is disabled instead of displaying a false active state.

## Android behavior

- No exact-alarm permission is requested.
- Launcher shortcut URI: `examtree://app/exam-day`.
- Deep-link authentication continuation uses the existing protected GoRouter contract.
