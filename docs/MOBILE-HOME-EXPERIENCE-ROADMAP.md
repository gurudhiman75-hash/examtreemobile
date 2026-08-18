# ExamTree Mobile Home Experience Roadmap

Status: Implementation in progress — UI foundation + Home Command Centre V4  
Scope: Student mobile application  
Primary surface: Home tab  
Principle: The home screen is the student's daily learning command centre, not a collection of promotional cards.

## Current implementation checkpoint — 18 August 2026

Implemented on `ui/mobile-foundation-v1` / PR #46:

- shared deep-indigo + teal mobile visual foundation;
- cleaner neutral surfaces and tighter mobile typography hierarchy;
- standardized Material 3 cards, buttons, inputs, chips, navigation, FABs and progress indicators;
- 48dp minimum primary/secondary button touch target contract;
- Home Command Centre V4 routed as the active Home implementation;
- compact identity/date/search/profile header replacing the oversized decorative greeting surface;
- one dominant state-aware learning action using the existing canonical Resume → Review → Start → Browse priority;
- active-attempt continuation rail before analytics when additional saved attempts exist;
- compact Performance Pulse using canonical attempt analytics only;
- reduced secondary action density for Tests and Results;
- compact recent-result review card;
- horizontally-scannable test discovery rail with duplicate active/primary tests removed;
- independent loading/error/empty states preserved;
- new Home V4 widget coverage including empty-catalogue truthfulness and 200% text-scale smoke coverage;
- existing golden preview workflow remains the visual review authority.

Still intentionally not surfaced without canonical contracts:

- fabricated streaks or daily missions;
- readiness scores;
- planner tasks;
- course/library entitlement modules;
- adaptive weakness prescriptions beyond truthful weakest-topic display;
- live-class/community placeholders.

## 1. Product vision

ExamTree mobile should feel unmistakably connected to the ExamTree web application while using capabilities that are native to a phone:

- instant resume and short practice sessions;
- notifications and daily planning;
- offline revision and downloaded content;
- quick exam-day utilities;
- personalised, state-aware ordering of content;
- cross-device continuity with canonical attempts and results;
- English, Hindi and Punjabi learning continuity.

The web and mobile products must share the same exam catalogue, identity, entitlements, attempts, results, explanations and analytics. Mobile may add convenience and habit-building features, but must not invent parallel scoring, access or content rules.

## 2. Design language continuity

The mobile visual system should carry forward the web application's identity:

- deep indigo as the primary brand field;
- teal as the learning-progress accent;
- warm semantic colours for correct, incorrect, warning and achievement states;
- rounded but disciplined cards;
- compact exam metadata and strong information hierarchy;
- meaningful gradients used for priority surfaces only;
- consistent category, subcategory and test naming across web and mobile;
- motion that explains state changes rather than decorating every element.

The app should feel more focused than the website. A phone screen must present the next useful action first and defer secondary content through horizontal rails, expandable panels and destination screens.

## 3. Benchmark lessons

Common capabilities expected from leading education platforms include:

- large mock-test and practice catalogues;
- live and recorded classes;
- PDFs and structured study material;
- daily practice and revision loops;
- personalised planners;
- doubt resolution;
- progress dashboards;
- streaks, goals, leagues or other habit systems;
- cross-device access.

ExamTree should match the useful baseline without copying another product's home screen. Its differentiator should be the depth of reasoning, multilingual explanation quality and the conversion of every attempt into the next precise learning action.

## 4. Home-screen content architecture

The home feed is modular. Modules are ordered by student urgency and can be hidden when there is no truthful data.

### H0. Compact system header

Contents:

- time-aware greeting and first name;
- profile avatar;
- notification inbox entry;
- global search entry;
- sync/offline indicator only when relevant.

The header must remain compact. It should not consume the first full viewport.

### H1. State-aware primary action

Exactly one dominant action appears near the top. Priority order:

1. Resume an active timed attempt.
2. Review a newly completed result.
3. Continue the current daily mission.
4. Start the highest-priority recommended practice.
5. Select a target exam for a first-time learner.

The card should explain why this is the next action and show only the metadata required to decide: test name, remaining or planned time, progress and primary button.

### H2. Today's plan

A compact daily mission card containing up to three actionable items:

- one weak-area drill;
- one revision item;
- one test, quiz or current-affairs task.

Each item has a clear completion state. The plan should be achievable in short sessions and must never contain fake tasks. Before the planner API exists, this module remains feature-gated.

### H3. Continue learning

A horizontal rail for resumable items:

- active tests;
- partially completed practice sets;
- paused lessons or videos;
- saved revision sessions.

The current canonical test attempt is the first implementation. Later content types should adopt the same resumable-item contract.

### H4. Smart practice prescription

A recommendation card generated from real attempt evidence:

- weak topic;
- error pattern;
- recommended number of questions;
- estimated session length;
- reason for recommendation;
- expected mastery impact.

This is different from a generic recommended-tests carousel. It answers: "What should I practise next, and why?"

### H5. Exam target and readiness

For the selected target exam:

- exam name and optional date countdown;
- syllabus completion;
- recent mock score trend;
- speed, accuracy and coverage indicators;
- readiness state with an explanation;
- next milestone.

The first version can show target-exam identity and canonical performance. A full readiness score must wait for an audited readiness model.

### H6. Daily challenge

A small, repeatable entry point:

- Daily Logic Challenge;
- Daily Quant Sprint;
- Daily Current Affairs;
- language-specific challenge where available.

One challenge is promoted at a time. Completing it can contribute to a streak, but the streak must reward meaningful learning rather than app opens.

### H7. Performance pulse

A lightweight summary rather than a full analytics dashboard:

- recent score;
- average accuracy;
- practice time or attempts;
- strongest area;
- area needing attention;
- one link to detailed results and analytics.

This module uses canonical result data and should remain independently recoverable if analytics fails.

### H8. My learning library

Personalised rails for owned or followed content:

- my test series;
- enrolled courses;
- saved PDFs and notes;
- downloaded content;
- bookmarked questions;
- recently viewed content.

Entitlement-backed modules appear only after the corresponding canonical services are live.

### H9. Live and upcoming

Time-sensitive learning events:

- live class;
- scheduled test;
- doubt session;
- exam deadline;
- planned revision reminder.

The card must state the exact time, duration and joining state. Mobile notifications should deep-link directly to the event.

### H10. Current affairs and revision capsules

A compact feed for:

- daily current-affairs capsule;
- weekly revision pack;
- important exam update;
- saved revision queue.

The home shows a preview, not the entire feed.

### H11. Recommended catalogue

A curated rail of tests, courses or materials selected using:

- target exam;
- entitlement;
- recent activity;
- language preference;
- difficulty readiness;
- new and popular canonical content.

Generic popularity may be used only when personal evidence is insufficient.

### H12. Community and motivation

Lower-priority, optional modules:

- friends or study group progress;
- rank movement;
- weekly league;
- educator announcement;
- achievement celebration.

Competition should be opt-in and should not dominate the learning workflow.

## 5. Home ordering engine

The home screen should not use one fixed order for every student. It should calculate module priority from state.

### Critical priority

- active timed test;
- submission/result requiring review;
- live event starting soon;
- expiring downloaded or entitled content;
- sync conflict requiring action.

### Daily priority

- today's plan;
- due revision;
- target-exam milestone;
- daily challenge;
- weak-area prescription.

### Discovery priority

- recommended tests;
- new courses;
- current-affairs capsules;
- announcements;
- community modules.

Rules:

- the first viewport should contain identity, one primary action and one progress signal;
- no more than one promotional module may appear before the student's active learning modules;
- modules with failed APIs recover independently;
- modules without truthful data hide or show an explicit empty state;
- the same test or task must not be repeated in multiple visible modules.

## 6. ExamTree differentiators

These are the strategic capabilities that can make the complete product distinctive when implemented together.

### 6.1 Logic Replay

Reconstruct the reasoning path of a question step by step. The learner can reveal clues, transformations, constraints and the final decision instead of reading only a static explanation.

### 6.2 Mistake Genome

Classify incorrect answers by cause, not merely topic:

- concept gap;
- misread condition;
- calculation slip;
- option trap;
- time pressure;
- guessed answer;
- incomplete method.

The classification then drives the next practice prescription.

### 6.3 Revision Queue

Automatically create a spaced revision queue from:

- wrong questions;
- slow correct questions;
- flagged questions;
- repeatedly weak concepts;
- manually saved items.

### 6.4 Readiness Compass

Explain readiness through multiple dimensions instead of one opaque score:

- coverage;
- accuracy;
- speed;
- consistency;
- mock difficulty;
- recency of practice.

Each dimension must link to a concrete improvement action.

### 6.5 Language Mirror

Allow a learner to switch supported question, option, hint and explanation language without losing attempt or review position. English, Hindi and Punjabi should remain semantically aligned rather than being separate disconnected experiences.

### 6.6 Practice Autopilot

Create a short session from the learner's available time and current evidence, for example:

- 5-minute recovery drill;
- 15-minute weak-topic session;
- 30-minute sectional test;
- full mock when readiness and available time permit.

### 6.7 Cross-device handoff

A learner can begin on web and resume on mobile, or vice versa, with:

- current question;
- selected answers;
- flags;
- elapsed time;
- remaining time;
- review position;
- downloaded-result availability where allowed.

### 6.8 Exam-day mode

