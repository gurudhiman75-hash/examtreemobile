import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../exams/presentation/widgets/exam_card.dart';

import '../../profile/presentation/providers/analytics_providers.dart';
import '../../exams/presentation/providers/exam_providers.dart';
import '../../results/presentation/providers/result_providers.dart';
import '../../auth/presentation/providers/auth_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final analyticsAsync = ref.watch(userAnalyticsProvider);
    final inProgressAsync = ref.watch(inProgressExamsProvider);
    final availableAsync = ref.watch(availableExamsProvider);
    final resultsAsync = ref.watch(userResultsProvider);

    final isLoading = analyticsAsync.isLoading ||
        inProgressAsync.isLoading ||
        availableAsync.isLoading ||
        resultsAsync.isLoading;

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final hasError = analyticsAsync.hasError ||
        inProgressAsync.hasError ||
        availableAsync.hasError ||
        resultsAsync.hasError;

    if (hasError) {
      return const Scaffold(body: Center(child: Text('Error loading data')));
    }

    final analytics = analyticsAsync.value;
    final inProgressExams = inProgressAsync.value ?? [];
    final availableExams = availableAsync.value ?? [];
    final results = resultsAsync.value ?? [];

    final authState = ref.watch(authStateChangesProvider);
    final user = authState.value;
    final userName = user?.displayName ?? user?.email?.split('@')[0] ?? 'Student';

    final totalTestsTaken = analytics?.totalTestsAttempted ?? 0;
    final averageScore = analytics?.averageScore.toInt() ?? 0;
    final accuracy = analytics?.averageAccuracy ?? 0.0;

    final recentResult = results.isNotEmpty ? results.first : null;
    final resumeTest = inProgressExams.isNotEmpty ? inProgressExams.first : null;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGreetingHeader(theme, userName),
                    const SizedBox(height: AppSpacing.lg),
                    
                    if (resumeTest != null) ...[
                      _buildSectionTitle(theme, 'Continue Learning'),
                      ExamCard(
                        title: resumeTest.title,
                        subject: resumeTest.category,
                        duration: '${resumeTest.durationInSeconds ~/ 60} mins',
                        totalQuestions: resumeTest.totalQuestions,
                        status: 'In Progress',
                        onTap: () => context.push('/test-attempt', extra: resumeTest.id),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],

                    _buildSectionTitle(theme, 'Performance Snapshot'),
                    _buildPerformanceSnapshot(theme, totalTestsTaken, averageScore, accuracy),
                    const SizedBox(height: AppSpacing.lg),
                    
                    if (recentResult != null) ...[
                      _buildSectionTitle(theme, 'Recent Result'),
                      _buildRecentResultCard(theme, recentResult),
                      const SizedBox(height: AppSpacing.lg),
                    ],

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionTitle(theme, 'Available Tests'),
                        TextButton(
                          onPressed: () => context.go('/exams'),
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    ...availableExams.take(2).map((test) => ExamCard(
                          title: test.title,
                          subject: test.category,
                          duration: '${test.durationInSeconds ~/ 60} mins',
                          totalQuestions: test.totalQuestions,
                          status: 'Available',
                          onTap: () => context.push('/exam-details', extra: test.id),
                        )),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGreetingHeader(ThemeData theme, String name) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, $name ðŸ‘‹',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              "Let's ace your exams today!",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        CircleAvatar(
          radius: 24,
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(Icons.person, color: theme.colorScheme.onPrimaryContainer),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPerformanceSnapshot(ThemeData theme, int testsTaken, int avgScore, double accuracy) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSnapshotItem(theme, Icons.assignment_turned_in, '$testsTaken', 'Tests Taken'),
            Container(width: 1, height: 40, color: theme.colorScheme.outlineVariant),
            _buildSnapshotItem(theme, Icons.star, '$avgScore%', 'Avg Score'),
            Container(width: 1, height: 40, color: theme.colorScheme.outlineVariant),
            _buildSnapshotItem(theme, Icons.track_changes, '$accuracy%', 'Accuracy'),
          ],
        ),
      ),
    );
  }

  Widget _buildSnapshotItem(ThemeData theme, IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 24),
        const SizedBox(height: AppSpacing.xs),
        Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: theme.textTheme.labelSmall),
      ],
    );
  }

  // Changed to accept a generic object or map, we'll just use dynamic for ease, but map is fine
  // or use the actual Result model.
  Widget _buildRecentResultCard(ThemeData theme, dynamic result) {
    // result is of type Result
    return Card(
      elevation: 0,
      color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        side: BorderSide(color: theme.colorScheme.secondaryContainer),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.emoji_events, color: theme.colorScheme.onSecondary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Exam ${result.examId}', // Need exam details ideally, but examId for now
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Taken ${result.calculatedAt.toString().split(' ')[0]}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${result.score}%',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  Text('Score', style: theme.textTheme.labelSmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

