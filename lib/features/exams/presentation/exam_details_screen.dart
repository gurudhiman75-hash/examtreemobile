import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/exam_model.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/network_failure_view.dart';
import '../../results/presentation/providers/result_providers.dart';
import 'providers/exam_providers.dart';

class ExamDetailsScreen extends ConsumerWidget {
  const ExamDetailsScreen({super.key, required this.examId});

  final String examId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final examAsync = ref.watch(examDetailsProvider(examId));
    final completedAttemptsAsync = ref.watch(
      completedAttemptCountProvider(examId),
    );

    Future<void> refresh() async {
      ref
        ..invalidate(examDetailsProvider(examId))
        ..invalidate(completedAttemptCountProvider(examId));
      try {
        await Future.wait([
          ref.read(examDetailsProvider(examId).future),
          ref.read(completedAttemptCountProvider(examId).future),
        ]);
      } catch (_) {
        // Body modules retain their own retry/error state.
      }
    }

    return examAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Test details')),
        body: const _DetailsLoadingState(),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(title: const Text('Test details')),
        body: NetworkFailureView(
          error: error,
          fallbackTitle: 'Unable to load these test details',
          onRetry: refresh,
        ),
      ),
      data: (exam) {
        final completedCount = completedAttemptsAsync.value;
        final attemptLimitReached = exam.maxAttempts < 99 &&
            completedCount != null &&
            completedCount >= exam.maxAttempts;

        return Scaffold(
          appBar: AppBar(title: const Text('Test details')),
          body: _ExamDetailsBody(
            exam: exam,
            completedAttemptsAsync: completedAttemptsAsync,
            onRefresh: refresh,
          ),
          bottomNavigationBar: _StartBar(
            exam: exam,
            completedAttemptsAsync: completedAttemptsAsync,
            attemptLimitReached: attemptLimitReached,
            onStart: () => context.push('/test-attempt', extra: examId),
          ),
        );
      },
    );
  }
}

class _ExamDetailsBody extends StatelessWidget {
  const _ExamDetailsBody({
    required this.exam,
    required this.completedAttemptsAsync,
    required this.onRefresh,
  });

  final Exam exam;
  final AsyncValue<int> completedAttemptsAsync;
  final Future<void> Function() onRefresh;

