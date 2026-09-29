import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../preferences/domain/question_language.dart';
import '../../preferences/presentation/providers/question_language_providers.dart';
import '../data/polity_learn_localizations.dart';
import '../domain/learn_lesson.dart';
import '../domain/learn_ui_copy.dart';
import 'learn_language_selector.dart';

class LearnLessonScreen extends ConsumerWidget {
  const LearnLessonScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language =
        ref.watch(questionLanguageProvider).value ?? QuestionLanguage.english;
    final copy = learnUiCopy(language);
    final subject = polityLearnSubjectFor(language);
    LearnLesson? lesson;
    for (final candidate in subject.lessons) {
      if (candidate.id == lessonId.trim().toUpperCase()) {
        lesson = candidate;
        break;
      }
    }

    if (lesson == null || !lesson.isReady) {
      return Scaffold(
        appBar: AppBar(title: Text(copy.learn)),
        body: Center(child: Text(copy.unavailable)),
      );
    }

    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(subject.title)),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.xxl,
          ),
          children: [
            const LearnLanguageSelector(),
            const SizedBox(height: AppSpacing.md),
            Text(
              lesson.id,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              lesson.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                height: 1.2,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              lesson.summary,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            for (final section in lesson.sections) ...[
              _LessonSection(section: section),
              const SizedBox(height: AppSpacing.xl),
            ],
            _HighlightPanel(
              title: copy.examFocus,
              icon: Icons.center_focus_strong_rounded,
              items: lesson.examFocus,
              background: theme.colorScheme.tertiaryContainer,
              foreground: theme.colorScheme.onTertiaryContainer,
            ),
            const SizedBox(height: AppSpacing.md),
            _HighlightPanel(
              title: copy.quickRevision,
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
                            Text(
                              copy.practiceThisTopic,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              copy.practicePending,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                height: 1.4,
                              ),
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
        Text(
          section.heading,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        for (final paragraph in section.paragraphs) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            paragraph,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.62),
          ),
        ],
        if (section.points.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          for (final point in section.points)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 7),
                    child: Icon(Icons.circle, size: 6),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      point,
                      style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                    ),
                  ),
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
        headingTextStyle: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w900,
        ),
        columns: [
          for (final header in table.headers) DataColumn(label: Text(header)),
        ],
        rows: [
          for (final row in table.rows)
            DataRow(
              cells: [
                for (final value in row) DataCell(Text(value)),
              ],
            ),
        ],
      ),
    );
  }
}

class _HighlightPanel extends StatelessWidget {
  const _HighlightPanel({
    required this.title,
    required this.icon,
    required this.items,
    required this.background,
    required this.foreground,
  });

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
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: foreground),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Text(
                '• $item',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: foreground,
                  height: 1.45,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
