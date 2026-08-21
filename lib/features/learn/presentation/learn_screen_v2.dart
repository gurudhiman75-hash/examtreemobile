import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/models/exam_model.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/network_failure_view.dart';
import '../domain/learning_resource.dart';
import 'providers/learning_resources_providers.dart';

class LearnScreen extends ConsumerWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resourcesAsync = ref.watch(relevantLearningResourcesProvider);
    final freeTestsAsync = ref.watch(learnFreeTestsProvider);

    final resources = resourcesAsync.value;
    final freeTests = freeTestsAsync.value;
    final loading = resources == null || freeTests == null;
    final resourceError = resourcesAsync.hasError ? resourcesAsync.error : null;
    final testsError = freeTestsAsync.hasError ? freeTestsAsync.error : null;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(learningResourcesProvider);
            ref.invalidate(availableExamsProvider);
            await Future.wait([
              ref.read(learningResourcesProvider.future),
              ref.read(availableExamsProvider.future),
            ]);
          },
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
                    const _LearnHeader(),
                    const SizedBox(height: AppSpacing.lg),
                    if (loading)
                      const _LearnLoading()
                    else if (resources!.isEmpty && freeTests!.isEmpty)
                      _LearnEmpty(
                        hasError: resourceError != null || testsError != null,
                        onRetry: () {
                          ref.invalidate(learningResourcesProvider);
                          ref.invalidate(availableExamsProvider);
                        },
                      )
                    else ...[
                      if (resources.where((item) => item.category == LearningResourceCategory.currentAffairs).isNotEmpty) ...[
                        _ResourceSection(
                          key: const Key('learn-current-affairs'),
                          title: 'Current affairs',
                          description: 'Published updates and revision material.',
                          icon: Icons.newspaper_rounded,
                          resources: resources
                              .where((item) => item.category == LearningResourceCategory.currentAffairs)
                              .toList(growable: false),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                      if (freeTests.isNotEmpty) ...[
                        _FreePracticeSection(tests: freeTests.take(6).toList(growable: false)),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                      if (resources.where((item) => item.category != LearningResourceCategory.currentAffairs).isNotEmpty) ...[
                        _ResourceSection(
                          key: const Key('learn-notes-pdfs'),
                          title: 'PDFs & notes',
                          description: 'Published notes and formula sheets.',
                          icon: Icons.menu_book_rounded,
                          resources: resources
                              .where((item) => item.category != LearningResourceCategory.currentAffairs)
                              .toList(growable: false),
                        ),
                      ],
                      if (resourceError != null || testsError != null) ...[
                        const SizedBox(height: AppSpacing.lg),
                        _PartialFailureNotice(
                          onRetry: () {
                            ref.invalidate(learningResourcesProvider);
                            ref.invalidate(availableExamsProvider);
                          },
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LearnHeader extends StatelessWidget {
  const _LearnHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Free learning',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.35,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Published current affairs, notes and free practice—organised around the exams you chose.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _ResourceSection extends StatelessWidget {
  const _ResourceSection({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.resources,
  });

  final String title;
  final String description;
  final IconData icon;
  final List<LearningResourceSummary> resources;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(title: title, description: description, icon: icon),
        const SizedBox(height: AppSpacing.sm),
        for (var index = 0; index < resources.length; index++) ...[
          _LearningResourceCard(resource: resources[index]),
          if (index != resources.length - 1)
            const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _FreePracticeSection extends StatelessWidget {
  const _FreePracticeSection({required this.tests});

  final List<Exam> tests;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading(
          title: 'Free practice',
          description: 'Live tests you can open without a purchase.',
          icon: Icons.task_alt_rounded,
        ),
        const SizedBox(height: AppSpacing.sm),
        for (var index = 0; index < tests.length; index++) ...[
          _FreeTestCard(exam: tests[index]),
          if (index != tests.length - 1)
            const SizedBox(height: AppSpacing.sm),
        ],
        const SizedBox(height: AppSpacing.sm),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => context.go('/exams'),
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            label: const Text('All tests'),
          ),
        ),
      ],
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Icon(icon, color: theme.colorScheme.onPrimaryContainer),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LearningResourceCard extends StatelessWidget {
  const _LearningResourceCard({required this.resource});

  final LearningResourceSummary resource;

  Future<void> _open(BuildContext context) async {
    if (resource.hasInlineContent) {
      context.push('/learn-resource?id=${Uri.encodeQueryComponent(resource.id)}');
      return;
    }
    final url = resource.contentUrl;
    if (url != null && await launchUrl(url, mode: LaunchMode.externalApplication)) {
      return;
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('This resource could not be opened.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final targetLabel = resource.isGeneral
        ? 'All exams'
        : resource.exams.isEmpty
            ? 'Selected exams'
            : resource.exams.take(2).map((exam) => exam.name).join(' · ');
    final dateLabel = _dateLabel(resource.contentDate ?? resource.publishedAt);

    return Material(
      color: scheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        onTap: () => _open(context),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _SmallBadge(
                    icon: resource.format == LearningResourceFormat.pdf
                        ? Icons.picture_as_pdf_outlined
                        : Icons.article_outlined,
                    label: resource.format == LearningResourceFormat.pdf ? 'PDF' : 'Article',
                  ),
                  _SmallBadge(
                    icon: Icons.translate_rounded,
                    label: resource.languageCode.toUpperCase(),
                  ),
                  if (dateLabel != null)
                    _SmallBadge(icon: Icons.calendar_today_outlined, label: dateLabel),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                resource.title,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              if (resource.summary.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  resource.summary,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(Icons.flag_outlined, size: 16, color: scheme.onSurfaceVariant),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      targetLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Icon(Icons.arrow_forward_rounded, size: 19, color: scheme.primary),
                ],
              ),
            ],
          ),
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
    final scheme = theme.colorScheme;
    final minutes = (exam.durationInSeconds / 60).round();
    return Material(
      color: scheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        onTap: () => context.push(
          '/exam-details?id=${Uri.encodeQueryComponent(exam.id)}',
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                exam.title,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              if (exam.description.trim().isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  exam.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  _SmallBadge(icon: Icons.help_outline_rounded, label: '${exam.totalQuestions} questions'),
                  _SmallBadge(icon: Icons.schedule_rounded, label: '$minutes min'),
                  const _SmallBadge(icon: Icons.lock_open_rounded, label: 'Free'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallBadge extends StatelessWidget {
  const _SmallBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _LearnLoading extends StatelessWidget {
  const _LearnLoading();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < 4; index++) ...[
          Container(
            height: index == 0 ? 120 : 100,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
          ),
          if (index != 3) const SizedBox(height: AppSpacing.sm),
        ],
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
        error: const Exception('Learning catalogue unavailable'),
        fallbackTitle: 'Unable to load free learning',
        onRetry: onRetry,
      );
    }
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Column(
        children: [
          Icon(Icons.menu_book_outlined, size: 52, color: theme.colorScheme.outline),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'No free learning resources are published yet.',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Published material will appear here automatically.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
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
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          Icon(Icons.sync_problem_outlined, color: theme.colorScheme.onErrorContainer),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Some learning content could not be refreshed.',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onErrorContainer),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

String? _dateLabel(DateTime? date) {
  if (date == null) return null;
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}
