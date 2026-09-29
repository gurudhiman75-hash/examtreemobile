import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../data/polity_learn_catalog.dart';

class SubjectLearningSection extends StatelessWidget {
  const SubjectLearningSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subject = polityLearnSubject;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Study by subject', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Short exam-focused lessons with quick revision and practice mapping.',
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.sm),
        Card(
          margin: EdgeInsets.zero,
          child: InkWell(
            key: const Key('learn-subject-polity'),
            onTap: () => context.push('/learn-course?subject=POL'),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(Icons.account_balance_rounded, color: theme.colorScheme.onPrimaryContainer),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(subject.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '${subject.readyLessonCount} lessons ready · ${subject.lessons.length} mapped',
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}