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

bool useCompactReviewLearningAction(double textScale) => textScale >= 1.5;

double reviewLearningBottomOffset({
  required double textScale,
  required double safeBottom,
}) {
  return safeBottom + (useCompactReviewLearningAction(textScale) ? 156 : 88);
}

class ReviewRetryScreen extends ConsumerWidget {
  const ReviewRetryScreen({super.key, required this.resultId});

  final String resultId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultAsync = ref.watch(resultProvider(resultId));
    final result = resultAsync.value;
    final showRevisionAction = shouldOfferRevisionAction(result);
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final compactAction = useCompactReviewLearningAction(textScale);

    return Stack(
      fit: StackFit.expand,
      children: [
        ReviewScreen(resultId: resultId),
        if (showRevisionAction)
          Positioned(
            right: AppSpacing.md,
            bottom: reviewLearningBottomOffset(
              textScale: textScale,
              safeBottom: MediaQuery.paddingOf(context).bottom,
            ),
            child: Semantics(
              button: true,
              label: 'Start a 5-minute revision session from saved mistakes',
              child: compactAction
                  ? FloatingActionButton.small(
                      heroTag: 'review-revise-$resultId',
                      tooltip: 'Revise mistakes',
                      onPressed: () =>
                          context.push('/quick-revision?minutes=5'),
                      child: const Icon(Icons.auto_awesome_rounded),
                    )
                  : FloatingActionButton.extended(
                      heroTag: 'review-revise-$resultId',
                      tooltip: 'Revise mistakes',
                      onPressed: () =>
                          context.push('/quick-revision?minutes=5'),
                      icon: const Icon(Icons.auto_awesome_rounded),
                      label: const Text('Revise mistakes'),
                    ),
            ),
          ),
      ],
    );
  }
}
