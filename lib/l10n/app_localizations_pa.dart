// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Panjabi Punjabi (`pa`).
class AppLocalizationsPa extends AppLocalizations {
  AppLocalizationsPa([String locale = 'pa']) : super(locale);

  @override
  String get navHome => 'ਹੋਮ';

  @override
  String get navLearn => 'ਸਿੱਖੋ';

  @override
  String get navTests => 'ਟੈਸਟ';

  @override
  String get navCurrentAffairs => 'ਕਰੰਟ ਅਫੇਅਰਜ਼';

  @override
  String get navResults => 'ਨਤੀਜੇ';

  @override
  String get navProfile => 'ਪ੍ਰੋਫਾਈਲ';

  @override
  String get navMenu => 'ਮੇਨੂ';

  @override
  String get appLanguage => 'ਐਪ ਦੀ ਭਾਸ਼ਾ';

  @override
  String get appLanguageHelp =>
      'ਮੇਨੂ, ਬਟਨਾਂ ਅਤੇ ਸਕ੍ਰੀਨ ਦੇ ਟੈਕਸਟ ਲਈ। ਅਨੁਵਾਦ ਪੂਰਾ ਹੋਣ ਤੱਕ ਕੁਝ ਸਕ੍ਰੀਨਾਂ ਅਜੇ ਅੰਗਰੇਜ਼ੀ ਵਿੱਚ ਹਨ।';

  @override
  String get alsoUseForQuestions => 'ਸਵਾਲ ਵੀ ਇਸੇ ਭਾਸ਼ਾ ਵਿੱਚ ਦਿਖਾਓ';

  @override
  String get questionLanguage => 'ਸਵਾਲਾਂ ਦੀ ਭਾਸ਼ਾ';

  @override
  String get languageSaveFailed => 'ਇਸ ਡਿਵਾਈਸ \'ਤੇ ਭਾਸ਼ਾ ਸੇਵ ਨਹੀਂ ਹੋ ਸਕੀ।';

  @override
  String get bookmarksTitle => 'ਬੁੱਕਮਾਰਕ';

