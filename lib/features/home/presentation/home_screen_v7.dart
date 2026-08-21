import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/providers/auth_providers.dart';
import '../../exam_preferences/presentation/providers/exam_preferences_providers.dart';
import '../../exams/presentation/providers/exam_providers.dart';
import 'home_exam_priority.dart';
import 'home_screen_v6.dart' as v6;

final homeSelectedExamCodesProvider = Provider<AsyncValue<List<String>>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return const AsyncValue.data(<String>[]);
  return ref.watch(selectedExamCodesProvider);
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, this.now});

  final DateTime Function()? now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availableAsync = ref.watch(availableExamsProvider);
    final selectedCodesAsync = ref.watch(homeSelectedExamCodesProvider);
    final available = availableAsync.value;
    final selectedCodes = selectedCodesAsync.value;

    if (available == null ||
        available.isEmpty ||
        selectedCodes == null ||
        selectedCodes.isEmpty) {
      return v6.HomeScreen(now: now);
    }

    final prioritized = prioritizeHomeExams(
      exams: available,
      selectedExamCodes: selectedCodes,
    );

    return ProviderScope(
      overrides: [
        availableExamsProvider.overrideWith((ref) async => prioritized),
      ],
      child: v6.HomeScreen(now: now),
    );
  }
}
