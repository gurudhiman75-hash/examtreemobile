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

    final resolvedLesson = lesson;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      appBar: AppBar(
        title: const Text(
          'Notes',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: const Color(0xFFF8FBFF),
        foregroundColor: const Color(0xFF10264A),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            12,
            AppSpacing.sm,
            12,
            AppSpacing.xxl,
          ),
          children: [
            const LearnLanguageSelector(),
            const SizedBox(height: 10),
            _LessonContextBar(
              subject: subject.title,
              lesson: resolvedLesson,
            ),
            const SizedBox(height: 12),
            _LessonHeader(lesson: resolvedLesson),
            const SizedBox(height: 22),
            for (var index = 0;
                index < resolvedLesson.sections.length;
                index++) ...[
              _LessonSection(
                section: resolvedLesson.sections[index],
                index: index,
              ),
              if (index != resolvedLesson.sections.length - 1)
                const SizedBox(height: 22),
            ],
            const SizedBox(height: 22),
            _HighlightPanel(
              title: copy.examFocus,
              icon: Icons.center_focus_strong_rounded,
              items: resolvedLesson.examFocus,
              background: const Color(0xFFFFF6DE),
              foreground: const Color(0xFF74500B),
              iconBackground: const Color(0xFFFFE7A8),
            ),
            const SizedBox(height: 12),
            _HighlightPanel(
              title: copy.quickRevision,
              icon: Icons.bolt_rounded,
              items: resolvedLesson.quickRevision,
              background: const Color(0xFFEAF4FF),
              foreground: const Color(0xFF164D7E),
              iconBackground: const Color(0xFFD4E9FF),
            ),
            if (resolvedLesson.practiceTags.isNotEmpty) ...[
              const SizedBox(height: 12),
              _PracticeCard(copy: copy),
            ],
          ],
        ),
      ),
    );
  }
}

class _LessonContextBar extends StatelessWidget {
  const _LessonContextBar({
    required this.subject,
    required this.lesson,
  });

  final String subject;
  final LearnLesson lesson;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4ECF6)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF5FF),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: Color(0xFF176CC0),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
                  style: const TextStyle(
                    color: Color(0xFF60759B),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  lesson.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF10264A),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4D6),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              lesson.estimatedMinutes.toString() + ' min',
              style: const TextStyle(
                color: Color(0xFF8A5A00),
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonHeader extends StatelessWidget {
  const _LessonHeader({required this.lesson});

  final LearnLesson lesson;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF031B3A),
            Color(0xFF063A70),
            Color(0xFF0B5D96),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF062D5C).withValues(alpha: .12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -28,
            top: -30,
            child: Container(
              width: 108,
              height: 108,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: .07),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD36B).withValues(alpha: .15),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      lesson.id,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: const Color(0xFFFFD36B),
                        fontWeight: FontWeight.w900,
                        letterSpacing: .45,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        size: 15,
                        color: Color(0xFFFFD36B),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${lesson.estimatedMinutes} min',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white.withValues(alpha: .86),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                lesson.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  height: 1.12,
                  letterSpacing: -.4,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                lesson.summary,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: .84),
                  height: 1.45,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LessonSection extends StatelessWidget {
  const _LessonSection({required this.section, required this.index});

  final LearnLessonSection section;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4ECF6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF4FF),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                '${index + 1}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: const Color(0xFF0B5D96),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                section.heading,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF10264A),
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.25,
                ),
              ),
            ),
          ],
        ),
        for (final paragraph in section.paragraphs) ...[
          const SizedBox(height: 11),
          Text(
            paragraph,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF334155),
              height: 1.62,
            ),
          ),
        ],
        if (section.points.isNotEmpty) ...[
          const SizedBox(height: 12),
          for (final point in section.points)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFD4A73A),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      point,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF334155),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
        if (section.table != null) ...[
          const SizedBox(height: 12),
          _LessonTable(table: section.table!),
        ],
      ],
    ),
    );
  }
}

class _LessonTable extends StatelessWidget {
  const _LessonTable({required this.table});

  final LearnLessonTable table;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFFBFCFE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(const Color(0xFFF0F5FA)),
          headingTextStyle: theme.textTheme.labelLarge?.copyWith(
            color: const Color(0xFF10264A),
            fontWeight: FontWeight.w900,
          ),
          dataTextStyle: theme.textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF334155),
          ),
          columns: [
            for (final header in table.headers)
              DataColumn(label: Text(header)),
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
    required this.iconBackground,
  });

  final String title;
  final IconData icon;
  final List<String> items;
  final Color background;
  final Color foreground;
  final Color iconBackground;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: foreground.withValues(alpha: .09)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: foreground, size: 20),
              ),
              const SizedBox(width: 9),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    margin: const EdgeInsets.only(top: 7),
                    decoration: BoxDecoration(
                      color: foreground.withValues(alpha: .72),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: foreground,
                        height: 1.45,
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

class _PracticeCard extends StatelessWidget {
  const _PracticeCard({required this.copy});

  final LearnUiCopy copy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF4FF),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.quiz_outlined,
              color: Color(0xFF0B5D96),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  copy.practiceThisTopic,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF10264A),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  copy.practicePending,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF718096),
                    height: 1.4,
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
