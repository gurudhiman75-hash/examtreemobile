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

  @override
  String get homeExamCategories => 'ਪ੍ਰੀਖਿਆ ਸ਼੍ਰੇਣੀਆਂ';

  @override
  String get homeSeeAll => 'ਸਾਰੇ ਦੇਖੋ';

  @override
  String get homeCategoriesFailed => 'ਪ੍ਰੀਖਿਆ ਸ਼੍ਰੇਣੀਆਂ ਲੋਡ ਨਹੀਂ ਹੋ ਸਕੀਆਂ';

  @override
  String get homeNoCategories => 'ਅਜੇ ਕੋਈ ਪ੍ਰੀਖਿਆ ਸ਼੍ਰੇਣੀ ਪ੍ਰਕਾਸ਼ਿਤ ਨਹੀਂ ਹੈ।';

  @override
  String get homeFeaturedSeries => 'ਚੋਣਵੀਆਂ ਟੈਸਟ ਸੀਰੀਜ਼';

  @override
  String get homeSeriesFailed => 'ਟੈਸਟ ਸੀਰੀਜ਼ ਲੋਡ ਨਹੀਂ ਹੋ ਸਕੀ';

  @override
  String get homeContinueLearning => 'ਸਿੱਖਣਾ ਜਾਰੀ ਰੱਖੋ';

  @override
  String get homeRecommendedLearning => 'ਸੁਝਾਈ ਗਈ ਸਮੱਗਰੀ';

  @override
  String get homeCurrentAffairs => 'ਕਰੰਟ ਅਫੇਅਰਜ਼';

  @override
  String get homeProgressUnavailable => 'ਪ੍ਰਗਤੀ ਅਜੇ ਉਪਲਬਧ ਨਹੀਂ ਹੈ';

  @override
  String get familyPunjab => 'ਪੰਜਾਬ ਸਰਕਾਰ';

  @override
  String get familyBanking => 'ਬੈਂਕਿੰਗ';

  @override
  String get familyRailway => 'ਰੇਲਵੇ';

  @override
  String get familyTeaching => 'ਅਧਿਆਪਨ';

  @override
  String get familyDefence => 'ਰੱਖਿਆ';

  @override
  String get familyStatePcs => 'ਰਾਜ PCS';

  @override
  String get familyOther => 'ਹੋਰ ਪ੍ਰੀਖਿਆਵਾਂ';

  @override
  String get homeExplore => 'ਦੇਖੋ';

  @override
  String get homeTests => 'ਟੈਸਟ';

  @override
  String get homeMins => 'ਮਿੰਟ';

  @override
  String get homeMarks => 'ਅੰਕ';

  @override
  String get homeQuestions => 'ਸਵਾਲ';

  @override
  String get homeDuration => 'ਸਮਾਂ';

  @override
  String minutesShort(int minutes) {
    return '$minutes ਮਿੰਟ';
  }

  @override
  String get homeHeroTitle => 'ਤੁਹਾਡੀ ਤਿਆਰੀ\nਇੱਥੋਂ ਸ਼ੁਰੂ';

  @override
  String get homeHeroBody =>
      'ਮੌਕ ਟੈਸਟ, ਪੜ੍ਹਾਈ ਅਤੇ ਪ੍ਰੀਖਿਆ-ਕੇਂਦਰਿਤ ਅਭਿਆਸ ਇੱਕੋ ਥਾਂ।';

  @override
  String get homeSearchHint => 'ਪ੍ਰੀਖਿਆਵਾਂ, ਟੈਸਟ ਸੀਰੀਜ਼, ਵਿਸ਼ੇ ਖੋਜੋ...';

  @override
  String get homeContinueUnavailable => 'ਸਿੱਖਣਾ ਜਾਰੀ ਰੱਖੋ ਅਜੇ ਉਪਲਬਧ ਨਹੀਂ ਹੈ';

  @override
  String get homeKeepGoing => 'ਲੱਗੇ ਰਹੋ!';

  @override
  String homeTestsCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ਹੁਣ ਤੱਕ $count ਟੈਸਟ ਪੂਰੇ।',
      one: 'ਹੁਣ ਤੱਕ 1 ਟੈਸਟ ਪੂਰਾ।',
    );
    return '$_temp0';
  }

  @override
  String get homeSearchTests => 'ਟੈਸਟ ਖੋਜੋ';

  @override
  String get homeOpenProfile => 'ਪ੍ਰੋਫਾਈਲ ਖੋਲ੍ਹੋ';

  @override
  String homeNotificationsUnreadA11y(int count) {
    return 'ਸੂਚਨਾਵਾਂ, $count ਅਣਪੜ੍ਹੀਆਂ';
  }

  @override
  String get homeNotificationsNoneA11y => 'ਸੂਚਨਾਵਾਂ, ਕੋਈ ਨਵੀਂ ਨਹੀਂ';

  @override
  String homeNotificationsUnread(int count) {
    return 'ਸੂਚਨਾਵਾਂ ($count ਅਣਪੜ੍ਹੀਆਂ)';
  }

  @override
  String get homeNotifications => 'ਸੂਚਨਾਵਾਂ';

  @override
  String get homeNextActionFailed => 'ਤੁਹਾਡਾ ਅਗਲਾ ਕਦਮ ਤਿਆਰ ਨਹੀਂ ਹੋ ਸਕਿਆ';

  @override
  String get homeLearn => 'ਸਿੱਖੋ';

  @override
  String get homeRevision => 'ਦੁਹਰਾਈ';

  @override
  String get homeStore => 'ਸਟੋਰ';

  @override
  String get homeStrongMomentum => 'ਵਧੀਆ ਰਫ਼ਤਾਰ';

  @override
  String get homeKeepConsistency => 'ਲਗਾਤਾਰਤਾ ਬਣਾਈ ਰੱਖੋ';

  @override
  String get homeFocusAccuracy => 'ਪਹਿਲਾਂ ਸ਼ੁੱਧਤਾ \'ਤੇ ਧਿਆਨ ਦਿਓ';

  @override
  String get homeAvgScore => 'ਔਸਤ ਸਕੋਰ';

  @override
  String get homePerQuestion => 'ਪ੍ਰਤੀ ਸਵਾਲ';

  @override
  String homeQs(int count) {
    return '$count ਸਵਾਲ';
  }

  @override
  String get homeNoTests => 'ਅਜੇ ਕੋਈ ਟੈਸਟ ਪ੍ਰਕਾਸ਼ਿਤ ਨਹੀਂ ਹੈ।';

  @override
  String get homeCaughtUp => 'ਤੁਸੀਂ ਸਾਰੇ ਮੌਜੂਦਾ ਸੁਝਾਅ ਪੂਰੇ ਕਰ ਲਏ ਹਨ।';

  @override
  String get homeBrowse => 'ਦੇਖੋ';

  @override
  String homeScorePct(int value) {
    return '$value% ਸਕੋਰ';
  }

  @override
  String homeAccuracyPct(int value) {
    return '$value% ਸ਼ੁੱਧਤਾ';
  }

  @override
  String homeDue(int count) {
    return '$count ਬਾਕੀ';
  }

  @override
  String get homeStudent => 'ਵਿਦਿਆਰਥੀ';

  @override
  String get homeGoodMorning => 'ਸ਼ੁਭ ਸਵੇਰ';

  @override
  String get homeGoodAfternoon => 'ਸਤਿ ਸ੍ਰੀ ਅਕਾਲ';

  @override
  String get homeGoodEvening => 'ਸ਼ੁਭ ਸ਼ਾਮ';

  @override
  String get storeEnterCoupon => 'ਪਹਿਲਾਂ ਕੂਪਨ ਕੋਡ ਦਰਜ ਕਰੋ।';

  @override
  String storeCouponApplied(String amount) {
    return 'ਕੂਪਨ ਲੱਗਿਆ • $amount ਦੀ ਬੱਚਤ';
  }

  @override
  String get storeChoosePlan => 'ਪਲਾਨ ਚੁਣੋ';

  @override
  String get storePlansFailed => 'ਪਲਾਨ ਲੋਡ ਨਹੀਂ ਹੋ ਸਕੇ';

  @override
  String get storeAlreadyActive => 'ਇਹ ਟੈਸਟ ਸੀਰੀਜ਼ ਪਹਿਲਾਂ ਹੀ ਚਾਲੂ ਹੈ।';

  @override
  String get storeOpenTestSeries => 'ਟੈਸਟ ਸੀਰੀਜ਼ ਖੋਲ੍ਹੋ';

  @override
  String get storeNoPlan => 'ਅਜੇ ਕੋਈ ਖਰੀਦ ਪਲਾਨ ਉਪਲਬਧ ਨਹੀਂ ਹੈ।';

  @override
  String storePremiumFree(int premium, int free) {
    return '$premium ਪ੍ਰੀਮੀਅਮ ਟੈਸਟ • $free ਮੁਫ਼ਤ';
  }

  @override
  String get storeChooseAccessPlan => 'ਆਪਣਾ ਐਕਸੈਸ ਪਲਾਨ ਚੁਣੋ';

  @override
  String get storePublishedOnly => 'ਸਿਰਫ਼ ਹੁਣ ਪ੍ਰਕਾਸ਼ਿਤ ਪਲਾਨ ਦਿਖਾਏ ਗਏ ਹਨ।';

  @override
  String get storeHaveCoupon => 'ਕੂਪਨ ਹੈ?';

  @override
  String get storeCouponHint => 'ਕੂਪਨ ਕੋਡ ਦਰਜ ਕਰੋ';

  @override
  String get storeApply => 'ਲਗਾਓ';

  @override
  String get storeSelectedPlan => 'ਚੁਣਿਆ ਪਲਾਨ';

  @override
  String get continueLabel => 'ਜਾਰੀ ਰੱਖੋ';

  @override
  String storeTestsIncluded(int count) {
    return '$count ਸੀਰੀਜ਼ ਟੈਸਟ ਸ਼ਾਮਲ';
  }

  @override
  String storePercentOff(int percent) {
    return '$percent% ਛੋਟ';
  }

  @override
  String get storeOpenPaymentFailed => 'ਸੁਰੱਖਿਅਤ ਭੁਗਤਾਨ ਨਹੀਂ ਖੁੱਲ੍ਹ ਸਕਿਆ।';

  @override
  String get storeIncompleteConfirmation =>
      'ਭੁਗਤਾਨ ਦੀ ਪੁਸ਼ਟੀ ਅਧੂਰੀ ਮਿਲੀ। ਕਿਰਪਾ ਕਰਕੇ ਦੁਬਾਰਾ ਜਾਂਚੋ।';

  @override
  String get storePaymentNotCompleted => 'ਭੁਗਤਾਨ ਪੂਰਾ ਨਹੀਂ ਹੋਇਆ।';

  @override
  String get storeContinueWallet =>
      'ਭੁਗਤਾਨ ਪੂਰਾ ਕਰਨ ਲਈ ਆਪਣੇ ਵਾਲੇਟ ਵਿੱਚ ਜਾਰੀ ਰੱਖੋ।';

  @override
  String storeContinueInWallet(String wallet) {
    return 'ਭੁਗਤਾਨ ਪੂਰਾ ਕਰਨ ਲਈ $wallet ਵਿੱਚ ਜਾਰੀ ਰੱਖੋ।';
  }

  @override
  String get storeActivationProcessing =>
      'ਭੁਗਤਾਨ ਮਿਲ ਗਿਆ ਹੈ ਪਰ ਐਕਟੀਵੇਸ਼ਨ ਅਜੇ ਚੱਲ ਰਹੀ ਹੈ। ਭੁਗਤਾਨ ਜਾਂਚੋ ਦਬਾਓ।';

  @override
  String get storeCheckout => 'ਚੈੱਕਆਊਟ';

  @override
  String get storeCheckoutFailed => 'ਚੈੱਕਆਊਟ ਲੋਡ ਨਹੀਂ ਹੋ ਸਕਿਆ';

  @override
  String get storePlanUnavailable => 'ਇਹ ਪਲਾਨ ਹੁਣ ਉਪਲਬਧ ਨਹੀਂ ਹੈ।';

  @override
  String get storeReviewPay => 'ਦੇਖੋ ਅਤੇ ਭੁਗਤਾਨ ਕਰੋ';

  @override
  String get storeCouponRevalidate =>
      'ਕੂਪਨ ਦੀ ਦੁਬਾਰਾ ਜਾਂਚ ਨਹੀਂ ਹੋ ਸਕੀ। ਵਾਪਸ ਜਾ ਕੇ ਦੁਬਾਰਾ ਲਗਾਓ।';

  @override
  String get storeVerifyPayment => 'ਭੁਗਤਾਨ ਜਾਂਚੋ';

  @override
  String storePayAmount(String amount) {
    return '$amount ਦਾ ਭੁਗਤਾਨ ਕਰੋ';
  }

  @override
  String get storeOrderSummary => 'ਆਰਡਰ ਸਾਰ';

  @override
  String storeAccess(String validity) {
    return '$validity ਐਕਸੈਸ';
  }

  @override
  String get storePlanPrice => 'ਪਲਾਨ ਕੀਮਤ';

  @override
  String get storeCouponDiscount => 'ਕੂਪਨ ਛੋਟ';

  @override
  String get storeTotalPayable => 'ਕੁੱਲ ਭੁਗਤਾਨ ਰਕਮ';

  @override
  String get storeUpiCards => 'UPI, ਕਾਰਡ ਅਤੇ ਹੋਰ';

  @override
  String get storeRazorpayBody =>
      'ਸੁਰੱਖਿਅਤ Razorpay ਚੈੱਕਆਊਟ ਵਿੱਚ UPI, ਕਾਰਡ, ਨੈੱਟ ਬੈਂਕਿੰਗ ਜਾਂ ਵਾਲੇਟ ਚੁਣੋ।';

  @override
  String storeCouponSaved(String code, String amount) {
    return '$code ਲੱਗਿਆ • ਤੁਹਾਡੀ ਬੱਚਤ $amount';
  }

  @override
  String get storeActivating => 'ਤੁਹਾਡੀ ਟੈਸਟ ਸੀਰੀਜ਼ ਚਾਲੂ ਹੋ ਰਹੀ ਹੈ…';

  @override
  String get storeKeepOpen => 'ਭੁਗਤਾਨ ਦੀ ਜਾਂਚ ਹੋਣ ਤੱਕ ਇਹ ਸਕ੍ਰੀਨ ਖੁੱਲ੍ਹੀ ਰੱਖੋ।';

  @override
  String get storeRazorpayNote =>
      'ਭੁਗਤਾਨ Razorpay ਰਾਹੀਂ ਸੁਰੱਖਿਅਤ ਢੰਗ ਨਾਲ ਹੁੰਦਾ ਹੈ। Examtree ਤੁਹਾਡੇ ਕਾਰਡ ਜਾਂ UPI ਵੇਰਵੇ ਕਦੇ ਸੇਵ ਨਹੀਂ ਕਰਦਾ।';

  @override
  String get validityAsPublished => 'ਪ੍ਰਕਾਸ਼ਿਤ ਮਿਆਦ ਅਨੁਸਾਰ';

  @override
  String validityMonths(int count) {
    return '$count ਮਹੀਨੇ';
  }

  @override
  String validityDays(int count) {
    return '$count ਦਿਨ';
  }

  @override
  String get paySuccessTitle => 'ਭੁਗਤਾਨ ਸਫਲ!';

  @override
  String get paySuccessBody =>
      'ਤੁਹਾਡੀ ਟੈਸਟ ਸੀਰੀਜ਼ ਅਨਲੌਕ ਹੋ ਗਈ ਹੈ ਅਤੇ ਤਿਆਰੀ ਲਈ ਤਿਆਰ ਹੈ।';

  @override
  String get payAccessActive => 'ਐਕਸੈਸ ਚਾਲੂ';

  @override
  String get payActive => 'ਚਾਲੂ';

  @override
  String get payMockTests => 'ਮੌਕ ਟੈਸਟ';

  @override
  String get payMockTestsBody => 'ਤੁਹਾਡੀ ਖਰੀਦੀ ਸੀਰੀਜ਼ ਦਾ ਪੂਰਾ ਐਕਸੈਸ';

  @override
  String get payAnalysis => 'ਵਿਸਤ੍ਰਿਤ ਵਿਸ਼ਲੇਸ਼ਣ';

  @override
  String get payAnalysisBody => 'ਕੋਸ਼ਿਸ਼ਾਂ, ਸ਼ੁੱਧਤਾ ਅਤੇ ਪ੍ਰਗਤੀ ਦੇਖੋ';

  @override
  String get payBilingual => 'ਦੋ-ਭਾਸ਼ੀ ਸਮੱਗਰੀ';

  @override
  String get payBilingualBody => 'ਪੂਰੀ ਸੀਰੀਜ਼ ਵਿੱਚ ਉਪਲਬਧ ਭਾਸ਼ਾਵਾਂ ਵਰਤੋ';

  @override
  String get paySolutions => 'ਵਿਸਤ੍ਰਿਤ ਹੱਲ';

  @override
  String get paySolutionsBody => 'ਹਰ ਕੋਸ਼ਿਸ਼ ਤੋਂ ਬਾਅਦ ਵਿਆਖਿਆ ਦੇਖੋ';

  @override
  String get paySafe => 'ਤੁਹਾਡੀ ਪ੍ਰਗਤੀ ਸੁਰੱਖਿਅਤ ਹੈ';

  @override
  String get paySafeBody =>
      'ਤੁਹਾਡੇ ਐਕਸੈਸ ਨਾਲ ਕੋਸ਼ਿਸ਼ਾਂ, ਵਿਸ਼ਲੇਸ਼ਣ ਅਤੇ ਬੁੱਕਮਾਰਕ ਸੁਰੱਖਿਅਤ ਰਹਿੰਦੇ ਹਨ।';

  @override
  String get payStart => 'ਹੁਣੇ ਸਿੱਖਣਾ ਸ਼ੁਰੂ ਕਰੋ';

  @override
  String get payStartBody =>
      'ਜਿੱਥੇ ਛੱਡਿਆ ਸੀ ਉੱਥੋਂ ਜਾਰੀ ਰੱਖੋ ਅਤੇ ਤਿਆਰੀ ਸਹੀ ਰਾਹ \'ਤੇ ਰੱਖੋ।';

  @override
  String get payOrder => 'ਆਰਡਰ';

  @override
  String get payViewReceipt => 'ਰਸੀਦ ਦੇਖੋ';

  @override
  String get readyTitle => 'ਤੁਸੀਂ ਤਿਆਰ ਹੋ!';

  @override
  String get readyBody =>
      'ਤੁਹਾਡੀ ExamTree ਟੈਸਟ ਸੀਰੀਜ਼ ਚਾਲੂ ਹੈ ਅਤੇ ਵਰਤੋਂ ਲਈ ਤਿਆਰ ਹੈ।';

  @override
  String get readyOpen => 'ਆਪਣੀ ਟੈਸਟ ਸੀਰੀਜ਼ ਖੋਲ੍ਹੋ';

  @override
  String get readyOpenBody =>
      'ਤੁਹਾਡੀ ਖਰੀਦੀ ਸੀਰੀਜ਼ ਹੁਣ ਮੇਰੀ ਟੈਸਟ ਸੀਰੀਜ਼ ਵਿੱਚ ਦਿਖਦੀ ਹੈ।';

  @override
  String get readyChoose => 'ਟੈਸਟ ਚੁਣੋ';

  @override
  String get readyChooseBody =>
      'ਫੁੱਲ ਮੌਕ, ਸੈਕਸ਼ਨਲ, PYQ ਜਾਂ ਵਿਸ਼ਾਵਾਰ ਟੈਸਟ ਨਾਲ ਸ਼ੁਰੂ ਕਰੋ।';

  @override
  String get readyTrack => 'ਆਪਣਾ ਪ੍ਰਦਰਸ਼ਨ ਦੇਖੋ';

  @override
  String get readyTrackBody =>
      'ਆਪਣੀ ਪ੍ਰੋਫਾਈਲ ਤੋਂ ਸਕੋਰ, ਸ਼ੁੱਧਤਾ, ਕੋਸ਼ਿਸ਼ਾਂ ਅਤੇ ਪ੍ਰਗਤੀ ਦੇਖੋ।';

  @override
  String get readyGoMySeries => 'ਮੇਰੀ ਟੈਸਟ ਸੀਰੀਜ਼ \'ਤੇ ਜਾਓ';

  @override
  String get readyViewOrder => 'ਆਰਡਰ ਵੇਰਵੇ ਦੇਖੋ';

  @override
  String get seriesLockedTitle => 'ਇਹ ਟੈਸਟ ਲਾਕ ਹੈ';

  @override
  String seriesFreeAvailable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ਇਸ ਸੀਰੀਜ਼ ਵਿੱਚ $count ਮੁਫ਼ਤ ਟੈਸਟ ਉਪਲਬਧ ਹਨ।',
      one: 'ਇਸ ਸੀਰੀਜ਼ ਵਿੱਚ 1 ਮੁਫ਼ਤ ਟੈਸਟ ਉਪਲਬਧ ਹੈ।',
    );
    return '$_temp0';
  }

  @override
  String get seriesTryFree => 'ਮੁਫ਼ਤ ਟੈਸਟ ਅਜ਼ਮਾਓ';

  @override
  String get seriesViewPlansUnlock => 'ਪਲਾਨ ਦੇਖੋ ਅਤੇ ਅਨਲੌਕ ਕਰੋ';

  @override
  String get seriesMaybeLater => 'ਬਾਅਦ ਵਿੱਚ';

  @override
  String seriesStructuredPractice(String exam) {
    return '$exam ਲਈ ਵਿਵਸਥਿਤ ਮੌਕ-ਟੈਸਟ ਅਭਿਆਸ।';
  }

  @override
  String get seriesComingSoon => 'ਜਲਦ ਆ ਰਿਹਾ ਹੈ';

  @override
  String get seriesActive => 'ਚਾਲੂ';

  @override
  String get seriesUnavailable => 'ਉਪਲਬਧ ਨਹੀਂ';

  @override
  String get seriesInPreparation => 'ਸਮੱਗਰੀ ਤਿਆਰ ਹੋ ਰਹੀ ਹੈ';

  @override
  String seriesPercentComplete(int percent) {
    return '$percent% ਪੂਰਾ';
  }

  @override
  String seriesTestsFraction(int done, int total) {
    return '$done/$total ਟੈਸਟ';
  }

  @override
  String get seriesPracticeTime => 'ਅਭਿਆਸ ਸਮਾਂ';

  @override
  String get seriesProgress => 'ਪ੍ਰਗਤੀ';

  @override
  String get seriesTabOverview => 'ਝਲਕ';

  @override
  String get seriesTabTestList => 'ਟੈਸਟ ਸੂਚੀ';

  @override
  String get seriesTabSyllabus => 'ਸਿਲੇਬਸ';

  @override
  String get seriesTabPattern => 'ਪ੍ਰੀਖਿਆ ਪੈਟਰਨ';

  @override
  String get seriesTabReviews => 'ਸਮੀਖਿਆਵਾਂ';

  @override
  String get seriesTabFaqs => 'ਸਵਾਲ-ਜਵਾਬ';

  @override
  String get seriesSequential => 'ਤਰਤੀਬ ਨਾਲ ਅੱਗੇ ਵਧੋ';

  @override
  String get seriesScoreGated => 'ਸਕੋਰ ਦੇ ਆਧਾਰ \'ਤੇ ਅੱਗੇ ਵਧੋ';

  @override
  String get seriesOpenProgression => 'ਕਿਸੇ ਵੀ ਤਰਤੀਬ ਵਿੱਚ ਦਿਓ';

  @override
  String get seriesAbout => 'ਇਸ ਸੀਰੀਜ਼ ਬਾਰੇ';

  @override
  String seriesOrganisedFor(String exam) {
    return 'ਇਹ ਸੀਰੀਜ਼ $exam ਦੇ ਵਿਵਸਥਿਤ ਅਭਿਆਸ ਲਈ ਬਣਾਈ ਗਈ ਹੈ।';
  }

  @override
  String get seriesIncluded => 'ਕੀ ਸ਼ਾਮਲ ਹੈ';

  @override
  String seriesRequired(int count) {
    return '$count ਲਾਜ਼ਮੀ';
  }

  @override
  String get seriesWhyChoose => 'ਇਹ ਸੀਰੀਜ਼ ਕਿਉਂ ਚੁਣੋ';

  @override
  String get seriesWhyProgress => 'ਪ੍ਰਗਤੀ ਟ੍ਰੈਕਿੰਗ';

  @override
  String get seriesWhyProgressBody =>
      'ਪੂਰੇ ਹੋਏ ਟੈਸਟ ਅਤੇ ਤੁਹਾਡਾ ਅਗਲਾ ਟੈਸਟ ਹਮੇਸ਼ਾ ਦਿਖਦੇ ਰਹਿੰਦੇ ਹਨ।';

  @override
  String get seriesWhyUnlock => 'ਸਾਫ਼ ਅਨਲੌਕ ਨਿਯਮ';

  @override
  String get seriesWhyUnlockBody =>
      'ਟੈਸਟ ਖੋਲ੍ਹਣ ਤੋਂ ਪਹਿਲਾਂ ਸਮੇਂ ਅਤੇ ਪ੍ਰਗਤੀ ਆਧਾਰਿਤ ਲਾਕ ਦਿਖਾਏ ਜਾਂਦੇ ਹਨ।';

  @override
  String get seriesWhyInstructions => 'ਕੋਸ਼ਿਸ਼ ਤੋਂ ਪਹਿਲਾਂ ਹਦਾਇਤਾਂ';

  @override
  String get seriesWhyInstructionsBody =>
      'ਹਰ ਅਨਲੌਕ ਟੈਸਟ ਟਾਈਮਰ ਸ਼ੁਰੂ ਹੋਣ ਤੋਂ ਪਹਿਲਾਂ ਆਪਣੇ ਵੇਰਵੇ ਅਤੇ ਹਦਾਇਤਾਂ ਦਿਖਾਉਂਦਾ ਹੈ।';

  @override
  String get seriesNoTests => 'ਇਸ ਸੀਰੀਜ਼ ਵਿੱਚ ਅਜੇ ਕੋਈ ਟੈਸਟ ਉਪਲਬਧ ਨਹੀਂ ਹੈ।';

  @override
  String seriesTypeCountA11y(String label, int count) {
    return '$label, $count ਟੈਸਟ';
  }

  @override
  String get seriesNoPattern => 'ਅਜੇ ਕੋਈ ਟੈਸਟ ਪੈਟਰਨ ਉਪਲਬਧ ਨਹੀਂ ਹੈ।';

  @override
  String get seriesPattern => 'ਸੀਰੀਜ਼ ਪੈਟਰਨ';

  @override
  String seriesMinTotal(int minutes) {
    return 'ਕੁੱਲ $minutes ਮਿੰਟ';
  }

  @override
  String get seriesBreakdown => 'ਟੈਸਟ-ਵਾਰ ਵੇਰਵਾ';

  @override
  String seriesSyllabusBody(String exam) {
    return '$exam ਦੀ ਵਿਸ਼ਾਵਾਰ ਪੂਰੀ ਤਿਆਰੀ। ਹੇਠਾਂ ਦੇ ਟੈਸਟ ਸਮੂਹ ਪ੍ਰਕਾਸ਼ਿਤ ਸੀਰੀਜ਼ ਸੂਚੀ ਤੋਂ ਬਣੇ ਹਨ।';
  }

  @override
  String get seriesSyllabusEmpty => 'ਟੈਸਟ ਪ੍ਰਕਾਸ਼ਿਤ ਹੋਣ \'ਤੇ ਸਿਲੇਬਸ ਦਿਖੇਗਾ।';

  @override
  String seriesPublishedTestsQuestions(int tests, int questions) {
    return '$tests ਪ੍ਰਕਾਸ਼ਿਤ ਟੈਸਟ · $questions ਸਵਾਲ';
  }

  @override
  String get seriesReviewsEmpty =>
      'ਪ੍ਰਕਾਸ਼ਿਤ ਸਮੀਖਿਆਵਾਂ ਉਪਲਬਧ ਹੋਣ \'ਤੇ ਇੱਥੇ ਦਿਖਣਗੀਆਂ।';

  @override
  String get seriesStudentReviews => 'ਵਿਦਿਆਰਥੀਆਂ ਦੀਆਂ ਸਮੀਖਿਆਵਾਂ';

  @override
  String seriesRatedReviews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ਰੇਟਡ ਸਮੀਖਿਆਵਾਂ',
      one: '1 ਰੇਟਡ ਸਮੀਖਿਆ',
    );
    return '$_temp0';
  }

  @override
  String get faqIncludedQ => 'ਇਸ ਟੈਸਟ ਸੀਰੀਜ਼ ਵਿੱਚ ਕੀ ਸ਼ਾਮਲ ਹੈ?';

  @override
  String faqIncludedA(int tests, int questions) {
    return '$tests ਪ੍ਰਕਾਸ਼ਿਤ ਟੈਸਟ, ਕੁੱਲ $questions ਸਵਾਲ, ਲਾਈਵ ਸੂਚੀ ਅਤੇ ਤੁਹਾਡੇ ਐਕਸੈਸ ਪਲਾਨ ਅਨੁਸਾਰ।';
  }

  @override
  String get faqExplanationsQ => 'ਕੀ ਵਿਆਖਿਆ ਉਪਲਬਧ ਹੈ?';

  @override
  String get faqExplanationsA =>
      'ਪੂਰੀਆਂ ਕੋਸ਼ਿਸ਼ਾਂ ਦੀ ਸਮੀਖਿਆ ਟੈਸਟ ਵਿੱਚ ਉਪਲਬਧ ਵਿਆਖਿਆ ਅਤੇ ਵਿਸ਼ਲੇਸ਼ਣ ਨਾਲ ਕੀਤੀ ਜਾ ਸਕਦੀ ਹੈ।';

  @override
  String get faqMultipleQ => 'ਕੀ ਮੈਂ ਇੱਕ ਟੈਸਟ ਕਈ ਵਾਰ ਦੇ ਸਕਦਾ ਹਾਂ?';

  @override
  String get faqMultipleA =>
      'ਕੋਸ਼ਿਸ਼ਾਂ ਦੀ ਹੱਦ ਟੈਸਟ ਹਦਾਇਤਾਂ ਪੰਨੇ \'ਤੇ ਦਿਖਦੀ ਹੈ ਅਤੇ ਟੈਸਟ ਸੈਟਿੰਗ ਨਾਲ ਲਾਗੂ ਹੁੰਦੀ ਹੈ।';

  @override
  String get faqLanguageQ => 'ਕੀ ਮੈਂ ਸਵਾਲਾਂ ਦੀ ਭਾਸ਼ਾ ਬਦਲ ਸਕਦਾ ਹਾਂ?';

  @override
  String get faqLanguageA =>
      'ਟੈਸਟ ਸ਼ੁਰੂ ਕਰਨ ਤੋਂ ਪਹਿਲਾਂ ਉਪਲਬਧ ਭਾਸ਼ਾਵਾਂ ਦਿਖਾਈਆਂ ਜਾਂਦੀਆਂ ਹਨ। ਇਹ ਪ੍ਰਕਾਸ਼ਿਤ ਸਵਾਲਾਂ \'ਤੇ ਨਿਰਭਰ ਕਰਦਾ ਹੈ।';

  @override
  String get faqExpiryQ => 'ਮੇਰਾ ਐਕਸੈਸ ਖ਼ਤਮ ਹੋਣ \'ਤੇ ਕੀ ਹੋਵੇਗਾ?';

  @override
  String get faqExpiryA =>
      'ਤੁਸੀਂ ਮੇਰੀ ਟੈਸਟ ਸੀਰੀਜ਼ ਤੋਂ ਸੀਰੀਜ਼ ਰੀਨਿਊ ਕਰ ਸਕਦੇ ਹੋ। ਮੌਜੂਦਾ ਪ੍ਰਗਤੀ ਅਤੇ ਵਿਸ਼ਲੇਸ਼ਣ ਤੁਹਾਡੇ ਖਾਤੇ ਨਾਲ ਜੁੜੇ ਰਹਿੰਦੇ ਹਨ।';

  @override
  String get faqPreviousQ => 'ਮੈਂ ਆਪਣੀਆਂ ਪਿਛਲੀਆਂ ਕੋਸ਼ਿਸ਼ਾਂ ਕਿੱਥੇ ਦੇਖ ਸਕਦਾ ਹਾਂ?';

  @override
  String get faqPreviousA =>
      'ਪੂਰੀਆਂ ਕੋਸ਼ਿਸ਼ਾਂ ਅਤੇ ਪ੍ਰਦਰਸ਼ਨ ਦੇਖਣ ਲਈ ਮੇਰੀ ਟੈਸਟ ਸੀਰੀਜ਼, ਪ੍ਰੋਫਾਈਲ ਜਾਂ ਨਤੀਜੇ ਖੋਲ੍ਹੋ।';

  @override
  String get seriesYourProgress => 'ਤੁਹਾਡੀ ਸੀਰੀਜ਼ ਪ੍ਰਗਤੀ';

  @override
  String seriesCompletedOf(int done, int total) {
    return '$total ਵਿੱਚੋਂ $done ਟੈਸਟ ਪੂਰੇ';
  }

  @override
  String get typeFullTitle => 'ਫੁੱਲ ਲੈਂਥ ਮੌਕ ਟੈਸਟ';

  @override
  String get typeFullSubtitle => 'ਨਵੇਂ ਪੈਟਰਨ \'ਤੇ ਪੂਰੇ ਸਿਲੇਬਸ ਦੇ ਟੈਸਟ';

  @override
  String get typeSectionalTitle => 'ਸੈਕਸ਼ਨਲ ਟੈਸਟ';

  @override
  String get typeSectionalSubtitle => 'ਵਿਸ਼ਾਵਾਰ ਅਭਿਆਸ ਟੈਸਟ';

  @override
  String get typeTopicTitle => 'ਟੌਪਿਕ-ਵਾਰ ਟੈਸਟ';

  @override
  String get typeTopicSubtitle => 'ਜ਼ਰੂਰੀ ਟੌਪਿਕਾਂ \'ਤੇ ਕੇਂਦਰਿਤ ਅਭਿਆਸ';

  @override
  String get typePyqTitle => 'ਪਿਛਲੇ ਸਾਲ ਦੇ ਪੇਪਰ';

  @override
  String get typePyqSubtitle => 'ਸਮੀਖਿਆ ਸਮੇਤ ਪਿਛਲੇ ਪ੍ਰੀਖਿਆ ਪੇਪਰ';

  @override
  String get typeFullTab => 'ਫੁੱਲ';

  @override
  String get typeSectionalTab => 'ਸੈਕਸ਼ਨਲ';

  @override
  String get typeTopicTab => 'ਟੌਪਿਕ-ਵਾਰ';

  @override
  String get typePyqTab => 'PYQ';

  @override
  String get seriesStateCompleted => 'ਪੂਰਾ';

  @override
  String get seriesStatePremium => 'ਪ੍ਰੀਮੀਅਮ';

  @override
  String get seriesStateReady => 'ਤਿਆਰ';

  @override
  String get seriesStateLocked => 'ਲਾਕ';

  @override
  String get seriesOptional => 'ਵਿਕਲਪਿਕ';

  @override
  String get seriesRequiredTag => 'ਲਾਜ਼ਮੀ';

  @override
  String seriesBestScore(String score) {
    return 'ਸਭ ਤੋਂ ਵਧੀਆ ਸਕੋਰ: $score';
  }

  @override
  String get seriesOpenAgain => 'ਟੈਸਟ ਦੁਬਾਰਾ ਖੋਲ੍ਹੋ';

  @override
  String get seriesViewInstructions => 'ਹਦਾਇਤਾਂ ਦੇਖੋ';

  @override
  String get seriesUnlockPremium => 'ਪ੍ਰੀਮੀਅਮ ਟੈਸਟ ਅਨਲੌਕ ਕਰੋ';

  @override
  String get seriesProgressLabel => 'ਸੀਰੀਜ਼ ਪ੍ਰਗਤੀ';

  @override
  String get seriesStatus => 'ਸੀਰੀਜ਼ ਸਥਿਤੀ';

  @override
  String get seriesUpNext => 'ਅਗਲਾ';

  @override
  String get seriesPremiumRequired => 'ਪ੍ਰੀਮੀਅਮ ਐਕਸੈਸ ਲਾਜ਼ਮੀ';

  @override
  String seriesFromPrice(String price) {
    return '$price ਤੋਂ';
  }

  @override
  String get seriesAllCompleted => 'ਸਾਰੇ ਟੈਸਟ ਪੂਰੇ';

  @override
  String get seriesNoneAvailable => 'ਅਜੇ ਕੋਈ ਟੈਸਟ ਉਪਲਬਧ ਨਹੀਂ';

  @override
  String get seriesViewPlans => 'ਪਲਾਨ ਦੇਖੋ';

  @override
  String get seriesReviewTests => 'ਟੈਸਟ ਦੇਖੋ';

  @override
  String get seriesOpenTest => 'ਟੈਸਟ ਖੋਲ੍ਹੋ';

  @override
  String get seriesLoadFailed => 'ਟੈਸਟ ਸੀਰੀਜ਼ ਲੋਡ ਨਹੀਂ ਹੋ ਸਕੀ।';

  @override
  String get seriesCheckConnection => 'ਇੰਟਰਨੈੱਟ ਜਾਂਚੋ ਅਤੇ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get loginLetSBuildYourExam => 'ਆਓ ਤੁਹਾਡੀ ਪ੍ਰੀਖਿਆ ਸਫਲਤਾ ਬਣਾਈਏ';

  @override
  String get loginMasterConceptsPracticeSmarterGet =>
      'ਕਾਂਸੈਪਟ ਸਮਝੋ। ਸਮਝਦਾਰੀ ਨਾਲ ਅਭਿਆਸ ਕਰੋ। ਅਸਲ ਨਤੀਜੇ ਪਾਓ।';

  @override
  String get loginPracticeTheWayRealExams =>
      'ਉਵੇਂ ਹੀ ਅਭਿਆਸ ਕਰੋ ਜਿਵੇਂ ਅਸਲ ਪ੍ਰੀਖਿਆ ਪੁੱਛਦੀ ਹੈ';

  @override
  String get loginUseFocusedMockTestsAnd =>
      'ਕੇਂਦਰਿਤ ਮੌਕ ਟੈਸਟਾਂ ਅਤੇ ਵਿਸਤ੍ਰਿਤ ਹੱਲਾਂ ਨਾਲ ਤਿਆਰੀ ਨੂੰ ਪ੍ਰੀਖਿਆ ਲਈ ਤਿਆਰ ਬਣਾਓ।';

  @override
  String get loginKnowWhatToReviseNext => 'ਜਾਣੋ ਅੱਗੇ ਕੀ ਦੁਹਰਾਉਣਾ ਹੈ';

  @override
  String get loginContinueWhereYouLeftOff =>
      'ਜਿੱਥੇ ਛੱਡਿਆ ਸੀ ਉੱਥੋਂ ਜਾਰੀ ਰੱਖੋ ਅਤੇ ਆਪਣੀ ਪ੍ਰਗਤੀ ਨਾਲ ਦੁਹਰਾਈ ਨੂੰ ਸਹੀ ਦਿਸ਼ਾ ਦਿਓ।';

  @override
  String get loginTooManyVerificationAttemptsPlease =>
      'ਬਹੁਤ ਜ਼ਿਆਦਾ ਕੋਸ਼ਿਸ਼ਾਂ ਹੋ ਗਈਆਂ। ਥੋੜ੍ਹਾ ਰੁਕ ਕੇ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get loginSmsVerificationIsTemporarilyUnavailable =>
      'SMS ਤਸਦੀਕ ਅਜੇ ਉਪਲਬਧ ਨਹੀਂ ਹੈ। ਬਾਅਦ ਵਿੱਚ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get loginThisExamtreeBuildIsNot =>
      'ਇਹ ExamTree ਵਰਜ਼ਨ ਫ਼ੋਨ ਸਾਈਨ-ਇਨ ਲਈ ਅਧਿਕਾਰਤ ਨਹੀਂ ਹੈ।';

  @override
  String get loginPhoneVerificationCouldNotBe =>
      'ਫ਼ੋਨ ਤਸਦੀਕ ਦੀ ਪੁਸ਼ਟੀ ਨਹੀਂ ਹੋ ਸਕੀ। ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get loginCouldNotReachTheVerification =>
      'ਤਸਦੀਕ ਸੇਵਾ ਤੱਕ ਨਹੀਂ ਪਹੁੰਚ ਸਕੇ। ਇੰਟਰਨੈੱਟ ਜਾਂਚੋ ਅਤੇ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get loginThisVerificationSessionHasExpired =>
      'ਇਹ ਤਸਦੀਕ ਸੈਸ਼ਨ ਖ਼ਤਮ ਹੋ ਗਿਆ ਹੈ। ਨਵਾਂ OTP ਮੰਗਵਾਓ।';

  @override
  String get loginPhoneSignInIsNot =>
      'ਇਸ ExamTree ਵਰਜ਼ਨ ਵਿੱਚ ਫ਼ੋਨ ਸਾਈਨ-ਇਨ ਚਾਲੂ ਨਹੀਂ ਹੈ।';

  @override
  String get loginGoogleSignInIsTemporarily =>
      'Google ਸਾਈਨ-ਇਨ ਅਜੇ ਉਪਲਬਧ ਨਹੀਂ ਹੈ। ਬਾਅਦ ਵਿੱਚ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get loginThisEmailAlreadyHasAn =>
      'ਇਸ ਈਮੇਲ ਦਾ ExamTree ਸਾਈਨ-ਇਨ ਤਰੀਕਾ ਪਹਿਲਾਂ ਤੋਂ ਹੈ। ਪਹਿਲਾਂ ਉਸ ਤਰੀਕੇ ਨਾਲ ਸਾਈਨ ਇਨ ਕਰੋ, ਫਿਰ Google ਦੁਬਾਰਾ ਅਜ਼ਮਾਓ।';

  @override
  String get loginGoogleDidNotProvideA =>
      'Google ਨੇ ਇਸ ਖਾਤੇ ਲਈ ਤਸਦੀਕਸ਼ੁਦਾ ਈਮੇਲ ਨਹੀਂ ਦਿੱਤੀ।';

  @override
  String get loginGoogleSignInCouldNot =>
      'Google ਸਾਈਨ-ਇਨ ਸੇਵਾ ਤੱਕ ਨਹੀਂ ਪਹੁੰਚ ਸਕਿਆ। ਇੰਟਰਨੈੱਟ ਜਾਂਚੋ ਅਤੇ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get loginAppleSignInWasCanceled =>
      'Apple ਸਾਈਨ-ਇਨ ਰੱਦ ਹੋਇਆ। ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get loginAppleSignInIsTemporarily =>
      'Apple ਸਾਈਨ-ਇਨ ਅਜੇ ਉਪਲਬਧ ਨਹੀਂ ਹੈ। ਬਾਅਦ ਵਿੱਚ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get loginThisEmailAlreadyHasAn2 =>
      'ਇਸ ਈਮੇਲ ਦਾ ExamTree ਸਾਈਨ-ਇਨ ਤਰੀਕਾ ਪਹਿਲਾਂ ਤੋਂ ਹੈ। ਪਹਿਲਾਂ ਉਸ ਤਰੀਕੇ ਨਾਲ ਸਾਈਨ ਇਨ ਕਰੋ, ਫਿਰ Apple ਦੁਬਾਰਾ ਅਜ਼ਮਾਓ।';

  @override
  String get loginAppleDidNotProvideA =>
      'Apple ਨੇ ਇਸ ਖਾਤੇ ਲਈ ਵਰਤਣਯੋਗ ਤਸਦੀਕਸ਼ੁਦਾ ਈਮੇਲ ਨਹੀਂ ਦਿੱਤੀ।';

  @override
  String get loginAppleSignInCouldNot =>
      'Apple ਸਾਈਨ-ਇਨ ਸੇਵਾ ਤੱਕ ਨਹੀਂ ਪਹੁੰਚ ਸਕਿਆ। ਇੰਟਰਨੈੱਟ ਜਾਂਚੋ ਅਤੇ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get loginResetPassword => 'ਪਾਸਵਰਡ ਰੀਸੈੱਟ ਕਰੋ';

  @override
  String get loginRecoverYourAccount => 'ਆਪਣਾ ਖਾਤਾ ਵਾਪਸ ਪਾਓ';

  @override
  String get loginEnterTheEmailYouUse =>
      'ExamTree ਲਈ ਵਰਤੀ ਈਮੇਲ ਦਰਜ ਕਰੋ, ਅਸੀਂ ਪਾਸਵਰਡ ਰੀਸੈੱਟ ਹਦਾਇਤਾਂ ਭੇਜਾਂਗੇ।';

  @override
  String get loginEmail => 'ਈਮੇਲ';

  @override
  String get loginForPrivacyTheConfirmationScreen =>
      'ਪਰਦੇਦਾਰੀ ਲਈ, ਪੁਸ਼ਟੀ ਸਕ੍ਰੀਨ ਇਹ ਨਹੀਂ ਦੱਸਦੀ ਕਿ ਈਮੇਲ ਰਜਿਸਟਰਡ ਹੈ ਜਾਂ ਨਹੀਂ।';

  @override
  String get loginBackToSignIn => 'ਸਾਈਨ ਇਨ \'ਤੇ ਵਾਪਸ ਜਾਓ';

  @override
  String get loginCheckYourEmail => 'ਆਪਣੀ ਈਮੇਲ ਦੇਖੋ';

  @override
  String get loginCheckYourSpamFolderToo =>
      'ਸਪੈਮ ਫ਼ੋਲਡਰ ਵੀ ਦੇਖੋ। ਪਰਦੇਦਾਰੀ ਲਈ ਅਸੀਂ ਨਹੀਂ ਦੱਸਦੇ ਕਿ ਈਮੇਲ ਰਜਿਸਟਰਡ ਹੈ ਜਾਂ ਨਹੀਂ।';

  @override
  String get loginSendingAnotherResetEmail =>
      'ਇੱਕ ਹੋਰ ਰੀਸੈੱਟ ਈਮੇਲ ਭੇਜੀ ਜਾ ਰਹੀ ਹੈ…';

  @override
  String get loginUseAnotherEmail => 'ਹੋਰ ਈਮੇਲ ਵਰਤੋ';

  @override
  String get loginEnterAValidEmailAddress => 'ਸਹੀ ਈਮੇਲ ਪਤਾ ਦਰਜ ਕਰੋ।';

  @override
  String get loginEnterYourPassword => 'ਆਪਣਾ ਪਾਸਵਰਡ ਦਰਜ ਕਰੋ।';

  @override
  String get loginPreparingSignIn => 'ਸਾਈਨ-ਇਨ ਤਿਆਰ ਹੋ ਰਿਹਾ ਹੈ…';

  @override
  String get loginUnableToSignInPlease =>
      'ਸਾਈਨ ਇਨ ਨਹੀਂ ਹੋ ਸਕਿਆ। ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get loginEnterAValidMobileNumber => 'ਸਹੀ ਮੋਬਾਈਲ ਨੰਬਰ ਦਰਜ ਕਰੋ।';

  @override
  String get loginTheOtpYouEnteredIs => 'ਤੁਹਾਡਾ ਦਰਜ ਕੀਤਾ OTP ਗਲਤ ਹੈ।';

  @override
  String get loginUnableToVerifyThisMobile =>
      'ਇਹ ਮੋਬਾਈਲ ਨੰਬਰ ਤਸਦੀਕ ਨਹੀਂ ਹੋ ਸਕਿਆ। ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get loginEnterAValid10Digit => 'ਸਹੀ 10 ਅੰਕਾਂ ਦਾ ਮੋਬਾਈਲ ਨੰਬਰ ਦਰਜ ਕਰੋ।';

  @override
  String get loginSendingOtp => 'OTP ਭੇਜਿਆ ਜਾ ਰਿਹਾ ਹੈ…';

  @override
  String get loginUnableToSendTheOtp =>
      'OTP ਨਹੀਂ ਭੇਜਿਆ ਜਾ ਸਕਿਆ। ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get loginRequestANewOtpFirst => 'ਪਹਿਲਾਂ ਨਵਾਂ OTP ਮੰਗਵਾਓ।';

  @override
  String get loginEnterThe6DigitOtp => '6 ਅੰਕਾਂ ਦਾ OTP ਦਰਜ ਕਰੋ।';

  @override
  String get loginVerifyingOtp => 'OTP ਤਸਦੀਕ ਹੋ ਰਿਹਾ ਹੈ…';

  @override
  String get loginUnableToVerifyTheOtp =>
      'OTP ਤਸਦੀਕ ਨਹੀਂ ਹੋ ਸਕਿਆ। ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get loginSendingANewOtp => 'ਨਵਾਂ OTP ਭੇਜਿਆ ਜਾ ਰਿਹਾ ਹੈ…';

  @override
  String get loginUnableToResendTheOtp =>
      'OTP ਦੁਬਾਰਾ ਨਹੀਂ ਭੇਜਿਆ ਜਾ ਸਕਿਆ। ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get loginPreparingGoogleSignIn => 'Google ਸਾਈਨ-ਇਨ ਤਿਆਰ ਹੋ ਰਿਹਾ ਹੈ…';

  @override
  String get loginGoogleSignInWasCanceled =>
      'Google ਸਾਈਨ-ਇਨ ਰੱਦ ਹੋਇਆ। ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get loginGoogleSignInCouldNot2 =>
      'Google ਸਾਈਨ-ਇਨ ਪੂਰਾ ਨਹੀਂ ਹੋ ਸਕਿਆ। ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get loginUnableToSignInWith =>
      'Google ਨਾਲ ਸਾਈਨ ਇਨ ਨਹੀਂ ਹੋ ਸਕਿਆ। ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get loginPreparingAppleSignIn => 'Apple ਸਾਈਨ-ਇਨ ਤਿਆਰ ਹੋ ਰਿਹਾ ਹੈ…';

  @override
  String get loginAppleSignInCouldNot2 =>
      'Apple ਸਾਈਨ-ਇਨ ਪੂਰਾ ਨਹੀਂ ਹੋ ਸਕਿਆ। ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get loginUnableToSignInWith2 =>
      'Apple ਨਾਲ ਸਾਈਨ ਇਨ ਨਹੀਂ ਹੋ ਸਕਿਆ। ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get loginEnterYourName => 'ਆਪਣਾ ਨਾਮ ਦਰਜ ਕਰੋ।';

  @override
  String get loginNameMustBe80Characters =>
      'ਨਾਮ 80 ਅੱਖਰਾਂ ਜਾਂ ਘੱਟ ਦਾ ਹੋਣਾ ਚਾਹੀਦਾ ਹੈ।';

  @override
  String get loginUseAtLeast6Characters => 'ਪਾਸਵਰਡ ਵਿੱਚ ਘੱਟੋ-ਘੱਟ 6 ਅੱਖਰ ਰੱਖੋ।';

  @override
  String get loginPasswordsDoNotMatch => 'ਪਾਸਵਰਡ ਮੇਲ ਨਹੀਂ ਖਾਂਦੇ।';

  @override
  String get loginPreparingAccountSetup => 'ਖਾਤਾ ਬਣਾਉਣ ਦੀ ਤਿਆਰੀ ਹੋ ਰਹੀ ਹੈ…';

  @override
  String get loginUnableToCreateYourAccount =>
      'ਤੁਹਾਡਾ ਖਾਤਾ ਨਹੀਂ ਬਣ ਸਕਿਆ। ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get authCreateYourExamtreeAccount => 'ਆਪਣਾ ExamTree ਖਾਤਾ ਬਣਾਓ';

  @override
  String get authSetUpYourAccountAnd => 'ਖਾਤਾ ਬਣਾਓ ਅਤੇ ਆਪਣੀ ਤਿਆਰੀ ਸਿੰਕ ਰੱਖੋ।';

  @override
  String get authSecureSignInYourProgress =>
      'ਸੁਰੱਖਿਅਤ ਸਾਈਨ-ਇਨ। ਤੁਹਾਡੀ ਪ੍ਰਗਤੀ ਸਿੰਕ ਰਹਿੰਦੀ ਹੈ।';

  @override
  String get authLoginWithMobileNumber => 'ਮੋਬਾਈਲ ਨੰਬਰ ਨਾਲ ਲੌਗਇਨ ਕਰੋ';

  @override
  String get authWeLlSendYouA => 'ਅਸੀਂ ਤੁਹਾਨੂੰ ਇੱਕ ਵਾਰ ਦਾ ਪਾਸਵਰਡ (OTP) ਭੇਜਾਂਗੇ';

  @override
  String get authEnterMobileNumber => 'ਮੋਬਾਈਲ ਨੰਬਰ ਦਰਜ ਕਰੋ';

  @override
  String get authGetOtp => 'OTP ਪ੍ਰਾਪਤ ਕਰੋ';

  @override
  String get authEnterOtp => 'OTP ਦਰਜ ਕਰੋ';

  @override
  String get authChange => 'ਬਦਲੋ';

  @override
  String get authVerifyContinue => 'ਤਸਦੀਕ ਕਰੋ ਅਤੇ ਜਾਰੀ ਰੱਖੋ';

  @override
  String get authContinueWithGoogle => 'Google ਨਾਲ ਜਾਰੀ ਰੱਖੋ';

  @override
  String get authContinueWithEmail => 'ਈਮੇਲ ਨਾਲ ਜਾਰੀ ਰੱਖੋ';

  @override
  String get authContinueWithApple => 'Apple ਨਾਲ ਜਾਰੀ ਰੱਖੋ';

  @override
  String get authSignInWithEmail => 'ਈਮੇਲ ਨਾਲ ਸਾਈਨ ਇਨ ਕਰੋ';

  @override
  String get authName => 'ਨਾਮ';

  @override
  String get authPassword => 'ਪਾਸਵਰਡ';

  @override
  String get authConfirmPassword => 'ਪਾਸਵਰਡ ਦੀ ਪੁਸ਼ਟੀ ਕਰੋ';

  @override
  String get authForgotPassword => 'ਪਾਸਵਰਡ ਭੁੱਲ ਗਏ?';
}
