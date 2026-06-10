# Mobile Draft Sync Plan

## File-by-file implementation plan

- `lib/core/network/api_client.dart`: add the shared Dio client with API base URL and optional Bearer token dart-defines.
- `lib/core/models/attempt_draft_model.dart`: add Freezed/JsonSerializable models for draft state, draft rows, list responses, and save responses.
- `lib/core/repositories/attempt_draft_repository.dart`: define the draft repository contract and submit payload helpers.
- `lib/core/repositories/api_attempt_draft_repository.dart`: implement the backend draft endpoints and final attempt submit call.
- `lib/core/providers/repository_providers.dart`: expose `apiClientProvider` and `attemptDraftRepositoryProvider`.
- `lib/features/test_attempt/presentation/providers/draft_providers.dart`: add `activeDraftProvider`, `draftListProvider`, and `draftSaveProvider`.
- `lib/features/test_attempt/presentation/test_attempt_screen.dart`: load existing drafts, prompt resume, restore answers/timer/current question/flags, autosave with debounce, save on app pause, and submit with `draftId` plus `expectedDraftVersion`.

## Modified files

- `lib/core/network/api_client.dart`
- `lib/core/models/attempt_draft_model.dart`
- `lib/core/models/attempt_draft_model.freezed.dart`
- `lib/core/models/attempt_draft_model.g.dart`
- `lib/core/repositories/attempt_draft_repository.dart`
- `lib/core/repositories/api_attempt_draft_repository.dart`
- `lib/core/providers/repository_providers.dart`
- `lib/features/test_attempt/presentation/providers/draft_providers.dart`
- `lib/features/test_attempt/presentation/test_attempt_screen.dart`

## Compile verification plan

1. Run `dart run build_runner build` after draft model changes.
2. Run `dart format` on touched Dart files.
3. Run `flutter analyze`.
4. Run `flutter test`; the current template counter test is expected to fail until replaced with an app-specific smoke test.
