import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../preferences/domain/question_language.dart';
import '../../preferences/presentation/providers/question_language_providers.dart';
import '../data/learn_module_catalog.dart';
import '../data/learn_practice_catalog.dart';
import '../data/polity_learn_localizations.dart';
import '../domain/learn_lesson.dart';
import '../domain/learn_practice_models.dart';
import 'providers/learn_practice_providers.dart';

class LearnSubmoduleScreen extends ConsumerWidget {
  const LearnSubmoduleScreen({super.key, required this.submoduleId});

  final String submoduleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submodule = learnSubmoduleById(submoduleId);
    if (submodule == null) {
      return const Scaffold(
        body: Center(child: Text('Sub-module unavailable')),
      );
    }

    final language =
        ref.watch(questionLanguageProvider).value ?? QuestionLanguage.english;
    final theme = Theme.of(context);

    if (submodule.id == 'english-vocabulary') {
      final topics = learnPracticeTopicsForSubmodule(submodule.id);
      return Scaffold(
        appBar: AppBar(title: Text(submodule.title)),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.xxl,
          ),
          children: [
            Text(
              'Build vocabulary with short untimed sessions. Every answer is checked immediately and followed by an explanation.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            for (final topic in topics) ...[
              _StandalonePracticeTopicCard(topic: topic),
              const SizedBox(height: AppSpacing.sm),
            ],
          ],
        ),
      );
    }

    if (submodule.id != 'gk-polity') {
      return Scaffold(
        appBar: AppBar(title: Text(submodule.title)),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Text(
              'Practice mapping for this sub-module is being connected to Question Studio.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final subject = polityLearnSubjectFor(language);
    return Scaffold(
      appBar: AppBar(title: Text(submodule.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.xxl,
        ),
        children: [
          Text(
            'Choose a topic for a short untimed practice session. Answers and explanations appear immediately after each question.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final lesson in subject.lessons) ...[
            _TopicCard(lesson: lesson),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _TopicCard extends ConsumerWidget {
  const _TopicCard({required this.lesson});

  final LearnLesson lesson;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final progressAsync = ref.watch(learnPracticeProgressProvider(lesson.id));
    final progress = progressAsync.value;
    final status = progress?.status ?? LearnPracticeStatus.notStarted;
    final buttonLabel = switch (status) {
      LearnPracticeStatus.notStarted => 'Start',
      LearnPracticeStatus.inProgress => 'Resume',
      LearnPracticeStatus.completed => 'Retake',
    };

    final detail = switch (status) {
      LearnPracticeStatus.notStarted => '15–20 questions · Untimed',
      LearnPracticeStatus.inProgress =>
        '${progress!.currentQuestion} of ${progress.totalQuestions} answered',
      LearnPracticeStatus.completed =>
        'Last score ${progress!.correctAnswers}/${progress.totalQuestions}',
    };

    final lessonNumber = int.tryParse(lesson.id.split('-').last) ?? 0;
    final progressValue = progress == null || progress.totalQuestions <= 0
        ? 0.0
        : (progress.currentQuestion / progress.totalQuestions).clamp(0, 1);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: status == LearnPracticeStatus.completed
                        ? AppColors.mintContainer
                        : theme.colorScheme.surfaceContainerLow,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    lessonNumber.toString().padLeft(2, '0'),
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: status == LearnPracticeStatus.completed
                          ? AppColors.onMintContainer
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lesson.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        detail,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                if (status == LearnPracticeStatus.completed)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.mint,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                minHeight: 5,
                value: progressValue,
                backgroundColor: theme.colorScheme.surfaceContainerHigh,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    icon: const Icon(Icons.menu_book_outlined, size: 18),
                    onPressed: () => context.push(
                      '/learn-lesson?id=${Uri.encodeQueryComponent(lesson.id)}',
                    ),
                    label: const Text('Review lesson'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: FilledButton(
                    key: Key('learn-practice-${lesson.id}'),
                    onPressed: () async {
                      if (status == LearnPracticeStatus.completed) {
                        await ref
                            .read(learnPracticeProgressStoreProvider)
                            .clear(lesson.id);
                        ref.invalidate(learnPracticeProgressProvider(lesson.id));
                        ref.invalidate(learnPracticeProgressListProvider);
                        ref.invalidate(learnPracticeQuestionsProvider);
                      }
                      if (context.mounted) {
                        final freshQuery =
                            status == LearnPracticeStatus.completed ? '&fresh=1' : '';
                        context.push(
                          '/learn-practice?topic=${Uri.encodeQueryComponent(lesson.id)}$freshQuery',
                        );
                      }
                    },
                    child: Text(buttonLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class _StandalonePracticeTopicCard extends ConsumerWidget {
  const _StandalonePracticeTopicCard({required this.topic});

  final LearnPracticeTopic topic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final progress = ref.watch(learnPracticeProgressProvider(topic.id)).value;
    final status = progress?.status ?? LearnPracticeStatus.notStarted;
    final buttonLabel = switch (status) {
      LearnPracticeStatus.notStarted => 'Start',
      LearnPracticeStatus.inProgress => 'Resume',
      LearnPracticeStatus.completed => 'Retake',
    };
    final detail = switch (status) {
      LearnPracticeStatus.notStarted =>
        '${topic.questionTarget} questions · Untimed',
      LearnPracticeStatus.inProgress =>
        '${progress!.currentQuestion} of ${progress.totalQuestions} answered',
      LearnPracticeStatus.completed =>
        'Last score ${progress!.correctAnswers}/${progress.totalQuestions}',
    };

    final progressValue = progress == null || progress.totalQuestions <= 0
        ? 0.0
        : (progress.currentQuestion / progress.totalQuestions).clamp(0, 1);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              topic.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              topic.subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              detail,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                minHeight: 5,
                value: progressValue,
                backgroundColor: theme.colorScheme.surfaceContainerHigh,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                key: Key('learn-practice-${topic.id}'),
                onPressed: () async {
                  if (status == LearnPracticeStatus.completed) {
                    await ref
                        .read(learnPracticeProgressStoreProvider)
                        .clear(topic.id);
                    ref.invalidate(learnPracticeProgressProvider(topic.id));
                    ref.invalidate(learnPracticeProgressListProvider);
                    ref.invalidate(learnPracticeQuestionsProvider);
                  }
                  if (context.mounted) {
                    final freshQuery =
                        status == LearnPracticeStatus.completed ? '&fresh=1' : '';
                    context.push(
                      '/learn-practice?topic=${Uri.encodeQueryComponent(topic.id)}$freshQuery',
                    );
                  }
                },
                child: Text(buttonLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
