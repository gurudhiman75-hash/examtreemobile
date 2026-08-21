import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/exam_model.dart';
import '../../../core/theme/app_colors.dart';
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
        // Body modules keep independent recovery states.
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
    'Answers, review flags, position and remaining time are saved as you work.',
    'Keep an internet connection available so your progress can sync.',
    'A saved attempt can be resumed after signing in again on mobile or web.',
    'Submit before time runs out and follow the rules shown with each question.',
  ];

  @override
  Widget build(BuildContext context) {
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
          _TestSummaryHero(exam: exam),
          const SizedBox(height: AppSpacing.xl),
          const _SectionTitle(title: 'At a glance'),
          const SizedBox(height: AppSpacing.sm),
          _InfoGrid(
            items: [
              _InfoItem(
                icon: Icons.timer_outlined,
                label: 'Duration',
                value: '${exam.durationInSeconds ~/ 60} min',
                background: AppColors.skyContainer,
                foreground: AppColors.onSkyContainer,
              ),
              _InfoItem(
                icon: Icons.quiz_outlined,
                label: 'Questions',
                value: '${exam.totalQuestions}',
                background: AppColors.primaryContainer,
                foreground: AppColors.onPrimaryContainer,
              ),
              _InfoItem(
                icon: Icons.grade_outlined,
                label: 'Total marks',
                value: _formatNumber(exam.totalMarks),
                background: AppColors.mintContainer,
                foreground: AppColors.onMintContainer,
              ),
              _InfoItem(
                icon: Icons.remove_circle_outline_rounded,
                label: 'Negative mark',
                value: exam.negativeMarking == 0
                    ? 'None'
                    : '-${_formatNumber(exam.negativeMarking)}',
                background: AppColors.amberContainer,
                foreground: AppColors.onAmberContainer,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _AttemptStatusCard(
            exam: exam,
            completedAttemptsAsync: completedAttemptsAsync,
          ),
          const SizedBox(height: AppSpacing.xl),
          const _SectionTitle(title: 'Before you start'),
          const SizedBox(height: AppSpacing.md),
          for (var index = 0; index < instructions.length; index++) ...[
            _InstructionRow(
              number: index + 1,
              instruction: instructions[index],
            ),
            if (index != instructions.length - 1)
              const SizedBox(height: AppSpacing.md),
          ],
          const SizedBox(height: AppSpacing.lg),
          _ResumeNotice(),
        ],
      ),
    );
  }
}

class _TestSummaryHero extends StatelessWidget {
  const _TestSummaryHero({required this.exam});

  final Exam exam;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final access = exam.status.trim().toLowerCase() == 'paid'
        ? 'Premium'
        : 'Free';
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF0F2FF), Color(0xFFF7F4FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _HeroLabel(
                label: exam.category.trim().isEmpty ? 'General' : exam.category,
                background: AppColors.primaryContainer,
                foreground: AppColors.onPrimaryContainer,
              ),
              _HeroLabel(
                label: access,
                background: access == 'Premium'
                    ? AppColors.tertiaryContainer
                    : AppColors.mintContainer,
                foreground: access == 'Premium'
                    ? AppColors.onTertiaryContainer
                    : AppColors.onMintContainer,
              ),
              if (exam.difficulty.trim().isNotEmpty)
                _HeroLabel(
                  label: exam.difficulty,
                  background: AppColors.skyContainer,
                  foreground: AppColors.onSkyContainer,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            exam.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.55,
              height: 1.14,
            ),
          ),
          if (exam.description.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              exam.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HeroLabel extends StatelessWidget {
  const _HeroLabel({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w900,
            ),
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
        final scale = MediaQuery.textScalerOf(context).scale(1);
        final columns = constraints.maxWidth >= 700 && scale <= 1.4 ? 4 : 2;
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
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color background;
  final Color foreground;
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.item});

  final _InfoItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: '${item.label}: ${item.value}',
      excludeSemantics: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: 82),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(18),
          boxShadow: _softShadow(),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: item.background,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(item.icon, size: 19, color: item.foreground),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    item.label,
                    maxLines: 2,
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
    final limit = exam.maxAttempts >= 99 ? 'Unlimited' : '${exam.maxAttempts}';
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.mintContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.replay_rounded,
              color: AppColors.onMintContainer,
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
                    color: AppColors.onMintContainer,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                completedAttemptsAsync.when(
                  data: (count) => Text(
                    '$count completed · $limit allowed',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.onMintContainer,
                    ),
                  ),
                  loading: () => Text(
                    'Checking completed attempts…',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.onMintContainer,
                    ),
                  ),
                  error: (error, stackTrace) => Text(
                    'Completed-attempt count is unavailable. The server still enforces the attempt limit.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.onMintContainer,
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

class _InstructionRow extends StatelessWidget {
  const _InstructionRow({required this.number, required this.instruction});

  final int number;
  final String instruction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$number',
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.onPrimaryContainer,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              instruction,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.42),
            ),
          ),
        ),
      ],
    );
  }
}

class _ResumeNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.cloud_done_rounded, color: AppColors.onPrimaryContainer),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Already started? Opening this test continues your saved attempt instead of starting over.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.onPrimaryContainer,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
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
    final limitLabel = exam.maxAttempts >= 99
        ? 'Unlimited attempts'
        : '${exam.maxAttempts} attempts max';
    final progressLabel = completedCount == null
        ? limitLabel
        : '$completedCount completed · $limitLabel';

    return Material(
      color: scheme.surfaceContainerLowest,
      elevation: 8,
      shadowColor: scheme.shadow.withValues(alpha: 0.1),
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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      attemptLimitReached
                          ? 'Attempt limit reached'
                          : progressLabel,
                      maxLines: 2,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: attemptLimitReached
                            ? scheme.error
                            : scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (!attemptLimitReached)
                    const Icon(
                      Icons.verified_rounded,
                      size: 18,
                      color: AppColors.secondary,
                    ),
                ],
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

class _DetailsLoadingState extends StatelessWidget {
  const _DetailsLoadingState();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget block(double height, {double radius = 20}) => Container(
          height: height,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(radius),
          ),
        );
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        block(176, radius: 26),
        const SizedBox(height: AppSpacing.xl),
        block(24),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(child: block(86)),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: block(86)),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(child: block(86)),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: block(86)),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        block(180),
      ],
    );
  }
}

List<BoxShadow> _softShadow() => [
      BoxShadow(
        color: AppColors.shadow.withValues(alpha: 0.045),
        blurRadius: 18,
        offset: const Offset(0, 6),
      ),
    ];

String _formatNumber(double value) {
  if (value == value.roundToDouble()) return value.toInt().toString();
  return value
      .toStringAsFixed(2)
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}
