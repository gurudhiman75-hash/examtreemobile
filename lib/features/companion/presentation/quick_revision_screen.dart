import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../domain/daily_companion.dart';
import 'providers/daily_companion_providers.dart';

class QuickRevisionScreen extends ConsumerStatefulWidget {
  const QuickRevisionScreen({super.key, required this.minutes});

  final int minutes;

  @override
  ConsumerState<QuickRevisionScreen> createState() =>
      _QuickRevisionScreenState();
}

class _QuickRevisionScreenState extends ConsumerState<QuickRevisionScreen> {
  List<RevisionItem>? _items;
  int _index = 0;
  bool _revealed = false;
  bool _saving = false;
  bool _done = false;

  Future<void> _record(RevisionItem item, bool remembered) async {
    final user = ref.read(authStateChangesProvider).value;
    if (user == null || _saving) return;
    setState(() => _saving = true);
    try {
      await ref.read(dailyCompanionControllerProvider).recordOutcome(
            userId: user.uid,
            item: item,
            remembered: remembered,
            reviewedAt: DateTime.now(),
          );
      if (!mounted) return;
      setState(() {
        _saving = false;
        _revealed = false;
        if (_items == null || _index + 1 >= _items!.length) {
          _done = true;
        } else {
          _index++;
        }
      });
      ref.invalidate(dailyCompanionSnapshotProvider);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to save this review.')),
      );
    }
  }

  void _finish(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/daily');
    }
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(dailyCompanionSnapshotProvider);

    return Scaffold(
      appBar: AppBar(title: Text('${widget.minutes}-minute revision')),
      body: snapshot.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _RevisionErrorState(
          onRetry: () => ref.invalidate(dailyCompanionSnapshotProvider),
        ),
        data: (data) {
          _items ??= selectQuickRevisionItems(
            data.items,
            minutes: widget.minutes,
            now: DateTime.now(),
          );

          if (_done || _items!.isEmpty) {
            return _SessionCompleteState(
              empty: _items!.isEmpty,
              onDone: () => _finish(context),
            );
          }

          final item = _items![_index];
          return _RevisionSessionBody(
            minutes: widget.minutes,
            item: item,
            index: _index,
            total: _items!.length,
            revealed: _revealed,
            saving: _saving,
            onReveal: () => setState(() => _revealed = true),
            onReviewAgain: () => _record(item, false),
            onRemembered: () => _record(item, true),
          );
        },
      ),
    );
  }
}

class _RevisionErrorState extends StatelessWidget {
  const _RevisionErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 52,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Revision queue unavailable',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Try loading your saved revision questions again.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionCompleteState extends StatelessWidget {
  const _SessionCompleteState({required this.empty, required this.onDone});

