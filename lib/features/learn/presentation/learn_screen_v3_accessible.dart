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
import 'learn_screen_v3.dart' as standard;
import 'providers/learning_resources_providers.dart';

/// Keeps Learn V3's compact visual rails at normal text sizes and switches to
/// natural-height vertical content when accessibility text becomes large.
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
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    if (textScale <= 1.5) return const standard.LearnScreen();

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
                  _AccessibleIntro(
                    currentAffairsCount: currentAffairs.length,
                    notesCount: notes.length,
                    freeTestsCount: freeTests.length,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  if (initialLoading)
                    const _AccessibleLoading()
                  else if (!hasContent)
                    _AccessibleEmpty(
                      hasError: hasError,
                      onRetry: () => _refresh(ref),
                    )
                  else ...[
                    if (currentAffairs.isNotEmpty) ...[
                      const _Heading(
                        title: 'Current affairs',
                        subtitle: 'Fresh published updates for quick revision.',
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Column(
                        key: const Key('learn-current-affairs'),
                        children: [
                          for (var index = 0;
                              index < currentAffairs.length;
                              index++) ...[
                            _AccessibleResourceCard(
                              resource: currentAffairs[index],
                              featured: true,
                            ),
                            if (index != currentAffairs.length - 1)
                              const SizedBox(height: AppSpacing.sm),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                    if (freeTests.isNotEmpty) ...[
                      const _Heading(
                        title: 'Free practice',
                        subtitle: 'Turn reading into an immediate test session.',
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Column(
                        key: const Key('learn-free-practice'),
                        children: [
                          for (var index = 0; index < freeTests.length; index++) ...[
                            _AccessibleTestCard(exam: freeTests[index]),
                            if (index != freeTests.length - 1)
                              const SizedBox(height: AppSpacing.sm),
                          ],
                        ],
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () => context.go('/exams'),
                          icon: const Icon(Icons.arrow_forward_rounded),
                          label: const Text('All tests'),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                    if (notes.isNotEmpty) ...[
                      const _Heading(
                        title: 'Notes & formula sheets',
                        subtitle: 'Focused material published for your exams.',
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Column(
                        key: const Key('learn-notes-pdfs'),
                        children: [
                          for (var index = 0; index < notes.length; index++) ...[
                            _AccessibleResourceCard(resource: notes[index]),
                            if (index != notes.length - 1)
                              const SizedBox(height: AppSpacing.sm),
                          ],
                        ],
                      ),
                    ],
                    if (hasError) ...[
                      const SizedBox(height: AppSpacing.lg),
                      _AccessibleNotice(onRetry: () => _refresh(ref)),
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

class _AccessibleIntro extends StatelessWidget {
  const _AccessibleIntro({
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
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Current affairs, notes and free practice selected from what is actually published for you.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _AccessibleStat(
          value: currentAffairsCount,
          label: 'updates',
          icon: Icons.newspaper_rounded,
          background: AppColors.skyContainer,
          foreground: AppColors.onSkyContainer,
        ),
        const SizedBox(height: AppSpacing.sm),
        _AccessibleStat(
          value: notesCount,
          label: 'notes',
          icon: Icons.menu_book_rounded,
          background: AppColors.tertiaryContainer,
          foreground: AppColors.onTertiaryContainer,
        ),
        const SizedBox(height: AppSpacing.sm),
        _AccessibleStat(
          value: freeTestsCount,
          label: 'free tests',
          icon: Icons.task_alt_rounded,
          background: AppColors.mintContainer,
          foreground: AppColors.onMintContainer,
        ),
      ],
    );
  }
}

class _AccessibleStat extends StatelessWidget {
  const _AccessibleStat({
    required this.value,
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final int value;
  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: foreground),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            '$value $label',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading({required this.title, required this.subtitle});

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
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _AccessibleResourceCard extends StatelessWidget {
  const _AccessibleResourceCard({
    required this.resource,
    this.featured = false,
  });

  final LearningResourceSummary resource;
  final bool featured;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = resource.contentDate ?? resource.publishedAt;
    final formula = resource.category == LearningResourceCategory.formulaSheet;
    final background = featured
        ? AppColors.skyContainer
        : theme.colorScheme.surfaceContainerLowest;
    final iconBackground = featured
        ? Colors.white.withValues(alpha: 0.78)
        : formula
            ? AppColors.amberContainer
            : AppColors.tertiaryContainer;
    final iconColor = featured
        ? AppColors.sky
        : formula
            ? AppColors.onAmberContainer
            : AppColors.onTertiaryContainer;

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(22),
        ),
        child: InkWell(
          onTap: () => _openResource(context, resource),
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBackground,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    featured
                        ? Icons.newspaper_rounded
                        : formula
                            ? Icons.functions_rounded
                            : Icons.menu_book_rounded,
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    _Badge(
                      label: resource.format == LearningResourceFormat.pdf
                          ? 'PDF'
                          : 'Article',
                    ),
                    _Badge(label: resource.languageCode.toUpperCase()),
                    if (date != null) _Badge(label: _dateLabel(date)),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  resource.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    height: 1.25,
                  ),
                ),
                if (resource.summary.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    resource.summary,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                Text(
                  _resourceTarget(resource),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AccessibleTestCard extends StatelessWidget {
  const _AccessibleTestCard({required this.exam});

  final Exam exam;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final minutes = (exam.durationInSeconds / 60).ceil();
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(22),
        ),
        child: InkWell(
          onTap: () => context.push('/exam-details', extra: exam.id),
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.mintContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.task_alt_rounded,
                    color: AppColors.onMintContainer,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  exam.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  '${exam.totalQuestions} questions',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '$minutes min · Free',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _AccessibleLoading extends StatelessWidget {
  const _AccessibleLoading();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerLow;
    return Column(
      children: [
        for (var index = 0; index < 3; index++) ...[
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(22),
            ),
          ),
          if (index != 2) const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

class _AccessibleEmpty extends StatelessWidget {
  const _AccessibleEmpty({required this.hasError, required this.onRetry});

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
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Text(
        'No free learning resources are published yet. Published material will appear here automatically.',
        style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
      ),
    );
  }
}

class _AccessibleNotice extends StatelessWidget {
  const _AccessibleNotice({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.amberContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Some learning content could not be refreshed. The items shown above are still available.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.onAmberContainer,
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
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
