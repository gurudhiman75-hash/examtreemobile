# Mobile Android Launcher Companion v1

Status: implemented on Android mobile

## Purpose

Bring the existing phone-local Daily Companion onto the Android launcher so a student can see useful revision state and start a short session without first navigating through the app.

## Home-screen widget

The widget displays only private, device-local Daily Companion summary data:

- questions due now;
- reviews completed today versus the local daily target;
- remaining target;
- number of saved review questions.

Actions:

- open Daily Companion;
- start a 5-minute quick revision session;
- open the canonical Tests catalogue.

The widget does not fetch the ExamTree API itself. Flutter publishes a summary after loading the authenticated user-scoped local companion snapshot. This keeps canonical attempts, marks, result history and entitlements inside the existing app/API contracts.

## Privacy

Widget state is cleared when Firebase authentication resolves to signed-out. One student's local revision counts must not remain visible after logout.

No question stem, answer, explanation, score, email or student identifier is written into launcher preferences.

## Deep links and shortcuts

Android launcher destinations use the private `examtree://app/...` scheme:

- `/daily`;
- `/quick-revision?minutes=5`;
- `/exams`.

The same destinations are registered as GoRouter routes. Protected deep links preserve their destination through sign-in and return to the requested mobile destination after authentication.

Static app shortcuts expose:

- Daily review;
- 5 min revision;
- Tests.

## Offline boundary

The widget is offline-readable because it consumes the already-cached Daily Companion summary. It does not imply offline test delivery or offline submission.

## Update model

The widget has no periodic background polling. It refreshes when the authenticated app loads or the Daily Companion snapshot changes. This avoids a background network service and keeps the launcher data consistent with the mobile-local revision store.

## Validation gates

- Flutter static analysis;
- complete Flutter tests;
- Android manifest/shortcut/widget contract tests;
- Android debug APK compilation, including Kotlin AppWidgetProvider and RemoteViews resources.
