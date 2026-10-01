import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/result_model.dart';
import '../../../core/theme/app_spacing.dart';
import '../../companion/domain/daily_companion.dart';
import 'providers/result_providers.dart';
import 'review_screen.dart';

bool shouldOfferRevisionAction(Result? result) {
  if (result == null || result.questionReview.isEmpty) return false;
  return deriveRevisionCandidates(
    [result],
    now: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
  ).isNotEmpty;
}

bool shouldStackReviewLearningFooter({
  required double width,
  required double textScale,
}) =>
    width < 330 || textScale > 1.5;

class ReviewRetryScreen extends ConsumerWidget {
  const ReviewRetryScreen({super.key, required this.resultId});

  final String resultId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(resultProvider(resultId)).value;
    final showRevisionAction = shouldOfferRevisionAction(result);

    return Column(
      children: [
        Expanded(child: ReviewScreen(resultId: resultId)),
        if (showRevisionAction)
          _ReviewLearningFooter(
            onStart: () => context.replace('/quick-revision?minutes=5'),
          ),
      ],
    );
  }
}

class _ReviewLearningFooter extends StatelessWidget {
  const _ReviewLearningFooter({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.white,
      shadowColor: const Color(0xFF10264A).withValues(alpha: .08),
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.xs,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            border: const Border(
              top: BorderSide(color: Color(0xFFE3E9F1)),
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final textScale = MediaQuery.textScalerOf(context).scale(1);
              final stack = shouldStackReviewLearningFooter(
                width: constraints.maxWidth,
                textScale: textScale,
              );
              final copy = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF4D6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      size: 19,
                      color: const Color(0xFFB2770D),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Revision ready',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: const Color(0xFF10264A),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'Revisit mistakes for 5 minutes.',
                          maxLines: stack ? 2 : 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF718096),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
              final start = FilledButton.icon(
                key: const Key('review-start-revision'),
                onPressed: onStart,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 44),
                  backgroundColor: const Color(0xFF073A6A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.w900),
                ),
                iconAlignment: IconAlignment.end,
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: const Text('Start 5 min'),
              );

              if (stack) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    copy,
                    const SizedBox(height: AppSpacing.xs),
                    start,
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: copy),
                  const SizedBox(width: AppSpacing.sm),
                  start,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
