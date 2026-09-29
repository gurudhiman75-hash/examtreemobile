import 'package:examtree/features/learn/data/polity_learn_localizations.dart';
import 'package:examtree/features/learn/domain/learn_ui_copy.dart';
import 'package:examtree/features/preferences/domain/question_language.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('polity localization overlays Hindi lessons and preserves fallback', () {
    final subject = polityLearnSubjectFor(QuestionLanguage.hindi);

    expect(subject.title, 'भारतीय राजव्यवस्था');
    expect(subject.lessons.first.title, 'भारतीय संविधान का निर्माण');
    expect(subject.lessons[4].title, 'नागरिकता');
    expect(subject.lessons[5].title, 'Fundamental Rights — Overview');
    expect(subject.lessons.length, 67);
  });

  test('polity localization overlays natural Punjabi lessons', () {
    final subject = polityLearnSubjectFor(QuestionLanguage.punjabi);

    expect(subject.title, 'ਭਾਰਤੀ ਰਾਜ-ਵਿਵਸਥਾ');
    expect(subject.lessons.first.title, 'ਭਾਰਤੀ ਸੰਵਿਧਾਨ ਦੀ ਬਣਤਰ');
    expect(subject.lessons[2].title, 'ਪ੍ਰਸਤਾਵਨਾ');
    expect(subject.lessons[4].title, 'ਨਾਗਰਿਕਤਾ');
  });

  test('Learn UI copy follows the global question language', () {
    expect(
      learnUiCopy(QuestionLanguage.hindi).quickRevision,
      'त्वरित पुनरावृत्ति',
    );
    expect(
      learnUiCopy(QuestionLanguage.punjabi).practiceThisTopic,
      'ਇਸ ਵਿਸ਼ੇ ਦਾ ਅਭਿਆਸ ਕਰੋ',
    );
  });
}
