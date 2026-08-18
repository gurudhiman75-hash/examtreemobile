# ExamTree Mobile UI Foundation V1

Status: implementation candidate
Scope: authenticated learner surfaces

## Goal

Make the mobile app feel like one focused ExamTree product instead of a set of individually styled feature screens. This pass changes presentation only. Authentication, routing contracts, catalogue rules, results data and analytics authority remain unchanged.

## Visual direction

The approved mobile brand palette remains the existing midnight navy, antique gold and warm ivory Material 3 scheme. This pass does not replace or reinterpret that palette.

The learner UI follows these rules:

- the first viewport prioritises useful learning information over decorative promotion;
- large gradients are reserved for genuinely dominant actions rather than generic page introductions;
- destination screens use compact headers and get the learner to searchable/actionable content quickly;
- cards use disciplined radius, subtle outlines and low elevation;
- metrics remain concise and expose complete semantic labels;
- filters and sort controls stay close to the content they affect;
- loading and failure states preserve the same page hierarchy where practical;
- no fabricated scores, progress, recommendations or account state are introduced.

## Shared components

`lib/shared/widgets/app_visual_components.dart` establishes reusable primitives outside Home:

- `AppPageHeader` — compact page identity, optional action and truthful summary metrics;
- `AppHeaderIcon` — consistent page icon treatment;
- `AppMetricStrip` / `AppMetricData` — responsive, semantic summary metrics;
- `AppSectionHeader` — consistent section hierarchy;
- `AppFilterSurface` — common container for filtering controls.

The components are intentionally data-agnostic. Feature modules continue to own their providers and business behavior.

## Screen changes

### Tests

- replaces the oversized discovery hero with a compact test-library header;
- surfaces available, free and in-progress counts without inventing data;
- keeps search, exam categories, access filters and sorting immediately reachable;
- keeps resumable attempts above generic catalogue discovery;
- keeps the catalogue usable if the independent in-progress request fails.

### Results

- replaces the oversized performance hero with a compact results header;
- retains canonical attempt count, average score, best score and accuracy;
- keeps search/category/sort and Review/Retake behavior unchanged;
- keeps the empty state within the same page hierarchy.

### Profile

- uses the same compact account header and section hierarchy;
- reuses the existing performance dashboard instead of duplicating analytics UI or logic;
- keeps Results and Sign out as explicit account actions.

### Authenticated shell

- retains Home, Tests, Results and Profile as the four primary tabs;
- retains Daily Companion as a contextual floating action;
- adds a restrained top divider and consistent selected-state treatment to bottom navigation;
- preserves the existing branch reset/navigation policy.

## Accessibility contract

- interactive controls target at least 48 logical pixels through Material controls;
- shared header and metrics must remain usable at 320 logical pixels with 200% text scaling;
- important metrics include semantic labels;
- state is not communicated by colour alone;
- content remains scrollable instead of clipping when text grows.

## Deliberately unchanged in V1

- Home command-centre information architecture and its reviewed golden baselines;
- login/authentication flow;
- test-attempt runner;
- exam details;
- result review;
- backend/API behavior;
- current four-tab product navigation.

Those surfaces can be polished in later UI slices after this shared foundation is verified.
