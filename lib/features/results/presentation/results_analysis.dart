import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/result_model.dart';
import '../../profile/domain/performance_analytics.dart';
import 'result_history_filter.dart';

class ResultsAnalysis extends StatelessWidget {
  const ResultsAnalysis({
    super.key,
    required this.results,
    required this.category,
    required this.onCategoryChanged,
    required this.onRefresh,
  });

  final List<Result> results;
  final String? category;
  final ValueChanged<String?> onCategoryChanged;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final categories = resultCategories(results);
    final selected = categories.contains(category) ? category : null;
    final attempts = filterAndSortResults(results: results, category: selected);
    final analytics = PerformanceAnalytics.fromResults(
      attempts.first.userId,
      attempts,
    );
    final weakest = analytics.weakestSection;
    final strongest = analytics.strongestSection;
    final colors = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
        children: [
          if (categories.length > 1)
            DropdownButton<String>(
              isExpanded: true,
              value: selected ?? '',
              onChanged: (value) =>
                  onCategoryChanged(value == '' ? null : value),
              items: [
                const DropdownMenuItem(value: '', child: Text('All exams')),
                for (final category in categories)
                  DropdownMenuItem(
                    value: category,
                    child: Text(category, overflow: TextOverflow.ellipsis),
                  ),
              ],
            ),
          _AnalysisCard(
            title: 'Performance overview',
            children: [
              Wrap(
                spacing: 18,
                runSpacing: 10,
                children: [
                  _Metric('Average score', _percent(analytics.averageScore)),
                  _Metric('Accuracy', _percent(analytics.averageAccuracy)),
                  _Metric(
                    'Completed tests',
                    '${analytics.totalTestsAttempted}',
                  ),
                  if (analytics.hasTimingData)
                    _Metric(
                      'Avg. time per question',
                      '${analytics.averageTimePerQuestion}s',
                    ),
                ],
              ),
            ],
          ),
          _AnalysisCard(
            title: 'Recent score and accuracy',
            children: [
              for (final point in analytics.scoreTrend.reversed)
                InkWell(
                  onTap: point.attemptId.trim().isEmpty
                      ? null
                      : () => context.push('/review', extra: point.attemptId),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          point.testName,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                          MaterialLocalizations.of(context)
                              .formatShortDate(point.completedAt),
                        ),
                        _Measure(
                          'Score',
                          point.percentageScore,
                          colors.primary,
                        ),
                        _Measure('Accuracy', point.accuracy, colors.tertiary),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          _AnalysisCard(
            title: 'Question outcomes',
            children: [
              Wrap(
                spacing: 18,
                runSpacing: 10,
                children: [
                  _Metric('Correct', '${analytics.totalCorrect}'),
                  _Metric('Incorrect', '${analytics.totalIncorrect}'),
                  _Metric('Unanswered', '${analytics.totalUnanswered}'),
                ],
              ),
            ],
          ),
          _AnalysisCard(
            title: 'Section performance',
            children: [
              if (analytics.sectionPerformance.isEmpty)
                const Text(
                  'Section breakdowns will appear when available for your attempts.',
                ),
              if (strongest != null &&
                  weakest != null &&
                  strongest != weakest) ...[
                Text('Highest accuracy: ${strongest.name}'),
                Text('Focus area: ${weakest.name}'),
                const SizedBox(height: 8),
              ],
              for (final section in analytics.sectionPerformance)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section.name,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                        '${section.correct} correct · ${section.incorrect} incorrect · ${section.unanswered} unanswered',
                      ),
                      if (section.answered > 0)
                        _Measure('Accuracy', section.accuracy, colors.tertiary),
                      if (section.timedQuestions > 0)
                        Text(
                          '${section.averageTimePerQuestion}s per timed question',
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnalysisCard extends StatelessWidget {
  const _AnalysisCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineSmall),
        Text(label),
      ],
    );
  }
}

class _Measure extends StatelessWidget {
  const _Measure(this.label, this.value, this.color);

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label ${_percent(value)}'),
          ExcludeSemantics(
            child: LinearProgressIndicator(
              value: (value / 100).clamp(0.0, 1.0).toDouble(),
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}

String _percent(double value) => '${value.round()}%';