  final bool empty;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.successContainer,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              child: const Icon(
                Icons.task_alt_rounded,
                size: 34,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              empty ? 'You’re caught up' : 'Revision complete',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              empty
                  ? 'No saved questions are due for review right now.'
                  : 'Your review choices have been saved to the local revision plan.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              key: const Key('quick-revision-done'),
              onPressed: onDone,
              icon: const Icon(Icons.done_rounded),
              label: Text(empty ? 'Nothing due — Done' : 'Session complete'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RevisionSessionBody extends StatelessWidget {
  const _RevisionSessionBody({
    required this.minutes,
    required this.item,
    required this.index,
    required this.total,
    required this.revealed,
    required this.saving,
    required this.onReveal,
    required this.onReviewAgain,
    required this.onRemembered,
  });

  final int minutes;
  final RevisionItem item;
  final int index;
  final int total;
  final bool revealed;
  final bool saving;
  final VoidCallback onReveal;
  final VoidCallback onReviewAgain;
  final VoidCallback onRemembered;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      key: const Key('quick-revision-scroll'),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xxl,
      ),
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: [
            Text(
              'Question ${index + 1} of $total',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              '$minutes min session',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Semantics(
          label: 'Revision progress: ${index + 1} of $total',
          child: LinearProgressIndicator(
            value: (index + 1) / total,
            minHeight: 7,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            if (item.testName.trim().isNotEmpty)
              _MetaTag(label: item.testName, icon: Icons.assignment_outlined),
            if (item.section.trim().isNotEmpty)
              _MetaTag(label: item.section, icon: Icons.folder_outlined),
            for (final reason in item.reasons)
              _ReasonTag(reason: reason),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          item.questionText,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            height: 1.4,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        ...List.generate(
          item.options.length,
          (optionIndex) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _RevisionOption(
              item: item,
              optionIndex: optionIndex,
              revealed: revealed,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (!revealed)
          FilledButton.icon(
            key: const Key('quick-revision-show-answer'),
            onPressed: onReveal,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            icon: const Icon(Icons.visibility_outlined),
            label: const Text('Show answer'),
          )
        else ...[
          _ExplanationCard(explanation: item.explanation),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'How well did you remember this?',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Choose “Got it” if you could explain the answer now. Choose “Review again” to bring it back sooner.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          if (saving) ...[
            const SizedBox(height: AppSpacing.md),
            const LinearProgressIndicator(),
          ],
          const SizedBox(height: AppSpacing.md),
          _OutcomeActions(
            saving: saving,
            onReviewAgain: onReviewAgain,
            onRemembered: onRemembered,
          ),
        ],
      ],
    );
  }
}

class _MetaTag extends StatelessWidget {
  const _MetaTag({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      constraints: const BoxConstraints(maxWidth: 240),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReasonTag extends StatelessWidget {
  const _ReasonTag({required this.reason});

  final RevisionReason reason;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Text(
        reason.label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onTertiaryContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _RevisionOption extends StatelessWidget {
  const _RevisionOption({
    required this.item,
    required this.optionIndex,
    required this.revealed,
  });

  final RevisionItem item;
  final int optionIndex;
  final bool revealed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final correct = revealed && optionIndex == item.correctIndex;
    final learnerChoice = revealed && optionIndex == item.selectedIndex;
    final wrongChoice = learnerChoice && !correct;

    final background = correct
        ? AppColors.successContainer
        : wrongChoice
            ? theme.colorScheme.errorContainer
            : theme.colorScheme.surfaceContainerLowest;
    final border = correct
        ? AppColors.success
        : wrongChoice
            ? theme.colorScheme.error
            : theme.colorScheme.outlineVariant;
    final foreground = correct
        ? AppColors.onSuccessContainer
        : wrongChoice
            ? theme.colorScheme.onErrorContainer
            : theme.colorScheme.onSurface;

    String? annotation;
    IconData? statusIcon;
    if (correct) {
      annotation = learnerChoice ? 'Your answer · Correct' : 'Correct answer';
      statusIcon = Icons.check_circle_rounded;
    } else if (wrongChoice) {
      annotation = 'Your answer';
      statusIcon = Icons.cancel_rounded;
    }

    return Container(
      key: Key('quick-revision-option-$optionIndex'),
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: border, width: correct || wrongChoice ? 2 : 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: foreground.withValues(alpha: 0.08),
            ),
            child: Text(
              String.fromCharCode(65 + optionIndex),
              style: theme.textTheme.labelLarge?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.options[optionIndex],
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: foreground,
                    fontWeight: correct || wrongChoice
                        ? FontWeight.w600
                        : FontWeight.normal,
                    height: 1.4,
                  ),
                ),
                if (annotation != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    annotation,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (statusIcon != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Icon(statusIcon, color: foreground),
          ],
        ],
      ),
    );
  }
}

class _ExplanationCard extends StatelessWidget {
  const _ExplanationCard({required this.explanation});

  final String explanation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      key: const Key('quick-revision-explanation'),
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Explanation',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            explanation.trim().isEmpty
                ? 'No explanation was stored with this result.'
                : explanation,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
          ),
        ],
      ),
    );
  }
}

class _OutcomeActions extends StatelessWidget {
  const _OutcomeActions({
    required this.saving,
    required this.onReviewAgain,
    required this.onRemembered,
  });

  final bool saving;
  final VoidCallback onReviewAgain;
  final VoidCallback onRemembered;

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);

    final reviewAgain = OutlinedButton.icon(
      key: const Key('quick-revision-review-again'),
      onPressed: saving ? null : onReviewAgain,
      icon: const Icon(Icons.replay_rounded),
      label: const Text('Review again'),
    );
    final remembered = FilledButton.icon(
      key: const Key('quick-revision-got-it'),
      onPressed: saving ? null : onRemembered,
      icon: const Icon(Icons.check_rounded),
      label: const Text('Got it'),
    );

    if (textScale >= 1.5) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          remembered,
          const SizedBox(height: AppSpacing.sm),
          reviewAgain,
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: reviewAgain),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: remembered),
      ],
    );
  }
}
