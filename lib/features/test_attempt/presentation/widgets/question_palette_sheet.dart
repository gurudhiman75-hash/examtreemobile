import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../domain/test_attempt_experience.dart';

class QuestionPaletteSheet extends StatefulWidget {
  const QuestionPaletteSheet({
    required this.states,
    required this.currentIndex,
    required this.onQuestionSelected,
    required this.statusColor,
    super.key,
  });

  final List<QuestionState> states;
  final int currentIndex;
  final ValueChanged<int> onQuestionSelected;
  final Color Function(BuildContext, QuestionStatus) statusColor;

  @override
  State<QuestionPaletteSheet> createState() => _QuestionPaletteSheetState();
}

class _QuestionPaletteSheetState extends State<QuestionPaletteSheet> {
  PaletteFilter _filter = PaletteFilter.all;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final summary = AttemptSubmissionSummary.fromStates(widget.states);
    final visible = <int>[
      for (var index = 0; index < widget.states.length; index++)
        if (matchesPaletteFilter(widget.states[index].status, _filter)) index,
    ];

    return DraggableScrollableSheet(
      initialChildSize: 0.76,
      minChildSize: 0.5,
      maxChildSize: 0.94,
      expand: false,
      builder: (context, controller) {
        return SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.sm,
                  AppSpacing.xs,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Question palette',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            '${visible.length} of ${widget.states.length} questions shown',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close palette',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Row(
                  children: [
                    Expanded(
                      child: _CountTile(
                        label: 'Answered',
                        count: summary.totalAnswered,
                        color: widget.statusColor(
                          context,
                          QuestionStatus.answered,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _CountTile(
                        label: 'Unanswered',
                        count: summary.totalUnanswered,
                        color: widget.statusColor(
                          context,
                          QuestionStatus.notAnswered,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _CountTile(
                        label: 'Marked',
                        count: summary.totalMarked,
                        color: widget.statusColor(
                          context,
                          QuestionStatus.markedForReview,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  children: [
                    _PaletteFilterChip(
                      label: 'All',
                      selected: _filter == PaletteFilter.all,
                      onSelected: () => setState(() => _filter = PaletteFilter.all),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _PaletteFilterChip(
                      label: 'Unanswered ${summary.totalUnanswered}',
                      selected: _filter == PaletteFilter.unanswered,
                      onSelected: () =>
                          setState(() => _filter = PaletteFilter.unanswered),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _PaletteFilterChip(
                      label: 'Marked ${summary.totalMarked}',
                      selected: _filter == PaletteFilter.marked,
                      onSelected: () =>
                          setState(() => _filter = PaletteFilter.marked),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Row(
                  children: [
                    Icon(
                      Icons.touch_app_outlined,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        'Tap a number to jump directly to that question.',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: AppSpacing.lg),
              Expanded(
                child: visible.isEmpty
                    ? _EmptyPaletteFilter(
                        onShowAll: () => setState(() => _filter = PaletteFilter.all),
                      )
                    : GridView.builder(
                        controller: controller,
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          0,
                          AppSpacing.md,
                          AppSpacing.lg,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 68,
                          mainAxisExtent: 54,
                          crossAxisSpacing: AppSpacing.sm,
                          mainAxisSpacing: AppSpacing.sm,
                        ),
                        itemCount: visible.length,
                        itemBuilder: (context, visibleIndex) {
                          final index = visible[visibleIndex];
                          final status = widget.states[index].status;
                          final selected = index == widget.currentIndex;
                          final statusColor = widget.statusColor(context, status);
                          return Semantics(
                            button: true,
                            selected: selected,
                            label:
                                'Question ${index + 1}, ${_statusLabel(status)}${selected ? ', current question' : ''}',
                            child: InkWell(
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusMd),
                              onTap: () {
                                Navigator.pop(context);
                                widget.onQuestionSelected(index);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 140),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  border: Border.all(
                                    color: selected
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.outlineVariant,
                                    width: selected ? 3 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusMd,
                                  ),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '${index + 1}',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      color: theme.colorScheme.onSurface,
                                      fontWeight: selected
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CountTile extends StatelessWidget {
  const _CountTile({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: '$label: $count',
      excludeSemantics: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: 64),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '$count',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _PaletteFilterChip extends StatelessWidget {
  const _PaletteFilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: selected,
      showCheckmark: false,
      label: Text(label),
      onSelected: (_) => onSelected(),
    );
  }
}

class _EmptyPaletteFilter extends StatelessWidget {
  const _EmptyPaletteFilter({required this.onShowAll});

  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.filter_alt_off_outlined,
              size: 40,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'No questions match this filter.',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: onShowAll,
              child: const Text('Show all questions'),
            ),
          ],
        ),
      ),
    );
  }
}

String _statusLabel(QuestionStatus status) {
  switch (status) {
    case QuestionStatus.notVisited:
      return 'not visited';
    case QuestionStatus.notAnswered:
      return 'unanswered';
    case QuestionStatus.answered:
      return 'answered';
    case QuestionStatus.markedForReview:
      return 'marked for review';
    case QuestionStatus.answeredAndMarkedForReview:
      return 'answered and marked for review';
  }
}
