import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/primary_button.dart';
import 'providers/exam_providers.dart';

class ExamDetailsScreen extends ConsumerWidget {
  final String examId;
  const ExamDetailsScreen({super.key, required this.examId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final examAsync = ref.watch(examDetailsProvider(examId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Details'),
      ),
      body: examAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (exam) {
          const instructions = [
            'Ensure you have a stable internet connection before starting.',
            'Do not switch tabs or minimize the app during the test.',
            'Calculators are not permitted.',
            'You can pause the test, but the timer will continue running.',
            'Submit the test before the timer runs out.'
          ];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exam.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  exam.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildInfoGrid(
                  theme,
                  '${exam.durationInSeconds ~/ 60} mins',
                  exam.totalQuestions,
                  1, // mock attempts used
                  exam.maxAttempts,
                  '-${exam.negativeMarking} per wrong answer',
                  exam.difficulty,
                ),
                const SizedBox(height: AppSpacing.lg),
                const Divider(),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Instructions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ...instructions.map((instruction) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• ', style: theme.textTheme.bodyMedium),
                          Expanded(
                            child: Text(
                              instruction,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: AppSpacing.xxl),
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    text: 'Start Exam',
                    onPressed: () {
                      context.push('/test-attempt', extra: examId);
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoGrid(
    ThemeData theme,
    String duration,
    int questionCount,
    int attemptsUsed,
    int maxAttempts,
    String negativeMarking,
    String difficulty,
  ) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.5,
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      children: [
        _buildInfoItem(theme, Icons.timer_outlined, 'Duration', duration),
        _buildInfoItem(theme, Icons.assignment_outlined, 'Questions', '$questionCount'),
        _buildInfoItem(theme, Icons.refresh_outlined, 'Attempts', '$attemptsUsed / $maxAttempts'),
        _buildInfoItem(theme, Icons.remove_circle_outline, 'Negative Marks', negativeMarking),
        _buildInfoItem(theme, Icons.trending_up, 'Difficulty', difficulty),
      ],
    );
  }

  Widget _buildInfoItem(ThemeData theme, IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
