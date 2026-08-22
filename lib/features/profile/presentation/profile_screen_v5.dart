import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/network_failure_view.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../../preferences/domain/question_language.dart';
import '../../preferences/presentation/providers/question_language_providers.dart';
import '../domain/performance_analytics.dart';
import 'providers/analytics_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref
      ..invalidate(performanceAnalyticsProvider)
      ..invalidate(userAnalyticsProvider);
    try {
      await ref.read(performanceAnalyticsProvider.future);
    } catch (_) {
      // The performance module renders its own recoverable state.
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateChangesProvider).value;
    final analyticsAsync = ref.watch(performanceAnalyticsProvider);
    final language =
        ref.watch(questionLanguageProvider).value ?? QuestionLanguage.english;
    final name = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!.trim()
        : user?.email?.split('@').first ?? 'Student';
    final email = user?.email?.trim() ?? '';
    final initial = name.trim().isEmpty ? 'S' : name.trim()[0].toUpperCase();

    return RefreshIndicator(
      onRefresh: () => _refresh(ref),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.xxl,
        ),
        children: [
          _IdentityHero(name: name, email: email, initial: initial),
          const SizedBox(height: AppSpacing.lg),
          analyticsAsync.when(
            loading: () => const _ProfileLoadingState(),
            error: (error, stackTrace) => NetworkFailureCard(
              error: error,
              fallbackTitle: 'Unable to load your performance',
              onRetry: () => ref.invalidate(performanceAnalyticsProvider),
            ),
            data: (analytics) => _PerformanceContent(
              analytics: analytics,
              onBrowseTests: () => context.go('/exams'),
              onOpenResults: () => context.go('/results'),
              onReviewLatest: analytics.latestAttemptId == null
                  ? null
                  : () => context.push(
                        '/review',
                        extra: analytics.latestAttemptId,
                      ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const _SectionHeading(
            title: 'Account',
            subtitle: 'Preferences, privacy and this device session.',
          ),
          const SizedBox(height: AppSpacing.sm),
          _AccountActions(
            language: language,
            onLanguage: () => _chooseQuestionLanguage(
              context,
              ref,
              language,
            ),
            onPrivacy: () => context.push('/account'),
            onResults: () => context.go('/results'),
            onLogout: () => ref.read(authControllerProvider).signOut(),
          ),
        ],
      ),
    );
  }

  Future<void> _chooseQuestionLanguage(
    BuildContext context,
    WidgetRef ref,
    QuestionLanguage current,
  ) async {
    final selected = await showModalBottomSheet<QuestionLanguage>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Question language',
                style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Used in tests, answer review and saved revision questions. English is used when a translation is unavailable.',
                style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(sheetContext).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              for (final language in QuestionLanguage.values)
                RadioListTile<QuestionLanguage>(
                  value: language,
                  groupValue: current,
                  title: Text(language.label),
                  subtitle: Text(language.shortLabel),
                  onChanged: (value) => Navigator.of(sheetContext).pop(value),
                ),
            ],
          ),
        ),
      ),
    );

    if (selected == null || selected == current || !context.mounted) return;
    try {
      await setQuestionLanguage(ref, selected);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to save the question language on this device.'),
        ),
      );
    }
  }
}

class _IdentityHero extends StatelessWidget {
  const _IdentityHero({
    required this.name,
    required this.email,
    required this.initial,
  });

  final String name;
  final String email;
  final String initial;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.5;
    final avatar = Container(
      width: largeText ? 64 : 58,
      height: largeText ? 64 : 58,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        initial,
        style: theme.textTheme.headlineSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your profile',
          style: theme.textTheme.labelMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.78),
            fontWeight: FontWeight.w800,
            letterSpacing: 0.35,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.45,
          ),
        ),
        if (email.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(
            email,
            maxLines: largeText ? 2 : 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.78),
            ),
          ),
        ],
      ],
    );

    return Semantics(
      container: true,
      label: email.isEmpty ? 'Profile for $name' : 'Profile for $name, $email',
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.tertiary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: _softShadow(),
        ),
        child: largeText
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  avatar,
                  const SizedBox(height: AppSpacing.md),
                  copy,
                ],
              )
            : Row(
                children: [
                  avatar,
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: copy),
                ],
              ),
      ),
    );
  }
}

