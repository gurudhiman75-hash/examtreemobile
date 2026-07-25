import 'package:examtree/core/models/attempt_session_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses a canonical cross-device attempt session', () {
    final session = AttemptSession.fromJson({
      'id': '91d8f9cf-cf2d-49bb-9e77-bac903f4fbab',
      'testId': 'c19cc122-d18c-4c40-a250-629721f8513e',
      'testVersionId': 'f7840ef1-1437-4a3a-8f0c-e4d3ce4b645c',
      'publicationId': 'c79082a7-ebfe-4453-a274-0d57d3fd3d5a',
      'attemptNumber': 1,
      'status': 'in_progress',
      'revision': 3,
      'startedAt': '2026-07-25T10:00:00.000Z',
      'updatedAt': '2026-07-25T10:05:00.000Z',
      'savedAt': '2026-07-25T10:05:00.000Z',
      'state': {
        'testId': 'c19cc122-d18c-4c40-a250-629721f8513e',
        'testName': 'SSC Mock Test',
        'category': 'SSC',
        'currentSectionIndex': 0,
        'currentQuestionIndex': 2,
        'answers': {'101': 1, '102': null},
        'flags': {'101': true},
        'timeLeft': 900,
        'sectionTimeLeftByName': {'Quant': 900},
        'updatedAt': 1784973900000,
        'attemptType': 'REAL',
        'lockedSections': <int>[],
        'visitedQuestionIds': [101, 102],
      },
    });

    expect(session.revision, 3);
    expect(session.state?.currentQuestionIndex, 2);
    expect(session.state?.answers['101'], 1);
    expect(session.state?.answers.containsKey('102'), isTrue);
    expect(session.state?.flags['101'], isTrue);
    expect(session.state?.visitedQuestionIds, [101, 102]);
  });

  test('serialises the state contract expected by the API', () {
    const state = AttemptSessionState(
      testId: 'test-id',
      testName: 'Test name',
      category: 'SSC',
      currentQuestionIndex: 4,
      currentSectionIndex: 1,
      answers: {'201': 3},
      flags: {'201': false},
      timeLeft: 1200,
      sectionTimeLeftByName: {'Reasoning': 600},
      updatedAt: 1784973900000,
      attemptType: 'REAL',
      lockedSections: [0],
      visitedQuestionIds: [201],
    );

    final json = state.toJson();

    expect(json['testId'], 'test-id');
    expect(json['answers'], {'201': 3});
    expect(json['timeLeft'], 1200);
    expect(json['attemptType'], 'REAL');
    expect(json['visitedQuestionIds'], [201]);
  });
}
