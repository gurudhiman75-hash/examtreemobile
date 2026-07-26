import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/result_model.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/primary_button.dart';
import 'providers/result_providers.dart';

class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key, required this.resultId});

  final String resultId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultAsync = ref.watch(resultProvider(resultId));

    return Scaffold(
      appBar: AppBar(title: const Text('Review Questions')),
      body: resultAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _ReviewLoadError(
          message: 'Unable to load this result.',
          onRetry: () => ref.invalidate(resultProvider(resultId)),
        ),
        data: (result) {
          if (result.questionReview.isEmpty) {
            return _ReviewLoadError(
              message: 'Question-level review is unavailable for this attempt.',
              onRetry: () => ref.invalidate(resultProvider(resultId)),
            );
          }
          return _ReviewScreenBody(result: result);
        },
      ),
    );
  }
}

class _ReviewLoadError extends StatelessWidget {
  const _ReviewLoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.fact_check_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewScreenBody extends StatefulWidget {
  const _ReviewScreenBody({required this.result});

  final Result result;

  @override
  State<_ReviewScreenBody> createState() => _ReviewScreenBodyState();
}

class _ReviewScreenBodyState extends State<_ReviewScreenBody> {
  int _currentIndex = 0;

  List<ResultQuestionReview> get _questions => widget.result.questionReview;

  void _next() {
    if (_currentIndex >= _questions.length - 1) return;
    setState(() => _currentIndex++);
  }

  void _previous() {
    if (_currentIndex <= 0) return;
    setState(() => _currentIndex--);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final question = _questions[_currentIndex];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Question ${_currentIndex + 1} of ${_questions.length}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _StatusBadge(question: question),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              LinearProgressIndicator(
                value: (_currentIndex + 1) / _questions.length,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    _MetaChip(
                      icon: Icons.folder_outlined,
                      label: question.section,
                    ),
                    if (question.flagged)
                      const _MetaChip(
                        icon: Icons.flag_outlined,
                        label: 'Marked for review',
                      ),
                    if (question.timeTakenSeconds != null)
                      _MetaChip(
                        icon: Icons.timer_outlined,
                        label: _formatDuration(question.timeTakenSeconds!),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Q${_currentIndex + 1}. ${question.text}',
                  style: theme.textTheme.titleLarge?.copyWith(height: 1.35),
                ),
                const SizedBox(height: AppSpacing.xl),
                ...List.generate(
                  question.options.length,
                  (index) => _OptionReviewTile(
                    optionIndex: index,
                    question: question,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const Divider(),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Explanation',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.55,
                    ),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant,
                    ),
                  ),
                  child: Text(
                    question.explanation.trim().isEmpty
                        ? 'No explanation was stored for this question.'
                        : question.explanation,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.55),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
        const Divider(height: 1),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _currentIndex > 0 ? _previous : null,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                    ),
                    child: const Text('Previous'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: PrimaryButton(
                    text: _currentIndex < _questions.length - 1
                        ? 'Next'
                        : 'Finish',
                    onPressed: _currentIndex < _questions.length - 1
                        ? _next
                        : () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.question});

  final ResultQuestionReview question;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (label, color, icon) = switch ((question.isAnswered, question.isCorrect)) {
      (false, _) => ('Unanswered', theme.colorScheme.outline, Icons.remove_circle_outline),
      (true, true) => ('Correct', Colors.green, Icons.check_circle_outline),
      (true, false) => ('Incorrect', theme.colorScheme.error, Icons.cancel_outlined),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(label, style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _OptionReviewTile extends StatelessWidget {
  const _OptionReviewTile({
    required this.optionIndex,
    required this.question,
  });

  final int optionIndex;
  final ResultQuestionReview question;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCorrect = optionIndex == question.correct;
    final isSelected = optionIndex == question.selected;
    final optionKey = optionIndex < question.optionKeys.length
        ? question.optionKeys[optionIndex]
        : String.fromCharCode(65 + optionIndex);

    Color background = theme.colorScheme.surface;
    Color border = theme.colorScheme.outlineVariant;
    Color foreground = theme.colorScheme.onSurface;
    IconData? icon;
    String? annotation;

    if (isCorrect) {
      background = Colors.green.withValues(alpha: 0.1);
      border = Colors.green;
      foreground = Colors.green.shade800;
      icon = Icons.check_circle;
      annotation = isSelected ? 'Your answer · Correct' : 'Correct answer';
    } else if (isSelected) {
      background = theme.colorScheme.errorContainer.withValues(alpha: 0.55);
      border = theme.colorScheme.error;
      foreground = theme.colorScheme.error;
      icon = Icons.cancel;
      annotation = 'Your answer';
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: background,
        border: Border.all(
          color: border,
          width: isCorrect || isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: foreground.withValues(alpha: 0.1),
            ),
            child: Text(
              optionKey,
              style: theme.textTheme.labelLarge?.copyWith(
                color: foreground,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question.options[optionIndex],
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: foreground,
                    fontWeight: isCorrect || isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                if (annotation != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    annotation,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (icon != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Icon(icon, color: foreground),
          ],
        ],
      ),
    );
  }
}

String _formatDuration(int seconds) {
  final safeSeconds = seconds < 0 ? 0 : seconds;
  final minutes = safeSeconds ~/ 60;
  final remainder = safeSeconds % 60;
  if (minutes == 0) return '${remainder}s';
  return '${minutes}m ${remainder.toString().padLeft(2, '0')}s';
}