class _PerformanceContent extends StatelessWidget {
  const _PerformanceContent({
    required this.analytics,
    required this.onBrowseTests,
    required this.onOpenResults,
    required this.onReviewLatest,
  });

  final PerformanceAnalytics analytics;
  final VoidCallback onBrowseTests;
  final VoidCallback onOpenResults;
  final VoidCallback? onReviewLatest;

  @override
  Widget build(BuildContext context) {
    if (analytics.totalTestsAttempted == 0) {
      return _EmptyPerformance(onBrowseTests: onBrowseTests);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(
          title: 'Performance',
          subtitle: 'Your completed-test signals at a glance.',
          trailing: TextButton(
            onPressed: onOpenResults,
            child: const Text('Full history'),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _PerformanceHero(analytics: analytics),
        const SizedBox(height: AppSpacing.lg),
        _FocusSection(
          analytics: analytics,
          onOpenResults: onOpenResults,
          onReviewLatest: onReviewLatest,
        ),
        if (analytics.scoreTrend.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xl),
          const _SectionHeading(
            title: 'Recent trend',
            subtitle: 'Your latest completed tests.',
          ),
          const SizedBox(height: AppSpacing.sm),
          _RecentTrend(analytics: analytics),
        ],
      ],
    );
  }
}

class _PerformanceHero extends StatelessWidget {
  const _PerformanceHero({required this.analytics});

  final PerformanceAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.5;
    final metrics = <({String value, String label, IconData icon})>[
      (
        value: '${analytics.totalTestsAttempted}',
        label: 'Tests',
        icon: Icons.assignment_turned_in_outlined,
      ),
      (
        value: '${_formatPercent(analytics.averageAccuracy)}%',
        label: 'Accuracy',
        icon: Icons.track_changes_rounded,
      ),
      (
        value: analytics.hasTimingData
            ? _formatDuration(analytics.averageTimePerQuestion)
            : '—',
        label: 'Avg time',
        icon: Icons.timer_outlined,
      ),
    ];

