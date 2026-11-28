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

  @override
  String get resultsHistoryLoadFailed => 'आपका प्रयास इतिहास लोड नहीं हो सका';

  @override
  String get resultsSearchHint => 'टेस्ट या परीक्षा श्रेणियाँ खोजें';

  @override
  String get clearSearch => 'खोज हटाएँ';

  @override
  String get resultsAttemptHistory => 'प्रयास इतिहास';

  @override
  String get resultsAverageScore => 'औसत स्कोर';

  @override
  String resultsAttemptsCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्रयास पूरे',
      one: '1 प्रयास पूरा',
    );
    return '$_temp0';
  }

  @override
  String get resultsBestScore => 'सर्वश्रेष्ठ स्कोर';

  @override
  String get resultsFindAttempt => 'कोई प्रयास खोजें';

  @override
  String get resultsFindHint =>
      'दोबारा क्या देना है, तय करने से पहले गलतियाँ देखें।';

  @override
  String get reset => 'रीसेट';

  @override
  String get resultsAllExams => 'सभी परीक्षाएँ';

  @override
  String get resultsSort => 'परिणाम क्रमबद्ध करें';

  @override
  String get resultsSortNewest => 'नवीनतम';

  @override
  String get resultsSortHighestScore => 'सबसे ज़्यादा स्कोर';

  @override
  String get resultsSortHighestAccuracy => 'सबसे ज़्यादा सटीकता';

  @override
  String get resultsReviewMistakes => 'गलतियाँ देखें';

  @override
  String get resultsReviewAnswers => 'उत्तर देखें';

  @override
  String get resultsRetake => 'दोबारा दें';

  @override
  String resultsAccuracyPct(String value) {
    return '$value% सटीकता';
  }

  @override
  String resultsCorrectCount(int count) {
    return '$count सही';
  }

  @override
  String resultsIncorrectCount(int count) {
    return '$count गलत';
  }

  @override
  String resultsSkippedCount(int count) {
    return '$count छोड़े';
  }

  @override
  String resultsScorePercentA11y(String value) {
    return 'स्कोर $value प्रतिशत';
  }

  @override
  String get resultsEmptyTitle => 'अभी कोई प्रयास पूरा नहीं हुआ';

  @override
  String get resultsEmptyBody =>
      'स्कोर इतिहास, सटीकता और उत्तर समीक्षा देखने के लिए अपना पहला टेस्ट पूरा करें।';

  @override
  String get resultsExploreTests => 'टेस्ट देखें';

  @override
  String get resultsNoMatchTitle => 'इन फ़िल्टर से कोई प्रयास मेल नहीं खाता';

  @override
  String get resultsNoMatchBody =>
      'कोई दूसरा टेस्ट नाम, श्रेणी या क्रम आज़माएँ।';

  @override
  String get resultsResetFilters => 'फ़िल्टर रीसेट करें';

  @override
  String get dateUnavailable => 'तारीख उपलब्ध नहीं';

  @override
  String get examsCategoriesLoadFailed => 'परीक्षा श्रेणियाँ लोड नहीं हो सकीं';

  @override
  String get examsTitle => 'परीक्षाएँ';

  @override
  String get examsLoadFailed => 'परीक्षाएँ लोड नहीं हो सकीं';

  @override
  String examsSearchIn(String category) {
    return '$category परीक्षाएँ खोजें';
  }

  @override
  String examsCategoryExams(String category) {
    return '$category परीक्षाएँ';
  }

  @override
  String examsAvailable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count परीक्षाएँ उपलब्ध',
      one: '1 परीक्षा उपलब्ध',
    );
    return '$_temp0';
  }

  @override
  String get examsTestSeries => 'टेस्ट सीरीज़';

  @override
  String get examsSeriesLoadFailed => 'टेस्ट सीरीज़ लोड नहीं हो सकी';

  @override
  String get examsAvailableSeries => 'उपलब्ध टेस्ट सीरीज़';

  @override
  String get examsNoActiveSeries => 'अभी कोई सक्रिय टेस्ट सीरीज़ नहीं';

  @override
  String examsSeriesAvailable(int count) {
    return '$count सीरीज़ उपलब्ध';
  }

  @override
  String get examsSearchCategories => 'परीक्षा श्रेणियाँ खोजें';

  @override
  String get examsCategories => 'परीक्षा श्रेणियाँ';

  @override
  String get examsChooseCategory =>
      'जिस परीक्षा की तैयारी कर रहे हैं, उसे खोजने के लिए श्रेणी चुनें।';

  @override
  String get examsChoosePath => 'अपनी परीक्षा का रास्ता चुनें';

  @override
  String get examsChoosePathBody =>
      'श्रेणी खोलें, अपनी परीक्षा चुनें और उसकी टेस्ट सीरीज़ पर जाएँ।';

  @override
  String examsCategoriesCount(int count) {
    return '$count श्रेणियाँ';
  }

  @override
  String examsExamsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count परीक्षाएँ',
      one: '1 परीक्षा',
    );
    return '$_temp0';
  }

  @override
  String examsSeriesCount(int count) {
    return '$count सीरीज़';
  }

  @override
  String examsLiveTests(int count) {
    return '$count उपलब्ध टेस्ट';
  }

  @override
  String examsTestsCount(int count) {
    return '$count टेस्ट';
  }

  @override
  String examsTestSeriesCount(int count) {
    return '$count टेस्ट सीरीज़';
  }

  @override
  String examsFullMocks(int count) {
    return '$count फुल मॉक';
  }

  @override
  String examsMinPerTest(int minutes) {
    return '~$minutes मिनट/टेस्ट';
  }

  @override
  String get examsViewTestSeries => 'टेस्ट सीरीज़ देखें';

  @override
  String get examsNoQuestionsYet => 'अभी कोई प्रश्न नहीं';

  @override
  String get examsViewDetails => 'विवरण देखें';

  @override
  String get examsViewSeries => 'सीरीज़ देखें';

  @override
  String get examsEmptyCatalogueTitle =>
      'अभी कोई परीक्षा श्रेणी प्रकाशित नहीं है।';

  @override
  String get examsEmptyCatalogueBody => 'फिर से देखने के लिए नीचे खींचें।';

  @override
  String get examsNoCategoryMatchTitle =>
      'आपकी खोज से कोई परीक्षा श्रेणी मेल नहीं खाती।';

  @override
  String get examsNoCategoryMatchBody =>
      'कोई दूसरा परीक्षा समूह आज़माएँ या खोज हटाएँ।';

  @override
  String get examsNoExamMatchTitle => 'इस खोज से कोई परीक्षा मेल नहीं खाती।';

  @override
  String get examsNoExamMatchBody => 'छोटा परीक्षा नाम आज़माएँ या खोज हटाएँ।';

  @override
  String get examsCategoryUnavailableTitle => 'परीक्षा श्रेणी उपलब्ध नहीं';

  @override
  String get examsCategoryUnavailableBody =>
      'परीक्षा पेज से श्रेणी फिर से खोलें।';

  @override
  String get examsExamUnavailableTitle => 'परीक्षा उपलब्ध नहीं';

  @override
  String get examsExamUnavailableBody =>
      'परीक्षा को उसकी श्रेणी से फिर से खोलें।';

  @override
  String examsNoneInCategoryTitle(String category) {
    return 'अभी कोई $category परीक्षा प्रकाशित नहीं है।';
  }

  @override
  String get examsNoneInCategoryBody =>
      'नई परीक्षाएँ प्रकाशित होते ही यहाँ अपने आप दिखेंगी।';

  @override
  String get examsNoSeriesTitle => 'अभी कोई टेस्ट सीरीज़ उपलब्ध नहीं';

  @override
  String get examsNoSeriesBody =>
      'इस परीक्षा की प्रकाशित टेस्ट सीरीज़ यहाँ अपने आप दिखेंगी।';

  @override
  String get learnCurrentAffairs => 'करंट अफेयर्स';

  @override
  String get learnCurrentAffairsSubtitle =>
      'जल्दी दोहराने के लिए ताज़ा प्रकाशित अपडेट।';

  @override
  String get learnFreePractice => 'मुफ़्त अभ्यास';

  @override
  String get learnFreePracticeSubtitle =>
      'पढ़ाई को तुरंत टेस्ट सत्र में बदलें।';

  @override
  String get learnAllTests => 'सभी टेस्ट';

  @override
  String get learnNotes => 'नोट्स और फ़ॉर्मूला शीट';

  @override
  String get learnNotesSubtitle => 'आपकी परीक्षाओं के लिए प्रकाशित सामग्री।';

  @override
  String get learnHeroTitle => 'अपनी परीक्षाओं के लिए सीखें';

  @override
  String get learnHeroBody =>
      'करंट अफेयर्स, नोट्स और मुफ़्त अभ्यास, जो वास्तव में आपके लिए प्रकाशित हैं।';

  @override
  String get learnArticle => 'लेख';

  @override
  String learnMinFree(int minutes) {
    return '$minutes मिनट · मुफ़्त';
  }

  @override
  String get learnLoadFailed => 'मुफ़्त सीखने की सामग्री लोड नहीं हो सकी';

  @override
  String get learnEmpty =>
      'अभी कोई मुफ़्त सामग्री प्रकाशित नहीं है। प्रकाशित सामग्री यहाँ अपने आप दिखेगी।';

  @override
  String get learnPartialRefresh =>
      'कुछ सामग्री रीफ़्रेश नहीं हो सकी। ऊपर दिखाई गई चीज़ें अभी भी उपलब्ध हैं।';

  @override
  String get learnOpenFailed => 'यह सामग्री खोली नहीं जा सकी।';

  @override
  String get learnSelectedExams => 'चुनी गई परीक्षाएँ';

  @override
  String get homeExamCategories => 'परीक्षा श्रेणियाँ';

  @override
  String get homeSeeAll => 'सभी देखें';

  @override
  String get homeCategoriesFailed => 'परीक्षा श्रेणियाँ लोड नहीं हो सकीं';

  @override
  String get homeNoCategories => 'अभी कोई परीक्षा श्रेणी प्रकाशित नहीं है।';

  @override
  String get homeFeaturedSeries => 'चुनिंदा टेस्ट सीरीज़';

  @override
  String get homeSeriesFailed => 'टेस्ट सीरीज़ लोड नहीं हो सकी';

  @override
  String get homeContinueLearning => 'सीखना जारी रखें';

  @override
  String get homeRecommendedLearning => 'सुझाई गई सामग्री';

  @override
  String get homeCurrentAffairs => 'करंट अफेयर्स';

  @override
  String get homeProgressUnavailable => 'प्रगति अभी उपलब्ध नहीं है';

  @override
  String get familyPunjab => 'पंजाब सरकार';

  @override
  String get familyBanking => 'बैंकिंग';

  @override
  String get familyRailway => 'रेलवे';

  @override
  String get familyTeaching => 'शिक्षण';

  @override
  String get familyDefence => 'रक्षा';

  @override
  String get familyStatePcs => 'राज्य PCS';

  @override
  String get familyOther => 'अन्य परीक्षाएँ';

  @override
  String get homeExplore => 'देखें';

  @override
  String get homeTests => 'टेस्ट';

  @override
  String get homeMins => 'मिनट';

  @override
  String get homeMarks => 'अंक';

  @override
  String get homeQuestions => 'प्रश्न';

  @override
  String get homeDuration => 'अवधि';

  @override
  String minutesShort(int minutes) {
    return '$minutes मिनट';
  }

  @override
  String get homeHeroTitle => 'आपकी तैयारी\nयहाँ से शुरू';

  @override
  String get homeHeroBody =>
      'मॉक टेस्ट, पढ़ाई और परीक्षा-केंद्रित अभ्यास एक ही जगह।';

  @override
  String get homeSearchHint => 'परीक्षाएँ, टेस्ट सीरीज़, विषय खोजें...';

  @override
  String get homeContinueUnavailable => 'सीखना जारी रखें अभी उपलब्ध नहीं है';

  @override
  String get homeKeepGoing => 'लगे रहिए!';

  @override
  String homeTestsCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'अब तक $count टेस्ट पूरे।',
      one: 'अब तक 1 टेस्ट पूरा।',
    );
    return '$_temp0';
  }

  @override
  String get homeSearchTests => 'टेस्ट खोजें';

  @override
  String get homeOpenProfile => 'प्रोफ़ाइल खोलें';

  @override
  String homeNotificationsUnreadA11y(int count) {
    return 'सूचनाएँ, $count अनपढ़ी';
  }

  @override
  String get homeNotificationsNoneA11y => 'सूचनाएँ, कोई नई नहीं';

  @override
  String homeNotificationsUnread(int count) {
    return 'सूचनाएँ ($count अनपढ़ी)';
  }

  @override
  String get homeNotifications => 'सूचनाएँ';

  @override
  String get homeNextActionFailed => 'आपका अगला कदम तैयार नहीं हो सका';

  @override
  String get homeLearn => 'सीखें';

  @override
  String get homeRevision => 'दोहराव';

  @override
  String get homeStore => 'स्टोर';

  @override
  String get homeStrongMomentum => 'बढ़िया रफ़्तार';

  @override
  String get homeKeepConsistency => 'निरंतरता बनाए रखें';

  @override
  String get homeFocusAccuracy => 'पहले सटीकता पर ध्यान दें';

  @override
  String get homeAvgScore => 'औसत स्कोर';

  @override
  String get homePerQuestion => 'प्रति प्रश्न';

  @override
  String homeQs(int count) {
    return '$count प्रश्न';
  }

  @override
  String get homeNoTests => 'अभी कोई टेस्ट प्रकाशित नहीं है।';

  @override
  String get homeCaughtUp => 'आपने सभी मौजूदा सुझाव पूरे कर लिए हैं।';

  @override
  String get homeBrowse => 'देखें';

  @override
  String homeScorePct(int value) {
    return '$value% स्कोर';
  }

  @override
  String homeAccuracyPct(int value) {
    return '$value% सटीकता';
  }

  @override
  String homeDue(int count) {
    return '$count बाकी';
  }

  @override
  String get homeStudent => 'विद्यार्थी';

  @override
  String get homeGoodMorning => 'सुप्रभात';

  @override
  String get homeGoodAfternoon => 'नमस्कार';

  @override
  String get homeGoodEvening => 'शुभ संध्या';

  @override
  String get storeEnterCoupon => 'पहले कूपन कोड डालें।';

  @override
  String storeCouponApplied(String amount) {
    return 'कूपन लगा • $amount की बचत';
  }

  @override
  String get storeChoosePlan => 'प्लान चुनें';

  @override
  String get storePlansFailed => 'प्लान लोड नहीं हो सके';

  @override
  String get storeAlreadyActive => 'यह टेस्ट सीरीज़ पहले से सक्रिय है।';

  @override
  String get storeOpenTestSeries => 'टेस्ट सीरीज़ खोलें';

  @override
  String get storeNoPlan => 'अभी कोई खरीद प्लान उपलब्ध नहीं है।';

  @override
  String storePremiumFree(int premium, int free) {
    return '$premium प्रीमियम टेस्ट • $free मुफ़्त';
  }

  @override
  String get storeChooseAccessPlan => 'अपना एक्सेस प्लान चुनें';

  @override
  String get storePublishedOnly => 'सिर्फ़ अभी प्रकाशित प्लान दिखाए गए हैं।';

  @override
  String get storeHaveCoupon => 'कूपन है?';

  @override
  String get storeCouponHint => 'कूपन कोड डालें';

  @override
  String get storeApply => 'लगाएँ';

  @override
  String get storeSelectedPlan => 'चुना गया प्लान';

  @override
  String get continueLabel => 'जारी रखें';

  @override
  String storeTestsIncluded(int count) {
    return '$count सीरीज़ टेस्ट शामिल';
  }

  @override
  String storePercentOff(int percent) {
    return '$percent% छूट';
  }

  @override
  String get storeOpenPaymentFailed => 'सुरक्षित भुगतान नहीं खुल सका।';

  @override
  String get storeIncompleteConfirmation =>
      'भुगतान की पुष्टि अधूरी मिली। कृपया फिर से जाँचें।';

  @override
  String get storePaymentNotCompleted => 'भुगतान पूरा नहीं हुआ।';

  @override
  String get storeContinueWallet =>
      'भुगतान पूरा करने के लिए अपने वॉलेट में जारी रखें।';

  @override
  String storeContinueInWallet(String wallet) {
    return 'भुगतान पूरा करने के लिए $wallet में जारी रखें।';
  }

  @override
  String get storeActivationProcessing =>
      'भुगतान मिल गया है पर एक्टिवेशन अभी चल रहा है। भुगतान जाँचें दबाएँ।';

  @override
  String get storeCheckout => 'चेकआउट';

  @override
  String get storeCheckoutFailed => 'चेकआउट लोड नहीं हो सका';

  @override
  String get storePlanUnavailable => 'यह प्लान अब उपलब्ध नहीं है।';

  @override
  String get storeReviewPay => 'देखें और भुगतान करें';

  @override
  String get storeCouponRevalidate =>
      'कूपन की दोबारा जाँच नहीं हो सकी। वापस जाकर फिर से लगाएँ।';

  @override
  String get storeVerifyPayment => 'भुगतान जाँचें';

  @override
  String storePayAmount(String amount) {
    return '$amount का भुगतान करें';
  }

  @override
  String get storeOrderSummary => 'ऑर्डर सारांश';

  @override
  String storeAccess(String validity) {
    return '$validity एक्सेस';
  }

  @override
  String get storePlanPrice => 'प्लान कीमत';

  @override
  String get storeCouponDiscount => 'कूपन छूट';

  @override
  String get storeTotalPayable => 'कुल देय राशि';

  @override
  String get storeUpiCards => 'UPI, कार्ड और अन्य';

  @override
  String get storeRazorpayBody =>
      'सुरक्षित Razorpay चेकआउट में UPI, कार्ड, नेट बैंकिंग या वॉलेट चुनें।';

  @override
  String storeCouponSaved(String code, String amount) {
    return '$code लगा • आपकी बचत $amount';
  }

  @override
  String get storeActivating => 'आपकी टेस्ट सीरीज़ सक्रिय हो रही है…';

  @override
  String get storeKeepOpen => 'भुगतान की जाँच होने तक यह स्क्रीन खुली रखें।';

  @override
  String get storeRazorpayNote =>
      'भुगतान Razorpay द्वारा सुरक्षित रूप से होता है। Examtree आपके कार्ड या UPI विवरण कभी सेव नहीं करता।';

  @override
  String get validityAsPublished => 'प्रकाशित वैधता के अनुसार';

  @override
  String validityMonths(int count) {
    return '$count महीने';
  }

  @override
  String validityDays(int count) {
    return '$count दिन';
  }

  @override
  String get paySuccessTitle => 'भुगतान सफल!';

  @override
  String get paySuccessBody =>
      'आपकी टेस्ट सीरीज़ अनलॉक हो गई है और तैयारी के लिए तैयार है।';

  @override
  String get payAccessActive => 'एक्सेस सक्रिय';

  @override
  String get payActive => 'सक्रिय';

  @override
  String get payMockTests => 'मॉक टेस्ट';

  @override
  String get payMockTestsBody => 'आपकी खरीदी गई सीरीज़ का पूरा एक्सेस';

  @override
  String get payAnalysis => 'विस्तृत विश्लेषण';

  @override
  String get payAnalysisBody => 'प्रयास, सटीकता और प्रगति देखें';

  @override
  String get payBilingual => 'द्विभाषी सामग्री';

  @override
  String get payBilingualBody => 'पूरी सीरीज़ में उपलब्ध भाषाओं का उपयोग करें';

  @override
  String get paySolutions => 'विस्तृत हल';

  @override
  String get paySolutionsBody => 'हर प्रयास के बाद व्याख्या देखें';

  @override
  String get paySafe => 'आपकी प्रगति सुरक्षित है';

  @override
  String get paySafeBody =>
      'आपके एक्सेस के साथ प्रयास, विश्लेषण और बुकमार्क सुरक्षित रहते हैं।';

  @override
  String get payStart => 'अभी सीखना शुरू करें';

  @override
  String get payStartBody =>
      'जहाँ छोड़ा था वहीं से जारी रखें और तैयारी सही राह पर रखें।';

  @override
  String get payOrder => 'ऑर्डर';

  @override
  String get payViewReceipt => 'रसीद देखें';

  @override
  String get readyTitle => 'आप तैयार हैं!';

  @override
  String get readyBody =>
      'आपकी ExamTree टेस्ट सीरीज़ सक्रिय है और उपयोग के लिए तैयार है।';

  @override
  String get readyOpen => 'अपनी टेस्ट सीरीज़ खोलें';

  @override
  String get readyOpenBody =>
      'आपकी खरीदी गई सीरीज़ अब मेरी टेस्ट सीरीज़ में दिखती है।';

  @override
  String get readyChoose => 'टेस्ट चुनें';

  @override
  String get readyChooseBody =>
      'फुल मॉक, सेक्शनल, PYQ या विषयवार टेस्ट से शुरू करें।';

  @override
  String get readyTrack => 'अपना प्रदर्शन देखें';

  @override
  String get readyTrackBody =>
      'अपनी प्रोफ़ाइल से स्कोर, सटीकता, प्रयास और प्रगति देखें।';

  @override
  String get readyGoMySeries => 'मेरी टेस्ट सीरीज़ पर जाएँ';

  @override
  String get readyViewOrder => 'ऑर्डर विवरण देखें';
}
