import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../domain/attempt_result_summary.dart';

/// Colours shared by the result charts. Outcomes also differ in fill and
/// outline (skipped is hollow) so they never rely on hue alone.
class ResultPalette {
  ResultPalette._();

  static const Color ink = Color(0xFF10264A);
  static const Color muted = Color(0xFF5F6F82);
  static const Color border = Color(0xFFE4E9F1);
  static const Color navy = Color(0xFF0B3A6F);
  static const Color gold = Color(0xFFFFD36B);
  static const Color amber = Color(0xFFD97706);
  static const Color correct = Color(0xFF15806C);
  static const Color wrong = Color(0xFFEC4F70);
  static const Color wrongOutline = Color(0xFF9F1239);
  static const Color wrongSoft = Color(0xFFFDA4AF);
  static const Color skipped = Color(0xFFC5CFDB);
  static const Color skippedOutline = Color(0xFF8796AA);

  static Color forOutcome(QuestionOutcome outcome) => switch (outcome) {
        QuestionOutcome.correct => correct,
        QuestionOutcome.wrong => wrong,
        QuestionOutcome.skipped => skippedOutline,
      };
}

String _month(int month) => const [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ][month - 1];

String formatTrendDate(DateTime date) => '${date.day} ${_month(date.month)}';

String formatPercent(double value) {
  final rounded = value.roundToDouble();
  return (value - rounded).abs() < 0.05
      ? '${rounded.toInt()}%'
      : '${value.toStringAsFixed(1)}%';
}

// ---------------------------------------------------------------------------
// Trend line
// ---------------------------------------------------------------------------

class AttemptTrendChart extends StatelessWidget {
  const AttemptTrendChart({super.key, required this.points});

  final List<TrendPoint> points;

