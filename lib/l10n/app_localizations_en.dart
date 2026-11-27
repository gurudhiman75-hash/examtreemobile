// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navHome => 'Home';

  @override
  String get navLearn => 'Learn';

  @override
  String get navTests => 'Tests';

  @override
  String get navCurrentAffairs => 'Current Affairs';

  @override
  String get navResults => 'Results';

  @override
  String get navProfile => 'Profile';

  @override
  String get navMenu => 'Menu';

  @override
  String get appLanguage => 'App language';

  @override
  String get appLanguageHelp =>
      'Used for menus, buttons and screen text. Some screens are still in English while translation is completed.';

  @override
  String get alsoUseForQuestions => 'Show questions in this language too';

  @override
  String get questionLanguage => 'Question language';

  @override
  String get languageSaveFailed =>
      'Unable to save the language on this device.';

  @override
  String get bookmarksTitle => 'Bookmarks';

  @override
  String bookmarksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count saved questions · on this device',
      one: '1 saved question · on this device',
    );
    return '$_temp0';
  }

  @override
  String get bookmarksAll => 'All';

  @override
  String get bookmarksEmptyTitle => 'No saved questions yet';

  @override
  String get bookmarksEmptyBody =>
      'While reviewing a test, tap the bookmark icon on any question to save it here with its solution.';

  @override
  String get bookmarkRemoved => 'This bookmark was removed.';

  @override
  String get savedQuestion => 'Saved question';

  @override
  String get removeBookmark => 'Remove bookmark';

  @override
  String get bookmarkQuestion => 'Bookmark this question';

  @override
  String get savedToBookmarks => 'Saved to Bookmarks';

  @override
  String get removedFromBookmarks => 'Removed from Bookmarks';

  @override
  String get bookmarkSaveFailed => 'Could not save this question. Try again.';

  @override
  String get view => 'View';

  @override
  String get solution => 'Solution';

  @override
  String get correctAnswer => 'Correct answer';

  @override
  String get yourAnswer => 'Your answer';

  @override
  String get correctYourAnswer => 'Correct · your answer';

  @override
  String get savedToday => 'Saved today';

  @override
  String get savedYesterday => 'Saved yesterday';

  @override
  String savedDaysAgo(int days) {
    return 'Saved $days days ago';
  }

  @override
  String get offlineTitle => 'Downloads & offline';

  @override
  String get offlineIntro => 'Available without internet on this phone';

  @override
  String get offlineSavedQuestions => 'Saved questions';

  @override
  String get offlineSavedQuestionsEmpty =>
      'Bookmark questions while reviewing a test';

  @override
  String offlineSavedQuestionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questions with solutions',
      one: '1 question with solutions',
    );
    return '$_temp0';
  }

  @override
  String get offlineRevision => 'Revision queue';

  @override
  String get offlineRevisionEmpty =>
      'Questions you get wrong are added here for revision';

  @override
  String offlineRevisionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questions from your past mistakes',
      one: '1 question from your past mistakes',
    );
    return '$_temp0';
  }

  @override
  String get offlineTestsTitle => 'Tests need a connection to start and submit';

  @override
  String get offlineTestsBody =>
      'If your connection drops during a test, your answers stay saved on this phone and you can continue when you are back online. Full tests and notes cannot be downloaded yet.';

  @override
  String get profileDownloads => 'Downloads & offline';

  @override
  String get profileBookmarks => 'Bookmarks';

  @override
  String get profilePrivacy => 'Privacy & account';

  @override
  String get profilePrivacySubtitle => 'Account controls and privacy settings';

  @override
  String get retry => 'Retry';
}
