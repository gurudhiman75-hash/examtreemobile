import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../domain/performance_analytics.dart';

class PerformanceDashboard extends StatelessWidget {
  const PerformanceDashboard({
    required this.analytics,
    required this.onOpenResults,
    required this.onReviewLatest,
    required this.onBrowseTests,
    super.key,
  });

  final PerformanceAnalytics analytics;
  final VoidCallback onOpenResults;
  final VoidCallback? onReviewLatest;
  final VoidCallback onBrowseTests;

  @override
  Widget build(BuildContext context) {
    if (analytics.totalTestsAttempted == 0) {
      return _EmptyPerformanceState(onBrowseTests: onBrowseTests);
    }

    return Column(
      children: [
        _OverviewCard(analytics: analytics),
        const SizedBox(height: AppSpacing.md),
        _TrendCard(analytics: analytics),
        const SizedBox(height: AppSpacing.md),
        _SectionPerformanceCard(analytics: analytics),
        const SizedBox(height: AppSpacing.md),
        _ImprovementActions(
          latestTestName: analytics.latestTestName,
          onOpenResults: onOpenResults,
          onReviewLatest: onReviewLatest,
        ),
      ],
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.analytics});

  final PerformanceAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scoreChange = analytics.latestScoreChange;

    return _SectionCard(
      title: 'Performance overview',
      subtitle: analytics.updatedAt.millisecondsSinceEpoch == 0
          ? null
          : 'Updated ${_formatDate(analytics.updatedAt)}',
      trailing: scoreChange == null
          ? null
          : _TrendBadge(change: scoreChange),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 720
              ? 4
              : constraints.maxWidth >= 460
                  ? 3
                  : 2;
          const gap = AppSpacing.sm;
          final width =
              (constraints.maxWidth - (gap * (columns - 1))) / columns;
          final metrics = [
            _MetricData(
              icon: Icons.assignment_turned_in_outlined,
              value: '${analytics.totalTestsAttempted}',
              label: 'Tests completed',
            ),
            _MetricData(
              icon: Icons.score_outlined,
              value: '${_formatPercent(analytics.averageScore)}%',
              label: 'Average score',
            ),
            _MetricData(
              icon: Icons.track_changes_outlined,
              value: '${_formatPercent(analytics.averageAccuracy)}%',
              label: 'Answer accuracy',
            ),
            _MetricData(
              icon: Icons.timer_outlined,
              value: analytics.hasTimingData
                  ? _formatCompactDuration(analytics.averageTimePerQuestion)
                  : '—',
              label: 'Average time',
            ),
            _MetricData(
              icon: Icons.check_circle_outline,
              value: '${analytics.totalCorrect}',
              label: 'Correct',
            ),
            _MetricData(
              icon: Icons.cancel_outlined,
              value: '${analytics.totalIncorrect}',
              label: 'Incorrect',
            ),
            _MetricData(
              icon: Icons.remove_circle_outline,
              value: '${analytics.totalUnanswered}',
              label: 'Unanswered',
            ),
            _MetricData(
              icon: Icons.quiz_outlined,
              value: '${analytics.totalQuestions}',
              label: 'Questions seen',
            ),
          ];

          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (final metric in metrics)
                SizedBox(
                  width: width,
                  child: _MetricTile(metric: metric),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _MetricData {
  const _MetricData({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.metric});

  final _MetricData metric;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: '${metric.label}: ${metric.value}',
      child: Container(
        constraints: const BoxConstraints(minHeight: 92),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(metric.icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(height: AppSpacing.sm),
            Text(
              metric.value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              metric.label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendBadge extends StatelessWidget {
  const _TrendBadge({required this.change});

  final double change;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final improved = change >= 0;
    final color = improved
        ? theme.colorScheme.primary
        : theme.colorScheme.error;
    return Semantics(
      label: improved
          ? 'Latest score increased by ${_formatPercent(change.abs())} percentage points'
          : 'Latest score decreased by ${_formatPercent(change.abs())} percentage points',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              improved ? Icons.arrow_upward : Icons.arrow_downward,
              size: 14,
              color: color,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              '${_formatPercent(change.abs())} pts',
              style: theme.textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.analytics});

  final PerformanceAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    final points = analytics.scoreTrend.length <= 6
        ? analytics.scoreTrend
        : analytics.scoreTrend.sublist(analytics.scoreTrend.length - 6);

    return _SectionCard(
      title: 'Recent progress',
      subtitle: points.length == 1
          ? 'Your first completed test'
          : 'Last ${points.length} completed tests',
      child: Column(
        children: [
          for (var index = 0; index < points.length; index++) ...[
            _TrendRow(point: points[index]),
            if (index != points.length - 1)
              const Divider(height: AppSpacing.lg),
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
    return Semantics(
      label:
          '${point.testName}, score ${_formatPercent(point.percentageScore)} percent, accuracy ${_formatPercent(point.accuracy)} percent',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  point.testName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                _formatDate(point.completedAt),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: _progress(point.percentageScore),
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Text(
                'Score ${_formatPercent(point.percentageScore)}%',
                style: theme.textTheme.labelMedium,
              ),
              const Spacer(),
              Text(
                'Accuracy ${_formatPercent(point.accuracy)}%',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionPerformanceCard extends StatelessWidget {
  const _SectionPerformanceCard({required this.analytics});

  final PerformanceAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    final strongest = analytics.strongestSection;
    final weakest = analytics.weakestSection;

    return _SectionCard(
      title: 'Section performance',
      subtitle: analytics.sectionPerformance.isEmpty
          ? 'Section details were not available in these results'
          : '${analytics.sectionPerformance.length} sections from reviewed questions',
      child: analytics.sectionPerformance.isEmpty
          ? const _UnavailableDetail(
              message:
                  'Overview totals are available, but these result snapshots do not include section-level review data.',
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (strongest != null || weakest != null) ...[
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      if (strongest != null)
                        _SectionHighlight(
                          icon: Icons.trending_up,
                          label: 'Strongest',
                          section: strongest,
                        ),
                      if (weakest != null)
                        _SectionHighlight(
                          icon: Icons.flag_outlined,
                          label: 'Needs attention',
                          section: weakest,
                          isWarning: true,
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                for (var index = 0;
                    index < analytics.sectionPerformance.length;
                    index++) ...[
                  _SectionRow(section: analytics.sectionPerformance[index]),
                  if (index != analytics.sectionPerformance.length - 1)
                    const Divider(height: AppSpacing.lg),
                ],
              ],
            ),
    );
  }
}

class _SectionHighlight extends StatelessWidget {
  const _SectionHighlight({
    required this.icon,
    required this.label,
    required this.section,
    this.isWarning = false,
  });

  final IconData icon;
  final String label;
  final SectionPerformance section;
  final bool isWarning;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isWarning
        ? theme.colorScheme.error
        : theme.colorScheme.primary;
    return Container(
      constraints: const BoxConstraints(minWidth: 150),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(color: color),
                ),
                Text(
                  section.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
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

class _SectionRow extends StatelessWidget {
  const _SectionRow({required this.section});

  final SectionPerformance section;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label:
          '${section.name}, accuracy ${_formatPercent(section.accuracy)} percent, ${section.correct} correct, ${section.incorrect} incorrect, ${section.unanswered} unanswered',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  section.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '${_formatPercent(section.accuracy)}%',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            child: LinearProgressIndicator(
              minHeight: 7,
              value: _progress(section.accuracy),
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.xs,
            children: [
              Text('${section.correct} correct'),
              Text('${section.incorrect} incorrect'),
              Text('${section.unanswered} unanswered'),
              Text(
                section.averageTimePerQuestion == 0
                    ? 'Timing unavailable'
                    : '${_formatCompactDuration(section.averageTimePerQuestion)} avg',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ImprovementActions extends StatelessWidget {
  const _ImprovementActions({
    required this.latestTestName,
    required this.onOpenResults,
    required this.onReviewLatest,
  });

  final String? latestTestName;
  final VoidCallback onOpenResults;
  final VoidCallback? onReviewLatest;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Next useful action',
      subtitle:
          'Use your real result history to review mistakes and unanswered questions.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (onReviewLatest != null)
            FilledButton.icon(
              onPressed: onReviewLatest,
              icon: const Icon(Icons.rate_review_outlined),
              label: Text(
                latestTestName == null
                    ? 'Review latest attempt'
                    : 'Review $latestTestName',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          if (onReviewLatest != null)
            const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: onOpenResults,
            icon: const Icon(Icons.history_outlined),
            label: const Text('Open complete result history'),
          ),
        ],
      ),
    );
  }
}

class _EmptyPerformanceState extends StatelessWidget {
  const _EmptyPerformanceState({required this.onBrowseTests});

  final VoidCallback onBrowseTests;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          side: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Icon(
                Icons.insights_outlined,
                size: 48,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Your progress starts with a completed test',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Scores, accuracy, timing and section insights will appear here after your first submission.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                onPressed: onBrowseTests,
                icon: const Icon(Icons.search),
                label: const Text('Browse tests'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnavailableDetail extends StatelessWidget {
  const _UnavailableDetail({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Text(
        message,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          side: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            subtitle!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    trailing!,
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

double _progress(double percentage) {
  if (!percentage.isFinite) return 0;
  return (percentage / 100).clamp(0.0, 1.0).toDouble();
}

String _formatPercent(double value) {
  if (!value.isFinite) return '0';
  if (value == value.roundToDouble()) return value.toInt().toString();
  return value.toStringAsFixed(1);
}

String _formatCompactDuration(int seconds) {
  final safe = seconds < 0 ? 0 : seconds;
  final minutes = safe ~/ 60;
  final remainder = safe % 60;
  if (minutes == 0) return '${remainder}s';
  return '${minutes}m ${remainder.toString().padLeft(2, '0')}s';
}

String _formatDate(DateTime value) {
  final local = value.toLocal();
  return '${local.day}/${local.month}/${local.year}';
}
