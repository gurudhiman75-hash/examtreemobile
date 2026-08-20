import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
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
                  Text(
                    'Free learning',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.35,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'One place for current affairs, free practice and revision material. Published resources will appear here without requiring an app update.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const _LearnModule(
                    key: Key('learn-current-affairs'),
                    icon: Icons.newspaper_rounded,
                    title: 'Current affairs',
                    description:
                        'Daily updates, weekly revision, monthly capsules and quizzes.',
                    items: ['Daily', 'Weekly', 'Monthly', 'Quiz'],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const _LearnModule(
                    key: Key('learn-free-practice'),
                    icon: Icons.task_alt_rounded,
                    title: 'Free practice',
                    description:
                        'Short practice sets, mini mocks and selected free full tests.',
                    items: ['Daily quiz', 'Topic practice', 'Mini mocks'],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const _LearnModule(
                    key: Key('learn-pdfs'),
                    icon: Icons.picture_as_pdf_rounded,
                    title: 'PDFs & notes',
                    description:
                        'Monthly current-affairs PDFs, formula sheets and concise study notes.',
                    items: ['Current affairs PDFs', 'Quick notes', 'Formula sheets'],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const _LearnModule(
                    key: Key('learn-pyq'),
                    icon: Icons.history_edu_rounded,
                    title: 'Previous-year practice',
                    description:
                        'Exam-tagged previous-year and PYQ-style practice when published.',
                    items: ['PYQs', 'Previous papers'],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: scheme.secondaryContainer.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: scheme.onSecondaryContainer,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'This is the catalogue foundation. We will connect each section only to real published resources, so empty categories never pretend content exists.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSecondaryContainer,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
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

class _LearnModule extends StatelessWidget {
  const _LearnModule({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.items,
  });

  final IconData icon;
  final String title;
  final String description;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      color: scheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        side: BorderSide(color: scheme.outlineVariant),
      ),
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
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Icon(icon, color: scheme.onPrimaryContainer),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'CATALOGUE',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final item in items)
                  Chip(
                    visualDensity: VisualDensity.compact,
                    label: Text(item),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
