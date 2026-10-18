import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../domain/performance_analytics.dart';

class PerformanceAnalysisView extends StatelessWidget {
  const PerformanceAnalysisView({
    required this.analytics,
    super.key,
  });

  final PerformanceAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    if (analytics.totalTestsAttempted == 0) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 92,
                height: 92,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5F1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.insights_outlined,
                  size: 44,
                  color: Color(0xFF15806C),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Your analysis starts with your first test',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF0C131F),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Complete a mock or practice test to unlock score, accuracy, timing and section insights.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF697580),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => context.go('/exams'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF15806C),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Browse Tests'),
              ),
            ],
          ),
        ),
      );
    }

    final strongest = analytics.strongestSection;
    final weakest = analytics.weakestSection;
    return ListView(
      key: const Key('performance-analysis-list'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
      children: [
        _Hero(analytics: analytics),
        const SizedBox(height: 14),
        _MetricGrid(analytics: analytics),
        const SizedBox(height: 20),
        _SectionHeader(
          title: 'Score trend',
          subtitle: analytics.scoreTrend.length <= 1
              ? 'Your first completed test'
              : 'Your latest ' +
                  analytics.scoreTrend.length.toString() +
                  ' completed tests',
          trailing: TextButton(
            onPressed: () => context.push('/results'),
            child: const Text('History'),
          ),
        ),
        const SizedBox(height: 10),
        _TrendCard(points: analytics.scoreTrend),
        const SizedBox(height: 20),
        const _SectionHeader(
          title: 'Question outcomes',
          subtitle: 'A truthful split from your completed attempts.',
        ),
        const SizedBox(height: 10),
        _OutcomeCard(analytics: analytics),
        const SizedBox(height: 20),
        const _SectionHeader(
          title: 'Strengths & focus',
          subtitle: 'Based only on sections with answered questions.',
        ),
        const SizedBox(height: 10),
        if (strongest == null && weakest == null)
          const _InfoCard(
            icon: Icons.layers_outlined,
            text:
                'Section-level insights will appear when completed results include reviewed questions.',
          )
        else
          _StrengthsCard(strongest: strongest, weakest: weakest),
        const SizedBox(height: 20),
        const _SectionHeader(
          title: 'Section performance',
          subtitle: 'Accuracy, outcomes and average timing by section.',
        ),
        const SizedBox(height: 10),
        if (analytics.sectionPerformance.isEmpty)
          const _InfoCard(
            icon: Icons.query_stats_outlined,
            text:
                'Section details are unavailable for these result snapshots. Overall score and accuracy remain valid.',
          )
        else
          _SectionList(sections: analytics.sectionPerformance),
        const SizedBox(height: 20),
        _NextAction(
          latestTestName: analytics.latestTestName,
          latestAttemptId: analytics.latestAttemptId,
        ),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.analytics});
  final PerformanceAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    final score = analytics.averageScore.clamp(0, 100).toDouble();
    final change = analytics.latestScoreChange;
    return Container(
      key: const Key('performance-analysis-hero'),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFE7EFE7),
            Color(0xFFF7F7F1),
            Color(0xFFE1EBE2),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE3E8E4)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 88,
            height: 88,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 8,
                  strokeCap: StrokeCap.round,
                  backgroundColor: const Color(0xFFD8E5E1),
                  color: const Color(0xFF15806C),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _pct(score),
                        style: const TextStyle(
                          color: Color(0xFF0C131F),
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Text(
                        'Avg score',
                        style: TextStyle(
                          color: Color(0xFF697580),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'YOUR PERFORMANCE',
                  style: TextStyle(
                    color: Color(0xFF15806C),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .75,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  analytics.totalTestsAttempted.toString() +
                      ' completed ' +
                      (analytics.totalTestsAttempted == 1 ? 'test' : 'tests'),
                  style: const TextStyle(
                    color: Color(0xFF0C131F),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _pct(analytics.averageAccuracy) + ' answer accuracy',
                  style: const TextStyle(
                    color: Color(0xFF58646F),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (change != null) ...[
                  const SizedBox(height: 8),
                  _ChangeBadge(change: change),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChangeBadge extends StatelessWidget {
  const _ChangeBadge({required this.change});
  final double change;

  @override
  Widget build(BuildContext context) {
    final improved = change >= 0;
    final value = change.abs();
    final label =
        (value == value.roundToDouble() ? value.toInt().toString() : value.toStringAsFixed(1)) +
            ' pts vs previous';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: improved ? const Color(0xFFDDF2EC) : const Color(0xFFFFE8E5),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            improved ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            size: 14,
            color: improved
                ? const Color(0xFF15806C)
                : const Color(0xFFB5473D),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: improved
                    ? const Color(0xFF15806C)
                    : const Color(0xFFB5473D),
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.analytics});
  final PerformanceAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    final items = [
      (_pct(analytics.averageAccuracy), 'Accuracy', Icons.track_changes_rounded),
      (
        analytics.hasTimingData
            ? _duration(analytics.averageTimePerQuestion)
            : '—',
        'Avg time',
        Icons.timer_outlined
      ),
      (
        analytics.totalQuestions.toString(),
        'Questions',
        Icons.quiz_outlined
      ),
      (
        analytics.totalTestsAttempted.toString(),
        'Tests',
        Icons.fact_check_outlined
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 10) / 2;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final item in items)
              SizedBox(
                width: width,
                child: _Metric(
                  value: item.$1,
                  label: item.$2,
                  icon: item.$3,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 92),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EBEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19, color: const Color(0xFF15806C)),
          const SizedBox(height: 9),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF0C131F),
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF697580),
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF0C131F),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF697580),
                  fontSize: 11.5,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.points});
  final List<PerformanceTrendPoint> points;

  @override
  Widget build(BuildContext context) {
    final visible =
        points.length <= 8 ? points : points.sublist(points.length - 8);
    return Container(
      key: const Key('performance-score-trend'),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EBEE)),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 130,
            width: double.infinity,
            child: CustomPaint(
              painter: _TrendPainter(points: visible),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const _Legend(color: Color(0xFF15806C), label: 'Score'),
              const SizedBox(width: 14),
              const _Legend(color: Color(0xFF8FB9AE), label: 'Accuracy'),
              const Spacer(),
              Text(
                visible.isEmpty
                    ? 'No trend yet'
                    : visible.length.toString() + ' tests',
                style: const TextStyle(
                  color: Color(0xFF697580),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  const _TrendPainter({required this.points});
  final List<PerformanceTrendPoint> points;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = const Color(0xFFE8EBEE)
      ..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    if (points.isEmpty) return;

    Offset mapped(int index, double value) {
      final x = points.length == 1
          ? size.width / 2
          : size.width * index / (points.length - 1);
      final safe = value.clamp(0, 100).toDouble();
      return Offset(x, size.height - safe / 100 * size.height);
    }

    void drawSeries(
      double Function(PerformanceTrendPoint point) value,
      Color color,
      double stroke,
      double dot,
    ) {
      final paint = Paint()
        ..color = color
        ..strokeWidth = stroke
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      final path = Path();
      for (var i = 0; i < points.length; i++) {
        final p = mapped(i, value(points[i]));
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      canvas.drawPath(path, paint);
      final fill = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      for (var i = 0; i < points.length; i++) {
        canvas.drawCircle(mapped(i, value(points[i])), dot, fill);
      }
    }

    drawSeries(
      (point) => point.percentageScore,
      const Color(0xFF15806C),
      2.5,
      3.4,
    );
    drawSeries(
      (point) => point.accuracy,
      const Color(0xFF8FB9AE),
      2,
      2.8,
    );
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) =>
      oldDelegate.points != points;
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF697580),
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _OutcomeCard extends StatelessWidget {
  const _OutcomeCard({required this.analytics});
  final PerformanceAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    final total = analytics.totalQuestions;
    int flex(int value) => value <= 0 ? 0 : value;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EBEE)),
      ),
      child: Column(
        children: [
          if (total > 0)
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: SizedBox(
                height: 12,
                child: Row(
                  children: [
                    if (analytics.totalCorrect > 0)
                      Expanded(
                        flex: flex(analytics.totalCorrect),
                        child: Container(color: const Color(0xFF39A785)),
                      ),
                    if (analytics.totalIncorrect > 0)
                      Expanded(
                        flex: flex(analytics.totalIncorrect),
                        child: Container(color: const Color(0xFFE77269)),
                      ),
                    if (analytics.totalUnanswered > 0)
                      Expanded(
                        flex: flex(analytics.totalUnanswered),
                        child: Container(color: const Color(0xFFD7DCE1)),
                      ),
                  ],
                ),
              ),
            ),
          if (total > 0) const SizedBox(height: 13),
          Row(
            children: [
              Expanded(
                child: _Outcome(
                  label: 'Correct',
                  value: analytics.totalCorrect,
                  total: total,
                  color: const Color(0xFF15806C),
                ),
              ),
              Expanded(
                child: _Outcome(
                  label: 'Incorrect',
                  value: analytics.totalIncorrect,
                  total: total,
                  color: const Color(0xFFB5473D),
                ),
              ),
              Expanded(
                child: _Outcome(
                  label: 'Unanswered',
                  value: analytics.totalUnanswered,
                  total: total,
                  color: const Color(0xFF697580),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Outcome extends StatelessWidget {
  const _Outcome({
    required this.label,
    required this.value,
    required this.total,
    required this.color,
  });
  final String label;
  final int value;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final percent = total == 0 ? 0 : (value / total * 100).round();
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF697580),
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          percent.toString() + '%',
          style: const TextStyle(
            color: Color(0xFF9AA5AE),
            fontSize: 9.5,
          ),
        ),
      ],
    );
  }
}

class _StrengthsCard extends StatelessWidget {
  const _StrengthsCard({
    required this.strongest,
    required this.weakest,
  });
  final SectionPerformance? strongest;
  final SectionPerformance? weakest;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (strongest != null)
          Expanded(
            child: _Insight(
              icon: Icons.trending_up_rounded,
              label: 'Strongest',
              section: strongest!,
              positive: true,
            ),
          ),
        if (strongest != null && weakest != null)
          const SizedBox(width: 10),
        if (weakest != null)
          Expanded(
            child: _Insight(
              icon: Icons.flag_outlined,
              label: 'Needs focus',
              section: weakest!,
              positive: false,
            ),
          ),
      ],
    );
  }
}

