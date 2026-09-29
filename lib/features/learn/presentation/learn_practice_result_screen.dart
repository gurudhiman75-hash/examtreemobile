import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../preferences/domain/question_language.dart';
import '../../preferences/presentation/providers/question_language_providers.dart';
import '../data/polity_learn_localizations.dart';
import 'providers/learn_practice_providers.dart';

class LearnPracticeResultScreen extends ConsumerWidget {
  const LearnPracticeResultScreen({
    super.key,
    required this.topicId,
    required this.correct,
    required this.total,
  });

  final String topicId;
  final int correct;
  final int total;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language =
        ref.watch(questionLanguageProvider).value ?? QuestionLanguage.english;
    final subject = polityLearnSubjectFor(language);
    var index = subject.lessons.indexWhere((lesson) => lesson.id == topicId);
    if (index < 0) index = 0;
    final lesson = subject.lessons[index];
    final next = index + 1 < subject.lessons.length
        ? subject.lessons[index + 1]
        : null;
    final accuracy = total <= 0 ? 0 : ((correct / total) * 100).round();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Practice result')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.xxl,
        ),
        children: [
          Center(
            child: Container(
              width: 112,
              height: 112,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$accuracy%',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            lesson.title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '$correct of $total correct',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await ref
                        .read(learnPracticeProgressStoreProvider)
                        .clear(topicId);
                    ref.invalidate(learnPracticeProgressProvider(topicId));
                    ref.invalidate(learnPracticeProgressListProvider);
                    if (context.mounted) {
                      context.go(
                        '/learn-practice?topic=${Uri.encodeQueryComponent(topicId)}&fresh=1',
                      );
                    }
                  },
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Retake'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () =>
                      context.go('/learn-submodule?id=gk-polity'),
                  icon: const Icon(Icons.grid_view_rounded),
                  label: const Text('All topics'),
                ),
              ),
            ],
          ),
          if (next != null) ...[
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Suggested next topic',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Card(
              margin: EdgeInsets.zero,
              child: InkWell(
                key: const Key('learn-next-suggested-topic'),
                onTap: () => context.go(
                  '/learn-practice?topic=${Uri.encodeQueryComponent(next.id)}',
                ),
                borderRadius: BorderRadius.circular(18),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              next.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              '20 questions · Untimed · Instant explanations',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_rounded),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
