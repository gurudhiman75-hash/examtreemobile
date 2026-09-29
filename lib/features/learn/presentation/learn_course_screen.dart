import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../data/polity_learn_catalog.dart';
import '../domain/learn_lesson.dart';

class LearnCourseScreen extends StatelessWidget {
  const LearnCourseScreen({super.key, required this.subjectCode});

  final String subjectCode;

  @override
  Widget build(BuildContext context) {
    final subject = subjectCode.trim().toUpperCase() == 'POL' ? polityLearnSubject : null;

    if (subject == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Learn')),
        body: const Center(child: Text('This subject is not available yet.')),
      );
    }

    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(subject.title)),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xxl),
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.account_balance_rounded, size: 34, color: theme.colorScheme.onPrimaryContainer),
                  const SizedBox(height: AppSpacing.md),
                  Text(subject.title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, color: theme.colorScheme.onPrimaryContainer)),
                  const SizedBox(height: AppSpacing.sm),
                  Text(subject.subtitle, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimaryContainer, height: 1.45)),
                  const SizedBox(height: AppSpacing.md),
                  Text('${subject.readyLessonCount} lessons ready · ${subject.lessons.length} planned', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800, color: theme.colorScheme.onPrimaryContainer)),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Lessons', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: AppSpacing.sm),
            for (final lesson in subject.lessons) ...[
              _LessonTile(lesson: lesson),
              const SizedBox(height: AppSpacing.sm),
            ],
          ],
        ),
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  const _LessonTile({required this.lesson});
  final LearnLesson lesson;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: lesson.isReady ? () => context.push('/learn-lesson?id=${Uri.encodeQueryComponent(lesson.id)}') : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42, height: 42, alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: lesson.isReady ? theme.colorScheme.secondaryContainer : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  lesson.isReady ? Icons.menu_book_rounded : Icons.lock_outline_rounded,
                  size: 21,
                  color: lesson.isReady ? theme.colorScheme.onSecondaryContainer : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lesson.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                    const SizedBox(height: AppSpacing.xs),
                    Text(lesson.summary, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, height: 1.4)),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      lesson.isReady ? '${lesson.estimatedMinutes} min · ${lesson.id}' : 'Coming next · ${lesson.id}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: lesson.isReady ? theme.colorScheme.primary : theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              if (lesson.isReady) ...[
                const SizedBox(width: AppSpacing.sm),
                const Icon(Icons.chevron_right_rounded),
              ],
            ],
          ),
        ),
      ),
    );
  }
}