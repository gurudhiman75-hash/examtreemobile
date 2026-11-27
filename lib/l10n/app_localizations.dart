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

  /// No description provided for @attemptNoQuestions.
  ///
  /// In en, this message translates to:
  /// **'No questions available'**
  String get attemptNoQuestions;

  /// No description provided for @attemptSignInRequired.
  ///
  /// In en, this message translates to:
  /// **'Sign in required. Redirecting...'**
  String get attemptSignInRequired;

  /// No description provided for @attemptPurchaseRequired.
  ///
  /// In en, this message translates to:
  /// **'Purchase required to access this test.'**
  String get attemptPurchaseRequired;

  /// No description provided for @attemptLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to load test: {error}'**
  String attemptLoadFailed(String error);

  /// No description provided for @attemptRecoveredLocal.
  ///
  /// In en, this message translates to:
  /// **'Unsynced progress was recovered from this device. Syncing it to ExamTree now.'**
  String get attemptRecoveredLocal;

  /// No description provided for @attemptRestoredServer.
  ///
  /// In en, this message translates to:
  /// **'Saved progress restored from ExamTree.'**
  String get attemptRestoredServer;

  /// No description provided for @attemptTenMinutes.
  ///
  /// In en, this message translates to:
  /// **'10 minutes remaining'**
  String get attemptTenMinutes;

  /// No description provided for @attemptFiveMinutes.
  ///
  /// In en, this message translates to:
  /// **'5 minutes remaining'**
  String get attemptFiveMinutes;

  /// No description provided for @attemptOneMinute.
  ///
  /// In en, this message translates to:
  /// **'1 minute remaining. Finish your review now.'**
  String get attemptOneMinute;

  /// No description provided for @attemptSecondsRemaining.
  ///
  /// In en, this message translates to:
  /// **'{seconds} seconds remaining'**
  String attemptSecondsRemaining(int seconds);

  /// No description provided for @attemptTimeOverSubmitting.
  ///
  /// In en, this message translates to:
  /// **'Time is over. Your test is being submitted.'**
  String get attemptTimeOverSubmitting;

  /// No description provided for @attemptChangedElsewhere.
  ///
  /// In en, this message translates to:
  /// **'This test changed on another device. The latest server progress was loaded.'**
  String get attemptChangedElsewhere;

  /// No description provided for @attemptSavedNotSynced.
  ///
  /// In en, this message translates to:
  /// **'Progress is saved on this device but has not reached ExamTree yet.'**
  String get attemptSavedNotSynced;

  /// No description provided for @attemptTimeOverRetry.
  ///
  /// In en, this message translates to:
  /// **'Time is over. Your answers are safe on this device; reconnect and retry submission.'**
  String get attemptTimeOverRetry;

  /// No description provided for @attemptSubmitFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to submit right now. Your answers remain saved; try again.'**
  String get attemptSubmitFailed;

  /// No description provided for @attemptStillOpen.
  ///
  /// In en, this message translates to:
  /// **'The test remains open because the latest progress could not be saved.'**
  String get attemptStillOpen;

  /// No description provided for @attemptPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing your secure test session...'**
  String get attemptPreparing;

  /// No description provided for @attemptUnableToStart.
  ///
  /// In en, this message translates to:
  /// **'Unable to start test'**
  String get attemptUnableToStart;

  /// No description provided for @attemptSessionNotCreated.
  ///
  /// In en, this message translates to:
  /// **'The attempt session could not be created.'**
  String get attemptSessionNotCreated;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @attemptTimeExpiredSubmitting.
  ///
  /// In en, this message translates to:
  /// **'Time expired — submitting your test'**
  String get attemptTimeExpiredSubmitting;

  /// No description provided for @attemptSubmittingTest.
  ///
  /// In en, this message translates to:
  /// **'Submitting your test'**
  String get attemptSubmittingTest;

  /// No description provided for @attemptLockedPending.
  ///
  /// In en, this message translates to:
  /// **'Time expired. Answers are locked and submission is pending.'**
  String get attemptLockedPending;

  /// No description provided for @attemptRetrySubmit.
  ///
  /// In en, this message translates to:
  /// **'Retry submit'**
  String get attemptRetrySubmit;

  /// No description provided for @attemptSaveAnswer.
  ///
  /// In en, this message translates to:
  /// **'Save answer'**
  String get attemptSaveAnswer;

  /// No description provided for @attemptSaveNext.
  ///
  /// In en, this message translates to:
  /// **'Save & next'**
  String get attemptSaveNext;

  /// No description provided for @attemptPaletteLeft.
  ///
  /// In en, this message translates to:
  /// **'Palette · {count} left'**
  String attemptPaletteLeft(int count);

  /// No description provided for @attemptSubmitting.
  ///
  /// In en, this message translates to:
  /// **'Submitting…'**
  String get attemptSubmitting;

  /// No description provided for @attemptSubmitTest.
  ///
  /// In en, this message translates to:
  /// **'Submit test'**
  String get attemptSubmitTest;

  /// No description provided for @attemptQuestionOf.
  ///
  /// In en, this message translates to:
  /// **'Question {number} of {total}'**
  String attemptQuestionOf(int number, int total);

  /// No description provided for @attemptNotSavedRetry.
  ///
  /// In en, this message translates to:
  /// **'Progress not saved. Retry.'**
  String get attemptNotSavedRetry;

  /// No description provided for @attemptSavingProgress.
  ///
  /// In en, this message translates to:
  /// **'Saving progress'**
  String get attemptSavingProgress;

  /// No description provided for @attemptSaveExit.
  ///
  /// In en, this message translates to:
  /// **'Save and exit'**
  String get attemptSaveExit;

  /// No description provided for @attemptQuestionNumber.
  ///
  /// In en, this message translates to:
  /// **'Question {number}'**
  String attemptQuestionNumber(int number);

  /// No description provided for @attemptMarkedForReview.
  ///
  /// In en, this message translates to:
  /// **'Marked for review'**
  String get attemptMarkedForReview;

  /// No description provided for @attemptOptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Option {letter}: {text}'**
  String attemptOptionLabel(String letter, String text);

  /// No description provided for @attemptPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get attemptPrevious;

  /// No description provided for @attemptClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get attemptClear;

  /// No description provided for @attemptReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get attemptReview;

  /// No description provided for @attemptSubmitQuestion.
  ///
  /// In en, this message translates to:
  /// **'Submit test?'**
  String get attemptSubmitQuestion;

  /// No description provided for @attemptUnansweredLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 unanswered question is still left. You can review it before submitting.} other{{count} unanswered questions are still left. You can review them before submitting.}}'**
  String attemptUnansweredLeft(int count);

  /// No description provided for @attemptCannotChange.
  ///
  /// In en, this message translates to:
  /// **'After submission, answers cannot be changed.'**
  String get attemptCannotChange;

  /// No description provided for @attemptReviewUnanswered.
  ///
  /// In en, this message translates to:
  /// **'Review unanswered'**
  String get attemptReviewUnanswered;

  /// No description provided for @attemptSubmitNow.
  ///
  /// In en, this message translates to:
  /// **'Submit now'**
  String get attemptSubmitNow;

  /// No description provided for @attemptContinueTest.
  ///
  /// In en, this message translates to:
  /// **'Continue test'**
  String get attemptContinueTest;

  /// No description provided for @attemptAnswered.
  ///
  /// In en, this message translates to:
  /// **'Answered'**
  String get attemptAnswered;

  /// No description provided for @attemptUnanswered.
  ///
  /// In en, this message translates to:
  /// **'Unanswered'**
  String get attemptUnanswered;

  /// No description provided for @attemptAnsweredMarked.
  ///
  /// In en, this message translates to:
  /// **'Answered + marked'**
  String get attemptAnsweredMarked;

  /// No description provided for @attemptSyncNeededTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress still needs to sync'**
  String get attemptSyncNeededTitle;

  /// No description provided for @attemptSyncNeededBody.
  ///
  /// In en, this message translates to:
  /// **'Your latest answers are safe on this device, but they have not reached ExamTree yet. Retry saving before leaving.'**
  String get attemptSyncNeededBody;

  /// No description provided for @attemptSavingTitle.
  ///
  /// In en, this message translates to:
  /// **'Saving your progress'**
  String get attemptSavingTitle;

  /// No description provided for @attemptSavingBody.
  ///
  /// In en, this message translates to:
  /// **'ExamTree is still saving your latest changes. Keep the test open until this save finishes.'**
  String get attemptSavingBody;

  /// No description provided for @attemptLeaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Save and leave test?'**
  String get attemptLeaveTitle;

  /// No description provided for @attemptLeaveBody.
  ///
  /// In en, this message translates to:
  /// **'Your attempt will stay active and can be resumed later from this device or the ExamTree website.'**
  String get attemptLeaveBody;

  /// No description provided for @attemptRetrySave.
  ///
  /// In en, this message translates to:
  /// **'Retry save'**
  String get attemptRetrySave;

  /// No description provided for @attemptSaveLeave.
  ///
  /// In en, this message translates to:
  /// **'Save and leave'**
  String get attemptSaveLeave;

  /// No description provided for @attemptStay.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get attemptStay;

  /// No description provided for @attemptSavingEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Saving progress…'**
  String get attemptSavingEllipsis;

  /// No description provided for @attemptWaitingSync.
  ///
  /// In en, this message translates to:
  /// **'Saved on this device. Waiting to sync with ExamTree.'**
  String get attemptWaitingSync;

  /// No description provided for @attemptNotSyncedYet.
  ///
  /// In en, this message translates to:
  /// **'Latest changes are safe on this device but not synced yet.'**
  String get attemptNotSyncedYet;

  /// No description provided for @paletteTitle.
  ///
  /// In en, this message translates to:
  /// **'Question palette'**
  String get paletteTitle;

  /// No description provided for @paletteClose.
  ///
  /// In en, this message translates to:
  /// **'Close palette'**
  String get paletteClose;

  /// No description provided for @paletteMarked.
  ///
  /// In en, this message translates to:
  /// **'Marked'**
  String get paletteMarked;

  /// No description provided for @paletteUnansweredCount.
  ///
  /// In en, this message translates to:
  /// **'Unanswered {count}'**
  String paletteUnansweredCount(int count);

  /// No description provided for @paletteMarkedCount.
  ///
  /// In en, this message translates to:
  /// **'Marked {count}'**
  String paletteMarkedCount(int count);

  /// No description provided for @paletteHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a number to jump directly to that question.'**
  String get paletteHint;

  /// No description provided for @paletteNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No questions match this filter.'**
  String get paletteNoMatch;

  /// No description provided for @paletteShowAll.
  ///
  /// In en, this message translates to:
  /// **'Show all questions'**
  String get paletteShowAll;

  /// No description provided for @resultTitle.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get resultTitle;

  /// No description provided for @resultLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to load this result'**
  String get resultLoadFailed;

  /// No description provided for @resultTestResult.
  ///
  /// In en, this message translates to:
  /// **'Test result'**
  String get resultTestResult;

  /// No description provided for @resultQuestionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} questions'**
  String resultQuestionsCount(int count);

  /// No description provided for @resultMarks.
  ///
  /// In en, this message translates to:
  /// **'{marks} marks'**
  String resultMarks(String marks);

  /// No description provided for @resultRank.
  ///
  /// In en, this message translates to:
  /// **'Rank'**
  String get resultRank;

  /// No description provided for @resultAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get resultAccuracy;

  /// No description provided for @resultXofY.
  ///
  /// In en, this message translates to:
  /// **'{x} of {y}'**
  String resultXofY(int x, int y);

  /// No description provided for @resultTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get resultTime;

  /// No description provided for @resultSpent.
  ///
  /// In en, this message translates to:
  /// **'spent'**
  String get resultSpent;

  /// No description provided for @resultAttempted.
  ///
  /// In en, this message translates to:
  /// **'Attempted'**
  String get resultAttempted;

  /// No description provided for @resultOfTotal.
  ///
  /// In en, this message translates to:
  /// **'of {total}'**
  String resultOfTotal(int total);

  /// No description provided for @resultScoreA11y.
  ///
  /// In en, this message translates to:
  /// **'Score {score} out of {max}.'**
  String resultScoreA11y(String score, String max);

  /// No description provided for @resultDelta.
  ///
  /// In en, this message translates to:
  /// **'{delta} pts vs your last attempt'**
  String resultDelta(String delta);

  /// No description provided for @resultLastAttempts.
  ///
  /// In en, this message translates to:
  /// **'Your last {count} attempts'**
  String resultLastAttempts(int count);

  /// No description provided for @resultTrendSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Score as a percentage of the maximum.'**
  String get resultTrendSubtitle;

  /// No description provided for @resultCorrect.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get resultCorrect;

  /// No description provided for @resultWrong.
  ///
  /// In en, this message translates to:
  /// **'Wrong'**
  String get resultWrong;

  /// No description provided for @resultSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get resultSkipped;

  /// No description provided for @resultHowWent.
  ///
  /// In en, this message translates to:
  /// **'How your {total} questions went'**
  String resultHowWent(int total);

  /// No description provided for @resultQuickestWin.
  ///
  /// In en, this message translates to:
  /// **'Quickest win: {section}. '**
  String resultQuickestWin(String section);

  /// No description provided for @resultSkippedMost.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{You skipped 1 question there, more than in any other section.} other{You skipped {count} questions there, more than in any other section.}}'**
  String resultSkippedMost(int count);

  /// No description provided for @resultAccuracyValue.
  ///
  /// In en, this message translates to:
  /// **'Accuracy {value}'**
  String resultAccuracyValue(String value);

  /// No description provided for @resultTimeShare.
  ///
  /// In en, this message translates to:
  /// **'{section} took {share}% of your time.'**
  String resultTimeShare(String section, int share);

  /// No description provided for @resultTimeShareAccuracy.
  ///
  /// In en, this message translates to:
  /// **'{section} took {share}% of your time at {accuracy}% accuracy.'**
  String resultTimeShareAccuracy(String section, int share, int accuracy);

  /// No description provided for @resultLowestAccuracy.
  ///
  /// In en, this message translates to:
  /// **'{section} had your lowest accuracy, {accuracy}%.'**
  String resultLowestAccuracy(String section, int accuracy);

  /// No description provided for @resultLowestAccuracyShare.
  ///
  /// In en, this message translates to:
  /// **'{section} had your lowest accuracy, {accuracy}%, on {share}% of your time.'**
  String resultLowestAccuracyShare(String section, int accuracy, int share);

  /// No description provided for @resultAccuracyVsTime.
  ///
  /// In en, this message translates to:
  /// **'Accuracy vs time spent'**
  String get resultAccuracyVsTime;

  /// No description provided for @resultAccuracyVsTimeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Is your time going where your marks are?'**
  String get resultAccuracyVsTimeSubtitle;

  /// No description provided for @resultShareOfTime.
  ///
  /// In en, this message translates to:
  /// **'Share of your time'**
  String get resultShareOfTime;

  /// No description provided for @resultTimePerQuestion.
  ///
  /// In en, this message translates to:
  /// **'Time per question'**
  String get resultTimePerQuestion;

  /// No description provided for @resultTimePerQuestionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'One bar per question, in the order of the paper.'**
  String get resultTimePerQuestionSubtitle;

  /// No description provided for @resultSlowest.
  ///
  /// In en, this message translates to:
  /// **'Slowest question: {section} Q{number} at {time}.'**
  String resultSlowest(String section, int number, String time);

  /// No description provided for @resultQuestionMap.
  ///
  /// In en, this message translates to:
  /// **'Question map'**
  String get resultQuestionMap;

  /// No description provided for @resultReviewSolutions.
  ///
  /// In en, this message translates to:
  /// **'Review solutions'**
  String get resultReviewSolutions;

  /// No description provided for @resultReviseMistakes.
  ///
  /// In en, this message translates to:
  /// **'Revise mistakes (5 min)'**
  String get resultReviseMistakes;

  /// No description provided for @resultRetake.
  ///
  /// In en, this message translates to:
  /// **'Retake test'**
  String get resultRetake;
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
