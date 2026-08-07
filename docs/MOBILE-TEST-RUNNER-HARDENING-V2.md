# Mobile Test Runner Hardening v2

Status: Implementation candidate  
Scope: Canonical mobile test-attempt experience  
Work item: TST-001

## Goal

Make the existing canonical test runner safer and easier to use under real exam conditions without changing backend scoring, attempt, persistence or submission contracts.

## Implemented behaviour

### Submission safety

- manual submission opens a non-dismissible summary;
- the summary shows answered, unanswered, marked and answered-and-marked counts;
- students can return directly to the first unanswered question;
- final submission remains a deliberate action;
- repeated submission taps remain blocked;
- timer expiry bypasses the manual dialog and submits automatically.

### Question-state consistency

- selecting an option immediately updates the question to answered;
- selecting an answer on a marked question preserves the marked state;
- clearing an answered-and-marked response preserves marked-for-review;
- marked without an answer counts as unanswered for submission;
- answered-and-marked counts as answered and marked.

### Palette

- live answered, unanswered and marked counts;
- filters for all, unanswered and marked questions;
- visible status legend;
- stronger current-question outline;
- accessible status labels for question buttons.

### Timer

- warnings at 10 minutes, 5 minutes and 1 minute;
- resumed attempts show the most urgent applicable warning once;
- timer styling becomes more urgent below five minutes and one minute;
- expiry disables editing and starts submission.

### Save and exit

- app-bar close and Android back require confirmation;
- the runner attempts a fresh save before leaving;
- failed saves keep the test open;
- failed sync exposes a visible retry action;
- conflict handling continues to load the latest canonical server revision.

### Usability

- option cards provide larger touch targets;
- exam controls use icons and shorter labels;
- long questions and options remain vertically scrollable;
- palette and dialogs use safe-area-aware layouts.

## Data authority

The mobile app continues to use:

- `AttemptSessionRepository.startOrResume` for canonical resume state;
- `AttemptSessionRepository.saveSession` for revision-controlled persistence;
- `AttemptSessionRepository.submitAttempt` for canonical submission;
- server-generated immutable result snapshots for review.

No scoring, rank, result or entitlement rule is duplicated in Flutter.

## Validation contract

- pure tests for status counts, filters and timer thresholds;
- widget tests for submission counts, complete-attempt behaviour, sync retry and exit blocking;
- full Flutter analysis and test suite;
- Android debug APK build against the production API base URL.

## Manual acceptance checklist

1. Select and clear answers on normal and marked questions.
2. Filter the palette by unanswered and marked.
3. Tap Submit Test and verify all counts.
4. Choose Review unanswered and verify navigation.
5. Submit and verify review/results still work.
6. Start another attempt, press Android back and verify save confirmation.
7. Test a simulated weak network and verify failed save keeps the test open with Retry.
8. Verify timer warning and expiry behaviour with a short-duration test where available.
