import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/primary_button.dart';
import 'providers/result_providers.dart';

class ResultsScreen extends ConsumerWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final resultsAsync = ref.watch(userResultsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Results & Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: resultsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (results) {
          if (results.isEmpty) {
            return const Center(child: Text('No results available'));
          }

          final result = results.first;

          final examTitle = 'Exam ${result.examId}'; // Mocking title since we only have examId
          final score = result.score.toInt();
          final maxScore = result.maxScore.toInt();
          final rank = result.rank ?? 0;
          const totalStudents = 1000;
          final percentile = result.percentile ?? 0.0;
          final accuracy = result.accuracy;

          final correct = result.correctCount;
          final incorrect = result.incorrectCount;
          final unattempted = result.skippedCount;

          const strongestArea = 'Calculus & Integration';
          const weakestArea = 'Complex Probability';

          final subjectAnalysis = [
            {'name': 'Algebra', 'score': 90.0, 'color': Colors.blue},
            {'name': 'Geometry', 'score': 75.0, 'color': Colors.orange},
            {'name': 'Calculus', 'score': 95.0, 'color': Colors.green},
          ];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  examTitle,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildScoreCard(theme, score, maxScore),
                const SizedBox(height: AppSpacing.lg),
                _buildPerformanceGrid(theme, rank, totalStudents, percentile, accuracy),
                const SizedBox(height: AppSpacing.lg),
                _buildAttemptSummary(theme, correct, incorrect, unattempted),
                const SizedBox(height: AppSpacing.lg),
                _buildInsights(theme, strongestArea, weakestArea),
                const SizedBox(height: AppSpacing.lg),
                _buildSubjectAnalysis(theme, subjectAnalysis),
                const SizedBox(height: AppSpacing.xxl),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          context.push('/review', extra: result.attemptId);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                        ),
                        child: const Text('Review Questions'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: PrimaryButton(
                        text: 'Retake Test',
                        onPressed: () {
                          context.push('/test-attempt', extra: result.examId);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildScoreCard(ThemeData theme, int score, int maxScore) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        children: [
          Text(
            'Your Score',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$score',
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              Text(
                ' / $maxScore',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceGrid(ThemeData theme, int rank, int total, double percentile, double accuracy) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSpacing.sm,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(theme, 'Rank', '$rank', subtitle: '/$total', icon: Icons.emoji_events, iconColor: Colors.amber),
        _buildStatCard(theme, 'Percentile', '$percentile%', icon: Icons.show_chart, iconColor: Colors.blue),
        _buildStatCard(theme, 'Accuracy', '$accuracy%', icon: Icons.track_changes, iconColor: Colors.green),
      ],
    );
  }

  Widget _buildStatCard(ThemeData theme, String title, String value, {String? subtitle, required IconData icon, required Color iconColor}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: iconColor),
            const SizedBox(height: AppSpacing.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: theme.textTheme.labelSmall,
                  ),
              ],
            ),
            Text(title, style: theme.textTheme.labelSmall),
          ],
        ),
      ),
    );
  }

  Widget _buildAttemptSummary(ThemeData theme, int correct, int incorrect, int unattempted) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Attempt Summary', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAttemptBadge(theme, 'Correct', correct, Colors.green),
                _buildAttemptBadge(theme, 'Incorrect', incorrect, Colors.red),
                _buildAttemptBadge(theme, 'Skipped', unattempted, Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttemptBadge(ThemeData theme, String label, int count, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Text(
            '$count',
            style: theme.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(label, style: theme.textTheme.labelSmall),
      ],
    );
  }

  Widget _buildInsights(ThemeData theme, String strongest, String weakest) {
    return Row(
      children: [
        Expanded(
          child: _buildInsightCard(theme, 'Strongest Area', strongest, Icons.arrow_upward, Colors.green),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _buildInsightCard(theme, 'Weakest Area', weakest, Icons.arrow_downward, Colors.red),
        ),
      ],
    );
  }

  Widget _buildInsightCard(ThemeData theme, String title, String area, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: AppSpacing.xs),
              Text(title, style: theme.textTheme.labelSmall?.copyWith(color: color)),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            area,
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectAnalysis(ThemeData theme, List<Map<String, dynamic>> subjects) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Topic Analysis', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.md),
            ...subjects.map((subject) {
              final name = subject['name'] as String;
              final score = subject['score'] as double;
              final color = subject['color'] as Color;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(name, style: theme.textTheme.bodyMedium),
                        Text('${score.toInt()}%', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    LinearProgressIndicator(
                      value: score / 100,
                      backgroundColor: color.withValues(alpha: 0.2),
                      color: color,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
