import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_pa.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('pa'),
  ];

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navLearn.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get navLearn;

  /// No description provided for @navTests.
  ///
  /// In en, this message translates to:
  /// **'Tests'**
  String get navTests;

  /// No description provided for @navCurrentAffairs.
  ///
  /// In en, this message translates to:
  /// **'Current Affairs'**
  String get navCurrentAffairs;

  /// No description provided for @navResults.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get navResults;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navMenu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get navMenu;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get appLanguage;

  /// No description provided for @appLanguageHelp.
  ///
  /// In en, this message translates to:
  /// **'Used for menus, buttons and screen text. Some screens are still in English while translation is completed.'**
  String get appLanguageHelp;

  /// No description provided for @alsoUseForQuestions.
  ///
  /// In en, this message translates to:
  /// **'Show questions in this language too'**
  String get alsoUseForQuestions;

  /// No description provided for @questionLanguage.
  ///
  /// In en, this message translates to:
  /// **'Question language'**
  String get questionLanguage;

  /// No description provided for @languageSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to save the language on this device.'**
  String get languageSaveFailed;

  /// No description provided for @bookmarksTitle.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get bookmarksTitle;

  /// No description provided for @bookmarksCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 saved question · on this device} other{{count} saved questions · on this device}}'**
  String bookmarksCount(int count);

  /// No description provided for @bookmarksAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get bookmarksAll;

  /// No description provided for @bookmarksEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No saved questions yet'**
  String get bookmarksEmptyTitle;

  /// No description provided for @bookmarksEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'While reviewing a test, tap the bookmark icon on any question to save it here with its solution.'**
  String get bookmarksEmptyBody;

  /// No description provided for @bookmarkRemoved.
  ///
  /// In en, this message translates to:
  /// **'This bookmark was removed.'**
  String get bookmarkRemoved;

  /// No description provided for @savedQuestion.
  ///
  /// In en, this message translates to:
  /// **'Saved question'**
  String get savedQuestion;

  /// No description provided for @removeBookmark.
  ///
  /// In en, this message translates to:
  /// **'Remove bookmark'**
  String get removeBookmark;

  /// No description provided for @bookmarkQuestion.
  ///
  /// In en, this message translates to:
  /// **'Bookmark this question'**
  String get bookmarkQuestion;

  /// No description provided for @savedToBookmarks.
  ///
  /// In en, this message translates to:
  /// **'Saved to Bookmarks'**
  String get savedToBookmarks;

  /// No description provided for @removedFromBookmarks.
  ///
  /// In en, this message translates to:
  /// **'Removed from Bookmarks'**
  String get removedFromBookmarks;

  /// No description provided for @bookmarkSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save this question. Try again.'**
  String get bookmarkSaveFailed;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @solution.
  ///
  /// In en, this message translates to:
  /// **'Solution'**
  String get solution;

  /// No description provided for @correctAnswer.
  ///
  /// In en, this message translates to:
  /// **'Correct answer'**
  String get correctAnswer;

  /// No description provided for @yourAnswer.
  ///
  /// In en, this message translates to:
  /// **'Your answer'**
  String get yourAnswer;

  /// No description provided for @correctYourAnswer.
  ///
  /// In en, this message translates to:
  /// **'Correct · your answer'**
  String get correctYourAnswer;

  /// No description provided for @savedToday.
  ///
  /// In en, this message translates to:
  /// **'Saved today'**
  String get savedToday;

  /// No description provided for @savedYesterday.
  ///
  /// In en, this message translates to:
  /// **'Saved yesterday'**
  String get savedYesterday;

  /// No description provided for @savedDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'Saved {days} days ago'**
  String savedDaysAgo(int days);

  /// No description provided for @offlineTitle.
  ///
  /// In en, this message translates to:
  /// **'Downloads & offline'**
  String get offlineTitle;

  /// No description provided for @offlineIntro.
  ///
  /// In en, this message translates to:
  /// **'Available without internet on this phone'**
  String get offlineIntro;

  /// No description provided for @offlineSavedQuestions.
  ///
  /// In en, this message translates to:
  /// **'Saved questions'**
  String get offlineSavedQuestions;

  /// No description provided for @offlineSavedQuestionsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Bookmark questions while reviewing a test'**
  String get offlineSavedQuestionsEmpty;

  /// No description provided for @offlineSavedQuestionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 question with solutions} other{{count} questions with solutions}}'**
  String offlineSavedQuestionsCount(int count);

  /// No description provided for @offlineRevision.
  ///
  /// In en, this message translates to:
  /// **'Revision queue'**
  String get offlineRevision;

  /// No description provided for @offlineRevisionEmpty.
  ///
  /// In en, this message translates to:
  /// **'Questions you get wrong are added here for revision'**
  String get offlineRevisionEmpty;

  /// No description provided for @offlineRevisionCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 question from your past mistakes} other{{count} questions from your past mistakes}}'**
  String offlineRevisionCount(int count);

  /// No description provided for @offlineTestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tests need a connection to start and submit'**
  String get offlineTestsTitle;

  /// No description provided for @offlineTestsBody.
  ///
  /// In en, this message translates to:
  /// **'If your connection drops during a test, your answers stay saved on this phone and you can continue when you are back online. Full tests and notes cannot be downloaded yet.'**
  String get offlineTestsBody;

  /// No description provided for @profileDownloads.
  ///
  /// In en, this message translates to:
  /// **'Downloads & offline'**
  String get profileDownloads;

  /// No description provided for @profileBookmarks.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get profileBookmarks;

  /// No description provided for @profilePrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy & account'**
  String get profilePrivacy;

  /// No description provided for @profilePrivacySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Account controls and privacy settings'**
  String get profilePrivacySubtitle;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'pa'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'pa':
      return AppLocalizationsPa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
