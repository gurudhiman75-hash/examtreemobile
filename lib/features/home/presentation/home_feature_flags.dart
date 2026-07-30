abstract final class HomeFeatureFlags {
  static const showDailyPlan = bool.fromEnvironment(
    'EXAMTREE_HOME_DAILY_PLAN',
  );
  static const showTargetExam = bool.fromEnvironment(
    'EXAMTREE_HOME_TARGET_EXAM',
  );
  static const showAdaptivePractice = bool.fromEnvironment(
    'EXAMTREE_HOME_ADAPTIVE_PRACTICE',
  );
  static const showSyncBanner = bool.fromEnvironment(
    'EXAMTREE_HOME_SYNC_BANNER',
  );
}
