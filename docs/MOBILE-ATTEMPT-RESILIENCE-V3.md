# Mobile Attempt Resilience V3

## Scope

This pass closes the remaining high-risk reliability gaps in the active test experience without changing scoring authority.

## Student protections

- Every answer/navigation change is mirrored to a durable on-device SQLite draft before the debounced server save.
- A locally newer draft is recovered only when it belongs to the same canonical active attempt returned by ExamTree.
- Server progress wins revision conflicts from another device.
- Background time is deducted from the test clock when the app resumes.
- Per-question foreground time is accumulated, persisted in the draft, synced to ExamTree, and sent with the final submission.
- Save requests that arrive during an in-flight save wait for the queued save instead of allowing exit on an older snapshot.
- When time expires, answers remain locked even if final submission temporarily fails. The student receives an explicit retry-submission action.
- Successful submission clears the local draft.
- Canonical max-attempt values are displayed by Exam Details; clearly exhausted limits disable the start action locally while the backend performs the authoritative check.

## Authority boundaries

The local database is only a resilience mirror. It does not create attempts, score answers, extend time, bypass publication/access rules, or override server revision conflicts.

The canonical API remains authoritative for:

- active attempt identity
- attempt limits
- immutable test version
- revision conflict resolution
- scoring and evaluation
- result history

## Deferred separately

Firebase Android registration and installable APK packaging remain isolated from this source pass.
