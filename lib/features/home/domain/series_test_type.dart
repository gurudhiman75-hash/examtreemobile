/// The kind of test inside a test series, used to split the series test list
/// into tabs.
///
/// The series API does not send a type yet, so the type is read from the test
/// title. Anything that is not clearly sectional, topic-wise or a previous
/// year paper is treated as a full mock.
enum SeriesTestType {
  full(
    tabLabel: 'Full',
    title: 'Full Length Mock Tests',
    subtitle: 'Latest pattern full syllabus tests',
  ),
  sectional(
    tabLabel: 'Sectional',
    title: 'Sectional Tests',
    subtitle: 'Subject-wise practice tests',
  ),
  topic(
    tabLabel: 'Topic-wise',
    title: 'Topic-wise Tests',
    subtitle: 'Focused practice on important topics',
  ),
  previousYear(
    tabLabel: 'PYQs',
    title: 'Previous Year Papers',
    subtitle: 'Previous exam papers with review',
  );

  const SeriesTestType({
    required this.tabLabel,
    required this.title,
    required this.subtitle,
  });

  final String tabLabel;
  final String title;
  final String subtitle;

  static SeriesTestType fromTitle(String title) {
    final value = title.toLowerCase();
    if (value.contains('section')) return SeriesTestType.sectional;
    if (value.contains('previous') ||
        value.contains('pyq') ||
        RegExp(r'\bshift\b').hasMatch(value)) {
      return SeriesTestType.previousYear;
    }
    if (value.contains('topic') || value.contains('chapter')) {
      return SeriesTestType.topic;
    }
    return SeriesTestType.full;
  }
}

/// Groups items by test type in tab order (full, sectional, topic-wise,
/// previous year), keeping each item's original order and dropping empty
/// types.
Map<SeriesTestType, List<T>> groupBySeriesTestType<T>(
  Iterable<T> items,
  String Function(T item) titleOf,
) {
  final buckets = {for (final type in SeriesTestType.values) type: <T>[]};
  for (final item in items) {
    buckets[SeriesTestType.fromTitle(titleOf(item))]!.add(item);
  }
  buckets.removeWhere((_, list) => list.isEmpty);
  return buckets;
}
