# Home Visual System

Status: HME-005 and HME-006 implemented; HME-007 flags established.

The Home tab uses one shared component layer for its recurring visual and
interaction contracts:

- `HomeModuleShell` provides the standard surface, outline and touch treatment.
- `HomeSectionHeader` preserves hierarchy at narrow widths and large text.
- `LearningActionCard` owns the dominant action presentation and metadata.
- `CompactMetric` exposes one concise value with an explicit spoken label.
- `HorizontalContentRail` uses responsive card widths and settles to the
  nearest card after a user scroll.
- `HomeSkeleton` provides reduced-motion-aware loading variants.
- `SyncStateBanner` and `FeatureUnavailableCard` are truthful future-state
  surfaces; they do not appear until their canonical data contracts exist.

## Accessibility and motion contract

- interactive controls retain at least a 48 logical-pixel target;
- the layout remains usable at 200% text scaling on a 320-pixel-wide viewport;
- important metrics have complete semantic labels;
- rail items announce their position;
- reveal and shimmer motion stop when the platform requests reduced motion;
- colour is never the only state signal.

## Feature flags

Future modules are disabled by default and can only be exposed intentionally
with compile-time defines:

- `EXAMTREE_HOME_DAILY_PLAN`
- `EXAMTREE_HOME_TARGET_EXAM`
- `EXAMTREE_HOME_ADAPTIVE_PRACTICE`
- `EXAMTREE_HOME_SYNC_BANNER`

Enabling a flag does not fabricate data. It only permits a corresponding
canonical provider-backed module to be mounted.

## Test coverage

The component contract tests cover narrow screens, 200% text, reduced motion,
rail semantics/snapping, action reachability and metric semantics. Full-screen
pixel goldens remain a separate HME-008 checkpoint because their baselines must
be captured and reviewed on the repository's pinned Flutter renderer.
