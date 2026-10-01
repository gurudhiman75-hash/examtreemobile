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
      final progressItems =
          ref.watch(learnPracticeProgressListProvider).value ?? const [];
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(submodule.title),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF10264A),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            12,
            AppSpacing.sm,
            12,
            AppSpacing.xxl,
          ),
          children: [
            _SubmoduleOverview(
              title: 'Vocabulary',
              subtitle: 'Build stronger word power with focused practice.',
              topicIds: topics.map((topic) => topic.id).toList(growable: false),
              progressItems: progressItems,
              icon: Icons.translate_rounded,
              accent: AppColors.sky,
              accentContainer: AppColors.skyContainer,
            ),
            const SizedBox(height: AppSpacing.lg),
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
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(submodule.title),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF10264A),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
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
    final progressItems =
        ref.watch(learnPracticeProgressListProvider).value ?? const [];
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(submodule.title),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF10264A),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          12,
          AppSpacing.sm,
          12,
          AppSpacing.xxl,
        ),
        children: [
          _SubmoduleOverview(
            title: 'Polity',
            subtitle: 'Indian Constitution, institutions and governance.',
            topicIds:
                subject.lessons.map((lesson) => lesson.id).toList(growable: false),
            progressItems: progressItems,
            icon: Icons.account_balance_rounded,
            accent: AppColors.mint,
            accentContainer: AppColors.mintContainer,
          ),
          const SizedBox(height: AppSpacing.lg),
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


class _SubmoduleOverview extends StatelessWidget {
  const _SubmoduleOverview({
    required this.title,
    required this.subtitle,
    required this.topicIds,
    required this.progressItems,
    required this.icon,
    required this.accent,
    required this.accentContainer,
  });

  final String title;
  final String subtitle;
  final List<String> topicIds;
  final List<LearnPracticeProgress> progressItems;
  final IconData icon;
  final Color accent;
  final Color accentContainer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tracked = progressItems
        .where((item) => topicIds.contains(item.topicId))
        .toList(growable: false);
    final completed = tracked
        .where((item) => item.status == LearnPracticeStatus.completed)
        .length;
    final partial = tracked
        .where((item) => item.status == LearnPracticeStatus.inProgress)
        .fold<double>(0, (sum, item) {
      if (item.totalQuestions <= 0) return sum;
      return sum +
          (item.currentQuestion / item.totalQuestions).clamp(0.0, 1.0);
    });
    final total = topicIds.isEmpty ? 1 : topicIds.length;
    final progress = ((completed + partial) / total).clamp(0.0, 1.0).toDouble();
    final percent = (progress * 100).round();

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
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: const Color(0xFFFFD36B), size: 27),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: .82),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$completed / ${topicIds.length} topics completed',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: const Color(0xFFFFD36B),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 52,
            height: 52,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 5,
                  backgroundColor: Colors.white.withValues(alpha: .16),
                  color: const Color(0xFFFFD36B),
                ),
                Text(
                  '$percent%',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
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
        : (progress.currentQuestion / progress.totalQuestions).clamp(0.0, 1.0).toDouble();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE3E9F1)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10264A).withValues(alpha: .035),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
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
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF073A6A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                      textStyle: const TextStyle(fontWeight: FontWeight.w900),
                    ),
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
        : (progress.currentQuestion / progress.totalQuestions).clamp(0.0, 1.0).toDouble();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE3E9F1)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10264A).withValues(alpha: .035),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
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
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF073A6A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.w900),
                ),
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
