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

  /// Reads the type the backend sends for a series test (`kind`), accepting
  /// the admin values and common spellings. Returns null when the value is
  /// missing or unknown, so callers can fall back to [fromTitle].
  static SeriesTestType? fromKind(Object? kind) {
    final value = kind?.toString().trim().toLowerCase().replaceAll('_', '-');
    return switch (value) {
      'full' || 'full-length' || 'mock' => SeriesTestType.full,
      'sectional' || 'section' => SeriesTestType.sectional,
      'topic' || 'topic-wise' || 'chapter' => SeriesTestType.topic,
      'pyq' || 'previous-year' || 'previous' => SeriesTestType.previousYear,
      _ => null,
    };
  }

  /// The backend type when it sends one, otherwise a guess from the title.
  static SeriesTestType resolve({Object? kind, required String title}) =>
      fromKind(kind) ?? fromTitle(title);

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
  SeriesTestType Function(T item) typeOf,
) {
  final buckets = {for (final type in SeriesTestType.values) type: <T>[]};
  for (final item in items) {
    buckets[typeOf(item)]!.add(item);
  }
  buckets.removeWhere((_, list) => list.isEmpty);
  return buckets;
}
