import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class TestAttemptStage extends StatelessWidget {
  const TestAttemptStage({
    required this.examTitle,
    required this.questionNumber,
    required this.totalQuestions,
    required this.timeLabel,
    required this.timerBackground,
    required this.timerForeground,
    required this.syncing,
    required this.syncFailed,
    required this.onRetrySync,
    required this.onExit,
    required this.topBanners,
    required this.questionText,
    required this.options,
    required this.selectedIndex,
    required this.locked,
    required this.markedForReview,
    required this.onSelect,
    required this.onPrevious,
    required this.onClear,
    required this.onMarkReview,
    required this.onSaveNext,
    required this.saveNextLabel,
    required this.paletteLabel,
    required this.onPalette,
    required this.submitLabel,
    required this.onSubmit,
    super.key,
  });

  final String examTitle;
  final int questionNumber;
  final int totalQuestions;
  final String timeLabel;
  final Color timerBackground;
  final Color timerForeground;
  final bool syncing;
  final bool syncFailed;
  final VoidCallback? onRetrySync;
  final VoidCallback? onExit;
  final List<Widget> topBanners;
  final String questionText;
  final List<String> options;
  final int? selectedIndex;
  final bool locked;
  final bool markedForReview;
  final ValueChanged<int>? onSelect;
  final VoidCallback? onPrevious;
  final VoidCallback? onClear;
  final VoidCallback? onMarkReview;
  final VoidCallback? onSaveNext;
  final String saveNextLabel;
  final String paletteLabel;
  final VoidCallback? onPalette;
  final String submitLabel;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = totalQuestions <= 0
        ? 0.0
        : (questionNumber / totalQuestions).clamp(0.0, 1.0);

    return Scaffold(
      key: const Key('test-attempt-stage'),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: AppSpacing.md,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              examTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Question $questionNumber of $totalQuestions',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            key: const Key('test-attempt-timer'),
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: timerBackground,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.timer_outlined, size: 16, color: timerForeground),
                const SizedBox(width: 5),
                Text(
                  timeLabel,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: timerForeground,
                    fontWeight: FontWeight.w900,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: syncFailed
                ? 'Progress not saved. Retry.'
                : syncing
                    ? 'Saving progress'
                    : 'Progress saved',
            onPressed: syncFailed ? onRetrySync : null,
            icon: syncing
                ? const SizedBox.square(
                    dimension: 19,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    syncFailed
                        ? Icons.cloud_off_outlined
                        : Icons.cloud_done_outlined,
                  ),
          ),
          IconButton(
            tooltip: 'Save and exit',
            onPressed: onExit,
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          ...topBanners,
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.xs,
              AppSpacing.md,
              0,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                key: const Key('test-attempt-progress'),
                value: progress,
                minHeight: 5,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              key: const Key('test-attempt-question-scroll'),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.xl,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: [
                          _QuestionBadge(
                            icon: Icons.quiz_outlined,
                            label: 'Question $questionNumber',
                          ),
                          if (markedForReview)
                            const _QuestionBadge(
                              icon: Icons.bookmark_rounded,
                              label: 'Marked for review',
                              emphasized: true,
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        questionText,
                        key: const Key('test-attempt-question'),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1.42,
                          letterSpacing: -0.18,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      for (var index = 0; index < options.length; index++) ...[
                        _AttemptOption(
                          index: index,
                          text: options[index],
                          selected: selectedIndex == index,
                          enabled: !locked && onSelect != null,
                          onTap: onSelect == null ? null : () => onSelect!(index),
                        ),
                        if (index != options.length - 1)
                          const SizedBox(height: AppSpacing.sm),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _AttemptActions(
        onPrevious: onPrevious,
        onClear: onClear,
        onMarkReview: onMarkReview,
        onSaveNext: onSaveNext,
        saveNextLabel: saveNextLabel,
        paletteLabel: paletteLabel,
        onPalette: onPalette,
        submitLabel: submitLabel,
        onSubmit: onSubmit,
        locked: locked,
      ),
    );
  }
}

class _QuestionBadge extends StatelessWidget {
  const _QuestionBadge({
    required this.icon,
    required this.label,
    this.emphasized = false,
  });

  final IconData icon;
  final String label;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = emphasized
        ? AppColors.amberContainer
        : theme.colorScheme.surfaceContainerLow;
    final foreground = emphasized
        ? AppColors.onAmberContainer
        : theme.colorScheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: foreground),
          const SizedBox(width: 5),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttemptOption extends StatelessWidget {
  const _AttemptOption({
    required this.index,
    required this.text,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final int index;
  final String text;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = selected
        ? AppColors.onPrimaryContainer
        : theme.colorScheme.onSurface;
    final background = selected
        ? AppColors.primaryContainer
        : theme.colorScheme.surfaceContainerLowest;

    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      label: 'Option ${String.fromCharCode(65 + index)}: $text',
      child: Material(
        key: Key('test-attempt-option-$index'),
        color: background,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 15,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 130),
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary
                        : theme.colorScheme.surfaceContainerLow,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    String.fromCharCode(65 + index),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: selected
                          ? AppColors.onPrimary
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      text,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: foreground,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        height: 1.42,
                      ),
                    ),
                  ),
                ),
                if (selected) ...[
                  const SizedBox(width: AppSpacing.sm),
                  const Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AttemptActions extends StatelessWidget {
  const _AttemptActions({
    required this.onPrevious,
    required this.onClear,
    required this.onMarkReview,
    required this.onSaveNext,
    required this.saveNextLabel,
    required this.paletteLabel,
    required this.onPalette,
    required this.submitLabel,
    required this.onSubmit,
    required this.locked,
  });

  final VoidCallback? onPrevious;
  final VoidCallback? onClear;
  final VoidCallback? onMarkReview;
  final VoidCallback? onSaveNext;
  final String saveNextLabel;
  final String paletteLabel;
  final VoidCallback? onPalette;
  final String submitLabel;
  final VoidCallback? onSubmit;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textScale = MediaQuery.textScalerOf(context).scale(1);

    final previous = TextButton.icon(
      key: const Key('test-attempt-previous'),
      onPressed: locked ? null : onPrevious,
      icon: const Icon(Icons.arrow_back_rounded, size: 19),
      label: const Text('Previous'),
    );
    final clear = TextButton.icon(
      key: const Key('test-attempt-clear'),
      onPressed: locked ? null : onClear,
      icon: const Icon(Icons.backspace_outlined, size: 18),
      label: const Text('Clear'),
    );
    final review = TextButton.icon(
      key: const Key('test-attempt-review'),
      onPressed: locked ? null : onMarkReview,
      icon: const Icon(Icons.bookmark_border_rounded, size: 19),
      label: const Text('Review'),
    );

    return Material(
      color: theme.colorScheme.surfaceContainerLowest,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton.icon(
                key: const Key('test-attempt-save-next'),
                onPressed: locked ? null : onSaveNext,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                icon: const Icon(Icons.arrow_forward_rounded),
                label: Text(saveNextLabel),
              ),
              const SizedBox(height: 2),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: AppSpacing.xs,
                runSpacing: 0,
                children: [previous, clear, review],
              ),
              const Divider(height: AppSpacing.md),
              if (textScale >= 1.5) ...[
                OutlinedButton.icon(
                  key: const Key('test-attempt-palette'),
                  onPressed: locked ? null : onPalette,
                  icon: const Icon(Icons.grid_view_rounded),
                  label: Text(paletteLabel),
                ),
                const SizedBox(height: AppSpacing.xs),
                FilledButton.tonalIcon(
                  key: const Key('test-attempt-submit'),
                  onPressed: locked ? null : onSubmit,
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: Text(submitLabel),
                ),
              ] else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        key: const Key('test-attempt-palette'),
                        onPressed: locked ? null : onPalette,
                        icon: const Icon(Icons.grid_view_rounded),
                        label: Text(paletteLabel),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: FilledButton.tonalIcon(
                        key: const Key('test-attempt-submit'),
                        onPressed: locked ? null : onSubmit,
                        icon: const Icon(Icons.check_circle_outline_rounded),
                        label: Text(submitLabel),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
