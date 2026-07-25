import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import 'providers/exam_providers.dart';
import 'widgets/exam_card.dart';

class ExamsScreen extends ConsumerWidget {
  const ExamsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final availableAsync = ref.watch(availableExamsProvider);
    final inProgressAsync = ref.watch(inProgressExamsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tests & Exams')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(availableExamsProvider);
          ref.invalidate(inProgressExamsProvider);
        },
        child: availableAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Text('Could not load exams: $error'),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: () => ref.invalidate(availableExamsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
          data: (availableTests) {
            final inProgressTests = inProgressAsync.value ?? const [];
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      if (inProgressTests.isNotEmpty) ...[
                        _buildSectionTitle(theme, 'Resume Test'),
                        ...inProgressTests.map(
                          (test) => ExamCard(
                            title: test.title,
                            subject: test.category,
                            duration: '${test.durationInSeconds ~/ 60} mins',
                            totalQuestions: test.totalQuestions,
                            status: 'In Progress',
                            onTap: () => context.push('/test-attempt', extra: test.id),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                      _buildSectionTitle(theme, 'Available Tests'),
                      if (availableTests.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                          child: Text('No exams are available right now.'),
                        )
                      else
                        ...availableTests.map(
                          (test) => ExamCard(
                            title: test.title,
                            subject: test.category,
                            duration: '${test.durationInSeconds ~/ 60} mins',
                            totalQuestions: test.totalQuestions,
                            status: test.status == 'paid' ? 'Paid' : 'Available',
                            onTap: () => context.push('/exam-details', extra: test.id),
                          ),
                        ),
                      const SizedBox(height: AppSpacing.xxl),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}
