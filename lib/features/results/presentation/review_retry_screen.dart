import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/result_model.dart';
import '../../../core/theme/app_spacing.dart';
import 'providers/result_providers.dart';
import 'review_screen.dart';

String? retryExamId(Result? result) {
  final examId = result?.examId.trim() ?? '';
  return examId.isEmpty ? null : examId;
}

bool useCompactReviewRetryAction(double textScale) => textScale >= 1.5;

double reviewRetryBottomOffset({
  required double textScale,
  required double safeBottom,
}) {
  return safeBottom + (useCompactReviewRetryAction(textScale) ? 156 : 88);
}

class ReviewRetryScreen extends ConsumerWidget {
  const ReviewRetryScreen({super.key, required this.resultId});

  final String resultId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultAsync = ref.watch(resultProvider(resultId));
    final result = resultAsync.value;
    final examId = retryExamId(result);
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final compactRetry = useCompactReviewRetryAction(textScale);

    return Stack(
      fit: StackFit.expand,
      children: [
        ReviewScreen(resultId: resultId),
        if (examId != null)
          Positioned(
            right: AppSpacing.md,
            bottom: reviewRetryBottomOffset(
              textScale: textScale,
              safeBottom: MediaQuery.paddingOf(context).bottom,
            ),
            child: Semantics(
              button: true,
              label: result?.testName.trim().isNotEmpty == true
                  ? 'Retry ${result!.testName}'
                  : 'Retry this test',
              child: compactRetry
                  ? FloatingActionButton.small(
                      heroTag: 'review-retry-$resultId',
                      tooltip: 'Retry test',
                      onPressed: () =>
                          context.push('/exam-details', extra: examId),
                      child: const Icon(Icons.replay_rounded),
                    )
                  : FloatingActionButton.extended(
                      heroTag: 'review-retry-$resultId',
                      tooltip: 'Retry test',
                      onPressed: () =>
                          context.push('/exam-details', extra: examId),
                      icon: const Icon(Icons.replay_rounded),
                      label: const Text('Retry test'),
                    ),
            ),
          ),
      ],
    );
  }
}
