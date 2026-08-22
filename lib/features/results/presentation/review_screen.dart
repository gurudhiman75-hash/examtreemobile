import 'package:flutter/material.dart';

import 'review_screen_v3.dart' as v3;

export 'review_screen_v2.dart' hide ReviewScreen;
export 'review_screen_v3.dart' hide ReviewScreen;

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key, required this.resultId});

  final String resultId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
        chipTheme: theme.chipTheme.copyWith(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          labelPadding: const EdgeInsets.symmetric(horizontal: 4),
        ),
      ),
      child: v3.ReviewScreen(resultId: resultId),
    );
  }
}
