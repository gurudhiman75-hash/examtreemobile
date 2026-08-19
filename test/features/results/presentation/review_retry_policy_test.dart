import 'package:examtree/features/results/presentation/review_retry_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('retry action becomes compact when review navigation stacks', () {
    expect(useCompactReviewRetryAction(1), isFalse);
    expect(useCompactReviewRetryAction(1.49), isFalse);
    expect(useCompactReviewRetryAction(1.5), isTrue);
    expect(useCompactReviewRetryAction(2), isTrue);
  });

  test('large-text retry action clears the taller review navigation', () {
    expect(
      reviewRetryBottomOffset(textScale: 1, safeBottom: 24),
      112,
    );
    expect(
      reviewRetryBottomOffset(textScale: 2, safeBottom: 24),
      180,
    );
  });
}