A focused mode containing only:

- admit-card and exam-centre checklist;
- reporting-time reminder;
- last revision capsule;
- offline documents;
- calm countdown and instructions;
- no distracting promotional content.

## 7. Navigation architecture

Recommended primary navigation:

1. Home
2. Learn
3. Practice
4. Tests
5. Profile

Results, downloads, notifications, bookmarks and current affairs should be reachable through contextual actions and secondary destinations rather than permanently occupying the main navigation.

Until Learn and Practice have canonical content services, the existing Home, Tests, Results and Profile navigation remains. New tabs must not be introduced as empty shells.

## 8. Delivery roadmap

### Phase A — Home foundation, front-end first

Current status: HME-001 through HME-006 substantially implemented; HME-007 feature gating exists for future modules; HME-008 coverage is active and being extended.

- HME-001: modular home feed architecture;
- HME-002: compact header and state-aware primary action;
- HME-003: redesigned quick actions and target-exam entry;
- HME-004: independent loading, error and empty states for every module;
- HME-005: shared visual components for home rails, metrics and learning cards;
- HME-006: responsive behaviour, accessibility and motion rules;
- HME-007: local feature flags for unavailable future modules;
- HME-008: widget and golden-test coverage for major home states.

Existing canonical data used:

- authenticated user;
- available tests;
- active tests;
- completed results;
- aggregate analytics.

### Phase B — Daily learning loop

Requires planner and goal contracts.

- target exam selection;
- exam date and countdown;
- daily goal;
- meaningful learning streak;
- daily plan;
- reminders and deep links;
- completion history.

### Phase C — Learning library

Requires canonical content and entitlement contracts.

- courses and batches;
- lessons and video playback;
- PDFs and notes;
- bookmarks;
- current affairs;
- downloads;
- offline progress sync.

### Phase D — Adaptive intelligence

Requires audited analytics and recommendation contracts.

- weakness prescription;
- Revision Queue;
- Mistake Genome;
- Practice Autopilot;
- Readiness Compass;
- personalised home ordering.

### Phase E — Live and social learning

Requires event and community services.

- live classes and tests;
- doubt sessions;
- calendar and planner integration;
- study groups;
- optional leagues and leaderboards;
- educator announcements.

### Phase F — Premium mobile capabilities

- exam-day mode;
- home-screen widgets;
- notification action buttons;
- background downloads;
- offline review packs;
- tablet and foldable layouts;
- advanced accessibility;
- performance and battery optimisation.

## 9. Immediate implementation sequence

### Batch 1: Home Command Centre v2 → superseded by V4 active implementation

Implemented:

1. Compact command header.
2. State-aware primary action using active attempts and latest results.
3. Continue Learning before analytics when additional active tests exist.
4. Compact Performance Pulse.
5. Context actions instead of a fixed broad quick-action row.
6. Horizontal recommendation rail.
7. Future modules remain hidden/feature-gated rather than populated with fake data.
8. Section-level failure isolation and pull-to-refresh preserved.

### Batch 2: Home component system

Implemented shared components include:

- HomeModuleShell;
- HomeSectionHeader;
- LearningActionCard;
- CompactMetric;
- HorizontalContentRail;
- SyncStateBanner;
- HomeSkeleton variants.

### Batch 3: Home state tests

Coverage target remains:

- new learner with no attempts;
- learner with an active test;
- learner with completed results;
- learner with active and completed tests;
- partial provider failure;
- no available tests;
- narrow screen and large text scale;
- offline or timeout state;
- authenticated user without display name.

## 10. Non-negotiable quality gates

- No fabricated score, streak, mastery, user count, testimonial or recommendation.
- No duplicated backend business rules in Flutter.
- Every primary card has a working destination.
- Every asynchronous module has loading, error, empty and success handling.
- The entire home screen never fails because one provider fails.
- Touch targets meet accessibility guidance.
- Layout remains usable with 200% text scaling.
- Important information is not encoded by colour alone.
- Motion respects reduced-motion settings where available.
- Lists remain smooth on budget Android devices.
- Home modules are independently testable.
- Web and mobile use canonical names and identifiers.

## 11. Success measures

Product metrics to instrument after the event pipeline exists:

- home-to-learning-action conversion;
- active-test resume rate;
- daily mission completion;
- recommendation acceptance;
- seven-day learning retention;
- revision-queue completion;
- time from app open to first meaningful action;
- cross-device resume success;
- module error and empty-state rates;
- accessibility and crash-free session rates.

## 12. Decision

Home Command Centre V4 is now the active implementation candidate on PR #46. Keep current canonical APIs and action priority unchanged while validating visual hierarchy, golden previews, large-text behavior and Android packaging. Planner, streak, courses, current affairs and live-class modules remain gated until their data contracts exist.
