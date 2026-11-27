// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get navHome => 'होम';

  @override
  String get navLearn => 'सीखें';

  @override
  String get navTests => 'टेस्ट';

  @override
  String get navCurrentAffairs => 'करंट अफेयर्स';

  @override
  String get navResults => 'परिणाम';

  @override
  String get navProfile => 'प्रोफ़ाइल';

  @override
  String get navMenu => 'मेन्यू';

  @override
  String get appLanguage => 'ऐप की भाषा';

  @override
  String get appLanguageHelp =>
      'मेन्यू, बटन और स्क्रीन के टेक्स्ट के लिए। अनुवाद पूरा होने तक कुछ स्क्रीन अभी अंग्रेज़ी में हैं।';

  @override
  String get alsoUseForQuestions => 'प्रश्न भी इसी भाषा में दिखाएँ';

  @override
  String get questionLanguage => 'प्रश्नों की भाषा';

  @override
  String get languageSaveFailed => 'इस डिवाइस पर भाषा सेव नहीं हो सकी।';

  @override
  String get bookmarksTitle => 'बुकमार्क';

  @override
  String bookmarksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सेव किए गए प्रश्न · इस डिवाइस पर',
      one: '1 सेव किया गया प्रश्न · इस डिवाइस पर',
    );
    return '$_temp0';
  }

  @override
  String get bookmarksAll => 'सभी';

  @override
  String get bookmarksEmptyTitle => 'अभी कोई प्रश्न सेव नहीं है';

  @override
  String get bookmarksEmptyBody =>
      'टेस्ट की समीक्षा करते समय किसी भी प्रश्न पर बुकमार्क आइकन दबाएँ, वह हल के साथ यहाँ सेव हो जाएगा।';

  @override
  String get bookmarkRemoved => 'यह बुकमार्क हटा दिया गया।';

  @override
  String get savedQuestion => 'सेव किया गया प्रश्न';

  @override
  String get removeBookmark => 'बुकमार्क हटाएँ';

  @override
  String get bookmarkQuestion => 'इस प्रश्न को बुकमार्क करें';

  @override
  String get savedToBookmarks => 'बुकमार्क में सेव किया गया';

  @override
  String get removedFromBookmarks => 'बुकमार्क से हटाया गया';

  @override
  String get bookmarkSaveFailed =>
      'यह प्रश्न सेव नहीं हो सका। फिर से कोशिश करें।';

  @override
  String get view => 'देखें';

  @override
  String get solution => 'हल';

  @override
  String get correctAnswer => 'सही उत्तर';

  @override
  String get yourAnswer => 'आपका उत्तर';

  @override
  String get correctYourAnswer => 'सही · आपका उत्तर';

  @override
  String get savedToday => 'आज सेव किया';

  @override
  String get savedYesterday => 'कल सेव किया';

  @override
  String savedDaysAgo(int days) {
    return '$days दिन पहले सेव किया';
  }

  @override
  String get offlineTitle => 'डाउनलोड और ऑफ़लाइन';

  @override
  String get offlineIntro => 'इस फ़ोन पर बिना इंटरनेट उपलब्ध';

  @override
  String get offlineSavedQuestions => 'सेव किए गए प्रश्न';

  @override
  String get offlineSavedQuestionsEmpty =>
      'टेस्ट की समीक्षा करते समय प्रश्न बुकमार्क करें';

  @override
  String offlineSavedQuestionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'हल सहित $count प्रश्न',
      one: 'हल सहित 1 प्रश्न',
    );
    return '$_temp0';
  }

  @override
  String get offlineRevision => 'दोहराव सूची';

  @override
  String get offlineRevisionEmpty =>
      'आपके गलत प्रश्न दोहराने के लिए यहाँ जुड़ते हैं';

  @override
  String offlineRevisionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'आपकी पिछली गलतियों से $count प्रश्न',
      one: 'आपकी पिछली गलतियों से 1 प्रश्न',
    );
    return '$_temp0';
  }

  @override
  String get offlineTestsTitle =>
      'टेस्ट शुरू और सबमिट करने के लिए इंटरनेट चाहिए';

  @override
  String get offlineTestsBody =>
      'टेस्ट के दौरान इंटरनेट चला जाए तो आपके उत्तर इस फ़ोन पर सेव रहते हैं और ऑनलाइन होने पर आप जारी रख सकते हैं। पूरे टेस्ट और नोट्स अभी डाउनलोड नहीं किए जा सकते।';

  @override
  String get profileDownloads => 'डाउनलोड और ऑफ़लाइन';

  @override
  String get profileBookmarks => 'बुकमार्क';

  @override
  String get profilePrivacy => 'गोपनीयता और खाता';

  @override
  String get profilePrivacySubtitle => 'खाता नियंत्रण और गोपनीयता सेटिंग';

  @override
  String get retry => 'फिर से कोशिश करें';

  @override
  String get attemptNoQuestions => 'कोई प्रश्न उपलब्ध नहीं';

  @override
  String get attemptSignInRequired =>
      'साइन इन ज़रूरी है। आगे भेजा जा रहा है...';

  @override
  String get attemptPurchaseRequired => 'इस टेस्ट के लिए खरीदना ज़रूरी है।';

  @override
  String attemptLoadFailed(String error) {
    return 'टेस्ट लोड नहीं हो सका: $error';
  }

  @override
  String get attemptRecoveredLocal =>
      'इस डिवाइस से बिना सिंक हुई प्रगति वापस मिली। अब इसे ExamTree से सिंक किया जा रहा है।';

  @override
  String get attemptRestoredServer =>
      'ExamTree से सेव की गई प्रगति वापस लाई गई।';

  @override
  String get attemptTenMinutes => '10 मिनट बाकी';

  @override
  String get attemptFiveMinutes => '5 मिनट बाकी';

  @override
  String get attemptOneMinute => '1 मिनट बाकी। अपनी समीक्षा अभी पूरी करें।';

  @override
  String attemptSecondsRemaining(int seconds) {
    return '$seconds सेकंड बाकी';
  }

  @override
  String get attemptTimeOverSubmitting =>
      'समय समाप्त। आपका टेस्ट सबमिट किया जा रहा है।';

  @override
  String get attemptChangedElsewhere =>
      'यह टेस्ट किसी दूसरे डिवाइस पर बदला गया। सर्वर की नवीनतम प्रगति लोड की गई।';

  @override
  String get attemptSavedNotSynced =>
      'प्रगति इस डिवाइस पर सेव है, पर अभी ExamTree तक नहीं पहुँची।';

  @override
  String get attemptTimeOverRetry =>
      'समय समाप्त। आपके उत्तर इस डिवाइस पर सुरक्षित हैं; इंटरनेट जोड़कर फिर से सबमिट करें।';

  @override
  String get attemptSubmitFailed =>
      'अभी सबमिट नहीं हो सका। आपके उत्तर सेव हैं; फिर से कोशिश करें।';

  @override
  String get attemptStillOpen =>
      'टेस्ट खुला है क्योंकि नवीनतम प्रगति सेव नहीं हो सकी।';

  @override
  String get attemptPreparing => 'आपका सुरक्षित टेस्ट सत्र तैयार हो रहा है...';

  @override
  String get attemptUnableToStart => 'टेस्ट शुरू नहीं हो सका';

  @override
  String get attemptSessionNotCreated => 'टेस्ट सत्र नहीं बन सका।';

  @override
  String get tryAgain => 'फिर से कोशिश करें';

  @override
  String get attemptTimeExpiredSubmitting =>
      'समय समाप्त — आपका टेस्ट सबमिट हो रहा है';

  @override
  String get attemptSubmittingTest => 'आपका टेस्ट सबमिट हो रहा है';

  @override
  String get attemptLockedPending =>
      'समय समाप्त। उत्तर लॉक हैं और सबमिशन बाकी है।';

  @override
  String get attemptRetrySubmit => 'फिर से सबमिट करें';

  @override
  String get attemptSaveAnswer => 'उत्तर सेव करें';

  @override
  String get attemptSaveNext => 'सेव करें और आगे';

  @override
  String attemptPaletteLeft(int count) {
    return 'पैलेट · $count बाकी';
  }

  @override
  String get attemptSubmitting => 'सबमिट हो रहा है…';

  @override
  String get attemptSubmitTest => 'टेस्ट सबमिट करें';

  @override
  String attemptQuestionOf(int number, int total) {
    return 'प्रश्न $number / $total';
  }

  @override
  String get attemptNotSavedRetry => 'प्रगति सेव नहीं हुई। फिर से कोशिश करें।';

  @override
  String get attemptSavingProgress => 'प्रगति सेव हो रही है';

  @override
  String get attemptSaveExit => 'सेव करें और बाहर निकलें';

  @override
  String attemptQuestionNumber(int number) {
    return 'प्रश्न $number';
  }

  @override
  String get attemptMarkedForReview => 'समीक्षा के लिए चिह्नित';

  @override
  String attemptOptionLabel(String letter, String text) {
    return 'विकल्प $letter: $text';
  }

  @override
  String get attemptPrevious => 'पिछला';

  @override
  String get attemptClear => 'हटाएँ';

  @override
  String get attemptReview => 'समीक्षा';

  @override
  String get attemptSubmitQuestion => 'टेस्ट सबमिट करें?';

  @override
  String attemptUnansweredLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count प्रश्नों के उत्तर अभी बाकी हैं। सबमिट करने से पहले आप उन्हें देख सकते हैं।',
      one:
          '1 प्रश्न का उत्तर अभी बाकी है। सबमिट करने से पहले आप उसे देख सकते हैं।',
    );
    return '$_temp0';
  }

  @override
  String get attemptCannotChange =>
      'सबमिट करने के बाद उत्तर नहीं बदले जा सकते।';

  @override
  String get attemptReviewUnanswered => 'बिना उत्तर वाले देखें';

  @override
  String get attemptSubmitNow => 'अभी सबमिट करें';

  @override
  String get attemptContinueTest => 'टेस्ट जारी रखें';

  @override
  String get attemptAnswered => 'उत्तर दिया';

  @override
  String get attemptUnanswered => 'उत्तर नहीं दिया';

  @override
  String get attemptAnsweredMarked => 'उत्तर दिया + चिह्नित';

  @override
  String get attemptSyncNeededTitle => 'प्रगति अभी सिंक होनी बाकी है';

  @override
  String get attemptSyncNeededBody =>
      'आपके नवीनतम उत्तर इस डिवाइस पर सुरक्षित हैं, पर अभी ExamTree तक नहीं पहुँचे। जाने से पहले फिर से सेव करें।';

  @override
  String get attemptSavingTitle => 'आपकी प्रगति सेव हो रही है';

  @override
  String get attemptSavingBody =>
      'ExamTree अभी आपके नवीनतम बदलाव सेव कर रहा है। सेव पूरा होने तक टेस्ट खुला रखें।';

  @override
  String get attemptLeaveTitle => 'सेव करके टेस्ट छोड़ें?';

  @override
  String get attemptLeaveBody =>
      'आपका प्रयास सक्रिय रहेगा और बाद में इस डिवाइस या ExamTree वेबसाइट से जारी किया जा सकता है।';

  @override
  String get attemptRetrySave => 'फिर से सेव करें';

  @override
  String get attemptSaveLeave => 'सेव करें और छोड़ें';

  @override
  String get attemptStay => 'रुकें';

  @override
  String get attemptSavingEllipsis => 'प्रगति सेव हो रही है…';

  @override
  String get attemptWaitingSync =>
      'इस डिवाइस पर सेव। ExamTree से सिंक होने का इंतज़ार।';

  @override
  String get attemptNotSyncedYet =>
      'नवीनतम बदलाव इस डिवाइस पर सुरक्षित हैं पर अभी सिंक नहीं हुए।';

  @override
  String get paletteTitle => 'प्रश्न पैलेट';

  @override
  String get paletteClose => 'पैलेट बंद करें';

  @override
  String get paletteMarked => 'चिह्नित';

  @override
  String paletteUnansweredCount(int count) {
    return 'बिना उत्तर $count';
  }

  @override
  String paletteMarkedCount(int count) {
    return 'चिह्नित $count';
  }

  @override
  String get paletteHint => 'किसी नंबर पर टैप करें और सीधे उस प्रश्न पर जाएँ।';

  @override
  String get paletteNoMatch => 'इस फ़िल्टर से कोई प्रश्न मेल नहीं खाता।';

  @override
  String get paletteShowAll => 'सभी प्रश्न दिखाएँ';

  @override
  String get resultTitle => 'परिणाम';

  @override
  String get resultLoadFailed => 'यह परिणाम लोड नहीं हो सका';

  @override
  String get resultTestResult => 'टेस्ट परिणाम';

  @override
  String resultQuestionsCount(int count) {
    return '$count प्रश्न';
  }

  @override
  String resultMarks(String marks) {
    return '$marks अंक';
  }

  @override
  String get resultRank => 'रैंक';

  @override
  String get resultAccuracy => 'सटीकता';

  @override
  String resultXofY(int x, int y) {
    return '$y में से $x';
  }

  @override
  String get resultTime => 'समय';

  @override
  String get resultSpent => 'लगा';

  @override
  String get resultAttempted => 'हल किए';

  @override
  String resultOfTotal(int total) {
    return '$total में से';
  }

  @override
  String resultScoreA11y(String score, String max) {
    return 'स्कोर $max में से $score।';
  }

  @override
  String resultDelta(String delta) {
    return 'पिछले प्रयास से $delta अंक';
  }

  @override
  String resultLastAttempts(int count) {
    return 'आपके पिछले $count प्रयास';
  }

  @override
  String get resultTrendSubtitle => 'अधिकतम अंकों के प्रतिशत के रूप में स्कोर।';

  @override
  String get resultCorrect => 'सही';

  @override
  String get resultWrong => 'गलत';

  @override
  String get resultSkipped => 'छोड़े';

  @override
  String resultHowWent(int total) {
    return 'आपके $total प्रश्नों का हाल';
  }

  @override
  String resultQuickestWin(String section) {
    return 'सबसे जल्दी सुधार: $section। ';
  }

  @override
  String resultSkippedMost(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'वहाँ आपने $count प्रश्न छोड़े, किसी भी दूसरे सेक्शन से ज़्यादा।',
      one: 'वहाँ आपने 1 प्रश्न छोड़ा, किसी भी दूसरे सेक्शन से ज़्यादा।',
    );
    return '$_temp0';
  }

  @override
  String resultAccuracyValue(String value) {
    return 'सटीकता $value';
  }

  @override
  String resultTimeShare(String section, int share) {
    return '$section में आपका $share% समय लगा।';
  }

  @override
  String resultTimeShareAccuracy(String section, int share, int accuracy) {
    return '$section में आपका $share% समय लगा, $accuracy% सटीकता के साथ।';
  }

  @override
  String resultLowestAccuracy(String section, int accuracy) {
    return '$section में आपकी सबसे कम सटीकता रही, $accuracy%।';
  }

  @override
  String resultLowestAccuracyShare(String section, int accuracy, int share) {
    return '$section में आपकी सबसे कम सटीकता रही, $accuracy%, आपके $share% समय में।';
  }

  @override
  String get resultAccuracyVsTime => 'सटीकता बनाम लगा समय';

  @override
  String get resultAccuracyVsTimeSubtitle =>
      'क्या आपका समय वहीं लग रहा है जहाँ अंक हैं?';

  @override
  String get resultShareOfTime => 'आपके समय का हिस्सा';

  @override
  String get resultTimePerQuestion => 'प्रति प्रश्न समय';

  @override
  String get resultTimePerQuestionSubtitle =>
      'हर प्रश्न के लिए एक बार, पेपर के क्रम में।';

  @override
  String resultSlowest(String section, int number, String time) {
    return 'सबसे धीमा प्रश्न: $section Q$number, $time में।';
  }

  @override
  String get resultQuestionMap => 'प्रश्न मानचित्र';

  @override
  String get resultReviewSolutions => 'हल देखें';

  @override
  String get resultReviseMistakes => 'गलतियाँ दोहराएँ (5 मिनट)';

  @override
  String get resultRetake => 'टेस्ट दोबारा दें';
}