  static const instructions = [
    'Your selected answers, review flags, current position and remaining time are saved during the test.',
    'Keep an internet connection available so progress can sync with your ExamTree account.',
    'An in-progress attempt can be resumed after signing in again on mobile or web.',
    'Submit before the remaining time reaches zero and follow the rules shown in each question.',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accessLabel = exam.status.trim().toLowerCase() == 'paid' ? 'Paid' : 'Free';

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.xxl,
        ),
        children: [
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _LabelPill(label: exam.category, icon: Icons.category_outlined),
              _LabelPill(label: accessLabel, icon: Icons.lock_open_rounded),
              if (exam.difficulty.trim().isNotEmpty)
                _LabelPill(
                  label: exam.difficulty,
                  icon: Icons.signal_cellular_alt_rounded,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            exam.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              height: 1.14,
            ),
          ),
          if (exam.description.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              exam.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          const _SectionTitle(
            title: 'At a glance',
            subtitle: 'Know the test format before you begin.',
          ),
          const SizedBox(height: AppSpacing.sm),
          _InfoGrid(
            items: [
              _InfoItem(
                icon: Icons.timer_outlined,
                label: 'Duration',
                value: '${exam.durationInSeconds ~/ 60} min',
              ),
              _InfoItem(
                icon: Icons.quiz_outlined,
                label: 'Questions',
                value: '${exam.totalQuestions}',
              ),
              _InfoItem(
                icon: Icons.grade_outlined,
                label: 'Total marks',
                value: _formatNumber(exam.totalMarks),
              ),
              _InfoItem(
                icon: Icons.remove_circle_outline,
                label: 'Negative mark',
                value: exam.negativeMarking == 0
                    ? 'None'
                    : '-${_formatNumber(exam.negativeMarking)}',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _AttemptStatusCard(
            exam: exam,
            completedAttemptsAsync: completedAttemptsAsync,
          ),
          const SizedBox(height: AppSpacing.xl),
          const _SectionTitle(
            title: 'Before you start',
            subtitle: 'A few rules that protect your progress.',
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Column(
              children: [
                for (var index = 0; index < instructions.length; index++) ...[
                  _InstructionRow(
                    number: index + 1,
                    instruction: instructions[index],
                  ),
                  if (index != instructions.length - 1)
                    const Divider(height: AppSpacing.lg),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.sync_rounded, color: scheme.onPrimaryContainer),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'If you already have a saved attempt for this test, opening it continues that attempt instead of starting over.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onPrimaryContainer,
                      height: 1.4,
                    ),
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

class _StartBar extends StatelessWidget {
  const _StartBar({
    required this.exam,
    required this.completedAttemptsAsync,
    required this.attemptLimitReached,
    required this.onStart,
  });

  final Exam exam;
  final AsyncValue<int> completedAttemptsAsync;
  final bool attemptLimitReached;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final completedCount = completedAttemptsAsync.value;
    final limitLabel = exam.maxAttempts >= 99 ? 'Unlimited attempts' : '${exam.maxAttempts} attempts max';
    final progressLabel = completedCount == null
        ? limitLabel
        : '$completedCount completed · $limitLabel';

    return Material(
      color: scheme.surfaceContainerLowest,
      elevation: 6,
      shadowColor: scheme.shadow.withValues(alpha: 0.12),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                attemptLimitReached
                    ? 'Attempt limit reached'
                    : 'Ready when you are',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: attemptLimitReached ? scheme.error : scheme.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                attemptLimitReached
                    ? 'You have used all ${exam.maxAttempts} allowed attempts for this test.'
                    : progressLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              FilledButton.icon(
                key: const Key('exam-details-start'),
                onPressed: attemptLimitReached ? null : onStart,
                icon: Icon(
                  attemptLimitReached
                      ? Icons.block_rounded
                      : Icons.play_arrow_rounded,
                ),
                label: Text(
                  attemptLimitReached
                      ? 'Attempt limit reached'
                      : 'Start or resume test',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AttemptStatusCard extends StatelessWidget {
  const _AttemptStatusCard({
    required this.exam,
    required this.completedAttemptsAsync,
  });

  final Exam exam;
  final AsyncValue<int> completedAttemptsAsync;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final limit = exam.maxAttempts >= 99 ? 'Unlimited' : '${exam.maxAttempts}';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: scheme.secondaryContainer,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.replay_rounded,
              color: scheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Attempts',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                completedAttemptsAsync.when(
                  data: (count) => Text(
                    '$count completed · $limit allowed',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  loading: () => Text(
                    'Checking completed attempts…',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  error: (error, stackTrace) => Text(
                    'Completed-attempt count is unavailable. The test remains usable unless the server rejects the attempt.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.35,
                    ),
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

class _InfoGrid extends StatelessWidget {
  const _InfoGrid({required this.items});

  final List<_InfoItem> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final columns = constraints.maxWidth >= 700 && textScale <= 1.4 ? 4 : 2;
        const gap = AppSpacing.sm;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final item in items)
              SizedBox(width: width, child: _InfoTile(item: item)),
          ],
        );
      },
    );
  }
}

class _InfoItem {
  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.item});

  final _InfoItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Semantics(
      label: '${item.label}: ${item.value}',
      excludeSemantics: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: 72),
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(item.icon, size: 20, color: scheme.primary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    item.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
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

class _InstructionRow extends StatelessWidget {
  const _InstructionRow({required this.number, required this.instruction});

  final int number;
  final String instruction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '$number',
            style: theme.textTheme.labelMedium?.copyWith(
              color: scheme.onPrimaryContainer,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            instruction,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
          ),
        ),
      ],
    );
  }
}

class _LabelPill extends StatelessWidget {
  const _LabelPill({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    if (label.trim().isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: scheme.primary),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
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
  }
}

class _DetailsLoadingState extends StatelessWidget {
  const _DetailsLoadingState();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Container(
          height: 28,
          width: 240,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          height: 90,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          ),
        ),
      ],
    );
  }
}

String _formatNumber(double value) {
  if (value == value.roundToDouble()) return value.toInt().toString();
  return value
      .toStringAsFixed(2)
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}
