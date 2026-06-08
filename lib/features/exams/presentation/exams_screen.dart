import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_spacing.dart';
import 'widgets/exam_card.dart';

class ExamsScreen extends ConsumerWidget {
  const ExamsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Mock Data
    final resumeTests = [
      {
        'title': 'Advanced Mathematics Level 2',
        'subject': 'Mathematics',
        'duration': '120 mins',
        'totalQuestions': 50,
        'status': 'In Progress',
      },
    ];

    final availableTests = [
      {
        'title': 'General Science Foundation',
        'subject': 'Science',
        'duration': '60 mins',
        'totalQuestions': 30,
        'status': 'Available',
      },
      {
        'title': 'History of the Modern World',
        'subject': 'History',
        'duration': '90 mins',
        'totalQuestions': 40,
        'status': 'Available',
      },
      {
        'title': 'Basic English Grammar & Vocabulary',
        'subject': 'English',
        'duration': '45 mins',
        'totalQuestions': 25,
        'status': 'Available',
      },
    ];

    final completedTests = [
      {
        'title': 'Introduction to Algebra',
        'subject': 'Mathematics',
        'duration': '60 mins',
        'totalQuestions': 30,
        'status': 'Completed',
        'score': 85,
      },
      {
        'title': 'Physics Mechanics Basics',
        'subject': 'Physics',
        'duration': '90 mins',
        'totalQuestions': 40,
        'status': 'Completed',
        'score': 92,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tests & Exams'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.md),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (resumeTests.isNotEmpty) ...[
                  _buildSectionTitle(theme, 'Resume Test'),
                  ...resumeTests.map((test) => ExamCard(
                        title: test['title'] as String,
                        subject: test['subject'] as String,
                        duration: test['duration'] as String,
                        totalQuestions: test['totalQuestions'] as int,
                        status: test['status'] as String,
                        onTap: () => context.push('/exam-details'),
                      )),
                  const SizedBox(height: AppSpacing.lg),
                ],
                _buildSectionTitle(theme, 'Available Tests'),
                ...availableTests.map((test) => ExamCard(
                      title: test['title'] as String,
                      subject: test['subject'] as String,
                      duration: test['duration'] as String,
                      totalQuestions: test['totalQuestions'] as int,
                      status: test['status'] as String,
                      onTap: () => context.push('/exam-details'),
                    )),
                const SizedBox(height: AppSpacing.lg),
                _buildSectionTitle(theme, 'Completed Tests'),
                ...completedTests.map((test) => ExamCard(
                      title: test['title'] as String,
                      subject: test['subject'] as String,
                      duration: test['duration'] as String,
                      totalQuestions: test['totalQuestions'] as int,
                      status: test['status'] as String,
                      score: test['score'] as int?,
                      onTap: () => context.push('/results'),
                    )),
                // Add some bottom padding for the scroll view
                const SizedBox(height: AppSpacing.xxl),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