  @override
  Widget build(BuildContext context) {
    final description = StringBuffer('Score trend over your last '
        '${points.length} attempts: ');
    description.write(
      points.map((point) => formatPercent(point.percentage)).join(', '),
    );
    description.write('. The latest attempt is the last value.');
    return Semantics(
      label: description.toString(),
      image: true,
      child: ExcludeSemantics(
        child: SizedBox(
          height: 160,
          width: double.infinity,
          child: CustomPaint(painter: _TrendPainter(points)),
        ),
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  _TrendPainter(this.points);

  final List<TrendPoint> points;

  static const double _left = 36;
  static const double _right = 14;
  static const double _top = 24;
  static const double _bottom = 26;

  void _text(
    Canvas canvas,
    String text,
    Offset anchor, {
    required double fontSize,
    required Color color,
    FontWeight weight = FontWeight.w600,
    TextAlign align = TextAlign.center,
    bool anchorRight = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          color: color,
          fontWeight: weight,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
      textAlign: align,
      textDirection: TextDirection.ltr,
    )..layout();
    final dx = anchorRight
        ? anchor.dx - painter.width
        : anchor.dx - painter.width / 2;
    painter.paint(canvas, Offset(dx, anchor.dy - painter.height / 2));
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final values = points.map((point) => point.percentage);
    var minValue = (values.reduce((a, b) => a < b ? a : b) / 10).floor() * 10.0;
    var maxValue = (values.reduce((a, b) => a > b ? a : b) / 10).ceil() * 10.0;
    minValue = (minValue - 10).clamp(0, 100).toDouble();
    maxValue = (maxValue + 10).clamp(0, 100).toDouble();
    if (maxValue - minValue < 20) {
      maxValue = (minValue + 20).clamp(0, 100).toDouble();
      minValue = maxValue - 20;
    }

    final plotWidth = size.width - _left - _right;
    final plotHeight = size.height - _top - _bottom;
    double x(int index) => _left + plotWidth * index / (points.length - 1);
    double y(double value) =>
        _top + plotHeight * (1 - (value - minValue) / (maxValue - minValue));

    final grid = Paint()
      ..color = ResultPalette.border
      ..strokeWidth = 1;
    for (var tick = minValue; tick <= maxValue + 0.1; tick += 10) {
      final dy = y(tick);
      canvas.drawLine(Offset(_left, dy), Offset(size.width - _right, dy), grid);
      _text(
        canvas,
        '${tick.round()}%',
        Offset(_left - 6, dy),
        fontSize: 11,
        color: ResultPalette.muted,
        anchorRight: true,
      );
    }

    final line = Path()..moveTo(x(0), y(points.first.percentage));
    for (var i = 1; i < points.length; i++) {
      line.lineTo(x(i), y(points[i].percentage));
    }
    final area = Path.from(line)
      ..lineTo(x(points.length - 1), _top + plotHeight)
      ..lineTo(x(0), _top + plotHeight)
      ..close();
    canvas.drawPath(
      area,
      Paint()..color = ResultPalette.navy.withValues(alpha: .07),
    );
    canvas.drawPath(
      line,
      Paint()
        ..color = ResultPalette.navy
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );

    for (var i = 0; i < points.length; i++) {
      final point = points[i];
      final center = Offset(x(i), y(point.percentage));
      final radius = point.isCurrent ? 7.0 : 5.0;
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = point.isCurrent ? ResultPalette.gold : Colors.white,
      );
      canvas.drawCircle(
        center,
        radius - 1,
        Paint()
          ..color = ResultPalette.navy
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      _text(
        canvas,
        formatPercent(point.percentage).replaceAll('%', ''),
        Offset(center.dx, center.dy - radius - 9),
        fontSize: 11,
        color: ResultPalette.ink,
        weight: point.isCurrent ? FontWeight.w800 : FontWeight.w600,
      );
      _text(
        canvas,
        point.isCurrent ? 'This one' : formatTrendDate(point.date),
        Offset(center.dx, size.height - 8),
        fontSize: 11,
        color: point.isCurrent ? ResultPalette.ink : ResultPalette.muted,
        weight: point.isCurrent ? FontWeight.w800 : FontWeight.w500,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) =>
      oldDelegate.points != points;
}

// ---------------------------------------------------------------------------
// Accuracy vs share of time
// ---------------------------------------------------------------------------

class AccuracyTimeChart extends StatelessWidget {
  const AccuracyTimeChart({
    super.key,
    required this.sections,
    required this.totalSeconds,
  });

  final List<SectionSummary> sections;
  final int totalSeconds;

  static const double _plotHeight = 112;

  @override
  Widget build(BuildContext context) {
    final summary = sections.map((section) {
      final accuracy = section.accuracy;
      final share = section.timeShare(totalSeconds);
      return '${section.name}: '
          '${accuracy == null ? 'no answers' : '${accuracy.round()}% accuracy'}'
          '${share == null ? '' : ', ${share.round()}% of your time'}';
    }).join('. ');

    return Semantics(
      label: 'Accuracy and share of time by section. $summary.',
      image: true,
      child: ExcludeSemantics(
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: ResultPalette.border),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final section in sections)
                    Expanded(
                      child: _GroupedBars(
                        accuracy: section.accuracy,
                        share: section.timeShare(totalSeconds),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final section in sections)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Text(
                        section.name,
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: ResultPalette.muted,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupedBars extends StatelessWidget {
  const _GroupedBars({required this.accuracy, required this.share});

  final double? accuracy;
  final double? share;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AccuracyTimeChart._plotHeight + 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _Bar(value: accuracy, color: ResultPalette.navy),
          const SizedBox(width: 5),
          _Bar(value: share, color: ResultPalette.amber),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.value, required this.color});

  final double? value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final percent = value;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          percent == null ? '–' : '${percent.round()}%',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: ResultPalette.ink,
          ),
        ),
        const SizedBox(height: 3),
        Container(
          width: 22,
          height: percent == null
              ? 0
              : (percent.clamp(0, 100) / 100 * AccuracyTimeChart._plotHeight)
                  .toDouble(),
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Time per question
// ---------------------------------------------------------------------------

class PacingChart extends StatelessWidget {
  const PacingChart({super.key, required this.sections});

  final List<SectionSummary> sections;

  static const double _plotHeight = 76;

  @override
  Widget build(BuildContext context) {
    final withQuestions =
        sections.where((section) => section.questions.isNotEmpty).toList();
    var maxSeconds = 0;
    for (final section in withQuestions) {
      for (final question in section.questions) {
        final seconds = question.seconds ?? 0;
        if (seconds > maxSeconds) maxSeconds = seconds;
      }
    }
    if (maxSeconds == 0) return const SizedBox.shrink();

    return Semantics(
      label: 'Time spent on each question, grouped by section and coloured '
          'by whether the answer was correct, wrong or skipped.',
      image: true,
      child: ExcludeSemantics(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var i = 0; i < withQuestions.length; i++) ...[
              if (i > 0) const SizedBox(width: AppSpacing.sm),
              Expanded(
                flex: withQuestions[i].questions.length,
                child: Column(
                  children: [
                    Container(
                      height: _plotHeight,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: ResultPalette.border),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          for (final question in withQuestions[i].questions)
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: .5),
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    height: _barHeight(question, maxSeconds),
                                    decoration: BoxDecoration(
                                      color: ResultPalette.forOutcome(
                                        question.outcome,
                                      ),
                                      borderRadius:
                                          const BorderRadius.vertical(
                                        top: Radius.circular(1),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      withQuestions[i].name,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: ResultPalette.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static double _barHeight(PacedQuestion question, int maxSeconds) {
    final seconds = question.seconds;
    if (seconds == null || seconds <= 0) return 2;
    return (seconds / maxSeconds * _plotHeight).clamp(3, _plotHeight).toDouble();
  }
}

// ---------------------------------------------------------------------------
// Question map
// ---------------------------------------------------------------------------

class QuestionMap extends StatelessWidget {
  const QuestionMap({super.key, required this.sections});

  final List<SectionSummary> sections;

  static const double _dot = 20;
  static const double _gap = 6;
  static const int _columns = 5;
  static const double _gridWidth = _columns * _dot + (_columns - 1) * _gap;

  @override
  Widget build(BuildContext context) {
    final withQuestions =
        sections.where((section) => section.questions.isNotEmpty).toList();
    final summary = withQuestions
        .map(
          (section) => '${section.name}: ${section.correct} correct, '
              '${section.wrong} wrong, ${section.skipped} skipped',
        )
        .join('. ');
    return Semantics(
      label: 'Question map. $summary.',
      image: true,
      child: ExcludeSemantics(
        child: Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.lg - 4,
          children: [
            for (final section in withQuestions)
              SizedBox(
                width: _gridWidth + 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: ResultPalette.muted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: _gap,
                      runSpacing: _gap,
                      children: [
                        for (final question in section.questions)
                          OutcomeDot(outcome: question.outcome, size: _dot),
                      ],
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

class OutcomeDot extends StatelessWidget {
  const OutcomeDot({super.key, required this.outcome, this.size = 14});

  final QuestionOutcome outcome;
  final double size;

  @override
  Widget build(BuildContext context) {
    final (fill, outline) = switch (outcome) {
      QuestionOutcome.correct => (
          ResultPalette.correct,
          ResultPalette.correct,
        ),
      QuestionOutcome.wrong => (
          ResultPalette.wrongSoft,
          ResultPalette.wrongOutline,
        ),
      QuestionOutcome.skipped => (
          Colors.transparent,
          ResultPalette.skippedOutline,
        ),
    };
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: fill,
        border: Border.all(color: outline, width: 2),
      ),
    );
  }
}
