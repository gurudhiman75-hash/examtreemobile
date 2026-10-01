import 'package:examtree/core/theme/app_theme.dart';
import 'package:examtree/features/learn/data/local_learn_practice_progress_store.dart';
import 'package:examtree/features/learn/domain/learn_practice_models.dart';
import 'package:examtree/features/learn/domain/learn_practice_question.dart';
import 'package:examtree/features/learn/presentation/learn_practice_screen.dart';
import 'package:examtree/features/learn/presentation/providers/learn_practice_providers.dart';
import 'package:examtree/features/preferences/domain/question_language.dart';
import 'package:examtree/features/preferences/presentation/providers/question_language_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeQuestions implements LearnPracticeQuestionRepository {
  @override
  Future<List<LearnPracticeQuestion>> loadQuestions({
    required String topicId,
    required int limit,
    required String language,
    String tagQuery = '',
    bool fresh = false,
  }) async {
    return [
      const LearnPracticeQuestion(
        id: 'q1',
        topicId: 'POL-LRN-001',
        text: 'On which date was the Constitution of India adopted?',
        options: [
          '26 January 1950',
          '26 November 1949',
          '15 August 1947',
          '9 December 1946',
        ],
        correctOptionIndex: 1,
        explanation:
            'The Constitution was adopted on 26 November 1949 and came into force on 26 January 1950.',
      ),
      const LearnPracticeQuestion(
        id: 'q2',
        topicId: 'POL-LRN-001',
        text: 'Who chaired the Drafting Committee?',
        options: [
          'Rajendra Prasad',
          'Jawaharlal Nehru',
          'B. R. Ambedkar',
          'B. N. Rau',
        ],
        correctOptionIndex: 2,
        explanation: 'Dr. B. R. Ambedkar chaired the Drafting Committee.',
      ),
    ];
  }
}

class _MemoryProgress implements LearnPracticeProgressStore {
  final Map<String, LearnPracticeProgress> values = {};

  @override
  Future<void> clear(String topicId) async => values.remove(topicId);

  @override
  Future<LearnPracticeProgress?> read(String topicId) async => values[topicId];

  @override
  Future<List<LearnPracticeProgress>> readAll() async =>
      values.values.toList(growable: false);

  @override
  Future<void> write(LearnPracticeProgress progress) async {
    values[progress.topicId] = progress;
  }
}

void main() {
  testWidgets('practice reveals answer and explanation immediately', (tester) async {
    final progress = _MemoryProgress();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          questionLanguageProvider.overrideWith(
            (ref) async => QuestionLanguage.english,
          ),
          learnPracticeQuestionRepositoryProvider.overrideWithValue(
            _FakeQuestions(),
          ),
          learnPracticeProgressStoreProvider.overrideWithValue(progress),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const LearnPracticeScreen(topicId: 'POL-LRN-001'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('Untimed'), findsOneWidget);
    expect(find.byKey(const Key('learn-practice-back')), findsOneWidget);
    expect(find.byKey(const Key('learn-practice-submit')), findsOneWidget);
    expect(find.byKey(const Key('learn-practice-question')), findsOneWidget);
    expect(find.byIcon(Icons.timer_outlined), findsNothing);

    await tester.tap(find.byKey(const Key('learn-practice-option-1')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('learn-practice-feedback')), findsOneWidget);
    expect(find.text('Correct'), findsOneWidget);
    expect(
      find.textContaining('adopted on 26 November 1949'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('learn-practice-submit')));
    await tester.pumpAndSettle();
    expect(find.text('Submit practice?'), findsOneWidget);
    expect(find.textContaining('answered 1 of 2'), findsOneWidget);
    await tester.tap(find.text('Keep practicing'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('learn-practice-next')));
    await tester.pumpAndSettle();

    expect(find.text('Who chaired the Drafting Committee?'), findsOneWidget);
    expect(progress.values['POL-LRN-001']?.currentQuestion, 1);
  });

  testWidgets('practice back falls back to Learn when there is no route to pop', (tester) async {
    final progress = _MemoryProgress();
    final router = GoRouter(
      initialLocation: '/learn-practice',
      routes: [
        GoRoute(
          path: '/learn-practice',
          builder: (context, state) =>
              const LearnPracticeScreen(topicId: 'POL-LRN-001'),
        ),
        GoRoute(
          path: '/learn',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Learn landing'))),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          questionLanguageProvider.overrideWith(
            (ref) async => QuestionLanguage.english,
          ),
          learnPracticeQuestionRepositoryProvider.overrideWithValue(
            _FakeQuestions(),
          ),
          learnPracticeProgressStoreProvider.overrideWithValue(progress),
        ],
        child: MaterialApp.router(
          theme: AppTheme.lightTheme,
          routerConfig: router,
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byKey(const Key('learn-practice-back')), findsOneWidget);

    await tester.tap(find.byKey(const Key('learn-practice-back')));
    await tester.pumpAndSettle();

    expect(find.text('Learn landing'), findsOneWidget);
    expect(router.routeInformationProvider.value.uri.path, '/learn');
  });

}