    return Container(
      key: const Key('profile-performance-hero'),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(26),
        boxShadow: _softShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Average score',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      '${_formatPercent(analytics.averageScore)}%',
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.2,
                      ),
                    ),
                  ],
                ),
              ),
              if (analytics.latestScoreChange != null && !largeText)
                _ChangeBadge(change: analytics.latestScoreChange!),
            ],
          ),
          if (analytics.latestScoreChange != null && largeText) ...[
            const SizedBox(height: AppSpacing.sm),
            _ChangeBadge(change: analytics.latestScoreChange!),
          ],
          const SizedBox(height: AppSpacing.md),
          LinearProgressIndicator(
            minHeight: 8,
            borderRadius: BorderRadius.circular(999),
            value: analytics.averageScore.clamp(0, 100) / 100,
          ),
          const SizedBox(height: AppSpacing.lg),
          LayoutBuilder(
            builder: (context, constraints) {
              final stacked = largeText || constraints.maxWidth < 310;
              if (stacked) {
                return Column(
                  children: [
                    for (var index = 0; index < metrics.length; index++) ...[
                      _HeroMetric(metric: metrics[index]),
                      if (index != metrics.length - 1)
                        const SizedBox(height: AppSpacing.sm),
                    ],
                  ],
                );
              }
              return Row(
                children: [
                  for (var index = 0; index < metrics.length; index++) ...[
                    Expanded(child: _HeroMetric(metric: metrics[index])),
                    if (index != metrics.length - 1)
                      const SizedBox(width: AppSpacing.sm),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.metric});

  final ({String value, String label, IconData icon}) metric;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: '${metric.label}: ${metric.value}',
      excludeSemantics: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(metric.icon, size: 18, color: AppColors.primary),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    metric.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    metric.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FocusSection extends StatelessWidget {
  const _FocusSection({
    required this.analytics,
    required this.onOpenResults,
    required this.onReviewLatest,
  });

  final PerformanceAnalytics analytics;
  final VoidCallback onOpenResults;
  final VoidCallback? onReviewLatest;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strongest = analytics.strongestSection;
    final weakest = analytics.weakestSection;
    final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'What to focus on',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            if (analytics.latestScoreChange != null && !largeText)
              _ChangeBadge(change: analytics.latestScoreChange!),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (strongest == null && weakest == null)
          _SoftMessage(
            icon: Icons.insights_outlined,
            text:
                'Section detail will appear after reviewed questions are available.',
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final stacked = largeText || constraints.maxWidth < 330;
              final cards = <Widget>[
                if (strongest != null)
                  _SectionSignal(
                    label: 'Strongest',
                    section: strongest,
                    icon: Icons.trending_up_rounded,
                    foreground: AppColors.onMintContainer,
                    background: AppColors.mintContainer,
                  ),
                if (weakest != null)
                  _SectionSignal(
                    label: 'Needs attention',
                    section: weakest,
                    icon: Icons.flag_outlined,
                    foreground: AppColors.onAmberContainer,
                    background: AppColors.amberContainer,
                  ),
              ];
              if (stacked || cards.length < 2) {
                return Column(
                  children: [
                    for (var index = 0; index < cards.length; index++) ...[
                      cards[index],
                      if (index != cards.length - 1)
                        const SizedBox(height: AppSpacing.sm),
                    ],
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: cards[0]),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: cards[1]),
                ],
              );
            },
          ),
        const SizedBox(height: AppSpacing.md),
        LayoutBuilder(
          builder: (context, constraints) {
            final stacked = largeText || constraints.maxWidth < 320;
            final results = OutlinedButton.icon(
              onPressed: onOpenResults,
              icon: const Icon(Icons.history_rounded),
              label: const Text('Results'),
            );
            final review = onReviewLatest == null
                ? null
                : FilledButton.icon(
                    key: const Key('profile-review-latest'),
                    onPressed: onReviewLatest,
                    icon: const Icon(Icons.fact_check_outlined),
                    label: const Text('Review latest'),
                  );
            if (stacked) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (review != null) ...[
                    review,
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  results,
                ],
              );
            }
            if (review == null) return Align(alignment: Alignment.centerLeft, child: results);
            return Row(
              children: [
                Expanded(child: review),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: results),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _SectionSignal extends StatelessWidget {
  const _SectionSignal({
    required this.label,
    required this.section,
    required this.icon,
    required this.foreground,
    required this.background,
  });

  final String label;
  final SectionPerformance section;
  final IconData icon;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: foreground),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            section.name,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${_formatPercent(section.accuracy)}% accuracy',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChangeBadge extends StatelessWidget {
  const _ChangeBadge({required this.change});

  final double change;

  @override
  Widget build(BuildContext context) {
    final positive = change >= 0;
    final color = positive ? AppColors.onMintContainer : AppColors.error;
    final background = positive ? AppColors.mintContainer : AppColors.errorContainer;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '${positive ? '+' : '−'}${_formatPercent(change.abs())} pts',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
            ),
      ),
    );
  }
}

class _RecentTrend extends StatelessWidget {
  const _RecentTrend({required this.analytics});

