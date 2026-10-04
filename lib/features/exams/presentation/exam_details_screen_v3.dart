import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/exam_model.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/network_failure_view.dart';
import '../../results/presentation/providers/result_providers.dart';
import 'providers/exam_providers.dart';

class ExamDetailsScreen extends ConsumerStatefulWidget {
  const ExamDetailsScreen({
    super.key,
    required this.examId,
    this.seriesId,
  });

  final String examId;
  final String? seriesId;

  @override
  ConsumerState<ExamDetailsScreen> createState() => _ExamDetailsScreenState();
}

class _ExamDetailsScreenState extends ConsumerState<ExamDetailsScreen> {
  String _language = 'English';
  bool _confirmed = false;

  @override
  Widget build(BuildContext context) {
    final normalizedSeriesId = widget.seriesId?.trim();
    final hasSeriesContext =
        normalizedSeriesId != null && normalizedSeriesId.isNotEmpty;
    final accessKey = (
      examId: widget.examId,
      seriesId: hasSeriesContext ? normalizedSeriesId : null,
    );
    final examAsync = hasSeriesContext
        ? ref.watch(contextualExamDetailsProvider(accessKey))
        : ref.watch(examDetailsProvider(widget.examId));
    final completedAttemptsAsync =
        ref.watch(completedAttemptCountProvider(widget.examId));

    Future<void> refresh() async {
      if (hasSeriesContext) {
        ref.invalidate(contextualExamDetailsProvider(accessKey));
      } else {
        ref.invalidate(examDetailsProvider(widget.examId));
      }
      ref.invalidate(completedAttemptCountProvider(widget.examId));
      try {
        await Future.wait([
          if (hasSeriesContext)
            ref.read(contextualExamDetailsProvider(accessKey).future)
          else
            ref.read(examDetailsProvider(widget.examId).future),
          ref.read(completedAttemptCountProvider(widget.examId).future),
        ]);
      } catch (_) {}
    }

    return examAsync.when(
      loading: () => const Scaffold(
        backgroundColor: Color(0xFFF8FBFF),
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        backgroundColor: const Color(0xFFF8FBFF),
        appBar: _appBar(),
        body: NetworkFailureView(
          error: error,
          fallbackTitle: 'Unable to load test instructions',
          onRetry: refresh,
        ),
      ),
      data: (exam) {
        final completed = completedAttemptsAsync.value;
        final attemptLimitReached = exam.maxAttempts < 99 &&
            completed != null &&
            completed >= exam.maxAttempts;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FBFF),
          appBar: _appBar(),
          body: RefreshIndicator(
            onRefresh: refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 116),
              children: [
                _Hero(exam: exam),
                const SizedBox(height: 14),
                _Stats(exam: exam),
                const SizedBox(height: 16),
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _Heading(
                        icon: Icons.translate_rounded,
                        title: 'Choose Language',
                        iconColor: Color(0xFF1473E6),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'You can view questions, options and explanations in your preferred language.',
                        style: TextStyle(
                          color: Color(0xFF60759B),
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          for (final language in const ['English', 'हिंदी', 'ਪੰਜਾਬੀ']) ...[
                            Expanded(
                              child: _LanguageButton(
                                label: language,
                                selected: _language == language,
                                onTap: () => setState(() => _language = language),
                              ),
                            ),
                            if (language != 'ਪੰਜਾਬੀ') const SizedBox(width: 8),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _Heading(
                        icon: Icons.layers_rounded,
                        title: 'Section Details',
                        iconColor: Color(0xFF8B5CF6),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFDCE7F5)),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            const _TableRow(
                              values: ['Section', 'Questions', 'Marks', 'Time'],
                              header: true,
                            ),
                            _TableRow(
                              values: [
                                exam.category.trim().isEmpty
                                    ? 'Complete Test'
                                    : exam.category,
                                '${exam.totalQuestions}',
                                _number(exam.totalMarks),
                                '${exam.durationInSeconds ~/ 60} min',
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Section-wise breakup will follow the test configuration loaded by the exam engine.',
                        style: TextStyle(
                          color: Color(0xFF7A8DAE),
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _Heading(
                        icon: Icons.info_rounded,
                        title: 'Important Instructions',
                        iconColor: Color(0xFFF59E0B),
                      ),
                      const SizedBox(height: 12),
                      _Instruction(
                        icon: Icons.schedule_rounded,
                        text:
                            'The test duration is ${exam.durationInSeconds ~/ 60} minutes.',
                      ),
                      _Instruction(
                        icon: Icons.description_outlined,
                        text:
                            'The test consists of ${exam.totalQuestions} multiple choice questions.',
                      ),
                      _Instruction(
                        icon: Icons.remove_circle_outline_rounded,
                        iconColor: const Color(0xFFE11D48),
                        text: exam.negativeMarking == 0
                            ? 'There is no negative marking.'
                            : 'There is negative marking of ${_number(exam.negativeMarking)} marks for each wrong answer.',
                      ),
                      const _Instruction(
                        icon: Icons.swap_horiz_rounded,
                        text:
                            'You can navigate between questions within the test and change answers before final submission.',
                      ),
                      const _Instruction(
                        icon: Icons.cloud_done_rounded,
                        text:
                            'Your progress is saved while you work. Keep an internet connection available for sync.',
                      ),
                      const _Instruction(
                        icon: Icons.desktop_windows_outlined,
                        text: 'The test will be conducted online on this app.',
                      ),
                      const _Instruction(
                        icon: Icons.calculate_outlined,
                        text: 'Calculator is not allowed unless the test explicitly enables it.',
                      ),
                      const _Instruction(
                        icon: Icons.shield_outlined,
                        text: 'The test will be auto-submitted when time is over.',
                      ),
                      const SizedBox(height: 10),
                      InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: attemptLimitReached
                            ? null
                            : () => setState(() => _confirmed = !_confirmed),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF6FF),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: _confirmed,
                                onChanged: attemptLimitReached
                                    ? null
                                    : (value) => setState(
                                          () => _confirmed = value ?? false,
                                        ),
                              ),
                              const SizedBox(width: 4),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'I have read and understood all the instructions.',
                                      style: TextStyle(
                                        color: Color(0xFF09205B),
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'I am ready to start the test.',
                                      style: TextStyle(
                                        color: Color(0xFF60759B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (attemptLimitReached) ...[
                        const SizedBox(height: 10),
                        Text(
                          'Attempt limit reached',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              color: const Color(0xFFF8FBFF),
              child: SizedBox(
                height: 58,
                child: FilledButton(
                  key: const Key('exam-details-start'),
                  onPressed: !_confirmed || attemptLimitReached
                      ? null
                      : () => context.push(
                            hasSeriesContext
                                ? '/test-attempt?seriesId=' +
                                    Uri.encodeQueryComponent(normalizedSeriesId)
                                : '/test-attempt',
                            extra: widget.examId,
                          ),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF073A6A),
                    disabledBackgroundColor: const Color(0xFFB7C6D8),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(attemptLimitReached ? 'Attempt limit reached' : 'Start Test'),
                      const SizedBox(width: 10),
                      Icon(
                        attemptLimitReached
                            ? Icons.block_rounded
                            : Icons.arrow_forward_rounded,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

PreferredSizeWidget _appBar() => AppBar(
      title: const Text(
        'Test Instructions',
        style: TextStyle(
          color: Color(0xFF081847),
          fontWeight: FontWeight.w900,
        ),
      ),
      backgroundColor: const Color(0xFFF8FBFF),
      foregroundColor: const Color(0xFF081847),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    );

class _Hero extends StatelessWidget {
  const _Hero({required this.exam});
  final Exam exam;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF052D61), Color(0xFF0B5D96)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -28,
            child: Icon(
              Icons.account_balance_rounded,
              size: 145,
              color: Colors.white.withValues(alpha: .10),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                exam.category.trim().isEmpty
                    ? 'EXAMTREE MOCK TEST'
                    : exam.category.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFFDCEBFF),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                exam.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  height: 1.08,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFDFFBEF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.description_rounded,
                        size: 18, color: Color(0xFF087653)),
                    SizedBox(width: 6),
                    Text(
                      'Full Mock Test',
                      style: TextStyle(
                        color: Color(0xFF087653),
                        fontWeight: FontWeight.w800,
                      ),
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

class _Stats extends StatelessWidget {
  const _Stats({required this.exam});
  final Exam exam;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Stat(
          icon: Icons.description_outlined,
          value: '${exam.totalQuestions}',
          label: 'Questions',
          color: const Color(0xFF1473E6),
          bg: const Color(0xFFEAF4FF),
        ),
        const SizedBox(width: 8),
        _Stat(
          icon: Icons.schedule_rounded,
          value: '${exam.durationInSeconds ~/ 60}',
          label: 'Minutes',
          color: const Color(0xFFF59E0B),
          bg: const Color(0xFFFFF5DF),
        ),
        const SizedBox(width: 8),
        _Stat(
          icon: Icons.bar_chart_rounded,
          value: _number(exam.totalMarks),
          label: 'Total Marks',
          color: const Color(0xFF16A673),
          bg: const Color(0xFFEAFBF5),
        ),
        const SizedBox(width: 8),
        _Stat(
          icon: Icons.remove_circle_outline_rounded,
          value: _number(exam.negativeMarking),
          label: 'Negative',
          color: const Color(0xFFE11D48),
          bg: const Color(0xFFFFEEF2),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.bg,
  });
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFFE6EDF7)),
        ),
        child: Column(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 7),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF081847),
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF536B94),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE4ECF6)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0B2D5B).withValues(alpha: .04),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: child,
      );
}

class _Heading extends StatelessWidget {
  const _Heading({
    required this.icon,
    required this.title,
    required this.iconColor,
  });
  final IconData icon;
  final String title;
  final Color iconColor;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF081847),
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      );
}

class _LanguageButton extends StatelessWidget {
  const _LanguageButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFF1F7FF) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? const Color(0xFF1473E6)
                  : const Color(0xFFD5E0EE),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: const Color(0xFF081847),
              fontWeight: FontWeight.w800,
              fontSize: label == 'English' ? 15 : 18,
            ),
          ),
        ),
      );
}

class _TableRow extends StatelessWidget {
  const _TableRow({required this.values, this.header = false});
  final List<String> values;
  final bool header;

  @override
  Widget build(BuildContext context) => Container(
        color: header ? const Color(0xFFF0F6FD) : Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                values[0],
                style: TextStyle(
                  fontWeight: header ? FontWeight.w800 : FontWeight.w600,
                  color: const Color(0xFF153162),
                  fontSize: 12,
                ),
              ),
            ),
            for (final value in values.skip(1))
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: header ? FontWeight.w800 : FontWeight.w600,
                    color: const Color(0xFF153162),
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      );
}

class _Instruction extends StatelessWidget {
  const _Instruction({
    required this.icon,
    required this.text,
    this.iconColor = const Color(0xFF4F6A95),
  });
  final IconData icon;
  final String text;
  final Color iconColor;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 11),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 21, color: iconColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: Color(0xFF415B86),
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      );
}

String _number(double value) {
  if (value == value.roundToDouble()) return value.toInt().toString();
  return value
      .toStringAsFixed(2)
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}
