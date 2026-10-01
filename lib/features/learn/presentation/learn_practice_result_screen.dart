import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../preferences/domain/question_language.dart';
import '../../preferences/presentation/providers/question_language_providers.dart';
import '../data/learn_practice_catalog.dart';
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
    final standalone = learnPracticeTopicById(topicId);
    final subject = polityLearnSubjectFor(language);

    String title;
    String allTopicsPath;
    String? nextTopicId;
    String? nextTopicTitle;

    if (standalone != null) {
      final topics = learnPracticeTopicsForSubmodule(standalone.submoduleId);
      final index = topics.indexWhere((topic) => topic.id == topicId);
      final next = index >= 0 && index + 1 < topics.length
          ? topics[index + 1]
          : null;
      title = standalone.title;
      allTopicsPath =
          '/learn-submodule?id=${Uri.encodeQueryComponent(standalone.submoduleId)}';
      nextTopicId = next?.id;
      nextTopicTitle = next?.title;
    } else {
      var index = subject.lessons.indexWhere((lesson) => lesson.id == topicId);
      if (index < 0) index = 0;
      final lesson = subject.lessons[index];
      final next = index + 1 < subject.lessons.length
          ? subject.lessons[index + 1]
          : null;
      title = lesson.title;
      allTopicsPath = '/learn-submodule?id=gk-polity';
      nextTopicId = next?.id;
      nextTopicTitle = next?.title;
    }

    final accuracy = total <= 0 ? 0 : ((correct / total) * 100).round();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Practice result'),
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
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
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
            child: Column(
              children: [
                SizedBox(
                  width: 108,
                  height: 108,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: accuracy.clamp(0, 100) / 100,
                        strokeWidth: 8,
                        strokeCap: StrokeCap.round,
                        backgroundColor: Colors.white.withValues(alpha: .16),
                        color: const Color(0xFFFFD36B),
                      ),
                      Text(
                        '$accuracy%',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.35,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$correct of $total correct',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white.withValues(alpha: .82),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
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
                    ref.invalidate(learnPracticeQuestionsProvider);
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
                  onPressed: () => context.go(allTopicsPath),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF073A6A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  icon: const Icon(Icons.grid_view_rounded),
                  label: const Text('All topics'),
                ),
              ),
            ],
          ),
          if (nextTopicId != null && nextTopicTitle != null) ...[
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Suggested next topic',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Material(
              color: Colors.transparent,
              child: Ink(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE3E9F1)),
                  boxShadow: [
                    BoxShadow(
                      color:
                          const Color(0xFF10264A).withValues(alpha: .035),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: InkWell(
                  key: const Key('learn-next-suggested-topic'),
                  onTap: () => context.go(
                    '/learn-practice?topic=${Uri.encodeQueryComponent(nextTopicId!)}',
                  ),
                  borderRadius: BorderRadius.circular(18),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
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
                            Icons.arrow_forward_rounded,
                            color: Color(0xFF0B5D96),
                          ),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nextTopicTitle,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: const Color(0xFF162A48),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '20 questions · Untimed · Instant explanations',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: const Color(0xFF718096),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Color(0xFF52708F),
                        ),
                      ],
                    ),
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