  final PerformanceAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    final points = analytics.scoreTrend.length <= 4
        ? analytics.scoreTrend
        : analytics.scoreTrend.sublist(analytics.scoreTrend.length - 4);
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: _softShadow(),
      ),
      child: Column(
        children: [
          for (var index = 0; index < points.length; index++) ...[
            _TrendRow(point: points[index]),
            if (index != points.length - 1)
              const Divider(height: 1, indent: AppSpacing.md, endIndent: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}

class _TrendRow extends StatelessWidget {
  const _TrendRow({required this.point});

  final PerformanceTrendPoint point;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final score = point.percentageScore.clamp(0, 100).toDouble();
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${score.round()}%',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.onPrimaryContainer,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  point.testName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '${_formatPercent(point.accuracy)}% accuracy · ${_formatDate(point.completedAt)}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPerformance extends StatelessWidget {
  const _EmptyPerformance({required this.onBrowseTests});

  final VoidCallback onBrowseTests;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.insights_outlined,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Your performance starts with your first test',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Complete a test to build score, accuracy, section and trend insights here.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton.icon(
            onPressed: onBrowseTests,
            icon: const Icon(Icons.assignment_outlined),
            label: const Text('Browse tests'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stack = MediaQuery.textScalerOf(context).scale(1) > 1.5;
    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
    if (trailing == null) return copy;
    if (stack) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          copy,
          const SizedBox(height: AppSpacing.xs),
          trailing!,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: copy),
        const SizedBox(width: AppSpacing.sm),
        trailing!,
      ],
    );
  }
}

class _AccountActions extends StatelessWidget {
  const _AccountActions({
    required this.language,
    required this.onLanguage,
    required this.onPrivacy,
    required this.onResults,
    required this.onLogout,
  });

  final QuestionLanguage language;
  final VoidCallback onLanguage;
  final VoidCallback onPrivacy;
  final VoidCallback onResults;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: _softShadow(),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _AccountRow(
            key: const Key('profile-question-language'),
            icon: Icons.translate_rounded,
            iconBackground: AppColors.skyContainer,
            iconForeground: AppColors.onSkyContainer,
            title: 'Question language',
            subtitle: language.label,
            onTap: onLanguage,
          ),
          const Divider(height: 1),
          _AccountRow(
            key: const Key('profile-privacy-account'),
            icon: Icons.privacy_tip_outlined,
            iconBackground: AppColors.primaryContainer,
            iconForeground: AppColors.onPrimaryContainer,
            title: 'Privacy & account',
            subtitle: 'Account controls and privacy settings',
            onTap: onPrivacy,
          ),
          const Divider(height: 1),
          _AccountRow(
            icon: Icons.history_rounded,
            iconBackground: AppColors.mintContainer,
            iconForeground: AppColors.onMintContainer,
            title: 'My results',
            subtitle: 'Search and review completed attempts',
            onTap: onResults,
          ),
          const Divider(height: 1),
          _AccountRow(
            icon: Icons.logout_rounded,
            iconBackground: AppColors.errorContainer,
            iconForeground: AppColors.error,
            title: 'Sign out',
            subtitle: 'End this device session',
            onTap: onLogout,
            destructive: true,
          ),
        ],
      ),
    );
  }
}

class _AccountRow extends StatelessWidget {
  const _AccountRow({
    super.key,
    required this.icon,
    required this.iconBackground,
    required this.iconForeground,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final Color iconBackground;
  final Color iconForeground;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      minTileHeight: 72,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      leading: Container(
        width: 42,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: iconBackground,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, size: 21, color: iconForeground),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: destructive ? theme.colorScheme.error : null,
          fontWeight: FontWeight.w800,
        ),
      ),
      subtitle: Text(
        subtitle,
        maxLines: MediaQuery.textScalerOf(context).scale(1) > 1.5 ? 3 : 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: destructive ? null : const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

class _SoftMessage extends StatelessWidget {
  const _SoftMessage({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileLoadingState extends StatelessWidget {
  const _ProfileLoadingState();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHigh;
    return Column(
      children: [
        Container(
          height: 210,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          height: 160,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ],
    );
  }
}

List<BoxShadow> _softShadow() => [
      BoxShadow(
        color: AppColors.shadow.withValues(alpha: 0.055),
        blurRadius: 22,
        offset: const Offset(0, 8),
      ),
    ];

String _formatPercent(double value) {
  final safe = value.clamp(0, 100).toDouble();
  if (safe == safe.roundToDouble()) return safe.toInt().toString();
  return safe.toStringAsFixed(1);
}

String _formatDuration(int seconds) {
  if (seconds < 60) return '${seconds}s';
  final minutes = seconds ~/ 60;
  final remainder = seconds % 60;
  return remainder == 0 ? '${minutes}m' : '${minutes}m ${remainder}s';
}

String _formatDate(DateTime value) {
  if (value.millisecondsSinceEpoch == 0) return 'Date unavailable';
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final local = value.toLocal();
  return '${local.day} ${months[local.month - 1]}';
}
