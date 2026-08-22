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
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.cloud_off_outlined,
                size: 30,
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Revision queue unavailable',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Try loading your saved revision questions again.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
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
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.successContainer,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(20),
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
                  color: AppColors.onSuccessContainer,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                empty
                    ? 'No saved questions are due for review right now.'
                    : 'Your review choices have been saved to the local revision plan.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSuccessContainer,
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
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xxl,
      ),
      children: [
        _SessionHeader(
          minutes: minutes,
          index: index,
          total: total,
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
          'Review the question',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          item.questionText,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            height: 1.38,
            letterSpacing: -0.15,
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
              minimumSize: const Size.fromHeight(54),
            ),
            icon: const Icon(Icons.visibility_outlined),
            label: const Text('Show answer'),
          )
        else ...[
          _ExplanationCard(explanation: item.explanation),
          const SizedBox(height: AppSpacing.lg),
          _RecallPanel(
            saving: saving,
            onReviewAgain: onReviewAgain,
            onRemembered: onRemembered,
          ),
        ],
      ],
    );
  }
}

class _SessionHeader extends StatelessWidget {
  const _SessionHeader({
    required this.minutes,
    required this.index,
    required this.total,
  });

  final int minutes;
  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.5;
    final progress = (index + 1) / total;
    final sessionBadge = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$minutes min',
        style: theme.textTheme.labelMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w900,
        ),
      ),
    );

    return Container(
      key: const Key('quick-revision-session-header'),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (largeText) ...[
            sessionBadge,
            const SizedBox(height: AppSpacing.md),
            _SessionHeaderCopy(index: index, total: total),
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _SessionHeaderCopy(index: index, total: total)),
                const SizedBox(width: AppSpacing.md),
                sessionBadge,
              ],
            ),
          const SizedBox(height: AppSpacing.lg),
          Semantics(
            label: 'Revision progress: ${index + 1} of $total',
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              borderRadius: BorderRadius.circular(99),
              color: Colors.white,
              backgroundColor: Colors.white.withValues(alpha: 0.22),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionHeaderCopy extends StatelessWidget {
  const _SessionHeaderCopy({required this.index, required this.total});

  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'QUICK REVISION',
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.76),
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          'Question ${index + 1} of $total',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.35,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          'Recall first. Reveal the stored answer when you’re ready.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.84),
            height: 1.35,
          ),
        ),
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
      constraints: const BoxConstraints(maxWidth: 260),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
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
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        reason.label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onTertiaryContainer,
          fontWeight: FontWeight.w800,
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
            : theme.colorScheme.surfaceContainerLow;
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
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: foreground.withValues(alpha: 0.08),
            ),
            child: Text(
              String.fromCharCode(65 + optionIndex),
              style: theme.textTheme.labelLarge?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w900,
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
                        ? FontWeight.w700
                        : FontWeight.w500,
                    height: 1.4,
                  ),
                ),
                if (annotation != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    annotation,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w900,
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
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  Icons.lightbulb_outline_rounded,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Explanation',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      'Compare this with the reasoning you recalled.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
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

class _RecallPanel extends StatelessWidget {
  const _RecallPanel({
    required this.saving,
    required this.onReviewAgain,
    required this.onRemembered,
  });

  final bool saving;
  final VoidCallback onReviewAgain;
  final VoidCallback onRemembered;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How well did you remember this?',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
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
