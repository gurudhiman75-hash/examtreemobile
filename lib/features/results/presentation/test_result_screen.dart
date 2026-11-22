import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/result_model.dart';
import '../../../shared/widgets/network_failure_view.dart';
import 'providers/result_providers.dart';

const _navy = Color(0xFF142B56);
const _green = Color(0xFF23845A);
const _orange = Color(0xFFBB541F);
const _gold = Color(0xFFB17718);

class TestResultScreen extends ConsumerWidget {
  const TestResultScreen({super.key, required this.attemptId});

  final String attemptId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attempt = ref.watch(resultProvider(attemptId));

    final result = attempt.value;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text('Test Results'),
        centerTitle: true,
        leading: BackButton(
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/results'),
        ),
        actions: [
          if (result != null)
            IconButton(
              tooltip: 'Share score',
              icon: const Icon(Icons.ios_share_rounded),
              onPressed: () => _shareScore(context, result),
            ),
        ],
      ),
      body: attempt.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => NetworkFailureView(
          error: error,
          fallbackTitle: 'Unable to load this result',
          onRetry: () => ref.invalidate(resultProvider(attemptId)),
        ),
        data: (result) => _ResultSummary(result: result),
      ),
      bottomNavigationBar: result != null
          ? _ResultActions(result: result, attemptId: attemptId)
          : null,
    );
  }
}

class _ResultSummary extends StatelessWidget {
  const _ResultSummary({required this.result});

  final Result result;

  @override
  Widget build(BuildContext context) {
    final sections = result.sectionStats.isNotEmpty
        ? result.sectionStats
        : _sectionsFromReview(result.questionReview);
    final outcomes = [
      (result.correctCount, 'Correct', _green),
      (result.incorrectCount, 'Incorrect', _orange),
      (result.skippedCount, 'Unanswered', _gold),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        _ScoreCard(result: result),
        const SizedBox(height: 16),
        _SummaryCard(
          title: 'Answer breakdown',
          children: [
            if (outcomes.any((outcome) => outcome.$1 > 0))
              ExcludeSemantics(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Row(
                    children: [
                      for (final (count, _, color) in outcomes)
                        if (count > 0)
                          Expanded(
                            flex: count,
                            child: ColoredBox(
                              color: color,
                              child: const SizedBox(height: 12),
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                for (final (count, label, color) in outcomes)
                  _Metric(value: '$count', label: label, color: color),
              ],
            ),
          ],
        ),
        if (sections.isNotEmpty) ...[
          const SizedBox(height: 16),
          _SummaryCard(
            title: 'Section Analysis',
            children: [
              for (final section in sections) ...[
                Text(section.name, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(
                  '${section.correct} of ${section.totalQuestions} correct'
                  ' · ${_number(section.accuracy)}% accuracy',
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: (section.accuracy / 100).clamp(0.0, 1.0).toDouble(),
                  color: section.accuracy >= 80
                      ? _green
                      : section.accuracy >= 60
                          ? const Color(0xFF2768AD)
                          : _orange,
                  minHeight: 7,
                  borderRadius: BorderRadius.circular(8),
                  semanticsLabel: '${section.name} accuracy',
                ),
                const SizedBox(height: 14),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

List<ResultSectionStats> _sectionsFromReview(List<ResultQuestionReview> questions) {
  final grouped = <String, List<ResultQuestionReview>>{};
  for (final question in questions) {
    final name = question.section.trim();
    grouped.putIfAbsent(name.isEmpty ? 'General' : name, () => []).add(question);
  }
  return [
    for (final entry in grouped.entries)
      _sectionFromQuestions(entry.key, entry.value),
  ];
}

ResultSectionStats _sectionFromQuestions(
  String name,
  List<ResultQuestionReview> questions,
) {
  final correct = questions.where((question) => question.isCorrect).length;
  final answered = questions.where((question) => question.isAnswered).length;
  return ResultSectionStats(
    name: name,
    correct: correct,
    wrong: answered - correct,
    unanswered: questions.length - answered,
    totalQuestions: questions.length,
    accuracy: answered == 0 ? 0 : 100 * correct / answered,
  );
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.result});

  final Result result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white,
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Stack(
        children: [
          const Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 110,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_navy, Color(0xFF244678)],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.elliptical(220, 32),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: SizedBox.square(
                    dimension: 144,
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (result.maxScore > 0)
                              ExcludeSemantics(
                                child: CircularProgressIndicator(
                                  value: (result.rawScore / result.maxScore)
                                      .clamp(0.0, 1.0).toDouble(),
                                  strokeWidth: 7,
                                  strokeCap: StrokeCap.round,
                                  color: _green,
                                  backgroundColor: const Color(0xFFDDEFE6),
                                ),
                              ),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(18),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _number(result.rawScore),
                                        style: theme.textTheme.headlineLarge?.copyWith(
                                          color: _navy,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      Text(result.maxScore > 0
                                          ? '/ ${_number(result.maxScore)} marks'
                                          : 'Marks'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 22,
                  runSpacing: 10,
                  children: [
                    if (result.rank case final rank?)
                      _Metric(value: '#$rank', label: 'Rank', color: _navy),
                    if (result.percentile case final percentile?)
                      _Metric(value: '${_number(percentile)}%', label: 'Percentile', color: _navy),
                    _Metric(value: '${_number(result.accuracy)}%', label: 'Accuracy', color: _green),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  result.testName,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(color: _navy),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: _navy,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label, required this.color});

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _ResultActions extends StatelessWidget {
  const _ResultActions({required this.result, required this.attemptId});

  final Result result;
  final String attemptId;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 4,
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: _navy),
              onPressed: () => context.push('/review', extra: attemptId),
              child: const Text('View Solutions'),
            ),
            if (result.examId.trim().isNotEmpty)
              OutlinedButton(
                onPressed: () => context.push('/exam-details', extra: result.examId.trim()),
                child: const Text('Retake Test'),
              ),
          ],
        ),
      ),
    );
  }
}

Future<void> _shareScore(BuildContext context, Result result) async {
  final max = result.maxScore > 0 ? ' / ${_number(result.maxScore)}' : '';
  final text = '${result.testName} · ${_number(result.rawScore)}$max marks'
      ' · ${_number(result.accuracy)}% accuracy on ExamTree';
  try {
    await const MethodChannel('com.examtree.examtree/score_share')
        .invokeMethod<void>('share', text);
    return;
  } on MissingPluginException {
    await Clipboard.setData(ClipboardData(text: text));
  } on PlatformException {
    await Clipboard.setData(ClipboardData(text: text));
  }
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Score copied')),
    );
  }
}

String _number(double value) =>
    value == value.truncateToDouble() ? value.toStringAsFixed(0) : value.toString();
