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
    final summary = AttemptSubmissionSummary.fromStates(widget.states);
    final visible = <int>[
      for (var index = 0; index < widget.states.length; index++)
        if (matchesPaletteFilter(widget.states[index].status, _filter)) index,
    ];

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.48,
      maxChildSize: 0.94,
      expand: false,
      builder: (context, controller) {
        return SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Question palette',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close palette',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    _CountChip(label: 'Answered', count: summary.totalAnswered),
                    _CountChip(
                      label: 'Unanswered',
                      count: summary.totalUnanswered,
                    ),
                    _CountChip(label: 'Marked', count: summary.totalMarked),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: SegmentedButton<PaletteFilter>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(
                      value: PaletteFilter.all,
                      label: Text('All'),
                    ),
                    ButtonSegment(
                      value: PaletteFilter.unanswered,
                      label: Text('Unanswered'),
                    ),
                    ButtonSegment(
                      value: PaletteFilter.marked,
                      label: Text('Marked'),
                    ),
                  ],
                  selected: {_filter},
                  onSelectionChanged: (selection) {
                    setState(() => _filter = selection.first);
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.xs,
                  children: const [
                    _LegendItem(
                      color: Color(0xFFE8F5E9),
                      label: 'Answered',
                    ),
                    _LegendItem(
                      color: Color(0xFFFFE0E0),
                      label: 'Unanswered',
                    ),
                    _LegendItem(
                      color: Color(0xFFEDE7F6),
                      label: 'Marked',
                    ),
                  ],
                ),
              ),
              const Divider(height: AppSpacing.lg),
              Expanded(
                child: visible.isEmpty
                    ? const Center(
                        child: Text('No questions match this filter.'),
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
                          maxCrossAxisExtent: 64,
                          mainAxisExtent: 52,
                          crossAxisSpacing: AppSpacing.sm,
                          mainAxisSpacing: AppSpacing.sm,
                        ),
                        itemCount: visible.length,
                        itemBuilder: (context, visibleIndex) {
                          final index = visible[visibleIndex];
                          final status = widget.states[index].status;
                          final selected = index == widget.currentIndex;
                          return Semantics(
                            button: true,
                            label: 'Question ${index + 1}, ${_statusLabel(status)}',
                            child: InkWell(
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusMd),
                              onTap: () {
                                Navigator.pop(context);
                                widget.onQuestionSelected(index);
                              },
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: widget.statusColor(context, status),
                                  border: Border.all(
                                    color: selected
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context)
                                            .colorScheme
                                            .outlineVariant,
                                    width: selected ? 3 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusMd,
                                  ),
                                ),
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontWeight: selected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
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

class _CountChip extends StatelessWidget {
  const _CountChip({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text('$label $count'));
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
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
