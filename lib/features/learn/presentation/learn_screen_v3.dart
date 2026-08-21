import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/models/exam_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/network_failure_view.dart';
import '../../exams/presentation/providers/exam_providers.dart';
import '../domain/learning_resource.dart';
import 'providers/learning_resources_providers.dart';

class LearnScreen extends ConsumerWidget {
  const LearnScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref
      ..invalidate(learningResourcesProvider)
      ..invalidate(availableExamsProvider);

    Future<void> settle(Future<Object?> request) async {
      try {
        await request;
      } catch (_) {
        // Learn modules keep independent recovery states.
      }
    }

    await Future.wait([
      settle(ref.read(learningResourcesProvider.future)),
      settle(ref.read(availableExamsProvider.future)),
    ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resourcesAsync = ref.watch(relevantLearningResourcesProvider);
    final freeTestsAsync = ref.watch(learnFreeTestsProvider);
    final resources = resourcesAsync.value ?? const <LearningResourceSummary>[];
    final freeTests = freeTestsAsync.value ?? const <Exam>[];
    final hasContent = resources.isNotEmpty || freeTests.isNotEmpty;
    final initialLoading = !hasContent &&
        (resourcesAsync.isLoading || freeTestsAsync.isLoading);
    final hasError = resourcesAsync.hasError || freeTestsAsync.hasError;

    final currentAffairs = resources
        .where((item) => item.category == LearningResourceCategory.currentAffairs)
        .toList(growable: false);
    final notes = resources
        .where((item) => item.category != LearningResourceCategory.currentAffairs)
        .toList(growable: false);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.xxl,
              ),
              sliver: SliverList.list(
                children: [
                  _LearnIntro(
                    currentAffairsCount: currentAffairs.length,
                    notesCount: notes.length,
                    freeTestsCount: freeTests.length,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  if (initialLoading)
                    const _LearnLoading()
                  else if (!hasContent)
                    _LearnEmpty(
                      hasError: hasError,
                      onRetry: () => _refresh(ref),
                    )
                  else ...[
                    if (currentAffairs.isNotEmpty) ...[
                      const _SectionHeading(
                        title: 'Current affairs',
                        subtitle: 'Fresh published updates for quick revision.',
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _CurrentAffairsRail(
                        key: const Key('learn-current-affairs'),
                        resources: currentAffairs,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                    if (freeTests.isNotEmpty) ...[
                      _SectionHeading(
                        title: 'Free practice',
                        subtitle: 'Turn reading into an immediate test session.',
                        actionLabel: 'All tests',
                        onAction: () => context.go('/exams'),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _FreePracticeRail(
                        tests: freeTests.take(6).toList(growable: false),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                    if (notes.isNotEmpty) ...[
                      const _SectionHeading(
                        title: 'Notes & formula sheets',
                        subtitle: 'Focused material published for your exams.',
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _NotesList(
                        key: const Key('learn-notes-pdfs'),
                        resources: notes,
                      ),
                    ],
                    if (hasError) ...[
                      const SizedBox(height: AppSpacing.lg),
                      _PartialFailureNotice(onRetry: () => _refresh(ref)),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LearnIntro extends StatelessWidget {
  const _LearnIntro({
    required this.currentAffairsCount,
    required this.notesCount,
    required this.freeTestsCount,
  });

  final int currentAffairsCount;
  final int notesCount;
  final int freeTestsCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Learn for your exams',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Current affairs, notes and free practice selected from what is actually published for you.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.42,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.lg,
          runSpacing: AppSpacing.sm,
          children: [
            _LearnStat(
              value: '$currentAffairsCount',
              label: 'updates',
              icon: Icons.newspaper_rounded,
              background: AppColors.skyContainer,
              foreground: AppColors.onSkyContainer,
            ),
            _LearnStat(
              value: '$notesCount',
              label: 'notes',
              icon: Icons.menu_book_rounded,
              background: AppColors.tertiaryContainer,
              foreground: AppColors.onTertiaryContainer,
            ),
            _LearnStat(
              value: '$freeTestsCount',
              label: 'free tests',
              icon: Icons.task_alt_rounded,
              background: AppColors.mintContainer,
              foreground: AppColors.onMintContainer,
            ),
          ],
        ),
      ],
    );
  }
}

class _LearnStat extends StatelessWidget {
  const _LearnStat({
    required this.value,
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: foreground),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
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
    if (actionLabel == null || onAction == null) return copy;
    if (textScale > 1.5) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          copy,
          const SizedBox(height: AppSpacing.xs),
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: copy),
        const SizedBox(width: AppSpacing.sm),
        TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    );
  }
}

class _CurrentAffairsRail extends StatelessWidget {
  const _CurrentAffairsRail({super.key, required this.resources});

  final List<LearningResourceSummary> resources;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final itemWidth = (width * 0.78).clamp(270.0, 340.0).toDouble();
    final railHeight = textScale > 1.5 ? 356.0 : 222.0;
    return SizedBox(
      height: railHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: resources.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) => SizedBox(
          width: itemWidth,
          child: _FeaturedResourceCard(resource: resources[index]),
        ),
      ),
    );
  }
}

class _FeaturedResourceCard extends StatelessWidget {
  const _FeaturedResourceCard({required this.resource});

  final LearningResourceSummary resource;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final target = _resourceTarget(resource);
    final date = resource.contentDate ?? resource.publishedAt;
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE0F2FE), Color(0xFFEEF2FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: _softShadow(),
        ),
        child: InkWell(
          onTap: () => _openResource(context, resource),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.78),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.newspaper_rounded,
                        color: AppColors.sky,
                      ),
                    ),
                    const Spacer(),
                    _ResourceBadge(
                      label: resource.format == LearningResourceFormat.pdf
                          ? 'PDF'
                          : 'ARTICLE',
                      foreground: AppColors.onPrimaryContainer,
                      background: Colors.white.withValues(alpha: 0.74),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                if (date != null)
                  Text(
                    _dateLabel(date),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.sky,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.45,
                    ),
                  ),
                if (date != null) const SizedBox(height: AppSpacing.xs),
                Text(
                  resource.title,
                  maxLines: MediaQuery.textScalerOf(context).scale(1) > 1.5
                      ? 4
                      : 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppColors.onPrimaryContainer,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
                if (resource.summary.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    resource.summary,
                    maxLines: MediaQuery.textScalerOf(context).scale(1) > 1.5
                        ? 4
                        : 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.onPrimaryContainer.withValues(alpha: 0.72),
                      height: 1.4,
                    ),
                  ),
                ],
                const Spacer(),
                Row(
                  children: [
                    const Icon(
                      Icons.flag_outlined,
                      size: 16,
                      color: AppColors.onPrimaryContainer,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        target,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppColors.onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 19,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FreePracticeRail extends StatelessWidget {
  const _FreePracticeRail({required this.tests});

  final List<Exam> tests;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final itemWidth = (width * 0.7).clamp(250.0, 310.0).toDouble();
    final railHeight = textScale > 1.5 ? 296.0 : 180.0;
    return SizedBox(
      height: railHeight,
      child: ListView.separated(
        key: const Key('learn-free-practice'),
        scrollDirection: Axis.horizontal,
        itemCount: tests.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) => SizedBox(
          width: itemWidth,
          child: _FreeTestCard(exam: tests[index]),
        ),
      ),
    );
  }
}

class _FreeTestCard extends StatelessWidget {
  const _FreeTestCard({required this.exam});

  final Exam exam;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final minutes = (exam.durationInSeconds / 60).ceil();
    final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.5;
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(22),
          boxShadow: _softShadow(),
        ),
        child: InkWell(
          onTap: () => context.push('/exam-details', extra: exam.id),
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.mintContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.task_alt_rounded,
                        color: AppColors.onMintContainer,
                      ),
                    ),
                    const Spacer(),
                    const _ResourceBadge(
                      label: 'FREE',
                      foreground: AppColors.onMintContainer,
                      background: AppColors.mintContainer,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  exam.title,
                  maxLines: largeText ? 4 : 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    height: 1.22,
                  ),
                ),
                const Spacer(),
                if (largeText)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Meta(
                        icon: Icons.help_outline_rounded,
                        label: '${exam.totalQuestions} questions',
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      _Meta(
                        icon: Icons.schedule_rounded,
                        label: '$minutes min',
                      ),
                    ],
                  )
                else
                  Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.xs,
                    children: [
                      _Meta(
                        icon: Icons.help_outline_rounded,
                        label: '${exam.totalQuestions} questions',
                      ),
                      _Meta(
                        icon: Icons.schedule_rounded,
                        label: '$minutes min',
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NotesList extends StatelessWidget {
  const _NotesList({super.key, required this.resources});

  final List<LearningResourceSummary> resources;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < resources.length; index++) ...[
          _ResourceRow(resource: resources[index]),
          if (index != resources.length - 1)
            const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _ResourceRow extends StatelessWidget {
  const _ResourceRow({required this.resource});

  final LearningResourceSummary resource;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = resource.contentDate ?? resource.publishedAt;
    final formula = resource.category == LearningResourceCategory.formulaSheet;
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          boxShadow: _softShadow(),
        ),
        child: InkWell(
          onTap: () => _openResource(context, resource),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: formula
                        ? AppColors.amberContainer
                        : AppColors.tertiaryContainer,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    formula ? Icons.functions_rounded : Icons.menu_book_rounded,
                    color: formula
                        ? AppColors.onAmberContainer
                        : AppColors.onTertiaryContainer,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: [
                          _ResourceBadge(
                            label: resource.format == LearningResourceFormat.pdf
                                ? 'PDF'
                                : 'ARTICLE',
                            foreground: theme.colorScheme.onSurfaceVariant,
                            background: theme.colorScheme.surfaceContainerLow,
                          ),
                          _ResourceBadge(
                            label: resource.languageCode.toUpperCase(),
                            foreground: theme.colorScheme.onSurfaceVariant,
                            background: theme.colorScheme.surfaceContainerLow,
                          ),
                          if (date != null)
                            _ResourceBadge(
                              label: _dateLabel(date),
                              foreground: theme.colorScheme.onSurfaceVariant,
                              background: theme.colorScheme.surfaceContainerLow,
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        resource.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          height: 1.22,
                        ),
                      ),
                      if (resource.summary.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          resource.summary,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        _resourceTarget(resource),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.outline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResourceBadge extends StatelessWidget {
  const _ResourceBadge({
    required this.label,
    required this.foreground,
    required this.background,
  });

  final String label;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w900,
              fontSize: 10,
              letterSpacing: 0.35,
            ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: AppSpacing.xxs),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

class _LearnLoading extends StatelessWidget {
  const _LearnLoading();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget block(double height) => Container(
          height: height,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(22),
          ),
        );
    return Column(
      children: [
        block(220),
        const SizedBox(height: AppSpacing.xl),
        block(180),
        const SizedBox(height: AppSpacing.xl),
        block(132),
        const SizedBox(height: AppSpacing.sm),
        block(132),
      ],
    );
  }
}

class _LearnEmpty extends StatelessWidget {
  const _LearnEmpty({required this.hasError, required this.onRetry});

  final bool hasError;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (hasError) {
      return NetworkFailureView(
        error: Exception('Learning catalogue unavailable'),
        fallbackTitle: 'Unable to load free learning',
        onRetry: onRetry,
      );
    }
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: AppColors.tertiaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              size: 30,
              color: AppColors.onTertiaryContainer,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No free learning resources are published yet.',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Published material will appear here automatically.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _PartialFailureNotice extends StatelessWidget {
  const _PartialFailureNotice({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.amberContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 20,
            color: AppColors.onAmberContainer,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Some learning content could not be refreshed. The items shown above are still available.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.onAmberContainer,
                height: 1.4,
              ),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

Future<void> _openResource(
  BuildContext context,
  LearningResourceSummary resource,
) async {
  if (resource.hasInlineContent) {
    context.push('/learn-resource', extra: resource.id);
    return;
  }
  final url = resource.contentUrl;
  if (url != null &&
      await launchUrl(url, mode: LaunchMode.externalApplication)) {
    return;
  }
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('This resource could not be opened.')),
  );
}

String _resourceTarget(LearningResourceSummary resource) {
  if (resource.isGeneral) return 'All exams';
  if (resource.exams.isEmpty) return 'Selected exams';
  return resource.exams.take(2).map((exam) => exam.name).join(' · ');
}

String _dateLabel(DateTime value) {
  final local = value.toLocal();
  const months = <String>[
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
  return '${local.day} ${months[local.month - 1]} ${local.year}';
}

List<BoxShadow> _softShadow() => [
      BoxShadow(
        color: AppColors.shadow.withValues(alpha: 0.05),
        blurRadius: 20,
        offset: const Offset(0, 7),
      ),
    ];
