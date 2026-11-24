import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/result_model.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/network_failure_view.dart';
import '../domain/attempt_result_summary.dart';
import 'providers/result_providers.dart';
import 'review_retry_screen.dart' show shouldOfferRevisionAction;
import 'widgets/result_charts.dart';

/// Summary of one completed attempt: score, outcome split, section detail and
/// charts. It sits in front of the question-by-question review.
class AttemptResultScreen extends ConsumerWidget {
  const AttemptResultScreen({super.key, required this.resultId});

  final String resultId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultAsync = ref.watch(resultProvider(resultId));
    // History only feeds the trend chart; if it fails the chart is omitted.
    final history = ref.watch(userResultsProvider).value ?? const <Result>[];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F1),
      appBar: AppBar(
        title: const Text('Result'),
        backgroundColor: const Color(0xFFF7F7F1),
        foregroundColor: ResultPalette.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: resultAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => NetworkFailureView(
          error: error,
          fallbackTitle: 'Unable to load this result',
          onRetry: () => ref.invalidate(resultProvider(resultId)),
        ),
        data: (result) => AttemptResultView(
          summary: AttemptResultSummary.fromResult(result, history: history),
        ),
      ),
    );
  }
}

/// Provider-independent body so it can be rendered with fixtures in tests.
class AttemptResultView extends StatelessWidget {
  const AttemptResultView({super.key, required this.summary});

  final AttemptResultSummary summary;

  @override
  Widget build(BuildContext context) {
    final result = summary.result;
    final canReview = result.questionReview.isNotEmpty;
    final cards = <Widget>[
      _Header(result: result),
      _ScoreHero(summary: summary),
      if (summary.trend.length >= 2) _TrendCard(summary: summary),
      if (summary.total > 0) _OutcomeCard(summary: summary),
      if (summary.sections.isNotEmpty) ..._sectionCards(summary),
      if (summary.hasTiming &&
          summary.sections.where((s) => s.seconds != null).length >= 2)
        _AccuracyTimeCard(summary: summary),
      if (summary.hasTiming && summary.hasQuestionDetail)
        _PacingCard(summary: summary),
      if (summary.hasQuestionDetail) _MapCard(summary: summary),
      _Actions(result: result, canReview: canReview),
    ];

    return SafeArea(
      top: false,
      child: ListView.separated(
        key: const Key('attempt-result-list'),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.xs,
          AppSpacing.md,
          AppSpacing.xl,
        ),
        itemCount: cards.length,
        separatorBuilder: (context, index) =>
            const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) => cards[index],
      ),
    );
  }

  List<Widget> _sectionCards(AttemptResultSummary summary) => [
        const Padding(
          padding: EdgeInsets.only(top: AppSpacing.xs),
          child: Text(
            'Section-wise',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: ResultPalette.ink,
            ),
          ),
        ),
        for (final section in summary.sections)
          _SectionCard(section: section, totalSeconds: summary.totalSeconds),
      ];
}

String formatScore(double value) {
  final rounded = value.roundToDouble();
  return (value - rounded).abs() < 0.005
      ? rounded.toInt().toString()
      : value.toStringAsFixed(1);
}

String formatThousands(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return value < 0 ? '-$buffer' : buffer.toString();
}

String formatMinutes(int seconds) {
  final minutes = (seconds / 60).round();
  return minutes < 1 ? '<1 min' : '$minutes min';
}

String formatClock(int seconds) =>
    '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';

class _Header extends StatelessWidget {
  const _Header({required this.result});

  final Result result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name =
        result.testName.trim().isEmpty ? 'Test result' : result.testName;
    final facts = <String>[
      if (result.totalQuestions > 0) '${result.totalQuestions} questions',
      if (result.maxScore > 0) '${formatScore(result.maxScore)} marks',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: ResultPalette.ink,
            height: 1.2,
          ),
        ),
        if (facts.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            facts.join(' · '),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: ResultPalette.muted,
            ),
          ),
        ],
      ],
    );
  }
}

class _ScoreHero extends StatelessWidget {
  const _ScoreHero({required this.summary});

  final AttemptResultSummary summary;

