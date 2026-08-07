# Mobile Performance Analytics v2

Status: PERF-001 implementation baseline  
Surface: Profile > My progress  
Data authority: canonical completed-attempt result snapshots from `/api/attempts`

## Goal

Turn completed mock tests into a truthful, useful progress view without introducing a new backend, duplicated scoring rules, fabricated ranks or an unaudited readiness score.

## Included

- total completed tests;
- average percentage score;
- weighted answer accuracy;
- total correct, incorrect and unanswered questions;
- average time per timed reviewed question;
- the eight most recent score and accuracy trend points;
- section-level correct, incorrect, unanswered, accuracy and timing aggregation;
- strongest and weakest answered sections;
- direct navigation to the latest immutable review snapshot and complete result history;
- explicit empty, loading, error and section-data-unavailable states.

## Data rules

1. Test-level totals come from canonical `Result` snapshots.
2. Section and timing details come only from immutable `questionReview` entries.
3. Accuracy is weighted across answered questions, not averaged across test percentages.
4. Missing timing remains unavailable; zero is never presented as a measured speed.
5. A result without question-review data contributes to overview totals and trends but not to section claims.
6. Strongest and weakest labels require at least one answered question in the section.
7. Only the latest eight attempts are retained for the compact mobile trend.
8. No rank, percentile, mastery, streak, recommendation reason or readiness score is inferred.

## Architecture

- `PerformanceAnalytics` is a pure aggregation model under the Profile feature.
- `performanceAnalyticsProvider` loads canonical results through the existing `ResultRepository`.
- The existing lightweight `Analytics` model and repository remain unchanged for current Home modules.
- `PerformanceDashboard` is provider-independent and can be rendered with deterministic fixtures.

## Quality gates

- pure aggregation tests cover totals, weighted accuracy, timing, section outcomes, trend limits and empty states;
- widget contracts cover populated and empty dashboards plus primary actions;
- layouts use wrapping metrics and text-safe cards rather than fixed-height chart labels;
- important states are written in text and are not communicated by colour alone;
- every action routes to an existing working destination.

## Deferred

The following remain outside PERF-001 because their source contracts do not yet exist or are not yet audited:

- target-exam readiness scoring;
- adaptive weakness prescriptions;
- Revision Queue and bookmarks;
- planner goals and streaks;
- multilingual question comparison;
- ranks, percentiles and leaderboards.
