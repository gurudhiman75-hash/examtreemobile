# Mobile Attempt Result Summary v1

Status: implementation candidate
Surface: Results > attempt card, and the screen shown straight after a test is submitted
Route: `/result-summary` (extra: attempt id), then `Review solutions` continues to `/review`

## Goal

Give a completed attempt a proper summary before the question-by-question review: score, how the questions went, section detail, and three charts that show where time and marks went.

## Data rules

Everything comes from the canonical `Result` snapshot (and the learner's own history for the trend). This follows the same truthfulness rules as Performance Analytics v2.

1. Score is `rawScore / maxScore`. Accuracy is correct / answered.
2. Rank and percentile appear only when the API supplied them. With no percentile the ring shows the score percentage and is labelled "score".
3. Total, per-section and per-question time come only from `questionReview.timeTakenSeconds`. If no question has timing, the Time metric falls back to Attempted and the time charts are hidden. Zero is never shown as a measured time.
4. Section detail uses `sectionStats` when present, otherwise it is derived from `questionReview`. Section accuracy is correct / answered and is absent when nothing was answered.
5. The trend uses the learner's earlier attempts (latest six including this one, oldest first) and is hidden until there are two points.
6. No averages across other learners, target scores, marks-lost breakdowns or topic-level claims are shown: the result contract has no source for them.

## Layout

Score hero, trend line, outcome split, section cards, accuracy vs time share (grouped bars), time per question (bars coloured by outcome), question map, then actions.

Charts are drawn with `CustomPainter` or plain widgets (no new dependency), carry a text `Semantics` summary, and never rely on colour alone: skipped is hollow or a thin grey bar, wrong is a lighter fill with a dark outline.

## Files

- `lib/features/results/domain/attempt_result_summary.dart`: pure view-model.
- `lib/features/results/presentation/attempt_result_screen.dart`: screen and provider-independent `AttemptResultView`.
- `lib/features/results/presentation/widgets/result_charts.dart`: trend, grouped-bar, pacing and question-map charts.

## Deferred

Class averages and target scores need a backend contract. Topic-level weak and strong lists need a topic field on `ResultQuestionReview`.
