import '../../preferences/domain/question_language.dart';

class LearnUiCopy {
  const LearnUiCopy({
    required this.learn,
    required this.lessons,
    required this.examFocus,
    required this.quickRevision,
    required this.practiceThisTopic,
    required this.practicePending,
    required this.unavailable,
    required this.comingNext,
    required this.minutes,
    required this.studyBySubject,
    required this.studyBySubjectSubtitle,
    required this.lessonsReady,
    required this.lessonsMapped,
  });

  final String learn;
  final String lessons;
  final String examFocus;
  final String quickRevision;
  final String practiceThisTopic;
  final String practicePending;
  final String unavailable;
  final String comingNext;
  final String minutes;
  final String studyBySubject;
  final String studyBySubjectSubtitle;
  final String lessonsReady;
  final String lessonsMapped;
}

LearnUiCopy learnUiCopy(QuestionLanguage language) => switch (language) {
      QuestionLanguage.english => const LearnUiCopy(
          learn: 'Learn',
          lessons: 'Lessons',
          examFocus: 'Exam focus',
          quickRevision: 'Quick revision',
          practiceThisTopic: 'Practice this topic',
          practicePending:
              'Lesson-level Question Studio mapping is prepared. Practice launch will be connected in the next integration pass.',
          unavailable: 'This lesson is not available yet.',
          comingNext: 'Coming next',
          minutes: 'min',
          studyBySubject: 'Study by subject',
          studyBySubjectSubtitle:
              'Short exam-focused lessons with quick revision and practice mapping.',
          lessonsReady: 'lessons ready',
          lessonsMapped: 'mapped',
        ),
      QuestionLanguage.hindi => const LearnUiCopy(
          learn: 'सीखें',
          lessons: 'पाठ',
          examFocus: 'परीक्षा में क्या महत्वपूर्ण है',
          quickRevision: 'त्वरित पुनरावृत्ति',
          practiceThisTopic: 'इस विषय का अभ्यास करें',
          practicePending:
              'इस पाठ की Question Studio मैपिंग तैयार है। अभ्यास शुरू करने की सुविधा अगले एकीकरण चरण में जोड़ी जाएगी।',
          unavailable: 'यह पाठ अभी उपलब्ध नहीं है।',
          comingNext: 'आगे आएगा',
          minutes: 'मिनट',
          studyBySubject: 'विषय के अनुसार पढ़ें',
          studyBySubjectSubtitle:
              'संक्षिप्त परीक्षा-केंद्रित पाठ, त्वरित पुनरावृत्ति और अभ्यास मैपिंग के साथ।',
          lessonsReady: 'पाठ तैयार',
          lessonsMapped: 'मैप किए गए',
        ),
      QuestionLanguage.punjabi => const LearnUiCopy(
          learn: 'ਸਿੱਖੋ',
          lessons: 'ਪਾਠ',
          examFocus: 'ਪ੍ਰੀਖਿਆ ਲਈ ਮਹੱਤਵਪੂਰਨ',
          quickRevision: 'ਤੁਰੰਤ ਦੁਹਰਾਈ',
          practiceThisTopic: 'ਇਸ ਵਿਸ਼ੇ ਦਾ ਅਭਿਆਸ ਕਰੋ',
          practicePending:
              'ਇਸ ਪਾਠ ਦੀ Question Studio ਮੈਪਿੰਗ ਤਿਆਰ ਹੈ। ਅਭਿਆਸ ਸ਼ੁਰੂ ਕਰਨ ਦੀ ਸੁਵਿਧਾ ਅਗਲੇ ਇੰਟੀਗ੍ਰੇਸ਼ਨ ਪੜਾਅ ਵਿੱਚ ਜੋੜੀ ਜਾਵੇਗੀ।',
          unavailable: 'ਇਹ ਪਾਠ ਹਾਲੇ ਉਪਲਬਧ ਨਹੀਂ ਹੈ।',
          comingNext: 'ਅੱਗੇ ਆਵੇਗਾ',
          minutes: 'ਮਿੰਟ',
          studyBySubject: 'ਵਿਸ਼ੇ ਅਨੁਸਾਰ ਪੜ੍ਹੋ',
          studyBySubjectSubtitle:
              'ਛੋਟੇ, ਪ੍ਰੀਖਿਆ-ਕੇਂਦਰਿਤ ਪਾਠ, ਤੁਰੰਤ ਦੁਹਰਾਈ ਅਤੇ ਅਭਿਆਸ ਮੈਪਿੰਗ ਦੇ ਨਾਲ।',
          lessonsReady: 'ਪਾਠ ਤਿਆਰ',
          lessonsMapped: 'ਮੈਪ ਕੀਤੇ',
        ),
    };
