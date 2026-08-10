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

class ReviewRetryScreen extends ConsumerWidget {
  const ReviewRetryScreen({super.key, required this.resultId});

  final String resultId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultAsync = ref.watch(resultProvider(resultId));
    final result = resultAsync.value;
    final examId = retryExamId(result);

    return Stack(
      fit: StackFit.expand,
      children: [
        ReviewScreen(resultId: resultId),
        if (examId != null)
          Positioned(
            right: AppSpacing.md,
            bottom: MediaQuery.paddingOf(context).bottom + 88,
            child: Semantics(
              button: true,
              label: result?.testName.trim().isNotEmpty == true
                  ? 'Retry ${result!.testName}'
                  : 'Retry this test',
              child: FloatingActionButton.extended(
                heroTag: 'review-retry-$resultId',
                onPressed: () => context.push('/exam-details', extra: examId),
                icon: const Icon(Icons.replay_rounded),
                label: const Text('Retry test'),
              ),
            ),
          ),
      ],
    );
  }
}