  @override
  String bookmarksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ਸੇਵ ਕੀਤੇ ਸਵਾਲ · ਇਸ ਡਿਵਾਈਸ \'ਤੇ',
      one: '1 ਸੇਵ ਕੀਤਾ ਸਵਾਲ · ਇਸ ਡਿਵਾਈਸ \'ਤੇ',
    );
    return '$_temp0';
  }

  @override
  String get bookmarksAll => 'ਸਾਰੇ';

  @override
  String get bookmarksEmptyTitle => 'ਅਜੇ ਕੋਈ ਸਵਾਲ ਸੇਵ ਨਹੀਂ ਹੈ';

  @override
  String get bookmarksEmptyBody =>
      'ਟੈਸਟ ਦੀ ਸਮੀਖਿਆ ਕਰਦੇ ਸਮੇਂ ਕਿਸੇ ਵੀ ਸਵਾਲ \'ਤੇ ਬੁੱਕਮਾਰਕ ਆਈਕਨ ਦਬਾਓ, ਉਹ ਹੱਲ ਸਮੇਤ ਇੱਥੇ ਸੇਵ ਹੋ ਜਾਵੇਗਾ।';

  @override
  String get bookmarkRemoved => 'ਇਹ ਬੁੱਕਮਾਰਕ ਹਟਾ ਦਿੱਤਾ ਗਿਆ।';

  @override
  String get savedQuestion => 'ਸੇਵ ਕੀਤਾ ਸਵਾਲ';

  @override
  String get removeBookmark => 'ਬੁੱਕਮਾਰਕ ਹਟਾਓ';

  @override
  String get bookmarkQuestion => 'ਇਸ ਸਵਾਲ ਨੂੰ ਬੁੱਕਮਾਰਕ ਕਰੋ';

  @override
  String get savedToBookmarks => 'ਬੁੱਕਮਾਰਕ ਵਿੱਚ ਸੇਵ ਕੀਤਾ';

  @override
  String get removedFromBookmarks => 'ਬੁੱਕਮਾਰਕ ਵਿੱਚੋਂ ਹਟਾਇਆ';

  @override
  String get bookmarkSaveFailed =>
      'ਇਹ ਸਵਾਲ ਸੇਵ ਨਹੀਂ ਹੋ ਸਕਿਆ। ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get view => 'ਦੇਖੋ';

  @override
  String get solution => 'ਹੱਲ';

  @override
  String get correctAnswer => 'ਸਹੀ ਜਵਾਬ';

  @override
  String get yourAnswer => 'ਤੁਹਾਡਾ ਜਵਾਬ';

  @override
  String get correctYourAnswer => 'ਸਹੀ · ਤੁਹਾਡਾ ਜਵਾਬ';

  @override
  String get savedToday => 'ਅੱਜ ਸੇਵ ਕੀਤਾ';

  @override
  String get savedYesterday => 'ਕੱਲ੍ਹ ਸੇਵ ਕੀਤਾ';

  @override
  String savedDaysAgo(int days) {
    return '$days ਦਿਨ ਪਹਿਲਾਂ ਸੇਵ ਕੀਤਾ';
  }

  @override
  String get offlineTitle => 'ਡਾਊਨਲੋਡ ਅਤੇ ਆਫ਼ਲਾਈਨ';

  @override
  String get offlineIntro => 'ਇਸ ਫ਼ੋਨ \'ਤੇ ਬਿਨਾਂ ਇੰਟਰਨੈੱਟ ਉਪਲਬਧ';

  @override
  String get offlineSavedQuestions => 'ਸੇਵ ਕੀਤੇ ਸਵਾਲ';

  @override
  String get offlineSavedQuestionsEmpty =>
      'ਟੈਸਟ ਦੀ ਸਮੀਖਿਆ ਕਰਦੇ ਸਮੇਂ ਸਵਾਲ ਬੁੱਕਮਾਰਕ ਕਰੋ';

  @override
  String offlineSavedQuestionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ਹੱਲ ਸਮੇਤ $count ਸਵਾਲ',
      one: 'ਹੱਲ ਸਮੇਤ 1 ਸਵਾਲ',
    );
    return '$_temp0';
  }

  @override
  String get offlineRevision => 'ਦੁਹਰਾਈ ਸੂਚੀ';

  @override
  String get offlineRevisionEmpty => 'ਤੁਹਾਡੇ ਗਲਤ ਸਵਾਲ ਦੁਹਰਾਈ ਲਈ ਇੱਥੇ ਜੁੜਦੇ ਹਨ';

  @override
  String offlineRevisionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ਤੁਹਾਡੀਆਂ ਪਿਛਲੀਆਂ ਗਲਤੀਆਂ ਤੋਂ $count ਸਵਾਲ',
      one: 'ਤੁਹਾਡੀਆਂ ਪਿਛਲੀਆਂ ਗਲਤੀਆਂ ਤੋਂ 1 ਸਵਾਲ',
    );
    return '$_temp0';
  }

  @override
  String get offlineTestsTitle =>
      'ਟੈਸਟ ਸ਼ੁਰੂ ਅਤੇ ਸਬਮਿਟ ਕਰਨ ਲਈ ਇੰਟਰਨੈੱਟ ਚਾਹੀਦਾ ਹੈ';

  @override
  String get offlineTestsBody =>
      'ਟੈਸਟ ਦੌਰਾਨ ਇੰਟਰਨੈੱਟ ਚਲਾ ਜਾਵੇ ਤਾਂ ਤੁਹਾਡੇ ਜਵਾਬ ਇਸ ਫ਼ੋਨ \'ਤੇ ਸੇਵ ਰਹਿੰਦੇ ਹਨ ਅਤੇ ਆਨਲਾਈਨ ਹੋਣ \'ਤੇ ਤੁਸੀਂ ਜਾਰੀ ਰੱਖ ਸਕਦੇ ਹੋ। ਪੂਰੇ ਟੈਸਟ ਅਤੇ ਨੋਟਸ ਅਜੇ ਡਾਊਨਲੋਡ ਨਹੀਂ ਕੀਤੇ ਜਾ ਸਕਦੇ।';

  @override
  String get profileDownloads => 'ਡਾਊਨਲੋਡ ਅਤੇ ਆਫ਼ਲਾਈਨ';

  @override
  String get profileBookmarks => 'ਬੁੱਕਮਾਰਕ';

  @override
  String get profilePrivacy => 'ਪਰਦੇਦਾਰੀ ਅਤੇ ਖਾਤਾ';

  @override
  String get profilePrivacySubtitle => 'ਖਾਤਾ ਕੰਟਰੋਲ ਅਤੇ ਪਰਦੇਦਾਰੀ ਸੈਟਿੰਗਾਂ';

  @override
  String get retry => 'ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ';

  @override
  String get attemptNoQuestions => 'ਕੋਈ ਸਵਾਲ ਉਪਲਬਧ ਨਹੀਂ';

  @override
  String get attemptSignInRequired =>
      'ਸਾਈਨ ਇਨ ਲਾਜ਼ਮੀ ਹੈ। ਅੱਗੇ ਭੇਜਿਆ ਜਾ ਰਿਹਾ ਹੈ...';

  @override
  String get attemptPurchaseRequired => 'ਇਸ ਟੈਸਟ ਲਈ ਖਰੀਦਣਾ ਲਾਜ਼ਮੀ ਹੈ।';

  @override
  String attemptLoadFailed(String error) {
    return 'ਟੈਸਟ ਲੋਡ ਨਹੀਂ ਹੋ ਸਕਿਆ: $error';
  }

  @override
  String get attemptRecoveredLocal =>
      'ਇਸ ਡਿਵਾਈਸ ਤੋਂ ਬਿਨਾਂ ਸਿੰਕ ਹੋਈ ਪ੍ਰਗਤੀ ਵਾਪਸ ਮਿਲੀ। ਹੁਣ ਇਸਨੂੰ ExamTree ਨਾਲ ਸਿੰਕ ਕੀਤਾ ਜਾ ਰਿਹਾ ਹੈ।';

  @override
  String get attemptRestoredServer =>
      'ExamTree ਤੋਂ ਸੇਵ ਕੀਤੀ ਪ੍ਰਗਤੀ ਵਾਪਸ ਲਿਆਂਦੀ ਗਈ।';

  @override
  String get attemptTenMinutes => '10 ਮਿੰਟ ਬਾਕੀ';

  @override
  String get attemptFiveMinutes => '5 ਮਿੰਟ ਬਾਕੀ';

  @override
  String get attemptOneMinute => '1 ਮਿੰਟ ਬਾਕੀ। ਆਪਣੀ ਸਮੀਖਿਆ ਹੁਣੇ ਪੂਰੀ ਕਰੋ।';

  @override
  String attemptSecondsRemaining(int seconds) {
    return '$seconds ਸਕਿੰਟ ਬਾਕੀ';
  }

  @override
  String get attemptTimeOverSubmitting =>
      'ਸਮਾਂ ਖ਼ਤਮ। ਤੁਹਾਡਾ ਟੈਸਟ ਸਬਮਿਟ ਕੀਤਾ ਜਾ ਰਿਹਾ ਹੈ।';

  @override
  String get attemptChangedElsewhere =>
      'ਇਹ ਟੈਸਟ ਕਿਸੇ ਹੋਰ ਡਿਵਾਈਸ \'ਤੇ ਬਦਲਿਆ ਗਿਆ। ਸਰਵਰ ਦੀ ਨਵੀਂ ਪ੍ਰਗਤੀ ਲੋਡ ਕੀਤੀ ਗਈ।';

  @override
  String get attemptSavedNotSynced =>
      'ਪ੍ਰਗਤੀ ਇਸ ਡਿਵਾਈਸ \'ਤੇ ਸੇਵ ਹੈ, ਪਰ ਅਜੇ ExamTree ਤੱਕ ਨਹੀਂ ਪਹੁੰਚੀ।';

  @override
  String get attemptTimeOverRetry =>
      'ਸਮਾਂ ਖ਼ਤਮ। ਤੁਹਾਡੇ ਜਵਾਬ ਇਸ ਡਿਵਾਈਸ \'ਤੇ ਸੁਰੱਖਿਅਤ ਹਨ; ਇੰਟਰਨੈੱਟ ਜੋੜ ਕੇ ਦੁਬਾਰਾ ਸਬਮਿਟ ਕਰੋ।';

  @override
  String get attemptSubmitFailed =>
      'ਹੁਣੇ ਸਬਮਿਟ ਨਹੀਂ ਹੋ ਸਕਿਆ। ਤੁਹਾਡੇ ਜਵਾਬ ਸੇਵ ਹਨ; ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get attemptStillOpen =>
      'ਟੈਸਟ ਖੁੱਲ੍ਹਾ ਹੈ ਕਿਉਂਕਿ ਨਵੀਂ ਪ੍ਰਗਤੀ ਸੇਵ ਨਹੀਂ ਹੋ ਸਕੀ।';

  @override
  String get attemptPreparing =>
      'ਤੁਹਾਡਾ ਸੁਰੱਖਿਅਤ ਟੈਸਟ ਸੈਸ਼ਨ ਤਿਆਰ ਹੋ ਰਿਹਾ ਹੈ...';

  @override
  String get attemptUnableToStart => 'ਟੈਸਟ ਸ਼ੁਰੂ ਨਹੀਂ ਹੋ ਸਕਿਆ';

  @override
  String get attemptSessionNotCreated => 'ਟੈਸਟ ਸੈਸ਼ਨ ਨਹੀਂ ਬਣ ਸਕਿਆ।';

  @override
  String get tryAgain => 'ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ';

  @override
  String get attemptTimeExpiredSubmitting =>
      'ਸਮਾਂ ਖ਼ਤਮ — ਤੁਹਾਡਾ ਟੈਸਟ ਸਬਮਿਟ ਹੋ ਰਿਹਾ ਹੈ';

  @override
  String get attemptSubmittingTest => 'ਤੁਹਾਡਾ ਟੈਸਟ ਸਬਮਿਟ ਹੋ ਰਿਹਾ ਹੈ';

  @override
  String get attemptLockedPending =>
      'ਸਮਾਂ ਖ਼ਤਮ। ਜਵਾਬ ਲਾਕ ਹਨ ਅਤੇ ਸਬਮਿਸ਼ਨ ਬਾਕੀ ਹੈ।';

  @override
  String get attemptRetrySubmit => 'ਦੁਬਾਰਾ ਸਬਮਿਟ ਕਰੋ';

  @override
  String get attemptSaveAnswer => 'ਜਵਾਬ ਸੇਵ ਕਰੋ';

  @override
  String get attemptSaveNext => 'ਸੇਵ ਕਰੋ ਅਤੇ ਅੱਗੇ';

  @override
  String attemptPaletteLeft(int count) {
    return 'ਪੈਲੇਟ · $count ਬਾਕੀ';
  }

  @override
  String get attemptSubmitting => 'ਸਬਮਿਟ ਹੋ ਰਿਹਾ ਹੈ…';

  @override
  String get attemptSubmitTest => 'ਟੈਸਟ ਸਬਮਿਟ ਕਰੋ';

  @override
  String attemptQuestionOf(int number, int total) {
    return 'ਸਵਾਲ $number / $total';
  }

  @override
  String get attemptNotSavedRetry => 'ਪ੍ਰਗਤੀ ਸੇਵ ਨਹੀਂ ਹੋਈ। ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get attemptSavingProgress => 'ਪ੍ਰਗਤੀ ਸੇਵ ਹੋ ਰਹੀ ਹੈ';

  @override
  String get attemptSaveExit => 'ਸੇਵ ਕਰੋ ਅਤੇ ਬਾਹਰ ਜਾਓ';

  @override
  String attemptQuestionNumber(int number) {
    return 'ਸਵਾਲ $number';
  }

  @override
  String get attemptMarkedForReview => 'ਸਮੀਖਿਆ ਲਈ ਨਿਸ਼ਾਨਬੱਧ';

  @override
  String attemptOptionLabel(String letter, String text) {
    return 'ਵਿਕਲਪ $letter: $text';
  }

  @override
  String get attemptPrevious => 'ਪਿਛਲਾ';

  @override
  String get attemptClear => 'ਹਟਾਓ';

  @override
  String get attemptReview => 'ਸਮੀਖਿਆ';

  @override
  String get attemptSubmitQuestion => 'ਟੈਸਟ ਸਬਮਿਟ ਕਰਨਾ ਹੈ?';

  @override
  String attemptUnansweredLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count ਸਵਾਲਾਂ ਦੇ ਜਵਾਬ ਅਜੇ ਬਾਕੀ ਹਨ। ਸਬਮਿਟ ਕਰਨ ਤੋਂ ਪਹਿਲਾਂ ਤੁਸੀਂ ਉਨ੍ਹਾਂ ਨੂੰ ਦੇਖ ਸਕਦੇ ਹੋ।',
      one:
          '1 ਸਵਾਲ ਦਾ ਜਵਾਬ ਅਜੇ ਬਾਕੀ ਹੈ। ਸਬਮਿਟ ਕਰਨ ਤੋਂ ਪਹਿਲਾਂ ਤੁਸੀਂ ਉਸਨੂੰ ਦੇਖ ਸਕਦੇ ਹੋ।',
    );
    return '$_temp0';
  }

  @override
  String get attemptCannotChange =>
      'ਸਬਮਿਟ ਕਰਨ ਤੋਂ ਬਾਅਦ ਜਵਾਬ ਨਹੀਂ ਬਦਲੇ ਜਾ ਸਕਦੇ।';

  @override
  String get attemptReviewUnanswered => 'ਬਿਨਾਂ ਜਵਾਬ ਵਾਲੇ ਦੇਖੋ';

  @override
  String get attemptSubmitNow => 'ਹੁਣੇ ਸਬਮਿਟ ਕਰੋ';

  @override
  String get attemptContinueTest => 'ਟੈਸਟ ਜਾਰੀ ਰੱਖੋ';

  @override
  String get attemptAnswered => 'ਜਵਾਬ ਦਿੱਤਾ';

  @override
  String get attemptUnanswered => 'ਜਵਾਬ ਨਹੀਂ ਦਿੱਤਾ';

  @override
  String get attemptAnsweredMarked => 'ਜਵਾਬ ਦਿੱਤਾ + ਨਿਸ਼ਾਨਬੱਧ';

  @override
  String get attemptSyncNeededTitle => 'ਪ੍ਰਗਤੀ ਅਜੇ ਸਿੰਕ ਹੋਣੀ ਬਾਕੀ ਹੈ';

  @override
  String get attemptSyncNeededBody =>
      'ਤੁਹਾਡੇ ਨਵੇਂ ਜਵਾਬ ਇਸ ਡਿਵਾਈਸ \'ਤੇ ਸੁਰੱਖਿਅਤ ਹਨ, ਪਰ ਅਜੇ ExamTree ਤੱਕ ਨਹੀਂ ਪਹੁੰਚੇ। ਜਾਣ ਤੋਂ ਪਹਿਲਾਂ ਦੁਬਾਰਾ ਸੇਵ ਕਰੋ।';

  @override
  String get attemptSavingTitle => 'ਤੁਹਾਡੀ ਪ੍ਰਗਤੀ ਸੇਵ ਹੋ ਰਹੀ ਹੈ';

  @override
  String get attemptSavingBody =>
      'ExamTree ਅਜੇ ਤੁਹਾਡੇ ਨਵੇਂ ਬਦਲਾਅ ਸੇਵ ਕਰ ਰਿਹਾ ਹੈ। ਸੇਵ ਪੂਰਾ ਹੋਣ ਤੱਕ ਟੈਸਟ ਖੁੱਲ੍ਹਾ ਰੱਖੋ।';

  @override
  String get attemptLeaveTitle => 'ਸੇਵ ਕਰਕੇ ਟੈਸਟ ਛੱਡਣਾ ਹੈ?';

  @override
  String get attemptLeaveBody =>
      'ਤੁਹਾਡੀ ਕੋਸ਼ਿਸ਼ ਚਾਲੂ ਰਹੇਗੀ ਅਤੇ ਬਾਅਦ ਵਿੱਚ ਇਸ ਡਿਵਾਈਸ ਜਾਂ ExamTree ਵੈੱਬਸਾਈਟ ਤੋਂ ਜਾਰੀ ਕੀਤੀ ਜਾ ਸਕਦੀ ਹੈ।';

  @override
  String get attemptRetrySave => 'ਦੁਬਾਰਾ ਸੇਵ ਕਰੋ';

  @override
  String get attemptSaveLeave => 'ਸੇਵ ਕਰੋ ਅਤੇ ਛੱਡੋ';

  @override
  String get attemptStay => 'ਰੁਕੋ';

  @override
  String get attemptSavingEllipsis => 'ਪ੍ਰਗਤੀ ਸੇਵ ਹੋ ਰਹੀ ਹੈ…';

  @override
  String get attemptWaitingSync =>
      'ਇਸ ਡਿਵਾਈਸ \'ਤੇ ਸੇਵ। ExamTree ਨਾਲ ਸਿੰਕ ਹੋਣ ਦੀ ਉਡੀਕ।';

  @override
  String get attemptNotSyncedYet =>
      'ਨਵੇਂ ਬਦਲਾਅ ਇਸ ਡਿਵਾਈਸ \'ਤੇ ਸੁਰੱਖਿਅਤ ਹਨ ਪਰ ਅਜੇ ਸਿੰਕ ਨਹੀਂ ਹੋਏ।';

  @override
  String get paletteTitle => 'ਸਵਾਲ ਪੈਲੇਟ';

  @override
  String get paletteClose => 'ਪੈਲੇਟ ਬੰਦ ਕਰੋ';

  @override
  String get paletteMarked => 'ਨਿਸ਼ਾਨਬੱਧ';

  @override
  String paletteUnansweredCount(int count) {
    return 'ਬਿਨਾਂ ਜਵਾਬ $count';
  }

  @override
  String paletteMarkedCount(int count) {
    return 'ਨਿਸ਼ਾਨਬੱਧ $count';
  }

  @override
  String get paletteHint =>
      'ਕਿਸੇ ਨੰਬਰ \'ਤੇ ਟੈਪ ਕਰੋ ਅਤੇ ਸਿੱਧਾ ਉਸ ਸਵਾਲ \'ਤੇ ਜਾਓ।';

  @override
  String get paletteNoMatch => 'ਇਸ ਫ਼ਿਲਟਰ ਨਾਲ ਕੋਈ ਸਵਾਲ ਮੇਲ ਨਹੀਂ ਖਾਂਦਾ।';

  @override
  String get paletteShowAll => 'ਸਾਰੇ ਸਵਾਲ ਦਿਖਾਓ';

  @override
  String get resultTitle => 'ਨਤੀਜਾ';

  @override
  String get resultLoadFailed => 'ਇਹ ਨਤੀਜਾ ਲੋਡ ਨਹੀਂ ਹੋ ਸਕਿਆ';

  @override
  String get resultTestResult => 'ਟੈਸਟ ਨਤੀਜਾ';

  @override
  String resultQuestionsCount(int count) {
    return '$count ਸਵਾਲ';
  }

  @override
  String resultMarks(String marks) {
    return '$marks ਅੰਕ';
  }

  @override
  String get resultRank => 'ਰੈਂਕ';

  @override
  String get resultAccuracy => 'ਸ਼ੁੱਧਤਾ';

  @override
  String resultXofY(int x, int y) {
    return '$y ਵਿੱਚੋਂ $x';
  }

  @override
  String get resultTime => 'ਸਮਾਂ';

  @override
  String get resultSpent => 'ਲੱਗਾ';

  @override
  String get resultAttempted => 'ਹੱਲ ਕੀਤੇ';

  @override
  String resultOfTotal(int total) {
    return '$total ਵਿੱਚੋਂ';
  }

  @override
  String resultScoreA11y(String score, String max) {
    return 'ਸਕੋਰ $max ਵਿੱਚੋਂ $score।';
  }

  @override
  String resultDelta(String delta) {
    return 'ਪਿਛਲੀ ਕੋਸ਼ਿਸ਼ ਨਾਲੋਂ $delta ਅੰਕ';
  }

  @override
  String resultLastAttempts(int count) {
    return 'ਤੁਹਾਡੀਆਂ ਪਿਛਲੀਆਂ $count ਕੋਸ਼ਿਸ਼ਾਂ';
  }

  @override
  String get resultTrendSubtitle => 'ਵੱਧ ਤੋਂ ਵੱਧ ਅੰਕਾਂ ਦੇ ਪ੍ਰਤੀਸ਼ਤ ਵਜੋਂ ਸਕੋਰ।';

  @override
  String get resultCorrect => 'ਸਹੀ';

  @override
  String get resultWrong => 'ਗਲਤ';

  @override
  String get resultSkipped => 'ਛੱਡੇ';

  @override
  String resultHowWent(int total) {
    return 'ਤੁਹਾਡੇ $total ਸਵਾਲਾਂ ਦਾ ਹਾਲ';
  }

  @override
  String resultQuickestWin(String section) {
    return 'ਸਭ ਤੋਂ ਛੇਤੀ ਸੁਧਾਰ: $section। ';
  }

  @override
  String resultSkippedMost(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ਉੱਥੇ ਤੁਸੀਂ $count ਸਵਾਲ ਛੱਡੇ, ਕਿਸੇ ਵੀ ਹੋਰ ਸੈਕਸ਼ਨ ਨਾਲੋਂ ਵੱਧ।',
      one: 'ਉੱਥੇ ਤੁਸੀਂ 1 ਸਵਾਲ ਛੱਡਿਆ, ਕਿਸੇ ਵੀ ਹੋਰ ਸੈਕਸ਼ਨ ਨਾਲੋਂ ਵੱਧ।',
    );
    return '$_temp0';
  }

  @override
  String resultAccuracyValue(String value) {
    return 'ਸ਼ੁੱਧਤਾ $value';
  }

  @override
  String resultTimeShare(String section, int share) {
    return '$section ਵਿੱਚ ਤੁਹਾਡਾ $share% ਸਮਾਂ ਲੱਗਾ।';
  }

  @override
  String resultTimeShareAccuracy(String section, int share, int accuracy) {
    return '$section ਵਿੱਚ ਤੁਹਾਡਾ $share% ਸਮਾਂ ਲੱਗਾ, $accuracy% ਸ਼ੁੱਧਤਾ ਨਾਲ।';
  }

  @override
  String resultLowestAccuracy(String section, int accuracy) {
    return '$section ਵਿੱਚ ਤੁਹਾਡੀ ਸਭ ਤੋਂ ਘੱਟ ਸ਼ੁੱਧਤਾ ਰਹੀ, $accuracy%।';
  }

  @override
  String resultLowestAccuracyShare(String section, int accuracy, int share) {
    return '$section ਵਿੱਚ ਤੁਹਾਡੀ ਸਭ ਤੋਂ ਘੱਟ ਸ਼ੁੱਧਤਾ ਰਹੀ, $accuracy%, ਤੁਹਾਡੇ $share% ਸਮੇਂ ਵਿੱਚ।';
  }

  @override
  String get resultAccuracyVsTime => 'ਸ਼ੁੱਧਤਾ ਬਨਾਮ ਲੱਗਾ ਸਮਾਂ';

  @override
  String get resultAccuracyVsTimeSubtitle =>
      'ਕੀ ਤੁਹਾਡਾ ਸਮਾਂ ਉੱਥੇ ਹੀ ਲੱਗ ਰਿਹਾ ਹੈ ਜਿੱਥੇ ਅੰਕ ਹਨ?';

  @override
  String get resultShareOfTime => 'ਤੁਹਾਡੇ ਸਮੇਂ ਦਾ ਹਿੱਸਾ';

  @override
  String get resultTimePerQuestion => 'ਪ੍ਰਤੀ ਸਵਾਲ ਸਮਾਂ';

  @override
  String get resultTimePerQuestionSubtitle =>
      'ਹਰ ਸਵਾਲ ਲਈ ਇੱਕ ਬਾਰ, ਪੇਪਰ ਦੇ ਕ੍ਰਮ ਵਿੱਚ।';

  @override
  String resultSlowest(String section, int number, String time) {
    return 'ਸਭ ਤੋਂ ਹੌਲੀ ਸਵਾਲ: $section Q$number, $time ਵਿੱਚ।';
  }

  @override
  String get resultQuestionMap => 'ਸਵਾਲ ਨਕਸ਼ਾ';

  @override
  String get resultReviewSolutions => 'ਹੱਲ ਦੇਖੋ';

  @override
  String get resultReviseMistakes => 'ਗਲਤੀਆਂ ਦੁਹਰਾਓ (5 ਮਿੰਟ)';

  @override
  String get resultRetake => 'ਟੈਸਟ ਦੁਬਾਰਾ ਦਿਓ';

  @override
  String get resultsHistoryLoadFailed =>
      'ਤੁਹਾਡਾ ਕੋਸ਼ਿਸ਼ ਇਤਿਹਾਸ ਲੋਡ ਨਹੀਂ ਹੋ ਸਕਿਆ';

  @override
  String get resultsSearchHint => 'ਟੈਸਟ ਜਾਂ ਪ੍ਰੀਖਿਆ ਸ਼੍ਰੇਣੀਆਂ ਖੋਜੋ';

  @override
  String get clearSearch => 'ਖੋਜ ਹਟਾਓ';

  @override
  String get resultsAttemptHistory => 'ਕੋਸ਼ਿਸ਼ ਇਤਿਹਾਸ';

  @override
  String get resultsAverageScore => 'ਔਸਤ ਸਕੋਰ';

  @override
  String resultsAttemptsCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ਕੋਸ਼ਿਸ਼ਾਂ ਪੂਰੀਆਂ',
      one: '1 ਕੋਸ਼ਿਸ਼ ਪੂਰੀ',
    );
    return '$_temp0';
  }

  @override
  String get resultsBestScore => 'ਸਭ ਤੋਂ ਵਧੀਆ ਸਕੋਰ';

  @override
  String get resultsFindAttempt => 'ਕੋਈ ਕੋਸ਼ਿਸ਼ ਖੋਜੋ';

  @override
  String get resultsFindHint =>
      'ਦੁਬਾਰਾ ਕੀ ਦੇਣਾ ਹੈ, ਇਹ ਤੈਅ ਕਰਨ ਤੋਂ ਪਹਿਲਾਂ ਗਲਤੀਆਂ ਦੇਖੋ।';

  @override
  String get reset => 'ਰੀਸੈੱਟ';

  @override
  String get resultsAllExams => 'ਸਾਰੀਆਂ ਪ੍ਰੀਖਿਆਵਾਂ';

  @override
  String get resultsSort => 'ਨਤੀਜੇ ਤਰਤੀਬ ਦਿਓ';

  @override
  String get resultsSortNewest => 'ਸਭ ਤੋਂ ਨਵੇਂ';

  @override
  String get resultsSortHighestScore => 'ਸਭ ਤੋਂ ਵੱਧ ਸਕੋਰ';

  @override
  String get resultsSortHighestAccuracy => 'ਸਭ ਤੋਂ ਵੱਧ ਸ਼ੁੱਧਤਾ';

  @override
  String get resultsReviewMistakes => 'ਗਲਤੀਆਂ ਦੇਖੋ';

  @override
  String get resultsReviewAnswers => 'ਜਵਾਬ ਦੇਖੋ';

  @override
  String get resultsRetake => 'ਦੁਬਾਰਾ ਦਿਓ';

  @override
  String resultsAccuracyPct(String value) {
    return '$value% ਸ਼ੁੱਧਤਾ';
  }

  @override
  String resultsCorrectCount(int count) {
    return '$count ਸਹੀ';
  }

  @override
  String resultsIncorrectCount(int count) {
    return '$count ਗਲਤ';
  }

  @override
  String resultsSkippedCount(int count) {
    return '$count ਛੱਡੇ';
  }

  @override
  String resultsScorePercentA11y(String value) {
    return 'ਸਕੋਰ $value ਪ੍ਰਤੀਸ਼ਤ';
  }

  @override
  String get resultsEmptyTitle => 'ਅਜੇ ਕੋਈ ਕੋਸ਼ਿਸ਼ ਪੂਰੀ ਨਹੀਂ ਹੋਈ';

  @override
  String get resultsEmptyBody =>
      'ਸਕੋਰ ਇਤਿਹਾਸ, ਸ਼ੁੱਧਤਾ ਅਤੇ ਜਵਾਬ ਸਮੀਖਿਆ ਦੇਖਣ ਲਈ ਆਪਣਾ ਪਹਿਲਾ ਟੈਸਟ ਪੂਰਾ ਕਰੋ।';

  @override
  String get resultsExploreTests => 'ਟੈਸਟ ਦੇਖੋ';

  @override
  String get resultsNoMatchTitle =>
      'ਇਨ੍ਹਾਂ ਫ਼ਿਲਟਰਾਂ ਨਾਲ ਕੋਈ ਕੋਸ਼ਿਸ਼ ਮੇਲ ਨਹੀਂ ਖਾਂਦੀ';

  @override
  String get resultsNoMatchBody =>
      'ਕੋਈ ਹੋਰ ਟੈਸਟ ਨਾਮ, ਸ਼੍ਰੇਣੀ ਜਾਂ ਤਰਤੀਬ ਅਜ਼ਮਾਓ।';

  @override
  String get resultsResetFilters => 'ਫ਼ਿਲਟਰ ਰੀਸੈੱਟ ਕਰੋ';

  @override
  String get dateUnavailable => 'ਤਾਰੀਖ ਉਪਲਬਧ ਨਹੀਂ';

  @override
  String get examsCategoriesLoadFailed => 'ਪ੍ਰੀਖਿਆ ਸ਼੍ਰੇਣੀਆਂ ਲੋਡ ਨਹੀਂ ਹੋ ਸਕੀਆਂ';

  @override
  String get examsTitle => 'ਪ੍ਰੀਖਿਆਵਾਂ';

  @override
  String get examsLoadFailed => 'ਪ੍ਰੀਖਿਆਵਾਂ ਲੋਡ ਨਹੀਂ ਹੋ ਸਕੀਆਂ';

  @override
  String examsSearchIn(String category) {
    return '$category ਪ੍ਰੀਖਿਆਵਾਂ ਖੋਜੋ';
  }

  @override
  String examsCategoryExams(String category) {
    return '$category ਪ੍ਰੀਖਿਆਵਾਂ';
  }

  @override
  String examsAvailable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ਪ੍ਰੀਖਿਆਵਾਂ ਉਪਲਬਧ',
      one: '1 ਪ੍ਰੀਖਿਆ ਉਪਲਬਧ',
    );
    return '$_temp0';
  }

  @override
  String get examsTestSeries => 'ਟੈਸਟ ਸੀਰੀਜ਼';

  @override
  String get examsSeriesLoadFailed => 'ਟੈਸਟ ਸੀਰੀਜ਼ ਲੋਡ ਨਹੀਂ ਹੋ ਸਕੀ';

  @override
  String get examsAvailableSeries => 'ਉਪਲਬਧ ਟੈਸਟ ਸੀਰੀਜ਼';

  @override
  String get examsNoActiveSeries => 'ਅਜੇ ਕੋਈ ਚਾਲੂ ਟੈਸਟ ਸੀਰੀਜ਼ ਨਹੀਂ';

  @override
  String examsSeriesAvailable(int count) {
    return '$count ਸੀਰੀਜ਼ ਉਪਲਬਧ';
  }

  @override
  String get examsSearchCategories => 'ਪ੍ਰੀਖਿਆ ਸ਼੍ਰੇਣੀਆਂ ਖੋਜੋ';

  @override
  String get examsCategories => 'ਪ੍ਰੀਖਿਆ ਸ਼੍ਰੇਣੀਆਂ';

  @override
  String get examsChooseCategory =>
      'ਜਿਸ ਪ੍ਰੀਖਿਆ ਦੀ ਤਿਆਰੀ ਕਰ ਰਹੇ ਹੋ, ਉਸਨੂੰ ਲੱਭਣ ਲਈ ਸ਼੍ਰੇਣੀ ਚੁਣੋ।';

  @override
  String get examsChoosePath => 'ਆਪਣੀ ਪ੍ਰੀਖਿਆ ਦਾ ਰਾਹ ਚੁਣੋ';

  @override
  String get examsChoosePathBody =>
      'ਸ਼੍ਰੇਣੀ ਖੋਲ੍ਹੋ, ਆਪਣੀ ਪ੍ਰੀਖਿਆ ਚੁਣੋ ਅਤੇ ਉਸਦੀ ਟੈਸਟ ਸੀਰੀਜ਼ \'ਤੇ ਜਾਓ।';

  @override
  String examsCategoriesCount(int count) {
    return '$count ਸ਼੍ਰੇਣੀਆਂ';
  }

  @override
  String examsExamsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ਪ੍ਰੀਖਿਆਵਾਂ',
      one: '1 ਪ੍ਰੀਖਿਆ',
    );
    return '$_temp0';
  }

  @override
  String examsSeriesCount(int count) {
    return '$count ਸੀਰੀਜ਼';
  }

  @override
  String examsLiveTests(int count) {
    return '$count ਉਪਲਬਧ ਟੈਸਟ';
  }

  @override
  String examsTestsCount(int count) {
    return '$count ਟੈਸਟ';
  }

  @override
  String examsTestSeriesCount(int count) {
    return '$count ਟੈਸਟ ਸੀਰੀਜ਼';
  }

  @override
  String examsFullMocks(int count) {
    return '$count ਫੁੱਲ ਮੌਕ';
  }

  @override
  String examsMinPerTest(int minutes) {
    return '~$minutes ਮਿੰਟ/ਟੈਸਟ';
  }

  @override
  String get examsViewTestSeries => 'ਟੈਸਟ ਸੀਰੀਜ਼ ਦੇਖੋ';

  @override
  String get examsNoQuestionsYet => 'ਅਜੇ ਕੋਈ ਸਵਾਲ ਨਹੀਂ';

  @override
  String get examsViewDetails => 'ਵੇਰਵੇ ਦੇਖੋ';

  @override
  String get examsViewSeries => 'ਸੀਰੀਜ਼ ਦੇਖੋ';

  @override
  String get examsEmptyCatalogueTitle =>
      'ਅਜੇ ਕੋਈ ਪ੍ਰੀਖਿਆ ਸ਼੍ਰੇਣੀ ਪ੍ਰਕਾਸ਼ਿਤ ਨਹੀਂ ਹੈ।';

  @override
  String get examsEmptyCatalogueBody => 'ਦੁਬਾਰਾ ਦੇਖਣ ਲਈ ਹੇਠਾਂ ਖਿੱਚੋ।';

  @override
  String get examsNoCategoryMatchTitle =>
      'ਤੁਹਾਡੀ ਖੋਜ ਨਾਲ ਕੋਈ ਪ੍ਰੀਖਿਆ ਸ਼੍ਰੇਣੀ ਮੇਲ ਨਹੀਂ ਖਾਂਦੀ।';

  @override
  String get examsNoCategoryMatchBody =>
      'ਕੋਈ ਹੋਰ ਪ੍ਰੀਖਿਆ ਸਮੂਹ ਅਜ਼ਮਾਓ ਜਾਂ ਖੋਜ ਹਟਾਓ।';

  @override
  String get examsNoExamMatchTitle => 'ਇਸ ਖੋਜ ਨਾਲ ਕੋਈ ਪ੍ਰੀਖਿਆ ਮੇਲ ਨਹੀਂ ਖਾਂਦੀ।';

  @override
  String get examsNoExamMatchBody => 'ਛੋਟਾ ਪ੍ਰੀਖਿਆ ਨਾਮ ਅਜ਼ਮਾਓ ਜਾਂ ਖੋਜ ਹਟਾਓ।';

  @override
  String get examsCategoryUnavailableTitle => 'ਪ੍ਰੀਖਿਆ ਸ਼੍ਰੇਣੀ ਉਪਲਬਧ ਨਹੀਂ';

  @override
  String get examsCategoryUnavailableBody =>
      'ਪ੍ਰੀਖਿਆ ਪੰਨੇ ਤੋਂ ਸ਼੍ਰੇਣੀ ਦੁਬਾਰਾ ਖੋਲ੍ਹੋ।';

  @override
  String get examsExamUnavailableTitle => 'ਪ੍ਰੀਖਿਆ ਉਪਲਬਧ ਨਹੀਂ';

  @override
  String get examsExamUnavailableBody =>
      'ਪ੍ਰੀਖਿਆ ਨੂੰ ਉਸਦੀ ਸ਼੍ਰੇਣੀ ਤੋਂ ਦੁਬਾਰਾ ਖੋਲ੍ਹੋ।';

  @override
  String examsNoneInCategoryTitle(String category) {
    return 'ਅਜੇ ਕੋਈ $category ਪ੍ਰੀਖਿਆ ਪ੍ਰਕਾਸ਼ਿਤ ਨਹੀਂ ਹੈ।';
  }

  @override
  String get examsNoneInCategoryBody =>
      'ਨਵੀਆਂ ਪ੍ਰੀਖਿਆਵਾਂ ਪ੍ਰਕਾਸ਼ਿਤ ਹੁੰਦੇ ਹੀ ਇੱਥੇ ਆਪਣੇ ਆਪ ਦਿਖਣਗੀਆਂ।';

  @override
  String get examsNoSeriesTitle => 'ਅਜੇ ਕੋਈ ਟੈਸਟ ਸੀਰੀਜ਼ ਉਪਲਬਧ ਨਹੀਂ';

  @override
  String get examsNoSeriesBody =>
      'ਇਸ ਪ੍ਰੀਖਿਆ ਦੀਆਂ ਪ੍ਰਕਾਸ਼ਿਤ ਟੈਸਟ ਸੀਰੀਜ਼ ਇੱਥੇ ਆਪਣੇ ਆਪ ਦਿਖਣਗੀਆਂ।';

  @override
  String get learnCurrentAffairs => 'ਕਰੰਟ ਅਫੇਅਰਜ਼';

  @override
  String get learnCurrentAffairsSubtitle =>
      'ਛੇਤੀ ਦੁਹਰਾਈ ਲਈ ਤਾਜ਼ਾ ਪ੍ਰਕਾਸ਼ਿਤ ਅੱਪਡੇਟ।';

  @override
  String get learnFreePractice => 'ਮੁਫ਼ਤ ਅਭਿਆਸ';

  @override
  String get learnFreePracticeSubtitle =>
      'ਪੜ੍ਹਾਈ ਨੂੰ ਤੁਰੰਤ ਟੈਸਟ ਸੈਸ਼ਨ ਵਿੱਚ ਬਦਲੋ।';

  @override
  String get learnAllTests => 'ਸਾਰੇ ਟੈਸਟ';

  @override
  String get learnNotes => 'ਨੋਟਸ ਅਤੇ ਫ਼ਾਰਮੂਲਾ ਸ਼ੀਟਾਂ';

  @override
  String get learnNotesSubtitle => 'ਤੁਹਾਡੀਆਂ ਪ੍ਰੀਖਿਆਵਾਂ ਲਈ ਪ੍ਰਕਾਸ਼ਿਤ ਸਮੱਗਰੀ।';

  @override
  String get learnHeroTitle => 'ਆਪਣੀਆਂ ਪ੍ਰੀਖਿਆਵਾਂ ਲਈ ਸਿੱਖੋ';

  @override
  String get learnHeroBody =>
      'ਕਰੰਟ ਅਫੇਅਰਜ਼, ਨੋਟਸ ਅਤੇ ਮੁਫ਼ਤ ਅਭਿਆਸ, ਜੋ ਅਸਲ ਵਿੱਚ ਤੁਹਾਡੇ ਲਈ ਪ੍ਰਕਾਸ਼ਿਤ ਹਨ।';

  @override
  String get learnArticle => 'ਲੇਖ';

  @override
  String learnMinFree(int minutes) {
    return '$minutes ਮਿੰਟ · ਮੁਫ਼ਤ';
  }

  @override
  String get learnLoadFailed => 'ਮੁਫ਼ਤ ਸਿੱਖਣ ਦੀ ਸਮੱਗਰੀ ਲੋਡ ਨਹੀਂ ਹੋ ਸਕੀ';

  @override
  String get learnEmpty =>
      'ਅਜੇ ਕੋਈ ਮੁਫ਼ਤ ਸਮੱਗਰੀ ਪ੍ਰਕਾਸ਼ਿਤ ਨਹੀਂ ਹੈ। ਪ੍ਰਕਾਸ਼ਿਤ ਸਮੱਗਰੀ ਇੱਥੇ ਆਪਣੇ ਆਪ ਦਿਖੇਗੀ।';

  @override
  String get learnPartialRefresh =>
      'ਕੁਝ ਸਮੱਗਰੀ ਰੀਫ੍ਰੈਸ਼ ਨਹੀਂ ਹੋ ਸਕੀ। ਉੱਪਰ ਦਿਖਾਈਆਂ ਚੀਜ਼ਾਂ ਅਜੇ ਵੀ ਉਪਲਬਧ ਹਨ।';

  @override
  String get learnOpenFailed => 'ਇਹ ਸਮੱਗਰੀ ਖੋਲ੍ਹੀ ਨਹੀਂ ਜਾ ਸਕੀ।';

  @override
  String get learnSelectedExams => 'ਚੁਣੀਆਂ ਪ੍ਰੀਖਿਆਵਾਂ';
}