class _Insight extends StatelessWidget {
  const _Insight({
    required this.icon,
    required this.label,
    required this.section,
    required this.positive,
  });
  final IconData icon;
  final String label;
  final SectionPerformance section;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    final accent =
        positive ? const Color(0xFF15806C) : const Color(0xFFB47A35);
    return Container(
      constraints: const BoxConstraints(minHeight: 112),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: positive ? const Color(0xFFE8F5F1) : const Color(0xFFFFF3DF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19, color: accent),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: accent,
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            section.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF0C131F),
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _pct(section.accuracy) + ' accuracy',
            style: const TextStyle(
              color: Color(0xFF697580),
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionList extends StatelessWidget {
  const _SectionList({required this.sections});
  final List<SectionPerformance> sections;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EBEE)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < sections.length; i++) ...[
            _SectionRow(section: sections[i]),
            if (i != sections.length - 1)
              const Divider(
                height: 1,
                indent: 14,
                endIndent: 14,
                color: Color(0xFFEEF1F3),
              ),
          ],
        ],
      ),
    );
  }
}

class _SectionRow extends StatelessWidget {
  const _SectionRow({required this.section});
  final SectionPerformance section;

  @override
  Widget build(BuildContext context) {
    final accuracy = section.accuracy.clamp(0, 100).toDouble();
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  section.name,
                  style: const TextStyle(
                    color: Color(0xFF0C131F),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                _pct(accuracy),
                style: const TextStyle(
                  color: Color(0xFF15806C),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: accuracy / 100,
              minHeight: 6,
              backgroundColor: const Color(0xFFE7ECEF),
              color: const Color(0xFF15806C),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 5,
            children: [
              _Tiny(section.correct.toString() + ' correct'),
              _Tiny(section.incorrect.toString() + ' wrong'),
              _Tiny(section.unanswered.toString() + ' skipped'),
              _Tiny(
                section.averageTimePerQuestion > 0
                    ? _duration(section.averageTimePerQuestion) + ' avg'
                    : 'Timing unavailable',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tiny extends StatelessWidget {
  const _Tiny(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF697580),
        fontSize: 10.5,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF15806C)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF58646F),
                height: 1.4,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NextAction extends StatelessWidget {
  const _NextAction({
    required this.latestTestName,
    required this.latestAttemptId,
  });
  final String? latestTestName;
  final String? latestAttemptId;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5F1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD6EBE5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Next useful action',
            style: TextStyle(
              color: Color(0xFF0C131F),
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Review mistakes and unanswered questions before your next attempt.',
            style: TextStyle(
              color: Color(0xFF58646F),
              fontSize: 11.5,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          if (latestAttemptId != null)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () =>
                    context.push('/review', extra: latestAttemptId),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF15806C),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(44),
                ),
                icon: const Icon(Icons.rate_review_outlined, size: 18),
                label: Text(
                  latestTestName == null
                      ? 'Review latest attempt'
                      : 'Review ' + latestTestName!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => context.push('/results'),
              child: const Text('View full test history'),
            ),
          ),
        ],
      ),
    );
  }
}

String _pct(double value) {
  final safe = value.clamp(0, 100).toDouble();
  return safe == safe.roundToDouble()
      ? safe.toInt().toString() + '%'
      : safe.toStringAsFixed(1) + '%';
}

String _duration(int seconds) {
  if (seconds < 60) return seconds.toString() + 's';
  final minutes = seconds ~/ 60;
  final remaining = seconds % 60;
  return remaining == 0
      ? minutes.toString() + 'm'
      : minutes.toString() + 'm ' + remaining.toString() + 's';
}
