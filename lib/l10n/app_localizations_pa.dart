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
}
