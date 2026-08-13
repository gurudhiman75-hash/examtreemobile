# Mobile Daily Companion v1

Status: implemented on mobile  
Scope: phone-local learning utility

## Purpose

Daily Companion gives students a reason to return to the mobile app for short, useful revision sessions without creating a second source of truth for tests or scores.

## V1 capabilities

- Persistent **Daily** action above the main mobile navigation.
- Private, user-scoped SQLite revision queue.
- Queue candidates derived only from canonical completed-result evidence:
  - incorrect questions;
  - unanswered questions;
  - flagged questions;
  - unusually slow questions when timing evidence exists.
- Cached revision material remains usable during temporary network loss.
- 5, 10 and 20 minute quick revision sessions.
- Answer reveal and stored explanation review.
- Student outcome controls:
  - **Got it** advances through 1, 3, 7, 14, 30 and 60 day review intervals;
  - **Review again** resets the item for the next day.
- Local daily question goal.
- Android local study reminder with device-timezone scheduling.
- Inexact notification scheduling and reboot restoration; no exact-alarm permission is requested.

## Authority boundary

Daily Companion never edits canonical attempts, scores, result history, entitlements or analytics. The ExamTree API remains authoritative for those records. Mobile result data is consumed only to create local revision material.

The local queue is intentionally device-specific in v1. Cross-device revision sync requires a future canonical revision contract and is not simulated locally.

## Offline boundary

This is offline **revision**, not offline test delivery. A question must first have arrived on the device through canonical result/review data before it can be cached for Daily Companion.

## Privacy boundary

Local companion tables are keyed by the signed-in Firebase UID. One signed-in student's queue is never loaded for another UID.

## Validation

Required merge gates:

- Flutter static analysis;
- complete Flutter tests, including revision-selection and spacing contracts;
- Android debug compilation with the notification integration.

Firebase-enabled APK distribution remains a separate packaging concern and is not part of this feature contract.
