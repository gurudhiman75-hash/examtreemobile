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

  @override
  String get seriesLockedTitle => 'यह टेस्ट लॉक है';

  @override
  String seriesFreeAvailable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'इस सीरीज़ में $count मुफ़्त टेस्ट उपलब्ध हैं।',
      one: 'इस सीरीज़ में 1 मुफ़्त टेस्ट उपलब्ध है।',
    );
    return '$_temp0';
  }

  @override
  String get seriesTryFree => 'मुफ़्त टेस्ट आज़माएँ';

  @override
  String get seriesViewPlansUnlock => 'प्लान देखें और अनलॉक करें';

  @override
  String get seriesMaybeLater => 'बाद में';

  @override
  String seriesStructuredPractice(String exam) {
    return '$exam के लिए व्यवस्थित मॉक-टेस्ट अभ्यास।';
  }

  @override
  String get seriesComingSoon => 'जल्द आ रहा है';

  @override
  String get seriesActive => 'सक्रिय';

  @override
  String get seriesUnavailable => 'उपलब्ध नहीं';

  @override
  String get seriesInPreparation => 'सामग्री तैयार हो रही है';

  @override
  String seriesPercentComplete(int percent) {
    return '$percent% पूरा';
  }

  @override
  String seriesTestsFraction(int done, int total) {
    return '$done/$total टेस्ट';
  }

  @override
  String get seriesPracticeTime => 'अभ्यास समय';

  @override
  String get seriesProgress => 'प्रगति';

  @override
  String get seriesTabOverview => 'अवलोकन';

  @override
  String get seriesTabTestList => 'टेस्ट सूची';

  @override
  String get seriesTabSyllabus => 'पाठ्यक्रम';

  @override
  String get seriesTabPattern => 'परीक्षा पैटर्न';

  @override
  String get seriesTabReviews => 'समीक्षाएँ';

  @override
  String get seriesTabFaqs => 'सवाल-जवाब';

  @override
  String get seriesSequential => 'क्रम से आगे बढ़ें';

  @override
  String get seriesScoreGated => 'स्कोर के आधार पर आगे बढ़ें';

  @override
  String get seriesOpenProgression => 'किसी भी क्रम में दें';

  @override
  String get seriesAbout => 'इस सीरीज़ के बारे में';

  @override
  String seriesOrganisedFor(String exam) {
    return 'यह सीरीज़ $exam के व्यवस्थित अभ्यास के लिए बनाई गई है।';
  }

  @override
  String get seriesIncluded => 'क्या शामिल है';

  @override
  String seriesRequired(int count) {
    return '$count ज़रूरी';
  }

  @override
  String get seriesWhyChoose => 'यह सीरीज़ क्यों चुनें';

  @override
  String get seriesWhyProgress => 'प्रगति ट्रैकिंग';

  @override
  String get seriesWhyProgressBody =>
      'पूरे हुए टेस्ट और आपका अगला टेस्ट हमेशा दिखते रहते हैं।';

  @override
  String get seriesWhyUnlock => 'साफ़ अनलॉक नियम';

  @override
  String get seriesWhyUnlockBody =>
      'टेस्ट खोलने से पहले समय और प्रगति आधारित लॉक दिखाए जाते हैं।';

  @override
  String get seriesWhyInstructions => 'प्रयास से पहले निर्देश';

  @override
  String get seriesWhyInstructionsBody =>
      'हर अनलॉक टेस्ट टाइमर शुरू होने से पहले अपना विवरण और निर्देश दिखाता है।';

  @override
  String get seriesNoTests => 'इस सीरीज़ में अभी कोई टेस्ट उपलब्ध नहीं है।';

  @override
  String seriesTypeCountA11y(String label, int count) {
    return '$label, $count टेस्ट';
  }

  @override
  String get seriesNoPattern => 'अभी कोई टेस्ट पैटर्न उपलब्ध नहीं है।';

  @override
  String get seriesPattern => 'सीरीज़ पैटर्न';

  @override
  String seriesMinTotal(int minutes) {
    return 'कुल $minutes मिनट';
  }

  @override
  String get seriesBreakdown => 'टेस्ट-वार विवरण';

  @override
  String seriesSyllabusBody(String exam) {
    return '$exam की विषयवार पूरी तैयारी। नीचे के टेस्ट समूह प्रकाशित सीरीज़ सूची से बने हैं।';
  }

  @override
  String get seriesSyllabusEmpty => 'टेस्ट प्रकाशित होने पर पाठ्यक्रम दिखेगा।';

  @override
  String seriesPublishedTestsQuestions(int tests, int questions) {
    return '$tests प्रकाशित टेस्ट · $questions प्रश्न';
  }

  @override
  String get seriesReviewsEmpty =>
      'प्रकाशित समीक्षाएँ उपलब्ध होने पर यहाँ दिखेंगी।';

  @override
  String get seriesStudentReviews => 'विद्यार्थियों की समीक्षाएँ';

  @override
  String seriesRatedReviews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count रेटेड समीक्षाएँ',
      one: '1 रेटेड समीक्षा',
    );
    return '$_temp0';
  }

  @override
  String get faqIncludedQ => 'इस टेस्ट सीरीज़ में क्या शामिल है?';

  @override
  String faqIncludedA(int tests, int questions) {
    return '$tests प्रकाशित टेस्ट, कुल $questions प्रश्न, लाइव सूची और आपके एक्सेस प्लान के अनुसार।';
  }

  @override
  String get faqExplanationsQ => 'क्या व्याख्या उपलब्ध है?';

  @override
  String get faqExplanationsA =>
      'पूरे प्रयासों की समीक्षा टेस्ट में उपलब्ध व्याख्या और विश्लेषण के साथ की जा सकती है।';

  @override
  String get faqMultipleQ => 'क्या मैं एक टेस्ट कई बार दे सकता हूँ?';

  @override
  String get faqMultipleA =>
      'प्रयासों की सीमा टेस्ट निर्देश पेज पर दिखती है और टेस्ट सेटिंग से लागू होती है।';

  @override
  String get faqLanguageQ => 'क्या मैं प्रश्नों की भाषा बदल सकता हूँ?';

  @override
  String get faqLanguageA =>
      'टेस्ट शुरू करने से पहले उपलब्ध भाषाएँ दिखाई जाती हैं। यह प्रकाशित प्रश्नों पर निर्भर करता है।';

  @override
  String get faqExpiryQ => 'मेरा एक्सेस खत्म होने पर क्या होगा?';

  @override
  String get faqExpiryA =>
      'आप मेरी टेस्ट सीरीज़ से सीरीज़ रिन्यू कर सकते हैं। मौजूदा प्रगति और विश्लेषण आपके खाते से जुड़े रहते हैं।';

  @override
  String get faqPreviousQ => 'मैं अपने पिछले प्रयास कहाँ देख सकता हूँ?';

  @override
  String get faqPreviousA =>
      'पूरे प्रयास और प्रदर्शन देखने के लिए मेरी टेस्ट सीरीज़, प्रोफ़ाइल या परिणाम खोलें।';

  @override
  String get seriesYourProgress => 'आपकी सीरीज़ प्रगति';

  @override
  String seriesCompletedOf(int done, int total) {
    return '$total में से $done टेस्ट पूरे';
  }

  @override
  String get typeFullTitle => 'फुल लेंथ मॉक टेस्ट';

  @override
  String get typeFullSubtitle => 'नए पैटर्न पर पूरे पाठ्यक्रम के टेस्ट';

  @override
  String get typeSectionalTitle => 'सेक्शनल टेस्ट';

  @override
  String get typeSectionalSubtitle => 'विषयवार अभ्यास टेस्ट';

  @override
  String get typeTopicTitle => 'टॉपिक-वार टेस्ट';

  @override
  String get typeTopicSubtitle => 'ज़रूरी टॉपिक पर केंद्रित अभ्यास';

  @override
  String get typePyqTitle => 'पिछले वर्ष के पेपर';

  @override
  String get typePyqSubtitle => 'समीक्षा सहित पिछले परीक्षा पेपर';

  @override
  String get typeFullTab => 'फुल';

  @override
  String get typeSectionalTab => 'सेक्शनल';

  @override
  String get typeTopicTab => 'टॉपिक-वार';

  @override
  String get typePyqTab => 'PYQ';

  @override
  String get seriesStateCompleted => 'पूरा';

  @override
  String get seriesStatePremium => 'प्रीमियम';

  @override
  String get seriesStateReady => 'तैयार';

  @override
  String get seriesStateLocked => 'लॉक';

  @override
  String get seriesOptional => 'वैकल्पिक';

  @override
  String get seriesRequiredTag => 'ज़रूरी';

  @override
  String seriesBestScore(String score) {
    return 'सर्वश्रेष्ठ स्कोर: $score';
  }

  @override
  String get seriesOpenAgain => 'टेस्ट फिर से खोलें';

  @override
  String get seriesViewInstructions => 'निर्देश देखें';

  @override
  String get seriesUnlockPremium => 'प्रीमियम टेस्ट अनलॉक करें';

  @override
  String get seriesProgressLabel => 'सीरीज़ प्रगति';

  @override
  String get seriesStatus => 'सीरीज़ स्थिति';

  @override
  String get seriesUpNext => 'अगला';

  @override
  String get seriesPremiumRequired => 'प्रीमियम एक्सेस ज़रूरी';

  @override
  String seriesFromPrice(String price) {
    return '$price से';
  }

  @override
  String get seriesAllCompleted => 'सभी टेस्ट पूरे';

  @override
  String get seriesNoneAvailable => 'अभी कोई टेस्ट उपलब्ध नहीं';

  @override
  String get seriesViewPlans => 'प्लान देखें';

  @override
  String get seriesReviewTests => 'टेस्ट देखें';

  @override
  String get seriesOpenTest => 'टेस्ट खोलें';

  @override
  String get seriesLoadFailed => 'टेस्ट सीरीज़ लोड नहीं हो सकी।';

  @override
  String get seriesCheckConnection => 'इंटरनेट जाँचें और फिर से कोशिश करें।';

  @override
  String get loginLetSBuildYourExam => 'आइए आपकी परीक्षा सफलता बनाएँ';

  @override
  String get loginMasterConceptsPracticeSmarterGet =>
      'कॉन्सेप्ट समझें। समझदारी से अभ्यास करें। असली नतीजे पाएँ।';

  @override
  String get loginPracticeTheWayRealExams =>
      'वैसे ही अभ्यास करें जैसे असली परीक्षा पूछती है';

  @override
  String get loginUseFocusedMockTestsAnd =>
      'केंद्रित मॉक टेस्ट और विस्तृत हल से तैयारी को परीक्षा की तैयारी में बदलें।';

  @override
  String get loginKnowWhatToReviseNext => 'जानें आगे क्या दोहराना है';

  @override
  String get loginContinueWhereYouLeftOff =>
      'जहाँ छोड़ा था वहीं से जारी रखें और अपनी प्रगति से दोहराव को सही दिशा दें।';

  @override
  String get loginTooManyVerificationAttemptsPlease =>
      'बहुत ज़्यादा प्रयास हो गए। थोड़ा रुककर फिर से कोशिश करें।';

  @override
  String get loginSmsVerificationIsTemporarilyUnavailable =>
      'SMS सत्यापन अभी उपलब्ध नहीं है। बाद में फिर से कोशिश करें।';

  @override
  String get loginThisExamtreeBuildIsNot =>
      'यह ExamTree संस्करण फ़ोन साइन-इन के लिए अधिकृत नहीं है।';

  @override
  String get loginPhoneVerificationCouldNotBe =>
      'फ़ोन सत्यापन की पुष्टि नहीं हो सकी। फिर से कोशिश करें।';

  @override
  String get loginCouldNotReachTheVerification =>
      'सत्यापन सेवा तक नहीं पहुँच सके। इंटरनेट जाँचें और फिर से कोशिश करें।';

  @override
  String get loginThisVerificationSessionHasExpired =>
      'यह सत्यापन सत्र समाप्त हो गया है। नया OTP मँगाएँ।';

  @override
  String get loginPhoneSignInIsNot =>
      'इस ExamTree संस्करण में फ़ोन साइन-इन चालू नहीं है।';

  @override
  String get loginGoogleSignInIsTemporarily =>
      'Google साइन-इन अभी उपलब्ध नहीं है। बाद में फिर से कोशिश करें।';

  @override
  String get loginThisEmailAlreadyHasAn =>
      'इस ईमेल का ExamTree साइन-इन तरीका पहले से है। पहले उस तरीके से साइन इन करें, फिर Google दोबारा आज़माएँ।';

  @override
  String get loginGoogleDidNotProvideA =>
      'Google ने इस खाते के लिए सत्यापित ईमेल नहीं दिया।';

  @override
  String get loginGoogleSignInCouldNot =>
      'Google साइन-इन सेवा तक नहीं पहुँच सका। इंटरनेट जाँचें और फिर से कोशिश करें।';

  @override
  String get loginAppleSignInWasCanceled =>
      'Apple साइन-इन रद्द हुआ। फिर से कोशिश करें।';

  @override
  String get loginAppleSignInIsTemporarily =>
      'Apple साइन-इन अभी उपलब्ध नहीं है। बाद में फिर से कोशिश करें।';

  @override
  String get loginThisEmailAlreadyHasAn2 =>
      'इस ईमेल का ExamTree साइन-इन तरीका पहले से है। पहले उस तरीके से साइन इन करें, फिर Apple दोबारा आज़माएँ।';

  @override
  String get loginAppleDidNotProvideA =>
      'Apple ने इस खाते के लिए उपयोगी सत्यापित ईमेल नहीं दिया।';

  @override
  String get loginAppleSignInCouldNot =>
      'Apple साइन-इन सेवा तक नहीं पहुँच सका। इंटरनेट जाँचें और फिर से कोशिश करें।';

  @override
  String get loginResetPassword => 'पासवर्ड रीसेट करें';

  @override
  String get loginRecoverYourAccount => 'अपना खाता वापस पाएँ';

  @override
  String get loginEnterTheEmailYouUse =>
      'ExamTree के लिए इस्तेमाल किया ईमेल डालें, हम पासवर्ड रीसेट निर्देश भेजेंगे।';

  @override
  String get loginEmail => 'ईमेल';

  @override
  String get loginForPrivacyTheConfirmationScreen =>
      'गोपनीयता के लिए, पुष्टि स्क्रीन यह नहीं बताती कि ईमेल पंजीकृत है या नहीं।';

  @override
  String get loginBackToSignIn => 'साइन इन पर वापस जाएँ';

  @override
  String get loginCheckYourEmail => 'अपना ईमेल देखें';

  @override
  String get loginCheckYourSpamFolderToo =>
      'स्पैम फ़ोल्डर भी देखें। गोपनीयता के लिए हम नहीं बताते कि ईमेल पंजीकृत है या नहीं।';

  @override
  String get loginSendingAnotherResetEmail =>
      'एक और रीसेट ईमेल भेजा जा रहा है…';

  @override
  String get loginUseAnotherEmail => 'दूसरा ईमेल इस्तेमाल करें';

  @override
  String get loginEnterAValidEmailAddress => 'सही ईमेल पता डालें।';

  @override
  String get loginEnterYourPassword => 'अपना पासवर्ड डालें।';

  @override
  String get loginPreparingSignIn => 'साइन-इन तैयार हो रहा है…';

  @override
  String get loginUnableToSignInPlease =>
      'साइन इन नहीं हो सका। फिर से कोशिश करें।';

  @override
  String get loginEnterAValidMobileNumber => 'सही मोबाइल नंबर डालें।';

  @override
  String get loginTheOtpYouEnteredIs => 'आपका डाला OTP गलत है।';

  @override
  String get loginUnableToVerifyThisMobile =>
      'यह मोबाइल नंबर सत्यापित नहीं हो सका। फिर से कोशिश करें।';

  @override
  String get loginEnterAValid10Digit => 'सही 10 अंकों का मोबाइल नंबर डालें।';

  @override
  String get loginSendingOtp => 'OTP भेजा जा रहा है…';

  @override
  String get loginUnableToSendTheOtp =>
      'OTP नहीं भेजा जा सका। फिर से कोशिश करें।';

  @override
  String get loginRequestANewOtpFirst => 'पहले नया OTP मँगाएँ।';

  @override
  String get loginEnterThe6DigitOtp => '6 अंकों का OTP डालें।';

  @override
  String get loginVerifyingOtp => 'OTP सत्यापित हो रहा है…';

  @override
  String get loginUnableToVerifyTheOtp =>
      'OTP सत्यापित नहीं हो सका। फिर से कोशिश करें।';

  @override
  String get loginSendingANewOtp => 'नया OTP भेजा जा रहा है…';

  @override
  String get loginUnableToResendTheOtp =>
      'OTP दोबारा नहीं भेजा जा सका। फिर से कोशिश करें।';

  @override
  String get loginPreparingGoogleSignIn => 'Google साइन-इन तैयार हो रहा है…';

  @override
  String get loginGoogleSignInWasCanceled =>
      'Google साइन-इन रद्द हुआ। फिर से कोशिश करें।';

  @override
  String get loginGoogleSignInCouldNot2 =>
      'Google साइन-इन पूरा नहीं हो सका। फिर से कोशिश करें।';

  @override
  String get loginUnableToSignInWith =>
      'Google से साइन इन नहीं हो सका। फिर से कोशिश करें।';

  @override
  String get loginPreparingAppleSignIn => 'Apple साइन-इन तैयार हो रहा है…';

  @override
  String get loginAppleSignInCouldNot2 =>
      'Apple साइन-इन पूरा नहीं हो सका। फिर से कोशिश करें।';

  @override
  String get loginUnableToSignInWith2 =>
      'Apple से साइन इन नहीं हो सका। फिर से कोशिश करें।';

  @override
  String get loginEnterYourName => 'अपना नाम डालें।';

  @override
  String get loginNameMustBe80Characters =>
      'नाम 80 अक्षरों या कम का होना चाहिए।';

  @override
  String get loginUseAtLeast6Characters => 'पासवर्ड में कम से कम 6 अक्षर रखें।';

  @override
  String get loginPasswordsDoNotMatch => 'पासवर्ड मेल नहीं खाते।';

  @override
  String get loginPreparingAccountSetup => 'खाता बनाने की तैयारी हो रही है…';

  @override
  String get loginUnableToCreateYourAccount =>
      'आपका खाता नहीं बन सका। फिर से कोशिश करें।';

  @override
  String get authCreateYourExamtreeAccount => 'अपना ExamTree खाता बनाएँ';

  @override
  String get authSetUpYourAccountAnd => 'खाता बनाएँ और अपनी तैयारी सिंक रखें।';

  @override
  String get authSecureSignInYourProgress =>
      'सुरक्षित साइन-इन। आपकी प्रगति सिंक रहती है।';

  @override
  String get authLoginWithMobileNumber => 'मोबाइल नंबर से लॉगिन करें';

  @override
  String get authWeLlSendYouA => 'हम आपको एक बार का पासवर्ड (OTP) भेजेंगे';

  @override
  String get authEnterMobileNumber => 'मोबाइल नंबर डालें';

  @override
  String get authGetOtp => 'OTP पाएँ';

  @override
  String get authEnterOtp => 'OTP डालें';

  @override
  String get authChange => 'बदलें';

  @override
  String get authVerifyContinue => 'सत्यापित करें और जारी रखें';

  @override
  String get authContinueWithGoogle => 'Google से जारी रखें';

  @override
  String get authContinueWithEmail => 'ईमेल से जारी रखें';

  @override
  String get authContinueWithApple => 'Apple से जारी रखें';

  @override
  String get authSignInWithEmail => 'ईमेल से साइन इन करें';

  @override
  String get authName => 'नाम';

  @override
  String get authPassword => 'पासवर्ड';

  @override
  String get authConfirmPassword => 'पासवर्ड की पुष्टि करें';

  @override
  String get authForgotPassword => 'पासवर्ड भूल गए?';

  @override
  String get caThisCurrentAffairsItemCould =>
      'यह करंट अफेयर्स आइटम नहीं खुल सका।';

  @override
  String get caUnableToLoadCurrentAffairs => 'करंट अफेयर्स लोड नहीं हो सके';

  @override
  String get caLatestUpdates => 'ताज़ा अपडेट';

  @override
  String get caStayReadyForWhatChanged => 'जो बदला है, उसके लिए तैयार रहें।';

  @override
  String get caReadPublishedUpdatesInYour =>
      'प्रकाशित अपडेट अपनी पसंदीदा भाषा में पढ़ें और परीक्षा से जुड़ी घटनाएँ पास रखें।';

  @override
  String get caNoCurrentAffairsArePublished =>
      'अभी कोई करंट अफेयर्स प्रकाशित नहीं है।';

  @override
  String get caNewPublishedUpdatesWillAppear =>
      'नए प्रकाशित अपडेट यहाँ अपने आप दिखेंगे।';

  @override
  String get caNoPublishedItemsMatchThis =>
      'इस प्रारूप में अभी कोई प्रकाशित आइटम नहीं है।';

  @override
  String get myExamsMyExams => 'मेरी परीक्षाएँ';

  @override
  String get myExamsUnableToLoadYourExam => 'आपकी परीक्षा सूची लोड नहीं हो सकी';

  @override
  String get myExamsMyExamsUpdated => 'मेरी परीक्षाएँ अपडेट हुईं।';

  @override
  String get myExamsUnableToSaveYourSelected =>
      'आपकी चुनी परीक्षाएँ सेव नहीं हो सकीं।';

  @override
  String get myExamsSearchExamsOrExamFamilies =>
      'परीक्षाएँ या परीक्षा समूह खोजें';

  @override
  String get myExamsChooseWhatYouArePreparing =>
      'चुनें आप किसकी तैयारी कर रहे हैं';

  @override
  String get myExamsExamtreeWillUseTheseChoices =>
      'ExamTree इन विकल्पों से टेस्ट, मुफ़्त सामग्री और ज़रूरी अपडेट व्यवस्थित करेगा। आप इन्हें कभी भी बदल सकते हैं।';

  @override
  String get myExamsClearSelection => 'चुनाव हटाएँ';

  @override
  String get myExamsNoExamsMatchThatSearch =>
      'इस खोज से कोई परीक्षा मेल नहीं खाती।';

  @override
  String get myExamsTryTheExamNameCode =>
      'परीक्षा का नाम, कोड या परीक्षा समूह आज़माएँ।';

  @override
  String get dailyStudyPlanSavedButNotifications =>
      'अध्ययन योजना सेव हुई, पर सूचनाएँ बंद हैं।';

  @override
  String get dailyUnableToSaveTheStudy => 'अध्ययन योजना सेव नहीं हो सकी।';

  @override
  String get dailyDailyCompanion => 'दैनिक साथी';

  @override
  String get dailyRefresh => 'रीफ़्रेश';

  @override
  String get dailyQuickRevision => 'जल्दी दोहराव';

  @override
  String get dailyStudyPlan => 'अध्ययन योजना';

  @override
  String get dailyKeepYourDailyTargetAnd =>
      'अपना दैनिक लक्ष्य और रिमाइंडर व्यावहारिक रखें।';

  @override
  String get dailyDailyCompanionIsUnavailable => 'दैनिक साथी उपलब्ध नहीं है';

  @override
  String get dailyYourSavedRevisionQueueIs =>
      'आपकी सेव दोहराव सूची अभी भी इस डिवाइस पर है। फिर से लोड करें।';

  @override
  String get dailyRetryDailyCompanion => 'दैनिक साथी फिर से लोड करें';

  @override
  String get dailyTodaySRevision => 'आज का दोहराव';

  @override
  String get dailyExamDayMode => 'परीक्षा-दिवस मोड';

  @override
  String get dailyCountdownLogisticsChecklistAndLocal =>
      'उलटी गिनती, तैयारी चेकलिस्ट और रिमाइंडर';

  @override
  String get dailyCompleteTestsToBuildA =>
      'गलत, छोड़े गए, चिह्नित और धीमे प्रश्नों से निजी दोहराव सूची बनाने के लिए टेस्ट पूरे करें।';

  @override
  String get dailyMyStudyPlan => 'मेरी अध्ययन योजना';

  @override
  String get dailySetARealisticDailyReview =>
      'व्यावहारिक दैनिक लक्ष्य और वैकल्पिक रिमाइंडर सेट करें।';

  @override
  String get dailyLocalStudyReminder => 'अध्ययन रिमाइंडर';

  @override
  String get dailyChangeReminderTime => 'रिमाइंडर का समय बदलें';

  @override
  String get dailyDecreaseDailyQuestionGoal => 'दैनिक प्रश्न लक्ष्य घटाएँ';

  @override
  String get dailyIncreaseDailyQuestionGoal => 'दैनिक प्रश्न लक्ष्य बढ़ाएँ';

  @override
  String get dailyDailyQuestionGoal => 'दैनिक प्रश्न लक्ष्य';

  @override
  String get revisionUnableToSaveThisReview => 'यह समीक्षा सेव नहीं हो सकी।';

  @override
  String get revisionRevisionQueueUnavailable => 'दोहराव सूची उपलब्ध नहीं';

  @override
  String get revisionTryLoadingYourSavedRevision =>
      'अपने सेव किए दोहराव प्रश्न फिर से लोड करें।';

  @override
  String get revisionReviewTheQuestion => 'प्रश्न देखें';

  @override
  String get revisionShowAnswer => 'उत्तर दिखाएँ';

  @override
  String get revisionRecallFirstRevealTheStored =>
      'पहले याद करें। तैयार होने पर उत्तर देखें।';

  @override
  String get revisionCompareThisWithTheReasoning =>
      'इसे अपने याद किए तर्क से मिलाएँ।';

  @override
  String get revisionHowWellDidYouRemember => 'आपको यह कितना अच्छा याद था?';

  @override
  String get revisionChooseGotItIfYou =>
      'अगर आप अभी उत्तर समझा सकते हैं तो “समझ गया” चुनें। जल्दी दोबारा देखने के लिए “फिर से देखें” चुनें।';

  @override
  String get revisionReviewAgain => 'फिर से देखें';

  @override
  String get revisionGotIt => 'समझ गया';

  @override
  String get notifAllNotificationsMarkedAsRead =>
      'सभी सूचनाएँ पढ़ी गई चिह्नित।';

  @override
  String get notifUnableToMarkNotificationsAs =>
      'सूचनाओं को पढ़ा चिह्नित नहीं किया जा सका।';

  @override
  String get notifMarkAllRead => 'सभी पढ़ी चिह्नित करें';

  @override
  String get notifImportantUpdatesInOnePlace => 'ज़रूरी अपडेट, एक जगह।';

  @override
  String get notifExamRemindersLearningUpdatesAnd =>
      'परीक्षा रिमाइंडर, पढ़ाई अपडेट और टेस्ट घोषणाएँ आसानी से मिलती हैं।';

  @override
  String get notifOpenLink => 'लिंक खोलें';

  @override
  String get notifNoNotificationsYet => 'अभी कोई सूचना नहीं';

  @override
  String get notifImportantExamtreeUpdatesWillAppear =>
      'ज़रूरी ExamTree अपडेट यहाँ दिखेंगे जब कुछ ध्यान देने लायक होगा।';

  @override
  String get notifUnableToLoadNotifications => 'सूचनाएँ लोड नहीं हो सकीं';

  @override
  String get notifTryAgain => 'फिर से कोशिश करें';

  @override
  String get profileMyProfile => 'मेरी प्रोफ़ाइल';

  @override
  String get profileSettings => 'सेटिंग';

  @override
  String get profileUnableToLoadYourPerformance =>
      'आपका प्रदर्शन लोड नहीं हो सका';

  @override
  String get profileAccount => 'खाता';

  @override
  String get profilePreferencesPrivacyAndThisDevice =>
      'पसंद, गोपनीयता और इस डिवाइस का सत्र।';

  @override
  String get profileUsedInTestsAnswerReview =>
      'टेस्ट, उत्तर समीक्षा और सेव दोहराव प्रश्नों में उपयोग होती है। अनुवाद न होने पर अंग्रेज़ी दिखती है।';

  @override
  String get profileUnableToSaveTheQuestion =>
      'इस डिवाइस पर प्रश्नों की भाषा सेव नहीं हो सकी।';

  @override
  String get profileYourProfile => 'आपकी प्रोफ़ाइल';

  @override
  String get profileMyProgress => 'मेरी प्रगति';

  @override
  String get profileAccuracyAttemptsAndPerformance =>
      'सटीकता, प्रयास और प्रदर्शन';

  @override
  String get profileOfflineLearningResources => 'ऑफ़लाइन सामग्री';

  @override
  String get profileSavedRevisionItems => 'सेव किए दोहराव आइटम';

  @override
  String get profileTestHistory => 'टेस्ट इतिहास';

  @override
  String get profileCompletedAttemptsAndResults => 'पूरे प्रयास और परिणाम';

  @override
  String get profileCouponsOffers => 'कूपन और ऑफ़र';

  @override
  String get profileApplyDiscountsDuringCheckout => 'चेकआउट पर छूट लगाएँ';

  @override
  String get profileEditProfile => 'प्रोफ़ाइल बदलें';

  @override
  String get profileUpdateYourLearnerName => 'अपना नाम अपडेट करें';

  @override
  String get profileHelpSupport => 'सहायता';

  @override
  String get profileCommonQuestionsAndAccountHelp => 'आम सवाल और खाता सहायता';

  @override
  String get profilePerformance => 'प्रदर्शन';

  @override
  String get profileYourCompletedTestSignalsAt => 'आपके पूरे टेस्ट की झलक।';

  @override
  String get profileFullHistory => 'पूरा इतिहास';

  @override
  String get profileRecentTrend => 'हाल का रुझान';

  @override
  String get profileYourLatestCompletedTests => 'आपके हाल के पूरे टेस्ट।';

  @override
  String get profileAvgTime => 'औसत समय';

  @override
  String get profileWhatToFocusOn => 'किस पर ध्यान दें';

  @override
  String get profileSectionDetailWillAppearAfter =>
      'प्रश्नों की समीक्षा उपलब्ध होने पर सेक्शन विवरण दिखेगा।';

  @override
  String get profileStrongest => 'सबसे मज़बूत';

  @override
  String get profileNeedsAttention => 'ध्यान चाहिए';

  @override
  String get profileReviewLatest => 'नवीनतम देखें';

  @override
  String get profileYourPerformanceStartsWithYour =>
      'आपका प्रदर्शन पहले टेस्ट से शुरू होता है';

  @override
  String get profileCompleteATestToBuild =>
      'स्कोर, सटीकता, सेक्शन और रुझान देखने के लिए एक टेस्ट पूरा करें।';

  @override
  String get profileBrowseTests => 'टेस्ट देखें';

  @override
  String get profileMyResults => 'मेरे परिणाम';

  @override
  String get profileSearchAndReviewCompletedAttempts =>
      'पूरे प्रयास खोजें और देखें';

  @override
  String get profileSignOut => 'साइन आउट';

  @override
  String get profileEndThisDeviceSession => 'इस डिवाइस का सत्र समाप्त करें';

  @override
  String get auxYourProgressStartsWithYour =>
      'आपकी प्रगति पहले टेस्ट से शुरू होती है';

  @override
  String get auxCompleteAMockOrPractice =>
      'सटीकता, स्कोर और सेक्शन जानकारी के लिए कोई मॉक या अभ्यास टेस्ट पूरा करें।';

  @override
  String get auxOverallAccuracy => 'कुल सटीकता';

  @override
  String get auxAverageScore => 'औसत स्कोर';

  @override
  String get auxAppPreferences => 'ऐप पसंद';

  @override
  String get auxLanguage => 'भाषा';

  @override
  String get auxLearning => 'पढ़ाई';

  @override
  String get auxProfileUpdated => 'प्रोफ़ाइल अपडेट हुई।';

  @override
  String get auxUnableToUpdateYourProfile =>
      'अभी आपकी प्रोफ़ाइल अपडेट नहीं हो सकी।';

  @override
  String get auxVerifiedContact => 'सत्यापित संपर्क';

  @override
  String get auxEmailAndPhoneChangesRequire =>
      'ईमेल और फ़ोन बदलने के लिए सत्यापन ज़रूरी है; ये आपके साइन-इन खाते से बदलते हैं।';

  @override
  String get auxApplyCouponsAtCheckout => 'चेकआउट पर कूपन लगाएँ';

  @override
  String get auxAvailableCouponCodesCanBe =>
      'टेस्ट सीरीज़ प्लान चुनते या रिन्यू करते समय कूपन कोड डाले जा सकते हैं।';

  @override
  String get auxExploreTestSeries => 'टेस्ट सीरीज़ देखें';

  @override
  String get accountAccountDeletionCouldNotBe =>
      'खाता हटाना पूरा नहीं हो सका। फिर से कोशिश करें।';

  @override
  String get accountSignInAgainToContinue =>
      'जारी रखने के लिए फिर से साइन इन करें';

  @override
  String get accountYouWillReturnHereAfter =>
      'फिर से साइन इन करने के बाद आप यहीं लौटेंगे।';

  @override
  String get accountCancel => 'रद्द करें';

  @override
  String get accountSignInAgain => 'फिर से साइन इन करें';

  @override
  String get accountDeleteYourExamtreeAccount => 'अपना ExamTree खाता हटाएँ?';

  @override
  String get accountThisCannotBeUndoneType =>
      'यह वापस नहीं होगा। जारी रखने के लिए DELETE MY ACCOUNT लिखें।';

  @override
  String get accountConfirmation => 'पुष्टि';

  @override
  String get accountKeepMyAccount => 'मेरा खाता रखें';

  @override
  String get accountDeleteAccount => 'खाता हटाएँ';

  @override
  String get accountThisPageCouldNotBe =>
      'यह पेज नहीं खुल सका। बाद में फिर से कोशिश करें।';

  @override
  String get accountYourLearnerData => 'आपका डेटा';

  @override
  String get accountClearInformationAboutWhatExamtree =>
      'ExamTree क्या इस्तेमाल करता है और पूरी नीति कहाँ पढ़ें, इसकी साफ़ जानकारी।';

  @override
  String get accountLearningActivity => 'पढ़ाई गतिविधि';

  @override
  String get accountExamtreeUsesYourAccountInformation =>
      'ExamTree आपकी खाता जानकारी से आपको पहचानता है, टेस्ट प्रयास सेव करता है, परिणाम दिखाता है और विश्लेषण देता है। विज्ञापन के लिए हमें आपके उत्तरों की ज़रूरत नहीं है।';

  @override
  String get accountPrivacyPolicy => 'गोपनीयता नीति';

  @override
  String get accountReadTheProductionPolicyCovering =>
      'डेटा उपयोग, रखरखाव, हटाने और गोपनीयता संपर्क की पूरी नीति पढ़ें।';

  @override
  String get accountOpenPrivacyPolicy => 'गोपनीयता नीति खोलें';

  @override
  String get accountAccountDeletionOnTheWeb => 'वेब पर खाता हटाना';

  @override
  String get accountYouCanAlsoStartAn =>
      'आप ExamTree के सार्वजनिक वेब पेज से भी खाता हटाने का अनुरोध कर सकते हैं।';

  @override
  String get accountOpenDeletionPage => 'हटाने वाला पेज खोलें';

  @override
  String get accountYourPrivacyYourAccount => 'आपकी गोपनीयता, आपका खाता';

  @override
  String get accountReviewHowLearnerDataIs =>
      'देखें आपका डेटा कैसे इस्तेमाल होता है और खाता स्थायी रूप से हटाने का प्रबंधन करें।';

  @override
  String get accountDeletingYourAccountPermanentlyRemoves =>
      'खाता हटाने से आपके प्रयास, परिणाम, प्रोफ़ाइल डेटा और सक्रिय एक्सेस स्थायी रूप से हट जाते हैं। जहाँ वित्तीय या सुरक्षा रिकॉर्ड रखना ज़रूरी है, वहाँ सिर्फ़ एक गुमनाम रिकॉर्ड रह सकता है।';

  @override
  String get accountYouWillBeAskedTo =>
      'कुछ भी हटाने से पहले आपसे DELETE MY ACCOUNT लिखने को कहा जाएगा।';

  @override
  String get examDayExamTargetSavedButNotification =>
      'परीक्षा लक्ष्य सेव हुआ, पर सूचना अनुमति बंद है।';

  @override
  String get examDayUnableToSaveTheExam => 'परीक्षा लक्ष्य सेव नहीं हो सका।';

  @override
  String get examDayUnableToUpdateTheChecklist => 'चेकलिस्ट अपडेट नहीं हो सकी।';

  @override
  String get examDayAddChecklistItem => 'चेकलिस्ट आइटम जोड़ें';

  @override
  String get examDayEGBusTicketSaved => 'जैसे: बस टिकट ऑफ़लाइन सेव';

  @override
  String get examDayAdd => 'जोड़ें';

  @override
  String get examDayRemoveExamTarget => 'परीक्षा लक्ष्य हटाएँ?';

  @override
  String get examDayThisRemovesTheLocalCountdown =>
      'इससे इस डिवाइस से उलटी गिनती, चेकलिस्ट और परीक्षा-दिवस रिमाइंडर हट जाएँगे। टेस्ट इतिहास नहीं बदलेगा।';

  @override
  String get examDayRemoveTarget => 'लक्ष्य हटाएँ';

  @override
  String get examDayUnableToRemoveTheExam =>
      'परीक्षा लक्ष्य हटाया नहीं जा सका।';

  @override
  String get examDayEditTarget => 'लक्ष्य बदलें';

  @override
  String get examDayExamDayModeIsUnavailable =>
      'परीक्षा-दिवस मोड उपलब्ध नहीं है';

  @override
  String get examDayTryLoadingYourSavedTarget =>
      'अपना सेव लक्ष्य फिर से लोड करें।';

  @override
  String get examDayRetryExamDayMode => 'परीक्षा-दिवस मोड फिर से लोड करें';

  @override
  String get examDaySetOneActiveExamTarget =>
      'एक सक्रिय परीक्षा लक्ष्य सेट करें';

  @override
  String get examDayKeepAPrivateCountdownLogistics =>
      'इस फ़ोन पर निजी उलटी गिनती, तैयारी चेकलिस्ट और वैकल्पिक रिमाइंडर रखें।';

  @override
  String get examDaySetExamTarget => 'परीक्षा लक्ष्य सेट करें';

  @override
  String get examDayYouProvideTheExamDetails => 'परीक्षा विवरण आप देते हैं';

  @override
  String get examDayExamtreeDoesNotInventExam =>
      'ExamTree परीक्षा की तारीख, रिपोर्टिंग समय, केंद्र या तैयारी स्कोर नहीं बनाता। सेव विवरण हमेशा आधिकारिक सूचना या एडमिट कार्ड से मिलाएँ।';

  @override
  String get examDayReportingCountdown => 'रिपोर्टिंग उलटी गिनती';

  @override
  String get examDayUsefulNow => 'अभी काम का';

  @override
  String get examDayKeepTheLastMileActions =>
      'आखिरी तैयारी केंद्रित और जानी-पहचानी रखें।';

  @override
  String get examDaySavedLogistics => 'सेव विवरण';

  @override
  String get examDayOnlyTheDetailsYouEntered =>
      'सिर्फ़ वही विवरण जो आपने इस लक्ष्य के लिए डाले।';

  @override
  String get examDayEdit => 'बदलें';

  @override
  String get examDayOfficialInstructionsRemainAuthoritative =>
      'आधिकारिक निर्देश ही मान्य हैं';

  @override
  String get examDayThisChecklistIsAPersonal =>
      'यह चेकलिस्ट निजी मदद है। रिपोर्टिंग समय, दस्तावेज़, अनुमत सामान और केंद्र नियमों के लिए हमेशा आधिकारिक सूचना या एडमिट कार्ड देखें।';

  @override
  String get examDayExam => 'परीक्षा';

  @override
  String get examDayReporting => 'रिपोर्टिंग';

  @override
  String get examDayVenueNote => 'केंद्र नोट';

  @override
  String get examDayExamDayChecklist => 'परीक्षा-दिवस चेकलिस्ट';

  @override
  String get examDayRemoveCustomItem => 'अपना आइटम हटाएँ';

  @override
  String get examDayAddMyOwnItem => 'अपना आइटम जोड़ें';

  @override
  String get examDayChooseAFutureExamDate =>
      'आगे की परीक्षा तारीख और समय चुनें।';

  @override
  String get examDayReportingTimeMustBeBefore =>
      'रिपोर्टिंग समय परीक्षा समय से पहले होना चाहिए।';

  @override
  String get examDaySaveOnlyTheDetailsYou =>
      'सिर्फ़ वही विवरण सेव करें जो आप इस डिवाइस पर चाहते हैं।';

  @override
  String get examDayExamName => 'परीक्षा का नाम';

  @override
  String get examDayEGSscCglTier => 'जैसे: SSC CGL Tier I';

  @override
  String get examDayExamDate => 'परीक्षा तारीख';

  @override
  String get examDayExamTime => 'परीक्षा समय';

  @override
  String get examDayReportingTimeOptional => 'रिपोर्टिंग समय (वैकल्पिक)';

  @override
  String get examDayClearReportingTime => 'रिपोर्टिंग समय हटाएँ';

  @override
  String get examDayVenueNoteOptional => 'केंद्र नोट (वैकल्पिक)';

  @override
  String get examDaySaveTheVenueOrAddress =>
      'केंद्र या पता वैसे ही सेव करें जैसे याद रखना है';

  @override
  String get examDayExamDayReminders => 'परीक्षा-दिवस रिमाइंडर';

  @override
  String get examDayRequestLocalNotificationsAbout24 =>
      'सेव रिपोर्टिंग या परीक्षा समय से लगभग 24 घंटे और 2 घंटे पहले सूचनाएँ पाएँ।';

  @override
  String get examDaySaveExamTarget => 'परीक्षा लक्ष्य सेव करें';

  @override
  String get accountReauthBody =>
      'सुरक्षा के लिए खाता हटाने से पहले हाल में साइन इन ज़रूरी है। फिर से साइन इन करने के बाद आप यहीं लौटेंगे।';

  @override
  String get mySeriesMyTestSeries => 'मेरी टेस्ट सीरीज़';

  @override
  String get mySeriesHelp => 'सहायता';

  @override
  String get mySeriesYouHavenTPurchasedAny =>
      'आपने अभी तक कोई टेस्ट सीरीज़ नहीं खरीदी';

  @override
  String get mySeriesGetFullLengthMockTests =>
      'तैयारी मज़बूत करने के लिए फुल मॉक, सेक्शनल टेस्ट, पिछले वर्ष के पेपर और विस्तृत विश्लेषण पाएँ।';

  @override
  String get mySeriesYourAccessHasExpired => 'आपका एक्सेस समाप्त हो गया है';

  @override
  String get mySeriesRenewToContinueTestsYour =>
      'टेस्ट जारी रखने के लिए रिन्यू करें। आपकी प्रगति और विश्लेषण सुरक्षित हैं।';

  @override
  String get mySeriesTestsAttempted => 'दिए गए टेस्ट';

  @override
  String get mySeriesTopicTests => 'टॉपिक टेस्ट';

  @override
  String get mySeriesMySeries => 'मेरी सीरीज़';

  @override
  String get mySeriesDownloads => 'डाउनलोड';

  @override
  String get mySeriesHistory => 'इतिहास';

  @override
  String get mySeriesUnableToLoadYourTest =>
      'आपकी टेस्ट सीरीज़ लोड नहीं हो सकी।';

  @override
  String get orderOrderDetails => 'ऑर्डर विवरण';

  @override
  String get orderPaymentSuccessful => 'भुगतान सफल';

  @override
  String get orderYourTestSeriesIsNow => 'आपकी टेस्ट सीरीज़ अब सक्रिय है!';

  @override
  String get orderTransactionDetails => 'लेन-देन विवरण';

  @override
  String get orderOrderId => 'ऑर्डर ID';

  @override
  String get orderTransactionId => 'लेन-देन ID';

  @override
  String get orderStatus => 'स्थिति';

  @override
  String get orderIncludedInYourAccess => 'आपके एक्सेस में शामिल';

  @override
  String get renewContinueYourPractice => 'अपना अभ्यास जारी रखें';

  @override
  String get renewGetLatestUpdates => 'नवीनतम अपडेट पाएँ';

  @override
  String get renewKeepYourProgress => 'अपनी प्रगति बनाए रखें';

  @override
  String get renewDetailedSolutions => 'विस्तृत हल';

  @override
  String get storeBatchesAreNotPublishedYet => 'बैच अभी प्रकाशित नहीं हैं';

  @override
  String get storeExamtreeWillShowBatchesHere =>
      'असली बैच, समय-सारणी और एक्सेस नियम उपलब्ध होने पर ही ExamTree यहाँ बैच दिखाएगा।';

  @override
  String get storePreparationProducts => 'तैयारी उत्पाद';

  @override
  String get storePublishedTestSeriesAndFuture =>
      'प्रकाशित टेस्ट सीरीज़ और आगे के बैच, अलग-अलग।';

  @override
  String get storeTestSeries => 'टेस्ट सीरीज़';

  @override
  String get storeBatches => 'बैच';

  @override
  String get storeStoreCatalogueUnavailable => 'स्टोर सूची उपलब्ध नहीं';

  @override
  String get storeExamtreeCouldNotLoadPublished =>
      'ExamTree अभी प्रकाशित उत्पाद लोड नहीं कर सका।';

  @override
  String get storeNoTestProductsOnSale => 'बिक्री के लिए कोई टेस्ट उत्पाद नहीं';

  @override
  String get storeThereAreNoActiveProducts =>
      'प्रकाशित सूची में अभी कोई सक्रिय उत्पाद नहीं है। मुफ़्त और पहले से उपलब्ध टेस्ट टेस्ट सेक्शन में मिलेंगे।';

  @override
  String get storeViewTests => 'टेस्ट देखें';

  @override
  String get storePricesValidityAndAvailabilityCome =>
      'कीमत, वैधता और उपलब्धता प्रकाशित ExamTree सूची से आती है। मोबाइल चेकआउट अभी जुड़ा नहीं है, इसलिए यह स्क्रीन खरीद नहीं करती।';

  @override
  String get learnSubReadyLessons => 'तैयार पाठ';

  @override
  String get learnSubChapters => 'अध्याय';

  @override
  String get learnSubReading => 'पढ़ाई';

  @override
  String get learnSubModuleUnavailable => 'मॉड्यूल उपलब्ध नहीं';

  @override
  String get learnSubChooseATopicArea => 'विषय क्षेत्र चुनें';

  @override
  String get learnSubOpenAnAreaToContinue =>
      'सीखना और अभ्यास जारी रखने के लिए कोई क्षेत्र खोलें।';

  @override
  String get learnSubUntimed => 'बिना समय सीमा';

  @override
  String get learnSubComingSoon => 'जल्द आ रहा है';

  @override
  String get learnSubSubModuleUnavailable => 'उप-मॉड्यूल उपलब्ध नहीं';

  @override
  String get learnSubVocabulary => 'शब्दावली';

  @override
  String get learnSubBuildStrongerWordPowerWith =>
      'केंद्रित अभ्यास से शब्द-शक्ति मज़बूत करें।';

  @override
  String get learnSubBuildVocabularyWithShortUntimed =>
      'छोटे, बिना समय सीमा वाले सत्रों से शब्दावली बढ़ाएँ। हर उत्तर तुरंत जाँचा जाता है और व्याख्या मिलती है।';

  @override
  String get learnSubPracticeMappingForThisSub =>
      'इस उप-मॉड्यूल का अभ्यास Question Studio से जोड़ा जा रहा है।';

  @override
  String get learnSubPolity => 'राजव्यवस्था';

  @override
  String get learnSubIndianConstitutionInstitutionsAndGovernance =>
      'भारतीय संविधान, संस्थाएँ और शासन।';

  @override
  String get learnSubChooseAChapterToRead =>
      'नोट्स पढ़ने या छोटा अभ्यास सत्र शुरू करने के लिए अध्याय चुनें। हर प्रश्न के बाद उत्तर और व्याख्या तुरंत दिखती है।';

  @override
  String get learnSub1520QuestionsUntimed => '15–20 प्रश्न · बिना समय सीमा';

  @override
  String get learnSubReviewLesson => 'पाठ देखें';

  @override
  String get learnSubPracticeTopicUnavailable => 'अभ्यास विषय उपलब्ध नहीं';

  @override
  String get learnSubPracticeQuestionsAreNotAvailable =>
      'इस विषय के अभ्यास प्रश्न अभी उपलब्ध नहीं हैं।';

  @override
  String get learnSubUnableToLoadPracticeQuestions =>
      'अभी अभ्यास प्रश्न लोड नहीं हो सके। आपकी प्रगति सुरक्षित है।';

  @override
  String get learnSubSubmitPractice => 'अभ्यास सबमिट करें?';

  @override
  String get learnSubKeepPracticing => 'अभ्यास जारी रखें';

  @override
  String get learnSubSubmit => 'सबमिट करें';

  @override
  String get learnSubBack => 'वापस';

  @override
  String get learnSubPracticeResult => 'अभ्यास परिणाम';

  @override
  String get learnSubAllTopics => 'सभी विषय';

  @override
  String get learnSubSuggestedNextTopic => 'सुझाया अगला विषय';

  @override
  String get learnSub20QuestionsUntimedInstantExplanations =>
      '20 प्रश्न · बिना समय सीमा · तुरंत व्याख्या';
}
