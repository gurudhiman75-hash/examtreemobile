# ExamTree Mobile

Flutter client for the ExamTree student platform. The app uses the shared ExamTree API and Neon-backed canonical attempt sessions so a test can be resumed across mobile and web.

## Requirements

- Flutter stable
- Dart SDK compatible with `pubspec.yaml`
- access to the `sarbedutech` Firebase project for client-app registration

## API configuration

The API base URL is supplied at build time:

```bash
flutter run \
  --dart-define=EXAMTREE_API_BASE_URL=https://examtree-new.onrender.com/api
```

## Firebase Android setup

The Android application ID is:

```text
com.examtree.examtree
```

Register that Android app in the existing `sarbedutech` Firebase project. Copy the generated Android Firebase app ID, which has this shape:

```text
1:1083299267005:android:<app-specific-id>
```

Then run or build the app with:

```bash
flutter run \
  --dart-define=EXAMTREE_API_BASE_URL=https://examtree-new.onrender.com/api \
  --dart-define=FIREBASE_ANDROID_APP_ID=1:1083299267005:android:<app-specific-id>
```

The repository contains the existing public Firebase web-client metadata for project `sarbedutech`. It does not contain service-account credentials or Firebase Admin secrets.

The following values can be overridden when required:

```text
FIREBASE_API_KEY
FIREBASE_PROJECT_ID
FIREBASE_MESSAGING_SENDER_ID
FIREBASE_STORAGE_BUCKET
FIREBASE_AUTH_DOMAIN
FIREBASE_WEB_APP_ID
FIREBASE_ANDROID_APP_ID
FIREBASE_IOS_APP_ID
FIREBASE_IOS_BUNDLE_ID
FIREBASE_MACOS_APP_ID
FIREBASE_MACOS_BUNDLE_ID
```

When a required platform value is missing, ExamTree displays a configuration screen instead of initializing Firebase with placeholder identifiers.

## Verification

```bash
flutter pub get
flutter analyze --no-fatal-infos
flutter test
flutter build apk --debug \
  --dart-define=EXAMTREE_API_BASE_URL=https://examtree-new.onrender.com/api
```

The debug build can compile without a Firebase Android app ID, but authentication is intentionally disabled at runtime until the real app registration is supplied.
