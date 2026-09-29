import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../data/polity_learn_catalog.dart';
import '../domain/learn_lesson.dart';

class LearnLessonScreen extends StatelessWidget {
  const LearnLessonScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  Widget build(BuildContext context) {
    final lesson = polityLessonById(lessonId);
    if (lesson == null || !lesson.isReady) {
      return Scaffold(
        appBar: AppBar(title: const Text('Learn')),
        body: const Center(child: Text('This lesson is not available yet.')),
      );
    }

    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Indian Polity')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xxl),
          children: [
            Text(lesson.id, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w900)),
            const SizedBox(height: AppSpacing.xs),
            Text(lesson.title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, height: 1.2)),
            const SizedBox(height: AppSpacing.sm),
            Text(lesson.summary, style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant, height: 1.5)),
            const SizedBox(height: AppSpacing.xl),
            for (final section in lesson.sections) ...[
              _LessonSection(section: section),
              const SizedBox(height: AppSpacing.xl),
            ],
            _HighlightPanel(
              title: 'Exam focus',
              icon: Icons.center_focus_strong_rounded,
              items: lesson.examFocus,
              background: theme.colorScheme.tertiaryContainer,
              foreground: theme.colorScheme.onTertiaryContainer,
            ),
            const SizedBox(height: AppSpacing.md),
            _HighlightPanel(
              title: 'Quick revision',
              icon: Icons.bolt_rounded,
              items: lesson.quickRevision,
              background: theme.colorScheme.secondaryContainer,
              foreground: theme.colorScheme.onSecondaryContainer,
            ),
            if (lesson.practiceTags.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      const Icon(Icons.quiz_outlined),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Practice this topic', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Lesson-level Question Studio mapping is prepared. Practice launch will be connected in the next integration pass.',
                              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LessonSection extends StatelessWidget {
  const _LessonSection({required this.section});
  final LearnLessonSection section;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(section.heading, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
        for (final paragraph in section.paragraphs) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(paragraph, style: theme.textTheme.bodyLarge?.copyWith(height: 1.62)),
        ],
        if (section.points.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          for (final point in section.points)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(padding: EdgeInsets.only(top: 7), child: Icon(Icons.circle, size: 6)),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(point, style: theme.textTheme.bodyLarge?.copyWith(height: 1.5))),
                ],
              ),
            ),
        ],
        if (section.table != null) ...[
          const SizedBox(height: AppSpacing.md),
          _LessonTable(table: section.table!),
        ],
      ],
    );
  }
}

class _LessonTable extends StatelessWidget {
  const _LessonTable({required this.table});
  final LearnLessonTable table;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingTextStyle: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
        columns: [for (final header in table.headers) DataColumn(label: Text(header))],
        rows: [
          for (final row in table.rows)
            DataRow(cells: [for (final value in row) DataCell(Text(value))]),
        ],
      ),
    );
  }
}

class _HighlightPanel extends StatelessWidget {
  const _HighlightPanel({required this.title, required this.icon, required this.items, required this.background, required this.foreground});

  final String title;
  final IconData icon;
  final List<String> items;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: foreground),
            const SizedBox(width: AppSpacing.sm),
            Text(title, style: theme.textTheme.titleMedium?.copyWith(color: foreground, fontWeight: FontWeight.w900)),
          ]),
          const SizedBox(height: AppSpacing.sm),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Text('• $item', style: theme.textTheme.bodyMedium?.copyWith(color: foreground, height: 1.45)),
            ),
        ],
      ),
    );
  }
}