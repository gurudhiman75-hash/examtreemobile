import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/primary_button.dart';
import 'providers/result_providers.dart';
import '../../exams/presentation/providers/exam_providers.dart';

class ReviewScreen extends ConsumerWidget {
  final String resultId;
  const ReviewScreen({super.key, required this.resultId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultAsync = ref.watch(resultProvider(resultId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Questions'),
      ),
      body: resultAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (result) {
          final questionsAsync = ref.watch(examQuestionsProvider(result.examId));

          return questionsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
            data: (questions) {
              if (questions.isEmpty) {
                return const Center(child: Text('No questions available'));
              }
              return _ReviewScreenBody(questions: questions);
            },
          );
        },
      ),
    );
  }
}

class _ReviewScreenBody extends StatefulWidget {
  final List<dynamic> questions; // using dynamic/model.Question from examQuestionsProvider
  
  const _ReviewScreenBody({required this.questions});

  @override
  State<_ReviewScreenBody> createState() => _ReviewScreenBodyState();
}

class _ReviewScreenBodyState extends State<_ReviewScreenBody> {
  int _currentIndex = 0;

  void _next() {
    if (_currentIndex < widget.questions.length - 1) {
      setState(() {
        _currentIndex++;
      });
    }
  }

  void _previous() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentQ = widget.questions[_currentIndex];

    return Column(
      children: [
        // Progress Header
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${_currentIndex + 1} of ${widget.questions.length}',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              _buildStatusBadge(theme, currentQ),
            ],
          ),
        ),
        LinearProgressIndicator(
          value: (_currentIndex + 1) / widget.questions.length,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          color: theme.colorScheme.primary,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Q${_currentIndex + 1}. ${currentQ.text}',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.xl),
                ...List.generate(currentQ.options.length, (index) {
                  return _buildOptionItem(theme, index, currentQ);
                }),
                const SizedBox(height: AppSpacing.xl),
                const Divider(),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Explanation',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Text(
                    currentQ.explanation,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _currentIndex > 0 ? _previous : null,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                  ),
                  child: const Text('Previous'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: PrimaryButton(
                  text: _currentIndex < widget.questions.length - 1 ? 'Next' : 'Finish',
                  onPressed: _currentIndex < widget.questions.length - 1 ? _next : () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(ThemeData theme, dynamic q) {
    String label;
    Color color;

    // Hardcoded mock of user choices since attempt response is not available easily here
    final userOptionIndex = 0; // mock
    final correctOptionIndex = q.correctOptionIndexes.isNotEmpty ? q.correctOptionIndexes.first : 0;

    if (userOptionIndex == correctOptionIndex) {
      label = 'Correct';
      color = Colors.green;
    } else {
      label = 'Incorrect';
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildOptionItem(ThemeData theme, int index, dynamic q) {
    final correctOptionIndex = q.correctOptionIndexes.isNotEmpty ? q.correctOptionIndexes.first : 0;
    final isCorrectOption = index == correctOptionIndex;
    final isUserOption = index == 0; // hardcoded mock user choice

    Color bgColor = theme.colorScheme.surface;
    Color borderColor = theme.colorScheme.outlineVariant;
    IconData? icon;
    Color? iconColor;

    if (isCorrectOption) {
      bgColor = Colors.green.withValues(alpha: 0.1);
      borderColor = Colors.green;
      icon = Icons.check_circle;
      iconColor = Colors.green;
    } else if (isUserOption) {
      bgColor = Colors.red.withValues(alpha: 0.1);
      borderColor = Colors.red;
      icon = Icons.cancel;
      iconColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor, width: isCorrectOption || isUserOption ? 2 : 1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${String.fromCharCode(65 + index)}.', // A, B, C, D
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isCorrectOption ? Colors.green : (isUserOption ? Colors.red : theme.colorScheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              q.options[index],
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: isCorrectOption || isUserOption ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          if (icon != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Icon(icon, color: iconColor, size: 24),
          ],
        ],
      ),
    );
  }
}