  @override
  Widget build(BuildContext context) {
    final result = summary.result;
    final percentile = result.percentile;
    final ringValue = (percentile ?? result.percentageScore)
        .clamp(0, 100)
        .toDouble();
    final ringNumber = percentile != null
        ? percentile.round().toString()
        : result.percentageScore.round().toString();
    final ringLabel = percentile != null ? 'percentile' : 'score';
    final delta = summary.deltaVsPrevious;

    final metrics = <(String, String, String?)>[
      if (result.rank != null)
        ('Rank', formatThousands(result.rank!), null),
      (
        'Accuracy',
        formatPercent(summary.accuracy),
        '${summary.correct} of ${summary.answered}',
      ),
      if (summary.totalSeconds != null)
        ('Time', formatMinutes(summary.totalSeconds!), 'spent')
      else
        ('Attempted', '${summary.answered}', 'of ${summary.total}'),
    ];

    return Semantics(
      container: true,
      label: 'Score ${formatScore(result.rawScore)} out of '
          '${formatScore(result.maxScore)}.',
      child: Container(
        key: const Key('attempt-result-hero'),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF031B3A), Color(0xFF063A70), Color(0xFF0B5D96)],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF062D5C).withValues(alpha: .16),
              blurRadius: 22,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'YOUR SCORE',
                        style: TextStyle(
                          color: ResultPalette.gold,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              formatScore(result.rawScore),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 56,
                                fontWeight: FontWeight.w800,
                                height: 1.05,
                                letterSpacing: -1,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '/ ${formatScore(result.maxScore)}',
                              style: const TextStyle(
                                color: Color(0xFFC9D8EA),
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                SizedBox(
                  width: 88,
                  height: 88,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: ringValue / 100,
                        strokeWidth: 8,
                        strokeCap: StrokeCap.round,
                        backgroundColor: Colors.white.withValues(alpha: .18),
                        color: ResultPalette.gold,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            ringNumber,
                            style: const TextStyle(
                              color: ResultPalette.gold,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            ringLabel,
                            style: const TextStyle(
                              color: Color(0xFFC9D8EA),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (delta != null) ...[
              const SizedBox(height: AppSpacing.md),
              _DeltaChip(delta: delta),
            ],
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.white.withValues(alpha: .18)),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final metric in metrics)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            metric.$1,
                            style: const TextStyle(
                              color: Color(0xFFC9D8EA),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            metric.$2,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (metric.$3 != null)
                            Text(
                              metric.$3!,
                              style: const TextStyle(
                                color: Color(0xFFC9D8EA),
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeltaChip extends StatelessWidget {
  const _DeltaChip({required this.delta});

  final double delta;

  @override
  Widget build(BuildContext context) {
    final up = delta >= 0;
    final text = '${up ? '+' : '−'}${delta.abs().toStringAsFixed(1)} pts '
        'vs your last attempt';
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: ResultPalette.gold.withValues(alpha: .14),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              up ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
              size: 15,
              color: ResultPalette.gold,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                text,
                style: const TextStyle(
                  color: ResultPalette.gold,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ResultPalette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: ResultPalette.ink,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 3),
            Text(
              subtitle!,
              style: const TextStyle(fontSize: 13, color: ResultPalette.muted),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.items});

  final List<(Widget, String)> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.xs,
      children: [
        for (final item in items)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              item.$1,
              const SizedBox(width: 6),
              Text(
                item.$2,
                style: const TextStyle(
                  fontSize: 12,
                  color: ResultPalette.muted,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

Widget _swatch(Color color) => Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
    );

class _Insight extends StatelessWidget {
  const _Insight({
    required this.icon,
    required this.background,
    required this.iconColor,
    required this.child,
  });

  final IconData icon;
  final Color background;
  final Color iconColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 12),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.summary});

  final AttemptResultSummary summary;

  @override
  Widget build(BuildContext context) {
    final count = summary.trend.length;
    return _Card(
      key: const Key('attempt-result-trend'),
      title: 'Your last $count attempts',
      subtitle: 'Score as a percentage of the maximum.',
      child: AttemptTrendChart(points: summary.trend),
    );
  }
}

class _OutcomeCard extends StatelessWidget {
  const _OutcomeCard({required this.summary});

  final AttemptResultSummary summary;

  @override
  Widget build(BuildContext context) {
    final total = summary.total;
    final skippedSection = summary.mostSkippedSection;
    final rows = <(Color, String, int)>[
      (ResultPalette.correct, 'Correct', summary.correct),
      (ResultPalette.wrong, 'Wrong', summary.wrong),
      (ResultPalette.skipped, 'Skipped', summary.skipped),
    ];
    return _Card(
      key: const Key('attempt-result-outcome'),
      title: 'How your $total questions went',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: SizedBox(
              height: 14,
              child: Row(
                children: [
                  for (var i = 0; i < rows.length; i++)
                    if (rows[i].$3 > 0)
                      Expanded(
                        flex: rows[i].$3,
                        child: Container(
                          margin: EdgeInsets.only(left: i == 0 ? 0 : 2),
                          color: rows[i].$1,
                        ),
                      ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  _swatch(row.$1),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      row.$2,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: ResultPalette.ink,
                      ),
                    ),
                  ),
                  Text(
                    '${row.$3}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: ResultPalette.ink,
                    ),
                  ),
                  SizedBox(
                    width: 48,
                    child: Text(
                      formatPercent(row.$3 / total * 100),
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 13,
                        color: ResultPalette.muted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (skippedSection != null) ...[
            const SizedBox(height: AppSpacing.xs),
            _Insight(
              icon: Icons.flag_outlined,
              background: const Color(0xFFFFF6DC),
              iconColor: const Color(0xFF92400E),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Quickest win: ${skippedSection.name}. ',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    TextSpan(
                      text: 'You skipped ${skippedSection.skipped} '
                          'question${skippedSection.skipped == 1 ? '' : 's'}'
                          ' there, more than in any other section.',
                    ),
                  ],
                ),
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: ResultPalette.ink,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.section, required this.totalSeconds});

  final SectionSummary section;
  final int? totalSeconds;

  @override
  Widget build(BuildContext context) {
    final total = section.total;
    final accuracy = section.accuracy;
    final chips = <String>[
      if (accuracy != null) 'Accuracy ${formatPercent(accuracy)}',
      if (section.seconds != null) formatMinutes(section.seconds!),
    ];
    return Container(
      key: Key('attempt-result-section-${section.name}'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ResultPalette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  section.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ResultPalette.ink,
                  ),
                ),
              ),
              Text(
                '${section.correct}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: ResultPalette.ink,
                ),
              ),
              Text(
                ' / $total correct',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: ResultPalette.muted,
                ),
              ),
            ],
          ),
          if (total > 0) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 8,
                child: Row(
                  children: [
                    if (section.correct > 0)
                      Expanded(
                        flex: section.correct,
                        child: Container(color: ResultPalette.correct),
                      ),
                    if (section.wrong > 0)
                      Expanded(
                        flex: section.wrong,
                        child: Container(
                          margin: const EdgeInsets.only(left: 2),
                          color: ResultPalette.wrong,
                        ),
                      ),
                    if (section.skipped > 0)
                      Expanded(
                        flex: section.skipped,
                        child: Container(
                          margin: const EdgeInsets.only(left: 2),
                          color: ResultPalette.skipped,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Text(
            '${section.correct} correct · ${section.wrong} wrong · '
            '${section.skipped} skipped',
            style: const TextStyle(fontSize: 13, color: ResultPalette.muted),
          ),
          if (chips.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final chip in chips)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2F8),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      chip,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: ResultPalette.ink,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _AccuracyTimeCard extends StatelessWidget {
  const _AccuracyTimeCard({required this.summary});

  final AttemptResultSummary summary;

  @override
  Widget build(BuildContext context) {
    final totalSeconds = summary.totalSeconds!;
    final timeSection = summary.largestTimeSection;
    final weakest = summary.weakestSection;
    final sentences = <String>[];
    if (timeSection != null) {
      final share = timeSection.timeShare(totalSeconds);
      final accuracy = timeSection.accuracy;
      if (share != null) {
        sentences.add(
          '${timeSection.name} took ${share.round()}% of your time'
          '${accuracy == null ? '' : ' at ${accuracy.round()}% accuracy'}.',
        );
      }
    }
    if (weakest != null && weakest != timeSection) {
      final share = weakest.timeShare(totalSeconds);
      sentences.add(
        '${weakest.name} had your lowest accuracy, '
        '${weakest.accuracy!.round()}%'
        '${share == null ? '' : ', on ${share.round()}% of your time'}.',
      );
    }
    return _Card(
      key: const Key('attempt-result-accuracy-time'),
      title: 'Accuracy vs time spent',
      subtitle: 'Is your time going where your marks are?',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Legend(
            items: [
              (_swatch(ResultPalette.navy), 'Accuracy'),
              (_swatch(ResultPalette.amber), 'Share of your time'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AccuracyTimeChart(
            sections: summary.sections
                .where((section) => section.seconds != null)
                .toList(growable: false),
            totalSeconds: totalSeconds,
          ),
          if (sentences.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _Insight(
              icon: Icons.schedule_rounded,
              background: const Color(0xFFEAF4FF),
              iconColor: ResultPalette.navy,
              child: Text(
                sentences.join(' '),
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: ResultPalette.ink,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PacingCard extends StatelessWidget {
  const _PacingCard({required this.summary});

  final AttemptResultSummary summary;

  @override
  Widget build(BuildContext context) {
    final slowest = summary.slowestQuestion;
    return _Card(
      key: const Key('attempt-result-pacing'),
      title: 'Time per question',
      subtitle: 'One bar per question, in the order of the paper.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Legend(
            items: [
              (_swatch(ResultPalette.correct), 'Correct'),
              (_swatch(ResultPalette.wrong), 'Wrong'),
              (_swatch(ResultPalette.skippedOutline), 'Skipped'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          PacingChart(sections: summary.sections),
          if (slowest != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              'Slowest question: ${slowest.section} Q${slowest.number} '
              'at ${formatClock(slowest.seconds)}.',
              style: const TextStyle(
                fontSize: 14,
                height: 1.45,
                color: ResultPalette.ink,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MapCard extends StatelessWidget {
  const _MapCard({required this.summary});

  final AttemptResultSummary summary;

  @override
  Widget build(BuildContext context) {
    return _Card(
      key: const Key('attempt-result-map'),
      title: 'Question map',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Legend(
            items: [
              (OutcomeDot(outcome: QuestionOutcome.correct), 'Correct'),
              (OutcomeDot(outcome: QuestionOutcome.wrong), 'Wrong'),
              (OutcomeDot(outcome: QuestionOutcome.skipped), 'Skipped'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          QuestionMap(sections: summary.sections),
        ],
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.result, required this.canReview});

  final Result result;
  final bool canReview;

  @override
  Widget build(BuildContext context) {
    final offerRevision = shouldOfferRevisionAction(result);
    final canRetake = result.examId.trim().isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          key: const Key('attempt-result-review'),
          onPressed: canReview
              ? () => context.push('/review', extra: result.attemptId)
              : null,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
            backgroundColor: ResultPalette.navy,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          iconAlignment: IconAlignment.end,
          icon: const Icon(Icons.arrow_forward_rounded, size: 18),
          label: const Text('Review solutions'),
        ),
        const SizedBox(height: 10),
        if (offerRevision)
          OutlinedButton(
            key: const Key('attempt-result-revision'),
            onPressed: () => context.push('/quick-revision?minutes=5'),
            style: _outlined,
            child: const Text('Revise mistakes (5 min)'),
          )
        else
          OutlinedButton(
            key: const Key('attempt-result-retake'),
            onPressed: canRetake
                ? () => context.push('/exam-details', extra: result.examId.trim())
                : null,
            style: _outlined,
            child: const Text('Retake test'),
          ),
      ],
    );
  }

  static final ButtonStyle _outlined = OutlinedButton.styleFrom(
    minimumSize: const Size.fromHeight(54),
    foregroundColor: ResultPalette.navy,
    side: const BorderSide(color: ResultPalette.navy, width: 1.5),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
  );
}
