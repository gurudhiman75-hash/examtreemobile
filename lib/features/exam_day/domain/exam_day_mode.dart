class ExamDayChecklistItem {
  const ExamDayChecklistItem({
    required this.id,
    required this.label,
    required this.completed,
    this.isCustom = false,
  });

  final String id;
  final String label;
  final bool completed;
  final bool isCustom;

  ExamDayChecklistItem copyWith({
    String? label,
    bool? completed,
  }) {
    return ExamDayChecklistItem(
      id: id,
      label: label ?? this.label,
      completed: completed ?? this.completed,
      isCustom: isCustom,
    );
  }
}

const defaultExamDayChecklist = <ExamDayChecklistItem>[
  ExamDayChecklistItem(
    id: 'official_instructions',
    label: 'Official exam instructions reviewed',
    completed: false,
  ),
  ExamDayChecklistItem(
    id: 'admit_card',
    label: 'Admit card / hall ticket ready if required',
    completed: false,
  ),
  ExamDayChecklistItem(
    id: 'photo_id',
    label: 'Accepted photo ID confirmed from official instructions',
    completed: false,
  ),
  ExamDayChecklistItem(
    id: 'reporting_time',
    label: 'Reporting time confirmed',
    completed: false,
  ),
  ExamDayChecklistItem(
    id: 'venue_route',
    label: 'Venue and travel route checked',
    completed: false,
  ),
  ExamDayChecklistItem(
    id: 'allowed_items',
    label: 'Allowed and prohibited items checked in official instructions',
    completed: false,
  ),
  ExamDayChecklistItem(
    id: 'travel_plan',
    label: 'Travel plan and alarm arranged',
    completed: false,
  ),
];

class ExamDayTarget {
  const ExamDayTarget({
    required this.examName,
    required this.examAt,
    required this.remindersEnabled,
    required this.checklist,
    required this.updatedAt,
    this.reportingAt,
    this.venue = '',
  });

  final String examName;
  final DateTime examAt;
  final DateTime? reportingAt;
  final String venue;
  final bool remindersEnabled;
  final List<ExamDayChecklistItem> checklist;
  final DateTime updatedAt;

  int get completedChecklistCount =>
      checklist.where((item) => item.completed).length;

  ExamDayTarget copyWith({
    String? examName,
    DateTime? examAt,
    DateTime? reportingAt,
    bool clearReportingAt = false,
    String? venue,
    bool? remindersEnabled,
    List<ExamDayChecklistItem>? checklist,
    DateTime? updatedAt,
  }) {
    return ExamDayTarget(
      examName: examName ?? this.examName,
      examAt: examAt ?? this.examAt,
      reportingAt: clearReportingAt ? null : reportingAt ?? this.reportingAt,
      venue: venue ?? this.venue,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      checklist: checklist ?? this.checklist,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum ExamDayStage {
  planning,
  finalWeek,
  finalDay,
  examDay,
  scheduledTimeReached,
}

ExamDayStage examDayStage(ExamDayTarget target, DateTime now) {
  final localNow = now.toLocal();
  final localExam = target.examAt.toLocal();
  if (!localExam.isAfter(localNow)) return ExamDayStage.scheduledTimeReached;

  final sameDay = localNow.year == localExam.year &&
      localNow.month == localExam.month &&
      localNow.day == localExam.day;
  if (sameDay) return ExamDayStage.examDay;

  final remaining = localExam.difference(localNow);
  if (remaining <= const Duration(hours: 24)) return ExamDayStage.finalDay;
  if (remaining <= const Duration(days: 7)) return ExamDayStage.finalWeek;
  return ExamDayStage.planning;
}

String examDayStageTitle(ExamDayStage stage) => switch (stage) {
      ExamDayStage.planning => 'Preparation window',
      ExamDayStage.finalWeek => 'Final week',
      ExamDayStage.finalDay => 'Final 24 hours',
      ExamDayStage.examDay => 'Exam day',
      ExamDayStage.scheduledTimeReached => 'Scheduled time reached',
    };

String examDayGuidance(ExamDayStage stage) => switch (stage) {
      ExamDayStage.planning =>
        'Keep working through your normal plan. Use Daily Companion for due mistakes and Tests for deliberate practice.',
      ExamDayStage.finalWeek =>
        'Prioritise revision from questions you already missed or flagged, and confirm logistics from the official exam notice.',
      ExamDayStage.finalDay =>
        'Keep revision short and targeted. Re-check reporting time, venue, documents and permitted items against official instructions.',
      ExamDayStage.examDay =>
        'Use quick revision only if it is useful to you. Follow the official reporting, venue and item rules for your exam.',
      ExamDayStage.scheduledTimeReached =>
        'The scheduled start time has passed. ExamTree will not infer whether the exam is underway or completed; update or remove this target when appropriate.',
    };

String examCountdownLabel(DateTime target, DateTime now) {
  final difference = target.difference(now);
  if (difference <= Duration.zero) return 'Scheduled time reached';

  final days = difference.inDays;
  final hours = difference.inHours.remainder(24);
  final minutes = difference.inMinutes.remainder(60);
  if (days > 0) return '$days d $hours h';
  if (difference.inHours > 0) return '${difference.inHours} h $minutes min';
  return '${difference.inMinutes.clamp(1, 59)} min';
}

List<ExamDayChecklistItem> mergeExamDayChecklist(
  List<ExamDayChecklistItem> stored,
) {
  final byId = {for (final item in stored) item.id: item};
  final merged = <ExamDayChecklistItem>[
    for (final item in defaultExamDayChecklist) byId[item.id] ?? item,
  ];
  merged.addAll(
    stored.where(
      (item) => item.isCustom &&
          !defaultExamDayChecklist.any((builtIn) => builtIn.id == item.id),
    ),
  );
  return merged;
}
