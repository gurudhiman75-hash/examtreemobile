import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../preferences/domain/question_language.dart';
import '../../preferences/presentation/providers/question_language_providers.dart';
import '../data/polity_learn_localizations.dart';
import '../domain/learn_lesson.dart';
import '../domain/learn_ui_copy.dart';
import 'learn_language_selector.dart';

class LearnCourseScreen extends ConsumerWidget {
  const LearnCourseScreen({super.key, required this.subjectCode});

  final String subjectCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language =
        ref.watch(questionLanguageProvider).value ?? QuestionLanguage.english;
    final copy = learnUiCopy(language);
    final subject = subjectCode.trim().toUpperCase() == 'POL'
        ? polityLearnSubjectFor(language)
        : null;

    if (subject == null) {
      return Scaffold(
        appBar: AppBar(title: Text(copy.learn)),
        body: Center(child: Text(copy.unavailable)),
      );
    }

    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      appBar: AppBar(
        title: Text(
          subject.title,
          style: const TextStyle(fontWeight: FontWeight.w900),
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
            const SizedBox(height: 12),
            _CourseHero(subject: subject, copy: copy),
            const SizedBox(height: 14),
            _CourseStats(subject: subject),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    copy.lessons,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: const Color(0xFF10264A),
                      fontWeight: FontWeight.w900,
                      letterSpacing: -.3,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4D6),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    '${subject.readyLessonCount} ready',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: const Color(0xFF8A5A00),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            for (var index = 0; index < subject.lessons.length; index++) ...[
              _LessonTile(
                lesson: subject.lessons[index],
                copy: copy,
                index: index,
              ),
              if (index != subject.lessons.length - 1)
                const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class _CourseHero extends StatelessWidget {
  const _CourseHero({required this.subject, required this.copy});

  final LearnSubject subject;
  final LearnUiCopy copy;

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
            color: const Color(0xFF062D5C).withValues(alpha: .13),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -24,
            top: -30,
            child: Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: .07),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.account_balance_rounded,
                  color: Color(0xFFFFD36B),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                subject.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -.4,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subject.subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: .84),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 13),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _CoursePill(
                    icon: Icons.menu_book_rounded,
                    label:
                        '${subject.readyLessonCount} ${copy.lessonsReady}',
                  ),
                  _CoursePill(
                    icon: Icons.layers_rounded,
                    label: '${subject.lessons.length} ${copy.lessonsMapped}',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CourseStats extends StatelessWidget {
  const _CourseStats({
    required this.subject,
  });

  final LearnSubject subject;

  @override
  Widget build(BuildContext context) {
    final totalMinutes = subject.lessons.fold<int>(
      0,
      (sum, lesson) => sum + (lesson.isReady ? lesson.estimatedMinutes : 0),
    );
    return Row(
      children: [
        Expanded(
          child: _CourseMetric(
            icon: Icons.menu_book_rounded,
            value: subject.readyLessonCount.toString(),
            label: 'Ready lessons',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _CourseMetric(
            icon: Icons.layers_rounded,
            value: subject.lessons.length.toString(),
            label: 'Chapters',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _CourseMetric(
            icon: Icons.schedule_rounded,
            value: totalMinutes.toString() + ' min',
            label: 'Reading',
          ),
        ),
      ],
    );
  }
}

class _CourseMetric extends StatelessWidget {
  const _CourseMetric({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4ECF6)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF176CC0)),
          const SizedBox(height: 7),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF081847),
              fontWeight: FontWeight.w900,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF718096),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CoursePill extends StatelessWidget {
  const _CoursePill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .11),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: Colors.white.withValues(alpha: .1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFFFFD36B)),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  const _LessonTile({
    required this.lesson,
    required this.copy,
    required this.index,
  });

  final LearnLesson lesson;
  final LearnUiCopy copy;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ready = lesson.isReady;

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: ready ? Colors.white : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: ready
                ? const Color(0xFFE3E9F1)
                : const Color(0xFFEDF1F5),
          ),
          boxShadow: ready
              ? [
                  BoxShadow(
                    color: const Color(0xFF10264A).withValues(alpha: .04),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: InkWell(
          onTap: ready
              ? () => context.push(
                    '/learn-lesson?id=${Uri.encodeQueryComponent(lesson.id)}',
                  )
              : null,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(13, 12, 12, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: ready
                        ? const Color(0xFFEAF7FF)
                        : const Color(0xFFEEF2F6),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ready
                      ? Text(
                          '${index + 1}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: const Color(0xFF0369A1),
                            fontWeight: FontWeight.w900,
                          ),
                        )
                      : const Icon(
                          Icons.lock_outline_rounded,
                          size: 20,
                          color: Color(0xFF94A3B8),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lesson.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: const Color(0xFF162A48),
                          fontWeight: FontWeight.w900,
                          letterSpacing: -.15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lesson.summary,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF718096),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Row(
                        children: [
                          Icon(
                            ready
                                ? Icons.schedule_rounded
                                : Icons.hourglass_top_rounded,
                            size: 14,
                            color: ready
                                ? const Color(0xFF8A5A00)
                                : const Color(0xFF94A3B8),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              ready
                                  ? '${lesson.estimatedMinutes} ${copy.minutes} · ${lesson.id}'
                                  : '${copy.comingNext} · ${lesson.id}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: ready
                                    ? const Color(0xFF8A5A00)
                                    : const Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (ready) ...[
                  const SizedBox(width: 8),
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF5FF),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'Read',
                      style: TextStyle(
                        color: Color(0xFF176CC0),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
