import 'package:examtree/features/home/domain/series_test_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reads the test type from the title', () {
    expect(
      SeriesTestType.fromTitle('SSC CGL Full Mock 4'),
      SeriesTestType.full,
    );
    expect(
      SeriesTestType.fromTitle('Quant Sectional 1'),
      SeriesTestType.sectional,
    );
    expect(
      SeriesTestType.fromTitle('Topic Test: Percentages'),
      SeriesTestType.topic,
    );
    expect(
      SeriesTestType.fromTitle('Chapter test - Syllogism'),
      SeriesTestType.topic,
    );
    expect(
      SeriesTestType.fromTitle('Previous Year Paper 2024'),
      SeriesTestType.previousYear,
    );
    expect(
      SeriesTestType.fromTitle('SSC CGL 2025 · 12 Sep, Shift 2'),
      SeriesTestType.previousYear,
    );
    expect(SeriesTestType.fromTitle('Shiftwise mock'), SeriesTestType.full);
  });

  test('groups in tab order, keeps item order and drops empty types', () {
    final groups = groupBySeriesTestType<String>([
      'PYQ 2024 Shift 1',
      'Full Mock 1',
      'Reasoning Sectional 1',
      'Full Mock 2',
    ], SeriesTestType.fromTitle);

    expect(groups.keys, [
      SeriesTestType.full,
      SeriesTestType.sectional,
      SeriesTestType.previousYear,
    ]);
    expect(groups[SeriesTestType.full], ['Full Mock 1', 'Full Mock 2']);
  });
  test('prefers the backend kind over the title', () {
    expect(SeriesTestType.fromKind('full-length'), SeriesTestType.full);
    expect(SeriesTestType.fromKind('TOPIC_WISE'), SeriesTestType.topic);
    expect(SeriesTestType.fromKind('pyq'), SeriesTestType.previousYear);
    expect(SeriesTestType.fromKind('unknown'), isNull);
    expect(SeriesTestType.fromKind(null), isNull);
    expect(
      SeriesTestType.resolve(kind: 'sectional', title: 'Full Mock 3'),
      SeriesTestType.sectional,
    );
    expect(
      SeriesTestType.resolve(kind: null, title: 'Quant Sectional 2'),
      SeriesTestType.sectional,
    );
  });
}
