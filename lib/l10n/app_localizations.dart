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

  /// No description provided for @resultsHistoryLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to load your attempt history'**
  String get resultsHistoryLoadFailed;

  /// No description provided for @resultsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search tests or exam categories'**
  String get resultsSearchHint;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @resultsAttemptHistory.
  ///
  /// In en, this message translates to:
  /// **'Attempt history'**
  String get resultsAttemptHistory;

  /// No description provided for @resultsAverageScore.
  ///
  /// In en, this message translates to:
  /// **'Average score'**
  String get resultsAverageScore;

  /// No description provided for @resultsAttemptsCompleted.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 attempt completed} other{{count} attempts completed}}'**
  String resultsAttemptsCompleted(int count);

  /// No description provided for @resultsBestScore.
  ///
  /// In en, this message translates to:
  /// **'Best score'**
  String get resultsBestScore;

  /// No description provided for @resultsFindAttempt.
  ///
  /// In en, this message translates to:
  /// **'Find an attempt'**
  String get resultsFindAttempt;

  /// No description provided for @resultsFindHint.
  ///
  /// In en, this message translates to:
  /// **'Review mistakes before deciding what to retake.'**
  String get resultsFindHint;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @resultsAllExams.
  ///
  /// In en, this message translates to:
  /// **'All exams'**
  String get resultsAllExams;

  /// No description provided for @resultsSort.
  ///
  /// In en, this message translates to:
  /// **'Sort results'**
  String get resultsSort;

  /// No description provided for @resultsSortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get resultsSortNewest;

  /// No description provided for @resultsSortHighestScore.
  ///
  /// In en, this message translates to:
  /// **'Highest score'**
  String get resultsSortHighestScore;

  /// No description provided for @resultsSortHighestAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Highest accuracy'**
  String get resultsSortHighestAccuracy;

  /// No description provided for @resultsReviewMistakes.
  ///
  /// In en, this message translates to:
  /// **'Review mistakes'**
  String get resultsReviewMistakes;

  /// No description provided for @resultsReviewAnswers.
  ///
  /// In en, this message translates to:
  /// **'Review answers'**
  String get resultsReviewAnswers;

  /// No description provided for @resultsRetake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get resultsRetake;

  /// No description provided for @resultsAccuracyPct.
  ///
  /// In en, this message translates to:
  /// **'{value}% accuracy'**
  String resultsAccuracyPct(String value);

  /// No description provided for @resultsCorrectCount.
  ///
  /// In en, this message translates to:
  /// **'{count} correct'**
  String resultsCorrectCount(int count);

  /// No description provided for @resultsIncorrectCount.
  ///
  /// In en, this message translates to:
  /// **'{count} incorrect'**
  String resultsIncorrectCount(int count);

  /// No description provided for @resultsSkippedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} skipped'**
  String resultsSkippedCount(int count);

  /// No description provided for @resultsScorePercentA11y.
  ///
  /// In en, this message translates to:
  /// **'Score {value} percent'**
  String resultsScorePercentA11y(String value);

  /// No description provided for @resultsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No completed attempts yet'**
  String get resultsEmptyTitle;

  /// No description provided for @resultsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Complete your first test to unlock score history, accuracy and answer review.'**
  String get resultsEmptyBody;

  /// No description provided for @resultsExploreTests.
  ///
  /// In en, this message translates to:
  /// **'Explore tests'**
  String get resultsExploreTests;

  /// No description provided for @resultsNoMatchTitle.
  ///
  /// In en, this message translates to:
  /// **'No attempts match these filters'**
  String get resultsNoMatchTitle;

  /// No description provided for @resultsNoMatchBody.
  ///
  /// In en, this message translates to:
  /// **'Try another test name, category or sort order.'**
  String get resultsNoMatchBody;

  /// No description provided for @resultsResetFilters.
  ///
  /// In en, this message translates to:
  /// **'Reset filters'**
  String get resultsResetFilters;

  /// No description provided for @dateUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Date unavailable'**
  String get dateUnavailable;

  /// No description provided for @examsCategoriesLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to load exam categories'**
  String get examsCategoriesLoadFailed;

  /// No description provided for @examsTitle.
  ///
  /// In en, this message translates to:
  /// **'Exams'**
  String get examsTitle;

  /// No description provided for @examsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to load exams'**
  String get examsLoadFailed;

  /// No description provided for @examsSearchIn.
  ///
  /// In en, this message translates to:
  /// **'Search {category} exams'**
  String examsSearchIn(String category);

  /// No description provided for @examsCategoryExams.
  ///
  /// In en, this message translates to:
  /// **'{category} Exams'**
  String examsCategoryExams(String category);

  /// No description provided for @examsAvailable.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 exam available} other{{count} exams available}}'**
  String examsAvailable(int count);

  /// No description provided for @examsTestSeries.
  ///
  /// In en, this message translates to:
  /// **'Test Series'**
  String get examsTestSeries;

  /// No description provided for @examsSeriesLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to load test series'**
  String get examsSeriesLoadFailed;

  /// No description provided for @examsAvailableSeries.
  ///
  /// In en, this message translates to:
  /// **'Available Test Series'**
  String get examsAvailableSeries;

  /// No description provided for @examsNoActiveSeries.
  ///
  /// In en, this message translates to:
  /// **'No active test series yet'**
  String get examsNoActiveSeries;

  /// No description provided for @examsSeriesAvailable.
  ///
  /// In en, this message translates to:
  /// **'{count} series available'**
  String examsSeriesAvailable(int count);

  /// No description provided for @examsSearchCategories.
  ///
  /// In en, this message translates to:
  /// **'Search exam categories'**
  String get examsSearchCategories;

  /// No description provided for @examsCategories.
  ///
  /// In en, this message translates to:
  /// **'Exam Categories'**
  String get examsCategories;

  /// No description provided for @examsChooseCategory.
  ///
  /// In en, this message translates to:
  /// **'Choose a category to find the exam you are preparing for.'**
  String get examsChooseCategory;

  /// No description provided for @examsChoosePath.
  ///
  /// In en, this message translates to:
  /// **'Choose your exam path'**
  String get examsChoosePath;

  /// No description provided for @examsChoosePathBody.
  ///
  /// In en, this message translates to:
  /// **'Open a category, choose your exam and continue to its test series.'**
  String get examsChoosePathBody;

  /// No description provided for @examsCategoriesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} categories'**
  String examsCategoriesCount(int count);

  /// No description provided for @examsExamsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 exam} other{{count} exams}}'**
  String examsExamsCount(int count);

  /// No description provided for @examsSeriesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} series'**
  String examsSeriesCount(int count);

  /// No description provided for @examsLiveTests.
  ///
  /// In en, this message translates to:
  /// **'{count} live tests'**
  String examsLiveTests(int count);

  /// No description provided for @examsTestsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} tests'**
  String examsTestsCount(int count);

  /// No description provided for @examsTestSeriesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} test series'**
  String examsTestSeriesCount(int count);

  /// No description provided for @examsFullMocks.
  ///
  /// In en, this message translates to:
  /// **'{count} full mocks'**
  String examsFullMocks(int count);

  /// No description provided for @examsMinPerTest.
  ///
  /// In en, this message translates to:
  /// **'~{minutes} min/test'**
  String examsMinPerTest(int minutes);

  /// No description provided for @examsViewTestSeries.
  ///
  /// In en, this message translates to:
  /// **'View Test Series'**
  String get examsViewTestSeries;

  /// No description provided for @examsNoQuestionsYet.
  ///
  /// In en, this message translates to:
  /// **'No questions yet'**
  String get examsNoQuestionsYet;

  /// No description provided for @examsViewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get examsViewDetails;

  /// No description provided for @examsViewSeries.
  ///
  /// In en, this message translates to:
  /// **'View Series'**
  String get examsViewSeries;

  /// No description provided for @examsEmptyCatalogueTitle.
  ///
  /// In en, this message translates to:
  /// **'No exam categories are published yet.'**
  String get examsEmptyCatalogueTitle;

  /// No description provided for @examsEmptyCatalogueBody.
  ///
  /// In en, this message translates to:
  /// **'Pull down to check again.'**
  String get examsEmptyCatalogueBody;

  /// No description provided for @examsNoCategoryMatchTitle.
  ///
  /// In en, this message translates to:
  /// **'No exam category matches your search.'**
  String get examsNoCategoryMatchTitle;

  /// No description provided for @examsNoCategoryMatchBody.
  ///
  /// In en, this message translates to:
  /// **'Try another exam family or clear the search.'**
  String get examsNoCategoryMatchBody;

  /// No description provided for @examsNoExamMatchTitle.
  ///
  /// In en, this message translates to:
  /// **'No exams match this search.'**
  String get examsNoExamMatchTitle;

  /// No description provided for @examsNoExamMatchBody.
  ///
  /// In en, this message translates to:
  /// **'Try a shorter exam name or clear the search.'**
  String get examsNoExamMatchBody;

  /// No description provided for @examsCategoryUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Exam category unavailable'**
  String get examsCategoryUnavailableTitle;

  /// No description provided for @examsCategoryUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'Open the category again from the Exams page.'**
  String get examsCategoryUnavailableBody;

  /// No description provided for @examsExamUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Exam unavailable'**
  String get examsExamUnavailableTitle;

  /// No description provided for @examsExamUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'Open the exam again from its category.'**
  String get examsExamUnavailableBody;

  /// No description provided for @examsNoneInCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'No {category} exams are published yet.'**
  String examsNoneInCategoryTitle(String category);

  /// No description provided for @examsNoneInCategoryBody.
  ///
  /// In en, this message translates to:
  /// **'New exams will appear here automatically when published.'**
  String get examsNoneInCategoryBody;

  /// No description provided for @examsNoSeriesTitle.
  ///
  /// In en, this message translates to:
  /// **'No test series available yet'**
  String get examsNoSeriesTitle;

  /// No description provided for @examsNoSeriesBody.
  ///
  /// In en, this message translates to:
  /// **'Published test series for this exam will appear here automatically.'**
  String get examsNoSeriesBody;

  /// No description provided for @learnCurrentAffairs.
  ///
  /// In en, this message translates to:
  /// **'Current affairs'**
  String get learnCurrentAffairs;

  /// No description provided for @learnCurrentAffairsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fresh published updates for quick revision.'**
  String get learnCurrentAffairsSubtitle;

  /// No description provided for @learnFreePractice.
  ///
  /// In en, this message translates to:
  /// **'Free practice'**
  String get learnFreePractice;

  /// No description provided for @learnFreePracticeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Turn reading into an immediate test session.'**
  String get learnFreePracticeSubtitle;

  /// No description provided for @learnAllTests.
  ///
  /// In en, this message translates to:
  /// **'All tests'**
  String get learnAllTests;

  /// No description provided for @learnNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes & formula sheets'**
  String get learnNotes;

  /// No description provided for @learnNotesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Focused material published for your exams.'**
  String get learnNotesSubtitle;

  /// No description provided for @learnHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Learn for your exams'**
  String get learnHeroTitle;

  /// No description provided for @learnHeroBody.
  ///
  /// In en, this message translates to:
  /// **'Current affairs, notes and free practice selected from what is actually published for you.'**
  String get learnHeroBody;

  /// No description provided for @learnArticle.
  ///
  /// In en, this message translates to:
  /// **'Article'**
  String get learnArticle;

  /// No description provided for @learnMinFree.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min · Free'**
  String learnMinFree(int minutes);

  /// No description provided for @learnLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to load free learning'**
  String get learnLoadFailed;

  /// No description provided for @learnEmpty.
  ///
  /// In en, this message translates to:
  /// **'No free learning resources are published yet. Published material will appear here automatically.'**
  String get learnEmpty;

  /// No description provided for @learnPartialRefresh.
  ///
  /// In en, this message translates to:
  /// **'Some learning content could not be refreshed. The items shown above are still available.'**
  String get learnPartialRefresh;

  /// No description provided for @learnOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'This resource could not be opened.'**
  String get learnOpenFailed;

  /// No description provided for @learnSelectedExams.
  ///
  /// In en, this message translates to:
  /// **'Selected exams'**
  String get learnSelectedExams;

  /// No description provided for @homeExamCategories.
  ///
  /// In en, this message translates to:
  /// **'Exam Categories'**
  String get homeExamCategories;

  /// No description provided for @homeSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get homeSeeAll;

  /// No description provided for @homeCategoriesFailed.
  ///
  /// In en, this message translates to:
  /// **'Exam categories could not be loaded'**
  String get homeCategoriesFailed;

  /// No description provided for @homeNoCategories.
  ///
  /// In en, this message translates to:
  /// **'No exam categories are published right now.'**
  String get homeNoCategories;

  /// No description provided for @homeFeaturedSeries.
  ///
  /// In en, this message translates to:
  /// **'Featured Test Series'**
  String get homeFeaturedSeries;

  /// No description provided for @homeSeriesFailed.
  ///
  /// In en, this message translates to:
  /// **'Test series could not be loaded'**
  String get homeSeriesFailed;

  /// No description provided for @homeContinueLearning.
  ///
  /// In en, this message translates to:
  /// **'Continue Learning'**
  String get homeContinueLearning;

  /// No description provided for @homeRecommendedLearning.
  ///
  /// In en, this message translates to:
  /// **'Recommended Learning'**
  String get homeRecommendedLearning;

  /// No description provided for @homeCurrentAffairs.
  ///
  /// In en, this message translates to:
  /// **'Current Affairs'**
  String get homeCurrentAffairs;

  /// No description provided for @homeProgressUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Progress is temporarily unavailable'**
  String get homeProgressUnavailable;

  /// No description provided for @familyPunjab.
  ///
  /// In en, this message translates to:
  /// **'Punjab Govt.'**
  String get familyPunjab;

  /// No description provided for @familyBanking.
  ///
  /// In en, this message translates to:
  /// **'Banking'**
  String get familyBanking;

  /// No description provided for @familyRailway.
  ///
  /// In en, this message translates to:
  /// **'Railway'**
  String get familyRailway;

  /// No description provided for @familyTeaching.
  ///
  /// In en, this message translates to:
  /// **'Teaching'**
  String get familyTeaching;

  /// No description provided for @familyDefence.
  ///
  /// In en, this message translates to:
  /// **'Defence'**
  String get familyDefence;

  /// No description provided for @familyStatePcs.
  ///
  /// In en, this message translates to:
  /// **'State PCS'**
  String get familyStatePcs;

  /// No description provided for @familyOther.
  ///
  /// In en, this message translates to:
  /// **'Other Exams'**
  String get familyOther;

  /// No description provided for @homeExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get homeExplore;

  /// No description provided for @homeTests.
  ///
  /// In en, this message translates to:
  /// **'Tests'**
  String get homeTests;

  /// No description provided for @homeMins.
  ///
  /// In en, this message translates to:
  /// **'Mins'**
  String get homeMins;

  /// No description provided for @homeMarks.
  ///
  /// In en, this message translates to:
  /// **'Marks'**
  String get homeMarks;

  /// No description provided for @homeQuestions.
  ///
  /// In en, this message translates to:
  /// **'Questions'**
  String get homeQuestions;

  /// No description provided for @homeDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get homeDuration;

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String minutesShort(int minutes);

  /// No description provided for @homeHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Preparation\nStarts Here'**
  String get homeHeroTitle;

  /// No description provided for @homeHeroBody.
  ///
  /// In en, this message translates to:
  /// **'Mock tests, learning and exam-focused practice in one place.'**
  String get homeHeroBody;

  /// No description provided for @homeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search exams, test series, topics...'**
  String get homeSearchHint;

  /// No description provided for @homeContinueUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Continue learning is temporarily unavailable'**
  String get homeContinueUnavailable;

  /// No description provided for @homeKeepGoing.
  ///
  /// In en, this message translates to:
  /// **'Keep Going!'**
  String get homeKeepGoing;

  /// No description provided for @homeTestsCompleted.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 test completed so far.} other{{count} tests completed so far.}}'**
  String homeTestsCompleted(int count);

  /// No description provided for @homeSearchTests.
  ///
  /// In en, this message translates to:
  /// **'Search tests'**
  String get homeSearchTests;

  /// No description provided for @homeOpenProfile.
  ///
  /// In en, this message translates to:
  /// **'Open profile'**
  String get homeOpenProfile;

  /// No description provided for @homeNotificationsUnreadA11y.
  ///
  /// In en, this message translates to:
  /// **'Notifications, {count} unread'**
  String homeNotificationsUnreadA11y(int count);

  /// No description provided for @homeNotificationsNoneA11y.
  ///
  /// In en, this message translates to:
  /// **'Notifications, no unread updates'**
  String get homeNotificationsNoneA11y;

  /// No description provided for @homeNotificationsUnread.
  ///
  /// In en, this message translates to:
  /// **'Notifications ({count} unread)'**
  String homeNotificationsUnread(int count);

  /// No description provided for @homeNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get homeNotifications;

  /// No description provided for @homeNextActionFailed.
  ///
  /// In en, this message translates to:
  /// **'Your next action could not be prepared'**
  String get homeNextActionFailed;

  /// No description provided for @homeLearn.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get homeLearn;

  /// No description provided for @homeRevision.
  ///
  /// In en, this message translates to:
  /// **'Revision'**
  String get homeRevision;

  /// No description provided for @homeStore.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get homeStore;

  /// No description provided for @homeStrongMomentum.
  ///
  /// In en, this message translates to:
  /// **'Strong momentum'**
  String get homeStrongMomentum;

  /// No description provided for @homeKeepConsistency.
  ///
  /// In en, this message translates to:
  /// **'Keep building consistency'**
  String get homeKeepConsistency;

  /// No description provided for @homeFocusAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Focus on accuracy first'**
  String get homeFocusAccuracy;

  /// No description provided for @homeAvgScore.
  ///
  /// In en, this message translates to:
  /// **'Avg score'**
  String get homeAvgScore;

  /// No description provided for @homePerQuestion.
  ///
  /// In en, this message translates to:
  /// **'Per question'**
  String get homePerQuestion;

  /// No description provided for @homeQs.
  ///
  /// In en, this message translates to:
  /// **'{count} Qs'**
  String homeQs(int count);

  /// No description provided for @homeNoTests.
  ///
  /// In en, this message translates to:
  /// **'No tests are published right now.'**
  String get homeNoTests;

  /// No description provided for @homeCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'You are caught up on current recommendations.'**
  String get homeCaughtUp;

  /// No description provided for @homeBrowse.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get homeBrowse;

  /// No description provided for @homeScorePct.
  ///
  /// In en, this message translates to:
  /// **'{value}% score'**
  String homeScorePct(int value);

  /// No description provided for @homeAccuracyPct.
  ///
  /// In en, this message translates to:
  /// **'{value}% accuracy'**
  String homeAccuracyPct(int value);

  /// No description provided for @homeDue.
  ///
  /// In en, this message translates to:
  /// **'{count} due'**
  String homeDue(int count);

  /// No description provided for @homeStudent.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get homeStudent;

  /// No description provided for @homeGoodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get homeGoodMorning;

  /// No description provided for @homeGoodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get homeGoodAfternoon;

  /// No description provided for @homeGoodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get homeGoodEvening;

  /// No description provided for @storeEnterCoupon.
  ///
  /// In en, this message translates to:
  /// **'Enter a coupon code first.'**
  String get storeEnterCoupon;

  /// No description provided for @storeCouponApplied.
  ///
  /// In en, this message translates to:
  /// **'Coupon applied • Save {amount}'**
  String storeCouponApplied(String amount);

  /// No description provided for @storeChoosePlan.
  ///
  /// In en, this message translates to:
  /// **'Choose Plan'**
  String get storeChoosePlan;

  /// No description provided for @storePlansFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to load plans'**
  String get storePlansFailed;

  /// No description provided for @storeAlreadyActive.
  ///
  /// In en, this message translates to:
  /// **'This test series is already active.'**
  String get storeAlreadyActive;

  /// No description provided for @storeOpenTestSeries.
  ///
  /// In en, this message translates to:
  /// **'Open Test Series'**
  String get storeOpenTestSeries;

  /// No description provided for @storeNoPlan.
  ///
  /// In en, this message translates to:
  /// **'No purchase plan is available right now.'**
  String get storeNoPlan;

  /// No description provided for @storePremiumFree.
  ///
  /// In en, this message translates to:
  /// **'{premium} premium tests • {free} free'**
  String storePremiumFree(int premium, int free);

  /// No description provided for @storeChooseAccessPlan.
  ///
  /// In en, this message translates to:
  /// **'Choose your access plan'**
  String get storeChooseAccessPlan;

  /// No description provided for @storePublishedOnly.
  ///
  /// In en, this message translates to:
  /// **'Only currently published plans are shown.'**
  String get storePublishedOnly;

  /// No description provided for @storeHaveCoupon.
  ///
  /// In en, this message translates to:
  /// **'Have a coupon?'**
  String get storeHaveCoupon;

  /// No description provided for @storeCouponHint.
  ///
  /// In en, this message translates to:
  /// **'Enter coupon code'**
  String get storeCouponHint;

  /// No description provided for @storeApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get storeApply;

  /// No description provided for @storeSelectedPlan.
  ///
  /// In en, this message translates to:
  /// **'Selected plan'**
  String get storeSelectedPlan;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @storeTestsIncluded.
  ///
  /// In en, this message translates to:
  /// **'{count} series tests included'**
  String storeTestsIncluded(int count);

  /// No description provided for @storePercentOff.
  ///
  /// In en, this message translates to:
  /// **'{percent}% OFF'**
  String storePercentOff(int percent);

  /// No description provided for @storeOpenPaymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to open secure payment.'**
  String get storeOpenPaymentFailed;

  /// No description provided for @storeIncompleteConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Payment returned incomplete confirmation details. Please verify again.'**
  String get storeIncompleteConfirmation;

  /// No description provided for @storePaymentNotCompleted.
  ///
  /// In en, this message translates to:
  /// **'Payment was not completed.'**
  String get storePaymentNotCompleted;

  /// No description provided for @storeContinueWallet.
  ///
  /// In en, this message translates to:
  /// **'Continue in your wallet to complete payment.'**
  String get storeContinueWallet;

  /// No description provided for @storeContinueInWallet.
  ///
  /// In en, this message translates to:
  /// **'Continue in {wallet} to complete payment.'**
  String storeContinueInWallet(String wallet);

  /// No description provided for @storeActivationProcessing.
  ///
  /// In en, this message translates to:
  /// **'Payment was received but activation is still processing. Tap Verify Payment.'**
  String get storeActivationProcessing;

  /// No description provided for @storeCheckout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get storeCheckout;

  /// No description provided for @storeCheckoutFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to load checkout'**
  String get storeCheckoutFailed;

  /// No description provided for @storePlanUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This plan is no longer available.'**
  String get storePlanUnavailable;

  /// No description provided for @storeReviewPay.
  ///
  /// In en, this message translates to:
  /// **'Review & Pay'**
  String get storeReviewPay;

  /// No description provided for @storeCouponRevalidate.
  ///
  /// In en, this message translates to:
  /// **'Coupon could not be revalidated. Go back and apply it again.'**
  String get storeCouponRevalidate;

  /// No description provided for @storeVerifyPayment.
  ///
  /// In en, this message translates to:
  /// **'Verify Payment'**
  String get storeVerifyPayment;

  /// No description provided for @storePayAmount.
  ///
  /// In en, this message translates to:
  /// **'Pay {amount}'**
  String storePayAmount(String amount);

  /// No description provided for @storeOrderSummary.
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get storeOrderSummary;

  /// No description provided for @storeAccess.
  ///
  /// In en, this message translates to:
  /// **'{validity} access'**
  String storeAccess(String validity);

  /// No description provided for @storePlanPrice.
  ///
  /// In en, this message translates to:
  /// **'Plan price'**
  String get storePlanPrice;

  /// No description provided for @storeCouponDiscount.
  ///
  /// In en, this message translates to:
  /// **'Coupon discount'**
  String get storeCouponDiscount;

  /// No description provided for @storeTotalPayable.
  ///
  /// In en, this message translates to:
  /// **'Total Payable'**
  String get storeTotalPayable;

  /// No description provided for @storeUpiCards.
  ///
  /// In en, this message translates to:
  /// **'UPI, Cards & More'**
  String get storeUpiCards;

  /// No description provided for @storeRazorpayBody.
  ///
  /// In en, this message translates to:
  /// **'Choose UPI, card, net banking or wallet in secure Razorpay Checkout.'**
  String get storeRazorpayBody;

  /// No description provided for @storeCouponSaved.
  ///
  /// In en, this message translates to:
  /// **'{code} applied • You save {amount}'**
  String storeCouponSaved(String code, String amount);

  /// No description provided for @storeActivating.
  ///
  /// In en, this message translates to:
  /// **'Activating your test series…'**
  String get storeActivating;

  /// No description provided for @storeKeepOpen.
  ///
  /// In en, this message translates to:
  /// **'Please keep this screen open while we verify your payment.'**
  String get storeKeepOpen;

  /// No description provided for @storeRazorpayNote.
  ///
  /// In en, this message translates to:
  /// **'Payment is processed securely by Razorpay. Examtree never stores your card or UPI credentials.'**
  String get storeRazorpayNote;

  /// No description provided for @validityAsPublished.
  ///
  /// In en, this message translates to:
  /// **'Validity as published'**
  String get validityAsPublished;

  /// No description provided for @validityMonths.
  ///
  /// In en, this message translates to:
  /// **'{count} Months'**
  String validityMonths(int count);

  /// No description provided for @validityDays.
  ///
  /// In en, this message translates to:
  /// **'{count} Days'**
  String validityDays(int count);

  /// No description provided for @paySuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Successful!'**
  String get paySuccessTitle;

  /// No description provided for @paySuccessBody.
  ///
  /// In en, this message translates to:
  /// **'Your test series has been unlocked and is ready for your preparation.'**
  String get paySuccessBody;

  /// No description provided for @payAccessActive.
  ///
  /// In en, this message translates to:
  /// **'Access Active'**
  String get payAccessActive;

  /// No description provided for @payActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get payActive;

  /// No description provided for @payMockTests.
  ///
  /// In en, this message translates to:
  /// **'Mock Tests'**
  String get payMockTests;

  /// No description provided for @payMockTestsBody.
  ///
  /// In en, this message translates to:
  /// **'Full access to your purchased series'**
  String get payMockTestsBody;

  /// No description provided for @payAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Detailed Analysis'**
  String get payAnalysis;

  /// No description provided for @payAnalysisBody.
  ///
  /// In en, this message translates to:
  /// **'Track attempts, accuracy and progress'**
  String get payAnalysisBody;

  /// No description provided for @payBilingual.
  ///
  /// In en, this message translates to:
  /// **'Bilingual Content'**
  String get payBilingual;

  /// No description provided for @payBilingualBody.
  ///
  /// In en, this message translates to:
  /// **'Use supported languages throughout the series'**
  String get payBilingualBody;

  /// No description provided for @paySolutions.
  ///
  /// In en, this message translates to:
  /// **'Detailed Solutions'**
  String get paySolutions;

  /// No description provided for @paySolutionsBody.
  ///
  /// In en, this message translates to:
  /// **'Review explanations after every attempt'**
  String get paySolutionsBody;

  /// No description provided for @paySafe.
  ///
  /// In en, this message translates to:
  /// **'Your Progress is Safe'**
  String get paySafe;

  /// No description provided for @paySafeBody.
  ///
  /// In en, this message translates to:
  /// **'Attempts, analytics and bookmarks are preserved with your access.'**
  String get paySafeBody;

  /// No description provided for @payStart.
  ///
  /// In en, this message translates to:
  /// **'Start Learning Now'**
  String get payStart;

  /// No description provided for @payStartBody.
  ///
  /// In en, this message translates to:
  /// **'Continue from where you left off and keep your preparation on track.'**
  String get payStartBody;

  /// No description provided for @payOrder.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get payOrder;

  /// No description provided for @payViewReceipt.
  ///
  /// In en, this message translates to:
  /// **'View Receipt'**
  String get payViewReceipt;

  /// No description provided for @readyTitle.
  ///
  /// In en, this message translates to:
  /// **'You’re All Set!'**
  String get readyTitle;

  /// No description provided for @readyBody.
  ///
  /// In en, this message translates to:
  /// **'Your ExamTree test series is active and ready to use.'**
  String get readyBody;

  /// No description provided for @readyOpen.
  ///
  /// In en, this message translates to:
  /// **'Open your Test Series'**
  String get readyOpen;

  /// No description provided for @readyOpenBody.
  ///
  /// In en, this message translates to:
  /// **'Your purchased series now appears in My Test Series.'**
  String get readyOpenBody;

  /// No description provided for @readyChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose a test'**
  String get readyChoose;

  /// No description provided for @readyChooseBody.
  ///
  /// In en, this message translates to:
  /// **'Start with a full mock, sectional, PYQ or topic-wise test.'**
  String get readyChooseBody;

  /// No description provided for @readyTrack.
  ///
  /// In en, this message translates to:
  /// **'Track your performance'**
  String get readyTrack;

  /// No description provided for @readyTrackBody.
  ///
  /// In en, this message translates to:
  /// **'Review scores, accuracy, attempts and progress from your Profile.'**
  String get readyTrackBody;

  /// No description provided for @readyGoMySeries.
  ///
  /// In en, this message translates to:
  /// **'Go to My Test Series'**
  String get readyGoMySeries;

  /// No description provided for @readyViewOrder.
  ///
  /// In en, this message translates to:
  /// **'View Order Details'**
  String get readyViewOrder;

  /// No description provided for @seriesLockedTitle.
  ///
  /// In en, this message translates to:
  /// **'This Test is Locked'**
  String get seriesLockedTitle;

  /// No description provided for @seriesFreeAvailable.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 free test is available in this series.} other{{count} free tests are available in this series.}}'**
  String seriesFreeAvailable(int count);

  /// No description provided for @seriesTryFree.
  ///
  /// In en, this message translates to:
  /// **'Try Free Test'**
  String get seriesTryFree;

  /// No description provided for @seriesViewPlansUnlock.
  ///
  /// In en, this message translates to:
  /// **'View Plans & Unlock'**
  String get seriesViewPlansUnlock;

  /// No description provided for @seriesMaybeLater.
  ///
  /// In en, this message translates to:
  /// **'Maybe Later'**
  String get seriesMaybeLater;

  /// No description provided for @seriesStructuredPractice.
  ///
  /// In en, this message translates to:
  /// **'Structured mock-test practice for {exam}.'**
  String seriesStructuredPractice(String exam);

  /// No description provided for @seriesComingSoon.
  ///
  /// In en, this message translates to:
  /// **'COMING SOON'**
  String get seriesComingSoon;

  /// No description provided for @seriesActive.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get seriesActive;

  /// No description provided for @seriesUnavailable.
  ///
  /// In en, this message translates to:
  /// **'UNAVAILABLE'**
  String get seriesUnavailable;

  /// No description provided for @seriesInPreparation.
  ///
  /// In en, this message translates to:
  /// **'Content in preparation'**
  String get seriesInPreparation;

  /// No description provided for @seriesPercentComplete.
  ///
  /// In en, this message translates to:
  /// **'{percent}% complete'**
  String seriesPercentComplete(int percent);

  /// No description provided for @seriesTestsFraction.
  ///
  /// In en, this message translates to:
  /// **'{done}/{total} tests'**
  String seriesTestsFraction(int done, int total);

  /// No description provided for @seriesPracticeTime.
  ///
  /// In en, this message translates to:
  /// **'Practice time'**
  String get seriesPracticeTime;

  /// No description provided for @seriesProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get seriesProgress;

  /// No description provided for @seriesTabOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get seriesTabOverview;

  /// No description provided for @seriesTabTestList.
  ///
  /// In en, this message translates to:
  /// **'Test List'**
  String get seriesTabTestList;

  /// No description provided for @seriesTabSyllabus.
  ///
  /// In en, this message translates to:
  /// **'Syllabus'**
  String get seriesTabSyllabus;

  /// No description provided for @seriesTabPattern.
  ///
  /// In en, this message translates to:
  /// **'Exam Pattern'**
  String get seriesTabPattern;

  /// No description provided for @seriesTabReviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get seriesTabReviews;

  /// No description provided for @seriesTabFaqs.
  ///
  /// In en, this message translates to:
  /// **'FAQs'**
  String get seriesTabFaqs;

  /// No description provided for @seriesSequential.
  ///
  /// In en, this message translates to:
  /// **'Sequential progression'**
  String get seriesSequential;

  /// No description provided for @seriesScoreGated.
  ///
  /// In en, this message translates to:
  /// **'Score-gated progression'**
  String get seriesScoreGated;

  /// No description provided for @seriesOpenProgression.
  ///
  /// In en, this message translates to:
  /// **'Open progression'**
  String get seriesOpenProgression;

  /// No description provided for @seriesAbout.
  ///
  /// In en, this message translates to:
  /// **'About this series'**
  String get seriesAbout;

  /// No description provided for @seriesOrganisedFor.
  ///
  /// In en, this message translates to:
  /// **'This series is organised for structured {exam} practice.'**
  String seriesOrganisedFor(String exam);

  /// No description provided for @seriesIncluded.
  ///
  /// In en, this message translates to:
  /// **'What’s included'**
  String get seriesIncluded;

  /// No description provided for @seriesRequired.
  ///
  /// In en, this message translates to:
  /// **'{count} required'**
  String seriesRequired(int count);

  /// No description provided for @seriesWhyChoose.
  ///
  /// In en, this message translates to:
  /// **'Why choose this series'**
  String get seriesWhyChoose;

  /// No description provided for @seriesWhyProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress tracking'**
  String get seriesWhyProgress;

  /// No description provided for @seriesWhyProgressBody.
  ///
  /// In en, this message translates to:
  /// **'Completed tests and your next eligible test stay visible.'**
  String get seriesWhyProgressBody;

  /// No description provided for @seriesWhyUnlock.
  ///
  /// In en, this message translates to:
  /// **'Clear unlock rules'**
  String get seriesWhyUnlock;

  /// No description provided for @seriesWhyUnlockBody.
  ///
  /// In en, this message translates to:
  /// **'Scheduled and progression-based locks are shown before you open a test.'**
  String get seriesWhyUnlockBody;

  /// No description provided for @seriesWhyInstructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions before attempt'**
  String get seriesWhyInstructions;

  /// No description provided for @seriesWhyInstructionsBody.
  ///
  /// In en, this message translates to:
  /// **'Each unlocked test opens its details and instructions before the timer starts.'**
  String get seriesWhyInstructionsBody;

  /// No description provided for @seriesNoTests.
  ///
  /// In en, this message translates to:
  /// **'No tests are currently available in this series.'**
  String get seriesNoTests;

  /// No description provided for @seriesTypeCountA11y.
  ///
  /// In en, this message translates to:
  /// **'{label}, {count} tests'**
  String seriesTypeCountA11y(String label, int count);

  /// No description provided for @seriesNoPattern.
  ///
  /// In en, this message translates to:
  /// **'No test pattern is available yet.'**
  String get seriesNoPattern;

  /// No description provided for @seriesPattern.
  ///
  /// In en, this message translates to:
  /// **'Series pattern'**
  String get seriesPattern;

  /// No description provided for @seriesMinTotal.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min total'**
  String seriesMinTotal(int minutes);

  /// No description provided for @seriesBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Test-wise breakdown'**
  String get seriesBreakdown;

  /// No description provided for @seriesSyllabusBody.
  ///
  /// In en, this message translates to:
  /// **'Complete topic-wise preparation coverage for {exam}. Test groups below are derived from the published series catalogue.'**
  String seriesSyllabusBody(String exam);

  /// No description provided for @seriesSyllabusEmpty.
  ///
  /// In en, this message translates to:
  /// **'Syllabus will appear as tests are published.'**
  String get seriesSyllabusEmpty;

  /// No description provided for @seriesPublishedTestsQuestions.
  ///
  /// In en, this message translates to:
  /// **'{tests} published tests · {questions} questions'**
  String seriesPublishedTestsQuestions(int tests, int questions);

  /// No description provided for @seriesReviewsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Learner reviews will appear here when published reviews are available.'**
  String get seriesReviewsEmpty;

  /// No description provided for @seriesStudentReviews.
  ///
  /// In en, this message translates to:
  /// **'Student Reviews'**
  String get seriesStudentReviews;

  /// No description provided for @seriesRatedReviews.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 rated review} other{{count} rated reviews}}'**
  String seriesRatedReviews(int count);

  /// No description provided for @faqIncludedQ.
  ///
  /// In en, this message translates to:
  /// **'What is included in this test series?'**
  String get faqIncludedQ;

  /// No description provided for @faqIncludedA.
  ///
  /// In en, this message translates to:
  /// **'{tests} published tests with {questions} total questions, subject to the live catalogue and your access plan.'**
  String faqIncludedA(int tests, int questions);

  /// No description provided for @faqExplanationsQ.
  ///
  /// In en, this message translates to:
  /// **'Are explanations available?'**
  String get faqExplanationsQ;

  /// No description provided for @faqExplanationsA.
  ///
  /// In en, this message translates to:
  /// **'Completed attempts can be reviewed with the explanation and analysis supported by the test.'**
  String get faqExplanationsA;

  /// No description provided for @faqMultipleQ.
  ///
  /// In en, this message translates to:
  /// **'Can I attempt a test multiple times?'**
  String get faqMultipleQ;

  /// No description provided for @faqMultipleA.
  ///
  /// In en, this message translates to:
  /// **'Attempt limits are shown on the Test Instructions page and are enforced by the test configuration.'**
  String get faqMultipleA;

  /// No description provided for @faqLanguageQ.
  ///
  /// In en, this message translates to:
  /// **'Can I change the question language?'**
  String get faqLanguageQ;

  /// No description provided for @faqLanguageA.
  ///
  /// In en, this message translates to:
  /// **'Supported languages are shown before starting the test. Availability depends on the published question content.'**
  String get faqLanguageA;

  /// No description provided for @faqExpiryQ.
  ///
  /// In en, this message translates to:
  /// **'What happens when my access expires?'**
  String get faqExpiryQ;

  /// No description provided for @faqExpiryA.
  ///
  /// In en, this message translates to:
  /// **'You can renew the series from My Test Series. Existing progress and analytics remain tied to your account.'**
  String get faqExpiryA;

  /// No description provided for @faqPreviousQ.
  ///
  /// In en, this message translates to:
  /// **'Where can I see my previous attempts?'**
  String get faqPreviousQ;

  /// No description provided for @faqPreviousA.
  ///
  /// In en, this message translates to:
  /// **'Use My Test Series, Profile or Results to revisit completed attempts and performance information.'**
  String get faqPreviousA;

  /// No description provided for @seriesYourProgress.
  ///
  /// In en, this message translates to:
  /// **'Your series progress'**
  String get seriesYourProgress;

  /// No description provided for @seriesCompletedOf.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} tests completed'**
  String seriesCompletedOf(int done, int total);

  /// No description provided for @typeFullTitle.
  ///
  /// In en, this message translates to:
  /// **'Full Length Mock Tests'**
  String get typeFullTitle;

  /// No description provided for @typeFullSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Latest pattern full syllabus tests'**
  String get typeFullSubtitle;

  /// No description provided for @typeSectionalTitle.
  ///
  /// In en, this message translates to:
  /// **'Sectional Tests'**
  String get typeSectionalTitle;

  /// No description provided for @typeSectionalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Subject-wise practice tests'**
  String get typeSectionalSubtitle;

  /// No description provided for @typeTopicTitle.
  ///
  /// In en, this message translates to:
  /// **'Topic-wise Tests'**
  String get typeTopicTitle;

  /// No description provided for @typeTopicSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Focused practice on important topics'**
  String get typeTopicSubtitle;

  /// No description provided for @typePyqTitle.
  ///
  /// In en, this message translates to:
  /// **'Previous Year Papers'**
  String get typePyqTitle;

  /// No description provided for @typePyqSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Previous exam papers with review'**
  String get typePyqSubtitle;

  /// No description provided for @typeFullTab.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get typeFullTab;

  /// No description provided for @typeSectionalTab.
  ///
  /// In en, this message translates to:
  /// **'Sectional'**
  String get typeSectionalTab;

  /// No description provided for @typeTopicTab.
  ///
  /// In en, this message translates to:
  /// **'Topic-wise'**
  String get typeTopicTab;

  /// No description provided for @typePyqTab.
  ///
  /// In en, this message translates to:
  /// **'PYQs'**
  String get typePyqTab;

  /// No description provided for @seriesStateCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get seriesStateCompleted;

  /// No description provided for @seriesStatePremium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get seriesStatePremium;

  /// No description provided for @seriesStateReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get seriesStateReady;

  /// No description provided for @seriesStateLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get seriesStateLocked;

  /// No description provided for @seriesOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get seriesOptional;

  /// No description provided for @seriesRequiredTag.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get seriesRequiredTag;

  /// No description provided for @seriesBestScore.
  ///
  /// In en, this message translates to:
  /// **'Best score: {score}'**
  String seriesBestScore(String score);

  /// No description provided for @seriesOpenAgain.
  ///
  /// In en, this message translates to:
  /// **'Open test again'**
  String get seriesOpenAgain;

  /// No description provided for @seriesViewInstructions.
  ///
  /// In en, this message translates to:
  /// **'View instructions'**
  String get seriesViewInstructions;

  /// No description provided for @seriesUnlockPremium.
  ///
  /// In en, this message translates to:
  /// **'Unlock premium tests'**
  String get seriesUnlockPremium;

  /// No description provided for @seriesProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'Series progress'**
  String get seriesProgressLabel;

  /// No description provided for @seriesStatus.
  ///
  /// In en, this message translates to:
  /// **'Series status'**
  String get seriesStatus;

  /// No description provided for @seriesUpNext.
  ///
  /// In en, this message translates to:
  /// **'Up next'**
  String get seriesUpNext;

  /// No description provided for @seriesPremiumRequired.
  ///
  /// In en, this message translates to:
  /// **'Premium access required'**
  String get seriesPremiumRequired;

  /// No description provided for @seriesFromPrice.
  ///
  /// In en, this message translates to:
  /// **'From {price}'**
  String seriesFromPrice(String price);

  /// No description provided for @seriesAllCompleted.
  ///
  /// In en, this message translates to:
  /// **'All tests completed'**
  String get seriesAllCompleted;

  /// No description provided for @seriesNoneAvailable.
  ///
  /// In en, this message translates to:
  /// **'No test is available yet'**
  String get seriesNoneAvailable;

  /// No description provided for @seriesViewPlans.
  ///
  /// In en, this message translates to:
  /// **'View Plans'**
  String get seriesViewPlans;

  /// No description provided for @seriesReviewTests.
  ///
  /// In en, this message translates to:
  /// **'Review Tests'**
  String get seriesReviewTests;

  /// No description provided for @seriesOpenTest.
  ///
  /// In en, this message translates to:
  /// **'Open Test'**
  String get seriesOpenTest;

  /// No description provided for @seriesLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Test series could not be loaded.'**
  String get seriesLoadFailed;

  /// No description provided for @seriesCheckConnection.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get seriesCheckConnection;

  /// No description provided for @loginLetSBuildYourExam.
  ///
  /// In en, this message translates to:
  /// **'Let’s build your exam success'**
  String get loginLetSBuildYourExam;

  /// No description provided for @loginMasterConceptsPracticeSmarterGet.
  ///
  /// In en, this message translates to:
  /// **'Master concepts. Practice smarter. Get real results.'**
  String get loginMasterConceptsPracticeSmarterGet;

  /// No description provided for @loginPracticeTheWayRealExams.
  ///
  /// In en, this message translates to:
  /// **'Practice the way real exams ask'**
  String get loginPracticeTheWayRealExams;

  /// No description provided for @loginUseFocusedMockTestsAnd.
  ///
  /// In en, this message translates to:
  /// **'Use focused mock tests and detailed solutions to turn preparation into exam readiness.'**
  String get loginUseFocusedMockTestsAnd;

  /// No description provided for @loginKnowWhatToReviseNext.
  ///
  /// In en, this message translates to:
  /// **'Know what to revise next'**
  String get loginKnowWhatToReviseNext;

  /// No description provided for @loginContinueWhereYouLeftOff.
  ///
  /// In en, this message translates to:
  /// **'Continue where you left off and use your progress to keep revision targeted.'**
  String get loginContinueWhereYouLeftOff;

  /// No description provided for @loginTooManyVerificationAttemptsPlease.
  ///
  /// In en, this message translates to:
  /// **'Too many verification attempts. Please wait a little and try again.'**
  String get loginTooManyVerificationAttemptsPlease;

  /// No description provided for @loginSmsVerificationIsTemporarilyUnavailable.
  ///
  /// In en, this message translates to:
  /// **'SMS verification is temporarily unavailable. Please try again later.'**
  String get loginSmsVerificationIsTemporarilyUnavailable;

  /// No description provided for @loginThisExamtreeBuildIsNot.
  ///
  /// In en, this message translates to:
  /// **'This ExamTree build is not authorized for phone sign-in.'**
  String get loginThisExamtreeBuildIsNot;

  /// No description provided for @loginPhoneVerificationCouldNotBe.
  ///
  /// In en, this message translates to:
  /// **'Phone verification could not be confirmed. Please try again.'**
  String get loginPhoneVerificationCouldNotBe;

  /// No description provided for @loginCouldNotReachTheVerification.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the verification service. Check your connection and try again.'**
  String get loginCouldNotReachTheVerification;

  /// No description provided for @loginThisVerificationSessionHasExpired.
  ///
  /// In en, this message translates to:
  /// **'This verification session has expired. Request a new OTP.'**
  String get loginThisVerificationSessionHasExpired;

  /// No description provided for @loginPhoneSignInIsNot.
  ///
  /// In en, this message translates to:
  /// **'Phone sign-in is not enabled for this ExamTree build.'**
  String get loginPhoneSignInIsNot;

  /// No description provided for @loginGoogleSignInIsTemporarily.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in is temporarily unavailable. Please try again later.'**
  String get loginGoogleSignInIsTemporarily;

  /// No description provided for @loginThisEmailAlreadyHasAn.
  ///
  /// In en, this message translates to:
  /// **'This email already has an ExamTree sign-in method. Sign in with that method first, then try Google again.'**
  String get loginThisEmailAlreadyHasAn;

  /// No description provided for @loginGoogleDidNotProvideA.
  ///
  /// In en, this message translates to:
  /// **'Google did not provide a verified email for this account.'**
  String get loginGoogleDidNotProvideA;

  /// No description provided for @loginGoogleSignInCouldNot.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in could not reach the service. Check your connection and try again.'**
  String get loginGoogleSignInCouldNot;

  /// No description provided for @loginAppleSignInWasCanceled.
  ///
  /// In en, this message translates to:
  /// **'Apple sign-in was canceled. Please try again.'**
  String get loginAppleSignInWasCanceled;

  /// No description provided for @loginAppleSignInIsTemporarily.
  ///
  /// In en, this message translates to:
  /// **'Apple sign-in is temporarily unavailable. Please try again later.'**
  String get loginAppleSignInIsTemporarily;

  /// No description provided for @loginThisEmailAlreadyHasAn2.
  ///
  /// In en, this message translates to:
  /// **'This email already has an ExamTree sign-in method. Sign in with that method first, then try Apple again.'**
  String get loginThisEmailAlreadyHasAn2;

  /// No description provided for @loginAppleDidNotProvideA.
  ///
  /// In en, this message translates to:
  /// **'Apple did not provide a usable verified email for this account.'**
  String get loginAppleDidNotProvideA;

  /// No description provided for @loginAppleSignInCouldNot.
  ///
  /// In en, this message translates to:
  /// **'Apple sign-in could not reach the service. Check your connection and try again.'**
  String get loginAppleSignInCouldNot;

  /// No description provided for @loginResetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get loginResetPassword;

  /// No description provided for @loginRecoverYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Recover your account'**
  String get loginRecoverYourAccount;

  /// No description provided for @loginEnterTheEmailYouUse.
  ///
  /// In en, this message translates to:
  /// **'Enter the email you use for ExamTree and we will send password-reset instructions.'**
  String get loginEnterTheEmailYouUse;

  /// No description provided for @loginEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginEmail;

  /// No description provided for @loginForPrivacyTheConfirmationScreen.
  ///
  /// In en, this message translates to:
  /// **'For privacy, the confirmation screen does not reveal whether an email is registered.'**
  String get loginForPrivacyTheConfirmationScreen;

  /// No description provided for @loginBackToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get loginBackToSignIn;

  /// No description provided for @loginCheckYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get loginCheckYourEmail;

  /// No description provided for @loginCheckYourSpamFolderToo.
  ///
  /// In en, this message translates to:
  /// **'Check your spam folder too. For privacy, we do not confirm whether an email is registered.'**
  String get loginCheckYourSpamFolderToo;

  /// No description provided for @loginSendingAnotherResetEmail.
  ///
  /// In en, this message translates to:
  /// **'Sending another reset email…'**
  String get loginSendingAnotherResetEmail;

  /// No description provided for @loginUseAnotherEmail.
  ///
  /// In en, this message translates to:
  /// **'Use another email'**
  String get loginUseAnotherEmail;

  /// No description provided for @loginEnterAValidEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get loginEnterAValidEmailAddress;

  /// No description provided for @loginEnterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password.'**
  String get loginEnterYourPassword;

  /// No description provided for @loginPreparingSignIn.
  ///
  /// In en, this message translates to:
  /// **'Preparing sign-in…'**
  String get loginPreparingSignIn;

  /// No description provided for @loginUnableToSignInPlease.
  ///
  /// In en, this message translates to:
  /// **'Unable to sign in. Please try again.'**
  String get loginUnableToSignInPlease;

  /// No description provided for @loginEnterAValidMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid mobile number.'**
  String get loginEnterAValidMobileNumber;

  /// No description provided for @loginTheOtpYouEnteredIs.
  ///
  /// In en, this message translates to:
  /// **'The OTP you entered is incorrect.'**
  String get loginTheOtpYouEnteredIs;

  /// No description provided for @loginUnableToVerifyThisMobile.
  ///
  /// In en, this message translates to:
  /// **'Unable to verify this mobile number. Please try again.'**
  String get loginUnableToVerifyThisMobile;

  /// No description provided for @loginEnterAValid10Digit.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 10-digit mobile number.'**
  String get loginEnterAValid10Digit;

  /// No description provided for @loginSendingOtp.
  ///
  /// In en, this message translates to:
  /// **'Sending OTP…'**
  String get loginSendingOtp;

  /// No description provided for @loginUnableToSendTheOtp.
  ///
  /// In en, this message translates to:
  /// **'Unable to send the OTP. Please try again.'**
  String get loginUnableToSendTheOtp;

  /// No description provided for @loginRequestANewOtpFirst.
  ///
  /// In en, this message translates to:
  /// **'Request a new OTP first.'**
  String get loginRequestANewOtpFirst;

  /// No description provided for @loginEnterThe6DigitOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit OTP.'**
  String get loginEnterThe6DigitOtp;

  /// No description provided for @loginVerifyingOtp.
  ///
  /// In en, this message translates to:
  /// **'Verifying OTP…'**
  String get loginVerifyingOtp;

  /// No description provided for @loginUnableToVerifyTheOtp.
  ///
  /// In en, this message translates to:
  /// **'Unable to verify the OTP. Please try again.'**
  String get loginUnableToVerifyTheOtp;

  /// No description provided for @loginSendingANewOtp.
  ///
  /// In en, this message translates to:
  /// **'Sending a new OTP…'**
  String get loginSendingANewOtp;

  /// No description provided for @loginUnableToResendTheOtp.
  ///
  /// In en, this message translates to:
  /// **'Unable to resend the OTP. Please try again.'**
  String get loginUnableToResendTheOtp;

  /// No description provided for @loginPreparingGoogleSignIn.
  ///
  /// In en, this message translates to:
  /// **'Preparing Google sign-in…'**
  String get loginPreparingGoogleSignIn;

  /// No description provided for @loginGoogleSignInWasCanceled.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in was canceled. Please try again.'**
  String get loginGoogleSignInWasCanceled;

  /// No description provided for @loginGoogleSignInCouldNot2.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in could not be completed. Please try again.'**
  String get loginGoogleSignInCouldNot2;

  /// No description provided for @loginUnableToSignInWith.
  ///
  /// In en, this message translates to:
  /// **'Unable to sign in with Google. Please try again.'**
  String get loginUnableToSignInWith;

  /// No description provided for @loginPreparingAppleSignIn.
  ///
  /// In en, this message translates to:
  /// **'Preparing Apple sign-in…'**
  String get loginPreparingAppleSignIn;

  /// No description provided for @loginAppleSignInCouldNot2.
  ///
  /// In en, this message translates to:
  /// **'Apple sign-in could not be completed. Please try again.'**
  String get loginAppleSignInCouldNot2;

  /// No description provided for @loginUnableToSignInWith2.
  ///
  /// In en, this message translates to:
  /// **'Unable to sign in with Apple. Please try again.'**
  String get loginUnableToSignInWith2;

  /// No description provided for @loginEnterYourName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name.'**
  String get loginEnterYourName;

  /// No description provided for @loginNameMustBe80Characters.
  ///
  /// In en, this message translates to:
  /// **'Name must be 80 characters or fewer.'**
  String get loginNameMustBe80Characters;

  /// No description provided for @loginUseAtLeast6Characters.
  ///
  /// In en, this message translates to:
  /// **'Use at least 6 characters for your password.'**
  String get loginUseAtLeast6Characters;

  /// No description provided for @loginPasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get loginPasswordsDoNotMatch;

  /// No description provided for @loginPreparingAccountSetup.
  ///
  /// In en, this message translates to:
  /// **'Preparing account setup…'**
  String get loginPreparingAccountSetup;

  /// No description provided for @loginUnableToCreateYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Unable to create your account. Please try again.'**
  String get loginUnableToCreateYourAccount;

  /// No description provided for @authCreateYourExamtreeAccount.
  ///
  /// In en, this message translates to:
  /// **'Create your ExamTree account'**
  String get authCreateYourExamtreeAccount;

  /// No description provided for @authSetUpYourAccountAnd.
  ///
  /// In en, this message translates to:
  /// **'Set up your account and keep your preparation synced.'**
  String get authSetUpYourAccountAnd;

  /// No description provided for @authSecureSignInYourProgress.
  ///
  /// In en, this message translates to:
  /// **'Secure sign-in. Your progress stays synced.'**
  String get authSecureSignInYourProgress;

  /// No description provided for @authLoginWithMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Login with Mobile Number'**
  String get authLoginWithMobileNumber;

  /// No description provided for @authWeLlSendYouA.
  ///
  /// In en, this message translates to:
  /// **'We’ll send you a one-time password (OTP)'**
  String get authWeLlSendYouA;

  /// No description provided for @authEnterMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter mobile number'**
  String get authEnterMobileNumber;

  /// No description provided for @authGetOtp.
  ///
  /// In en, this message translates to:
  /// **'Get OTP'**
  String get authGetOtp;

  /// No description provided for @authEnterOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP'**
  String get authEnterOtp;

  /// No description provided for @authChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get authChange;

  /// No description provided for @authVerifyContinue.
  ///
  /// In en, this message translates to:
  /// **'Verify & Continue'**
  String get authVerifyContinue;

  /// No description provided for @authContinueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get authContinueWithGoogle;

  /// No description provided for @authContinueWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Continue with Email'**
  String get authContinueWithEmail;

  /// No description provided for @authContinueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get authContinueWithApple;

  /// No description provided for @authSignInWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Email'**
  String get authSignInWithEmail;

  /// No description provided for @authName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get authName;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get authConfirmPassword;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPassword;

  /// No description provided for @caThisCurrentAffairsItemCould.
  ///
  /// In en, this message translates to:
  /// **'This current-affairs item could not be opened.'**
  String get caThisCurrentAffairsItemCould;

  /// No description provided for @caUnableToLoadCurrentAffairs.
  ///
  /// In en, this message translates to:
  /// **'Unable to load current affairs'**
  String get caUnableToLoadCurrentAffairs;

  /// No description provided for @caLatestUpdates.
  ///
  /// In en, this message translates to:
  /// **'Latest updates'**
  String get caLatestUpdates;

  /// No description provided for @caStayReadyForWhatChanged.
  ///
  /// In en, this message translates to:
  /// **'Stay ready for what changed.'**
  String get caStayReadyForWhatChanged;

  /// No description provided for @caReadPublishedUpdatesInYour.
  ///
  /// In en, this message translates to:
  /// **'Read published updates in your preferred language and keep exam-relevant developments close at hand.'**
  String get caReadPublishedUpdatesInYour;

  /// No description provided for @caNoCurrentAffairsArePublished.
  ///
  /// In en, this message translates to:
  /// **'No current affairs are published yet.'**
  String get caNoCurrentAffairsArePublished;

  /// No description provided for @caNewPublishedUpdatesWillAppear.
  ///
  /// In en, this message translates to:
  /// **'New published updates will appear here automatically.'**
  String get caNewPublishedUpdatesWillAppear;

  /// No description provided for @caNoPublishedItemsMatchThis.
  ///
  /// In en, this message translates to:
  /// **'No published items match this format yet.'**
  String get caNoPublishedItemsMatchThis;

  /// No description provided for @myExamsMyExams.
  ///
  /// In en, this message translates to:
  /// **'My exams'**
  String get myExamsMyExams;

  /// No description provided for @myExamsUnableToLoadYourExam.
  ///
  /// In en, this message translates to:
  /// **'Unable to load your exam catalogue'**
  String get myExamsUnableToLoadYourExam;

  /// No description provided for @myExamsMyExamsUpdated.
  ///
  /// In en, this message translates to:
  /// **'My exams updated.'**
  String get myExamsMyExamsUpdated;

  /// No description provided for @myExamsUnableToSaveYourSelected.
  ///
  /// In en, this message translates to:
  /// **'Unable to save your selected exams.'**
  String get myExamsUnableToSaveYourSelected;

  /// No description provided for @myExamsSearchExamsOrExamFamilies.
  ///
  /// In en, this message translates to:
  /// **'Search exams or exam families'**
  String get myExamsSearchExamsOrExamFamilies;

  /// No description provided for @myExamsChooseWhatYouArePreparing.
  ///
  /// In en, this message translates to:
  /// **'Choose what you are preparing for'**
  String get myExamsChooseWhatYouArePreparing;

  /// No description provided for @myExamsExamtreeWillUseTheseChoices.
  ///
  /// In en, this message translates to:
  /// **'ExamTree will use these choices to organise tests, free material and relevant updates. You can change them anytime.'**
  String get myExamsExamtreeWillUseTheseChoices;

  /// No description provided for @myExamsClearSelection.
  ///
  /// In en, this message translates to:
  /// **'Clear selection'**
  String get myExamsClearSelection;

  /// No description provided for @myExamsNoExamsMatchThatSearch.
  ///
  /// In en, this message translates to:
  /// **'No exams match that search.'**
  String get myExamsNoExamsMatchThatSearch;

  /// No description provided for @myExamsTryTheExamNameCode.
  ///
  /// In en, this message translates to:
  /// **'Try the exam name, code, or exam family.'**
  String get myExamsTryTheExamNameCode;

  /// No description provided for @dailyStudyPlanSavedButNotifications.
  ///
  /// In en, this message translates to:
  /// **'Study plan saved, but notifications are disabled.'**
  String get dailyStudyPlanSavedButNotifications;

  /// No description provided for @dailyUnableToSaveTheStudy.
  ///
  /// In en, this message translates to:
  /// **'Unable to save the study plan.'**
  String get dailyUnableToSaveTheStudy;

  /// No description provided for @dailyDailyCompanion.
  ///
  /// In en, this message translates to:
  /// **'Daily Companion'**
  String get dailyDailyCompanion;

  /// No description provided for @dailyRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get dailyRefresh;

  /// No description provided for @dailyQuickRevision.
  ///
  /// In en, this message translates to:
  /// **'Quick revision'**
  String get dailyQuickRevision;

  /// No description provided for @dailyStudyPlan.
  ///
  /// In en, this message translates to:
  /// **'Study plan'**
  String get dailyStudyPlan;

  /// No description provided for @dailyKeepYourDailyTargetAnd.
  ///
  /// In en, this message translates to:
  /// **'Keep your daily target and local reminder realistic.'**
  String get dailyKeepYourDailyTargetAnd;

  /// No description provided for @dailyDailyCompanionIsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Daily Companion is unavailable'**
  String get dailyDailyCompanionIsUnavailable;

  /// No description provided for @dailyYourSavedRevisionQueueIs.
  ///
  /// In en, this message translates to:
  /// **'Your saved revision queue is still on this device. Try loading it again.'**
  String get dailyYourSavedRevisionQueueIs;

  /// No description provided for @dailyRetryDailyCompanion.
  ///
  /// In en, this message translates to:
  /// **'Retry Daily Companion'**
  String get dailyRetryDailyCompanion;

  /// No description provided for @dailyTodaySRevision.
  ///
  /// In en, this message translates to:
  /// **'Today’s revision'**
  String get dailyTodaySRevision;

  /// No description provided for @dailyExamDayMode.
  ///
  /// In en, this message translates to:
  /// **'Exam-Day Mode'**
  String get dailyExamDayMode;

  /// No description provided for @dailyCountdownLogisticsChecklistAndLocal.
  ///
  /// In en, this message translates to:
  /// **'Countdown, logistics checklist and local reminders'**
  String get dailyCountdownLogisticsChecklistAndLocal;

  /// No description provided for @dailyCompleteTestsToBuildA.
  ///
  /// In en, this message translates to:
  /// **'Complete tests to build a private revision queue from wrong, skipped, flagged and unusually slow questions.'**
  String get dailyCompleteTestsToBuildA;

  /// No description provided for @dailyMyStudyPlan.
  ///
  /// In en, this message translates to:
  /// **'My study plan'**
  String get dailyMyStudyPlan;

  /// No description provided for @dailySetARealisticDailyReview.
  ///
  /// In en, this message translates to:
  /// **'Set a realistic daily review target and an optional local reminder.'**
  String get dailySetARealisticDailyReview;

  /// No description provided for @dailyLocalStudyReminder.
  ///
  /// In en, this message translates to:
  /// **'Local study reminder'**
  String get dailyLocalStudyReminder;

  /// No description provided for @dailyChangeReminderTime.
  ///
  /// In en, this message translates to:
  /// **'Change reminder time'**
  String get dailyChangeReminderTime;

  /// No description provided for @dailyDecreaseDailyQuestionGoal.
  ///
  /// In en, this message translates to:
  /// **'Decrease daily question goal'**
  String get dailyDecreaseDailyQuestionGoal;

  /// No description provided for @dailyIncreaseDailyQuestionGoal.
  ///
  /// In en, this message translates to:
  /// **'Increase daily question goal'**
  String get dailyIncreaseDailyQuestionGoal;

  /// No description provided for @dailyDailyQuestionGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily question goal'**
  String get dailyDailyQuestionGoal;

  /// No description provided for @revisionUnableToSaveThisReview.
  ///
  /// In en, this message translates to:
  /// **'Unable to save this review.'**
  String get revisionUnableToSaveThisReview;

  /// No description provided for @revisionRevisionQueueUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Revision queue unavailable'**
  String get revisionRevisionQueueUnavailable;

  /// No description provided for @revisionTryLoadingYourSavedRevision.
  ///
  /// In en, this message translates to:
  /// **'Try loading your saved revision questions again.'**
  String get revisionTryLoadingYourSavedRevision;

  /// No description provided for @revisionReviewTheQuestion.
  ///
  /// In en, this message translates to:
  /// **'Review the question'**
  String get revisionReviewTheQuestion;

  /// No description provided for @revisionShowAnswer.
  ///
  /// In en, this message translates to:
  /// **'Show answer'**
  String get revisionShowAnswer;

  /// No description provided for @revisionRecallFirstRevealTheStored.
  ///
  /// In en, this message translates to:
  /// **'Recall first. Reveal the stored answer when you’re ready.'**
  String get revisionRecallFirstRevealTheStored;

  /// No description provided for @revisionCompareThisWithTheReasoning.
  ///
  /// In en, this message translates to:
  /// **'Compare this with the reasoning you recalled.'**
  String get revisionCompareThisWithTheReasoning;

  /// No description provided for @revisionHowWellDidYouRemember.
  ///
  /// In en, this message translates to:
  /// **'How well did you remember this?'**
  String get revisionHowWellDidYouRemember;

  /// No description provided for @revisionChooseGotItIfYou.
  ///
  /// In en, this message translates to:
  /// **'Choose “Got it” if you could explain the answer now. Choose “Review again” to bring it back sooner.'**
  String get revisionChooseGotItIfYou;

  /// No description provided for @revisionReviewAgain.
  ///
  /// In en, this message translates to:
  /// **'Review again'**
  String get revisionReviewAgain;

  /// No description provided for @revisionGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get revisionGotIt;

  /// No description provided for @notifAllNotificationsMarkedAsRead.
  ///
  /// In en, this message translates to:
  /// **'All notifications marked as read.'**
  String get notifAllNotificationsMarkedAsRead;

  /// No description provided for @notifUnableToMarkNotificationsAs.
  ///
  /// In en, this message translates to:
  /// **'Unable to mark notifications as read.'**
  String get notifUnableToMarkNotificationsAs;

  /// No description provided for @notifMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get notifMarkAllRead;

  /// No description provided for @notifImportantUpdatesInOnePlace.
  ///
  /// In en, this message translates to:
  /// **'Important updates, in one place.'**
  String get notifImportantUpdatesInOnePlace;

  /// No description provided for @notifExamRemindersLearningUpdatesAnd.
  ///
  /// In en, this message translates to:
  /// **'Exam reminders, learning updates and test announcements stay easy to find.'**
  String get notifExamRemindersLearningUpdatesAnd;

  /// No description provided for @notifOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Open link'**
  String get notifOpenLink;

  /// No description provided for @notifNoNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get notifNoNotificationsYet;

  /// No description provided for @notifImportantExamtreeUpdatesWillAppear.
  ///
  /// In en, this message translates to:
  /// **'Important ExamTree updates will appear here when there is something worth your attention.'**
  String get notifImportantExamtreeUpdatesWillAppear;

  /// No description provided for @notifUnableToLoadNotifications.
  ///
  /// In en, this message translates to:
  /// **'Unable to load notifications'**
  String get notifUnableToLoadNotifications;

  /// No description provided for @notifTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get notifTryAgain;

  /// No description provided for @profileMyProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get profileMyProfile;

  /// No description provided for @profileSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileSettings;

  /// No description provided for @profileUnableToLoadYourPerformance.
  ///
  /// In en, this message translates to:
  /// **'Unable to load your performance'**
  String get profileUnableToLoadYourPerformance;

  /// No description provided for @profileAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profileAccount;

  /// No description provided for @profilePreferencesPrivacyAndThisDevice.
  ///
  /// In en, this message translates to:
  /// **'Preferences, privacy and this device session.'**
  String get profilePreferencesPrivacyAndThisDevice;

  /// No description provided for @profileUsedInTestsAnswerReview.
  ///
  /// In en, this message translates to:
  /// **'Used in tests, answer review and saved revision questions. English is used when a translation is unavailable.'**
  String get profileUsedInTestsAnswerReview;

  /// No description provided for @profileUnableToSaveTheQuestion.
  ///
  /// In en, this message translates to:
  /// **'Unable to save the question language on this device.'**
  String get profileUnableToSaveTheQuestion;

  /// No description provided for @profileYourProfile.
  ///
  /// In en, this message translates to:
  /// **'Your profile'**
  String get profileYourProfile;

  /// No description provided for @profileMyProgress.
  ///
  /// In en, this message translates to:
  /// **'My Progress'**
  String get profileMyProgress;

  /// No description provided for @profileAccuracyAttemptsAndPerformance.
  ///
  /// In en, this message translates to:
  /// **'Accuracy, attempts and performance'**
  String get profileAccuracyAttemptsAndPerformance;

  /// No description provided for @profileOfflineLearningResources.
  ///
  /// In en, this message translates to:
  /// **'Offline learning resources'**
  String get profileOfflineLearningResources;

  /// No description provided for @profileSavedRevisionItems.
  ///
  /// In en, this message translates to:
  /// **'Saved revision items'**
  String get profileSavedRevisionItems;

  /// No description provided for @profileTestHistory.
  ///
  /// In en, this message translates to:
  /// **'Test History'**
  String get profileTestHistory;

  /// No description provided for @profileCompletedAttemptsAndResults.
  ///
  /// In en, this message translates to:
  /// **'Completed attempts and results'**
  String get profileCompletedAttemptsAndResults;

  /// No description provided for @profileCouponsOffers.
  ///
  /// In en, this message translates to:
  /// **'Coupons & Offers'**
  String get profileCouponsOffers;

  /// No description provided for @profileApplyDiscountsDuringCheckout.
  ///
  /// In en, this message translates to:
  /// **'Apply discounts during checkout'**
  String get profileApplyDiscountsDuringCheckout;

  /// No description provided for @profileEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profileEditProfile;

  /// No description provided for @profileUpdateYourLearnerName.
  ///
  /// In en, this message translates to:
  /// **'Update your learner name'**
  String get profileUpdateYourLearnerName;

  /// No description provided for @profileHelpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get profileHelpSupport;

  /// No description provided for @profileCommonQuestionsAndAccountHelp.
  ///
  /// In en, this message translates to:
  /// **'Common questions and account help'**
  String get profileCommonQuestionsAndAccountHelp;

  /// No description provided for @profilePerformance.
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get profilePerformance;

  /// No description provided for @profileYourCompletedTestSignalsAt.
  ///
  /// In en, this message translates to:
  /// **'Your completed-test signals at a glance.'**
  String get profileYourCompletedTestSignalsAt;

  /// No description provided for @profileFullHistory.
  ///
  /// In en, this message translates to:
  /// **'Full history'**
  String get profileFullHistory;

  /// No description provided for @profileRecentTrend.
  ///
  /// In en, this message translates to:
  /// **'Recent trend'**
  String get profileRecentTrend;

  /// No description provided for @profileYourLatestCompletedTests.
  ///
  /// In en, this message translates to:
  /// **'Your latest completed tests.'**
  String get profileYourLatestCompletedTests;

  /// No description provided for @profileAvgTime.
  ///
  /// In en, this message translates to:
  /// **'Avg time'**
  String get profileAvgTime;

  /// No description provided for @profileWhatToFocusOn.
  ///
  /// In en, this message translates to:
  /// **'What to focus on'**
  String get profileWhatToFocusOn;

  /// No description provided for @profileSectionDetailWillAppearAfter.
  ///
  /// In en, this message translates to:
  /// **'Section detail will appear after reviewed questions are available.'**
  String get profileSectionDetailWillAppearAfter;

  /// No description provided for @profileStrongest.
  ///
  /// In en, this message translates to:
  /// **'Strongest'**
  String get profileStrongest;

  /// No description provided for @profileNeedsAttention.
  ///
  /// In en, this message translates to:
  /// **'Needs attention'**
  String get profileNeedsAttention;

  /// No description provided for @profileReviewLatest.
  ///
  /// In en, this message translates to:
  /// **'Review latest'**
  String get profileReviewLatest;

  /// No description provided for @profileYourPerformanceStartsWithYour.
  ///
  /// In en, this message translates to:
  /// **'Your performance starts with your first test'**
  String get profileYourPerformanceStartsWithYour;

  /// No description provided for @profileCompleteATestToBuild.
  ///
  /// In en, this message translates to:
  /// **'Complete a test to build score, accuracy, section and trend insights here.'**
  String get profileCompleteATestToBuild;

  /// No description provided for @profileBrowseTests.
  ///
  /// In en, this message translates to:
  /// **'Browse tests'**
  String get profileBrowseTests;

  /// No description provided for @profileMyResults.
  ///
  /// In en, this message translates to:
  /// **'My results'**
  String get profileMyResults;

  /// No description provided for @profileSearchAndReviewCompletedAttempts.
  ///
  /// In en, this message translates to:
  /// **'Search and review completed attempts'**
  String get profileSearchAndReviewCompletedAttempts;

  /// No description provided for @profileSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get profileSignOut;

  /// No description provided for @profileEndThisDeviceSession.
  ///
  /// In en, this message translates to:
  /// **'End this device session'**
  String get profileEndThisDeviceSession;

  /// No description provided for @auxYourProgressStartsWithYour.
  ///
  /// In en, this message translates to:
  /// **'Your progress starts with your first test'**
  String get auxYourProgressStartsWithYour;

  /// No description provided for @auxCompleteAMockOrPractice.
  ///
  /// In en, this message translates to:
  /// **'Complete a mock or practice test to build accuracy, score and section insights here.'**
  String get auxCompleteAMockOrPractice;

  /// No description provided for @auxOverallAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Overall Accuracy'**
  String get auxOverallAccuracy;

  /// No description provided for @auxAverageScore.
  ///
  /// In en, this message translates to:
  /// **'Average Score'**
  String get auxAverageScore;

  /// No description provided for @auxAppPreferences.
  ///
  /// In en, this message translates to:
  /// **'App Preferences'**
  String get auxAppPreferences;

  /// No description provided for @auxLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get auxLanguage;

  /// No description provided for @auxLearning.
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get auxLearning;

  /// No description provided for @auxProfileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated.'**
  String get auxProfileUpdated;

  /// No description provided for @auxUnableToUpdateYourProfile.
  ///
  /// In en, this message translates to:
  /// **'Unable to update your profile right now.'**
  String get auxUnableToUpdateYourProfile;

  /// No description provided for @auxVerifiedContact.
  ///
  /// In en, this message translates to:
  /// **'Verified contact'**
  String get auxVerifiedContact;

  /// No description provided for @auxEmailAndPhoneChangesRequire.
  ///
  /// In en, this message translates to:
  /// **'Email and phone changes require verification and are managed through your sign-in account.'**
  String get auxEmailAndPhoneChangesRequire;

  /// No description provided for @auxApplyCouponsAtCheckout.
  ///
  /// In en, this message translates to:
  /// **'Apply coupons at checkout'**
  String get auxApplyCouponsAtCheckout;

  /// No description provided for @auxAvailableCouponCodesCanBe.
  ///
  /// In en, this message translates to:
  /// **'Available coupon codes can be entered when choosing or renewing a test-series plan.'**
  String get auxAvailableCouponCodesCanBe;

  /// No description provided for @auxExploreTestSeries.
  ///
  /// In en, this message translates to:
  /// **'Explore Test Series'**
  String get auxExploreTestSeries;

  /// No description provided for @accountAccountDeletionCouldNotBe.
  ///
  /// In en, this message translates to:
  /// **'Account deletion could not be completed. Please try again.'**
  String get accountAccountDeletionCouldNotBe;

  /// No description provided for @accountSignInAgainToContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in again to continue'**
  String get accountSignInAgainToContinue;

  /// No description provided for @accountYouWillReturnHereAfter.
  ///
  /// In en, this message translates to:
  /// **'You will return here after signing in again.'**
  String get accountYouWillReturnHereAfter;

  /// No description provided for @accountCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get accountCancel;

  /// No description provided for @accountSignInAgain.
  ///
  /// In en, this message translates to:
  /// **'Sign in again'**
  String get accountSignInAgain;

  /// No description provided for @accountDeleteYourExamtreeAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete your ExamTree account?'**
  String get accountDeleteYourExamtreeAccount;

  /// No description provided for @accountThisCannotBeUndoneType.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone. Type DELETE MY ACCOUNT to continue.'**
  String get accountThisCannotBeUndoneType;

  /// No description provided for @accountConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Confirmation'**
  String get accountConfirmation;

  /// No description provided for @accountKeepMyAccount.
  ///
  /// In en, this message translates to:
  /// **'Keep my account'**
  String get accountKeepMyAccount;

  /// No description provided for @accountDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get accountDeleteAccount;

  /// No description provided for @accountThisPageCouldNotBe.
  ///
  /// In en, this message translates to:
  /// **'This page could not be opened. Please try again later.'**
  String get accountThisPageCouldNotBe;

  /// No description provided for @accountYourLearnerData.
  ///
  /// In en, this message translates to:
  /// **'Your learner data'**
  String get accountYourLearnerData;

  /// No description provided for @accountClearInformationAboutWhatExamtree.
  ///
  /// In en, this message translates to:
  /// **'Clear information about what ExamTree uses and where to read the full policy.'**
  String get accountClearInformationAboutWhatExamtree;

  /// No description provided for @accountLearningActivity.
  ///
  /// In en, this message translates to:
  /// **'Learning activity'**
  String get accountLearningActivity;

  /// No description provided for @accountExamtreeUsesYourAccountInformation.
  ///
  /// In en, this message translates to:
  /// **'ExamTree uses your account information to authenticate you, save test attempts, show results and provide learning analytics. We do not need your question answers for advertising.'**
  String get accountExamtreeUsesYourAccountInformation;

  /// No description provided for @accountPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get accountPrivacyPolicy;

  /// No description provided for @accountReadTheProductionPolicyCovering.
  ///
  /// In en, this message translates to:
  /// **'Read the production policy covering data use, retention, deletion and privacy contact details.'**
  String get accountReadTheProductionPolicyCovering;

  /// No description provided for @accountOpenPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Open privacy policy'**
  String get accountOpenPrivacyPolicy;

  /// No description provided for @accountAccountDeletionOnTheWeb.
  ///
  /// In en, this message translates to:
  /// **'Account deletion on the web'**
  String get accountAccountDeletionOnTheWeb;

  /// No description provided for @accountYouCanAlsoStartAn.
  ///
  /// In en, this message translates to:
  /// **'You can also start an account-deletion request from ExamTree’s public web resource.'**
  String get accountYouCanAlsoStartAn;

  /// No description provided for @accountOpenDeletionPage.
  ///
  /// In en, this message translates to:
  /// **'Open deletion page'**
  String get accountOpenDeletionPage;

  /// No description provided for @accountYourPrivacyYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Your privacy, your account'**
  String get accountYourPrivacyYourAccount;

  /// No description provided for @accountReviewHowLearnerDataIs.
  ///
  /// In en, this message translates to:
  /// **'Review how learner data is used and manage permanent account deletion.'**
  String get accountReviewHowLearnerDataIs;

  /// No description provided for @accountDeletingYourAccountPermanentlyRemoves.
  ///
  /// In en, this message translates to:
  /// **'Deleting your account permanently removes learner-owned attempts, results, profile data and active entitlements. An anonymized account record may remain solely where financial or security records must be retained.'**
  String get accountDeletingYourAccountPermanentlyRemoves;

  /// No description provided for @accountYouWillBeAskedTo.
  ///
  /// In en, this message translates to:
  /// **'You will be asked to type DELETE MY ACCOUNT before anything is removed.'**
  String get accountYouWillBeAskedTo;

  /// No description provided for @examDayExamTargetSavedButNotification.
  ///
  /// In en, this message translates to:
  /// **'Exam target saved, but notification permission is disabled.'**
  String get examDayExamTargetSavedButNotification;

  /// No description provided for @examDayUnableToSaveTheExam.
  ///
  /// In en, this message translates to:
  /// **'Unable to save the exam target.'**
  String get examDayUnableToSaveTheExam;

  /// No description provided for @examDayUnableToUpdateTheChecklist.
  ///
  /// In en, this message translates to:
  /// **'Unable to update the checklist.'**
  String get examDayUnableToUpdateTheChecklist;

  /// No description provided for @examDayAddChecklistItem.
  ///
  /// In en, this message translates to:
  /// **'Add checklist item'**
  String get examDayAddChecklistItem;

  /// No description provided for @examDayEGBusTicketSaved.
  ///
  /// In en, this message translates to:
  /// **'e.g. Bus ticket saved offline'**
  String get examDayEGBusTicketSaved;

  /// No description provided for @examDayAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get examDayAdd;

  /// No description provided for @examDayRemoveExamTarget.
  ///
  /// In en, this message translates to:
  /// **'Remove exam target?'**
  String get examDayRemoveExamTarget;

  /// No description provided for @examDayThisRemovesTheLocalCountdown.
  ///
  /// In en, this message translates to:
  /// **'This removes the local countdown, checklist and scheduled exam-day reminders from this device. Test history is unchanged.'**
  String get examDayThisRemovesTheLocalCountdown;

  /// No description provided for @examDayRemoveTarget.
  ///
  /// In en, this message translates to:
  /// **'Remove target'**
  String get examDayRemoveTarget;

  /// No description provided for @examDayUnableToRemoveTheExam.
  ///
  /// In en, this message translates to:
  /// **'Unable to remove the exam target.'**
  String get examDayUnableToRemoveTheExam;

  /// No description provided for @examDayEditTarget.
  ///
  /// In en, this message translates to:
  /// **'Edit target'**
  String get examDayEditTarget;

  /// No description provided for @examDayExamDayModeIsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Exam-Day Mode is unavailable'**
  String get examDayExamDayModeIsUnavailable;

  /// No description provided for @examDayTryLoadingYourSavedTarget.
  ///
  /// In en, this message translates to:
  /// **'Try loading your saved target again.'**
  String get examDayTryLoadingYourSavedTarget;

  /// No description provided for @examDayRetryExamDayMode.
  ///
  /// In en, this message translates to:
  /// **'Retry Exam-Day Mode'**
  String get examDayRetryExamDayMode;

  /// No description provided for @examDaySetOneActiveExamTarget.
  ///
  /// In en, this message translates to:
  /// **'Set one active exam target'**
  String get examDaySetOneActiveExamTarget;

  /// No description provided for @examDayKeepAPrivateCountdownLogistics.
  ///
  /// In en, this message translates to:
  /// **'Keep a private countdown, logistics checklist and optional local reminders on this phone.'**
  String get examDayKeepAPrivateCountdownLogistics;

  /// No description provided for @examDaySetExamTarget.
  ///
  /// In en, this message translates to:
  /// **'Set exam target'**
  String get examDaySetExamTarget;

  /// No description provided for @examDayYouProvideTheExamDetails.
  ///
  /// In en, this message translates to:
  /// **'You provide the exam details'**
  String get examDayYouProvideTheExamDetails;

  /// No description provided for @examDayExamtreeDoesNotInventExam.
  ///
  /// In en, this message translates to:
  /// **'ExamTree does not invent exam dates, reporting times, venues or readiness scores. Always verify saved details against the official notice or admit card.'**
  String get examDayExamtreeDoesNotInventExam;

  /// No description provided for @examDayReportingCountdown.
  ///
  /// In en, this message translates to:
  /// **'Reporting countdown'**
  String get examDayReportingCountdown;

  /// No description provided for @examDayUsefulNow.
  ///
  /// In en, this message translates to:
  /// **'Useful now'**
  String get examDayUsefulNow;

  /// No description provided for @examDayKeepTheLastMileActions.
  ///
  /// In en, this message translates to:
  /// **'Keep the last-mile actions focused and familiar.'**
  String get examDayKeepTheLastMileActions;

  /// No description provided for @examDaySavedLogistics.
  ///
  /// In en, this message translates to:
  /// **'Saved logistics'**
  String get examDaySavedLogistics;

  /// No description provided for @examDayOnlyTheDetailsYouEntered.
  ///
  /// In en, this message translates to:
  /// **'Only the details you entered for this target.'**
  String get examDayOnlyTheDetailsYouEntered;

  /// No description provided for @examDayEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get examDayEdit;

  /// No description provided for @examDayOfficialInstructionsRemainAuthoritative.
  ///
  /// In en, this message translates to:
  /// **'Official instructions remain authoritative'**
  String get examDayOfficialInstructionsRemainAuthoritative;

  /// No description provided for @examDayThisChecklistIsAPersonal.
  ///
  /// In en, this message translates to:
  /// **'This checklist is a personal aid. Always use the official notice or admit card for reporting time, documents, permitted items and venue rules.'**
  String get examDayThisChecklistIsAPersonal;

  /// No description provided for @examDayExam.
  ///
  /// In en, this message translates to:
  /// **'Exam'**
  String get examDayExam;

  /// No description provided for @examDayReporting.
  ///
  /// In en, this message translates to:
  /// **'Reporting'**
  String get examDayReporting;

  /// No description provided for @examDayVenueNote.
  ///
  /// In en, this message translates to:
  /// **'Venue note'**
  String get examDayVenueNote;

  /// No description provided for @examDayExamDayChecklist.
  ///
  /// In en, this message translates to:
  /// **'Exam-day checklist'**
  String get examDayExamDayChecklist;

  /// No description provided for @examDayRemoveCustomItem.
  ///
  /// In en, this message translates to:
  /// **'Remove custom item'**
  String get examDayRemoveCustomItem;

  /// No description provided for @examDayAddMyOwnItem.
  ///
  /// In en, this message translates to:
  /// **'Add my own item'**
  String get examDayAddMyOwnItem;

  /// No description provided for @examDayChooseAFutureExamDate.
  ///
  /// In en, this message translates to:
  /// **'Choose a future exam date and time.'**
  String get examDayChooseAFutureExamDate;

  /// No description provided for @examDayReportingTimeMustBeBefore.
  ///
  /// In en, this message translates to:
  /// **'Reporting time must be before the exam time.'**
  String get examDayReportingTimeMustBeBefore;

  /// No description provided for @examDaySaveOnlyTheDetailsYou.
  ///
  /// In en, this message translates to:
  /// **'Save only the details you want available on this device.'**
  String get examDaySaveOnlyTheDetailsYou;

  /// No description provided for @examDayExamName.
  ///
  /// In en, this message translates to:
  /// **'Exam name'**
  String get examDayExamName;

  /// No description provided for @examDayEGSscCglTier.
  ///
  /// In en, this message translates to:
  /// **'e.g. SSC CGL Tier I'**
  String get examDayEGSscCglTier;

  /// No description provided for @examDayExamDate.
  ///
  /// In en, this message translates to:
  /// **'Exam date'**
  String get examDayExamDate;

  /// No description provided for @examDayExamTime.
  ///
  /// In en, this message translates to:
  /// **'Exam time'**
  String get examDayExamTime;

  /// No description provided for @examDayReportingTimeOptional.
  ///
  /// In en, this message translates to:
  /// **'Reporting time (optional)'**
  String get examDayReportingTimeOptional;

  /// No description provided for @examDayClearReportingTime.
  ///
  /// In en, this message translates to:
  /// **'Clear reporting time'**
  String get examDayClearReportingTime;

  /// No description provided for @examDayVenueNoteOptional.
  ///
  /// In en, this message translates to:
  /// **'Venue note (optional)'**
  String get examDayVenueNoteOptional;

  /// No description provided for @examDaySaveTheVenueOrAddress.
  ///
  /// In en, this message translates to:
  /// **'Save the venue or address exactly as you want to remember it'**
  String get examDaySaveTheVenueOrAddress;

  /// No description provided for @examDayExamDayReminders.
  ///
  /// In en, this message translates to:
  /// **'Exam-day reminders'**
  String get examDayExamDayReminders;

  /// No description provided for @examDayRequestLocalNotificationsAbout24.
  ///
  /// In en, this message translates to:
  /// **'Request local notifications about 24 hours and 2 hours before the saved reporting or exam time.'**
  String get examDayRequestLocalNotificationsAbout24;

  /// No description provided for @examDaySaveExamTarget.
  ///
  /// In en, this message translates to:
  /// **'Save exam target'**
  String get examDaySaveExamTarget;

  /// No description provided for @accountReauthBody.
  ///
  /// In en, this message translates to:
  /// **'For your security, account deletion requires a recent sign-in. You will return here after signing in again.'**
  String get accountReauthBody;

  /// No description provided for @mySeriesMyTestSeries.
  ///
  /// In en, this message translates to:
  /// **'My Test Series'**
  String get mySeriesMyTestSeries;

  /// No description provided for @mySeriesHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get mySeriesHelp;

  /// No description provided for @mySeriesYouHavenTPurchasedAny.
  ///
  /// In en, this message translates to:
  /// **'You haven’t purchased any Test Series yet'**
  String get mySeriesYouHavenTPurchasedAny;

  /// No description provided for @mySeriesGetFullLengthMockTests.
  ///
  /// In en, this message translates to:
  /// **'Get full-length mock tests, sectional tests, previous year papers and detailed analysis to boost your preparation.'**
  String get mySeriesGetFullLengthMockTests;

  /// No description provided for @mySeriesYourAccessHasExpired.
  ///
  /// In en, this message translates to:
  /// **'Your access has expired'**
  String get mySeriesYourAccessHasExpired;

  /// No description provided for @mySeriesRenewToContinueTestsYour.
  ///
  /// In en, this message translates to:
  /// **'Renew to continue tests. Your progress and analytics are preserved.'**
  String get mySeriesRenewToContinueTestsYour;

  /// No description provided for @mySeriesTestsAttempted.
  ///
  /// In en, this message translates to:
  /// **'Tests Attempted'**
  String get mySeriesTestsAttempted;

  /// No description provided for @mySeriesTopicTests.
  ///
  /// In en, this message translates to:
  /// **'Topic Tests'**
  String get mySeriesTopicTests;

  /// No description provided for @mySeriesMySeries.
  ///
  /// In en, this message translates to:
  /// **'My Series'**
  String get mySeriesMySeries;

  /// No description provided for @mySeriesDownloads.
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get mySeriesDownloads;

  /// No description provided for @mySeriesHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get mySeriesHistory;

  /// No description provided for @mySeriesUnableToLoadYourTest.
  ///
  /// In en, this message translates to:
  /// **'Unable to load your test series.'**
  String get mySeriesUnableToLoadYourTest;

  /// No description provided for @orderOrderDetails.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get orderOrderDetails;

  /// No description provided for @orderPaymentSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Payment Successful'**
  String get orderPaymentSuccessful;

  /// No description provided for @orderYourTestSeriesIsNow.
  ///
  /// In en, this message translates to:
  /// **'Your Test Series is now active!'**
  String get orderYourTestSeriesIsNow;

  /// No description provided for @orderTransactionDetails.
  ///
  /// In en, this message translates to:
  /// **'Transaction Details'**
  String get orderTransactionDetails;

  /// No description provided for @orderOrderId.
  ///
  /// In en, this message translates to:
  /// **'Order ID'**
  String get orderOrderId;

  /// No description provided for @orderTransactionId.
  ///
  /// In en, this message translates to:
  /// **'Transaction ID'**
  String get orderTransactionId;

  /// No description provided for @orderStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get orderStatus;

  /// No description provided for @orderIncludedInYourAccess.
  ///
  /// In en, this message translates to:
  /// **'Included in your access'**
  String get orderIncludedInYourAccess;

  /// No description provided for @renewContinueYourPractice.
  ///
  /// In en, this message translates to:
  /// **'Continue your practice'**
  String get renewContinueYourPractice;

  /// No description provided for @renewGetLatestUpdates.
  ///
  /// In en, this message translates to:
  /// **'Get latest updates'**
  String get renewGetLatestUpdates;

  /// No description provided for @renewKeepYourProgress.
  ///
  /// In en, this message translates to:
  /// **'Keep your progress'**
  String get renewKeepYourProgress;

  /// No description provided for @renewDetailedSolutions.
  ///
  /// In en, this message translates to:
  /// **'Detailed solutions'**
  String get renewDetailedSolutions;

  /// No description provided for @storeBatchesAreNotPublishedYet.
  ///
  /// In en, this message translates to:
  /// **'Batches are not published yet'**
  String get storeBatchesAreNotPublishedYet;

  /// No description provided for @storeExamtreeWillShowBatchesHere.
  ///
  /// In en, this message translates to:
  /// **'ExamTree will show batches here only after real batch products, schedules and access rules are available.'**
  String get storeExamtreeWillShowBatchesHere;

  /// No description provided for @storePreparationProducts.
  ///
  /// In en, this message translates to:
  /// **'Preparation products'**
  String get storePreparationProducts;

  /// No description provided for @storePublishedTestSeriesAndFuture.
  ///
  /// In en, this message translates to:
  /// **'Published test series and future batches, clearly separated.'**
  String get storePublishedTestSeriesAndFuture;

  /// No description provided for @storeTestSeries.
  ///
  /// In en, this message translates to:
  /// **'Test series'**
  String get storeTestSeries;

  /// No description provided for @storeBatches.
  ///
  /// In en, this message translates to:
  /// **'Batches'**
  String get storeBatches;

  /// No description provided for @storeStoreCatalogueUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Store catalogue unavailable'**
  String get storeStoreCatalogueUnavailable;

  /// No description provided for @storeExamtreeCouldNotLoadPublished.
  ///
  /// In en, this message translates to:
  /// **'ExamTree could not load published products right now.'**
  String get storeExamtreeCouldNotLoadPublished;

  /// No description provided for @storeNoTestProductsOnSale.
  ///
  /// In en, this message translates to:
  /// **'No test products on sale'**
  String get storeNoTestProductsOnSale;

  /// No description provided for @storeThereAreNoActiveProducts.
  ///
  /// In en, this message translates to:
  /// **'There are no active products in the published catalogue right now. Free and already-accessible tests remain available under Tests.'**
  String get storeThereAreNoActiveProducts;

  /// No description provided for @storeViewTests.
  ///
  /// In en, this message translates to:
  /// **'View tests'**
  String get storeViewTests;

  /// No description provided for @storePricesValidityAndAvailabilityCome.
  ///
  /// In en, this message translates to:
  /// **'Prices, validity and availability come from the published ExamTree catalogue. Mobile checkout is not connected yet, so this screen does not create a purchase action.'**
  String get storePricesValidityAndAvailabilityCome;

  /// No description provided for @learnSubReadyLessons.
  ///
  /// In en, this message translates to:
  /// **'Ready lessons'**
  String get learnSubReadyLessons;

  /// No description provided for @learnSubChapters.
  ///
  /// In en, this message translates to:
  /// **'Chapters'**
  String get learnSubChapters;

  /// No description provided for @learnSubReading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get learnSubReading;

  /// No description provided for @learnSubModuleUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Module unavailable'**
  String get learnSubModuleUnavailable;

  /// No description provided for @learnSubChooseATopicArea.
  ///
  /// In en, this message translates to:
  /// **'Choose a topic area'**
  String get learnSubChooseATopicArea;

  /// No description provided for @learnSubOpenAnAreaToContinue.
  ///
  /// In en, this message translates to:
  /// **'Open an area to continue learning and practice.'**
  String get learnSubOpenAnAreaToContinue;

  /// No description provided for @learnSubUntimed.
  ///
  /// In en, this message translates to:
  /// **'Untimed'**
  String get learnSubUntimed;

  /// No description provided for @learnSubComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get learnSubComingSoon;

  /// No description provided for @learnSubSubModuleUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Sub-module unavailable'**
  String get learnSubSubModuleUnavailable;

  /// No description provided for @learnSubVocabulary.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary'**
  String get learnSubVocabulary;

  /// No description provided for @learnSubBuildStrongerWordPowerWith.
  ///
  /// In en, this message translates to:
  /// **'Build stronger word power with focused practice.'**
  String get learnSubBuildStrongerWordPowerWith;

  /// No description provided for @learnSubBuildVocabularyWithShortUntimed.
  ///
  /// In en, this message translates to:
  /// **'Build vocabulary with short untimed sessions. Every answer is checked immediately and followed by an explanation.'**
  String get learnSubBuildVocabularyWithShortUntimed;

  /// No description provided for @learnSubPracticeMappingForThisSub.
  ///
  /// In en, this message translates to:
  /// **'Practice mapping for this sub-module is being connected to Question Studio.'**
  String get learnSubPracticeMappingForThisSub;

  /// No description provided for @learnSubPolity.
  ///
  /// In en, this message translates to:
  /// **'Polity'**
  String get learnSubPolity;

  /// No description provided for @learnSubIndianConstitutionInstitutionsAndGovernance.
  ///
  /// In en, this message translates to:
  /// **'Indian Constitution, institutions and governance.'**
  String get learnSubIndianConstitutionInstitutionsAndGovernance;

  /// No description provided for @learnSubChooseAChapterToRead.
  ///
  /// In en, this message translates to:
  /// **'Choose a chapter to read the notes or start a short untimed practice session. Answers and explanations appear immediately after each question.'**
  String get learnSubChooseAChapterToRead;

  /// No description provided for @learnSub1520QuestionsUntimed.
  ///
  /// In en, this message translates to:
  /// **'15–20 questions · Untimed'**
  String get learnSub1520QuestionsUntimed;

  /// No description provided for @learnSubReviewLesson.
  ///
  /// In en, this message translates to:
  /// **'Review lesson'**
  String get learnSubReviewLesson;

  /// No description provided for @learnSubPracticeTopicUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Practice topic unavailable'**
  String get learnSubPracticeTopicUnavailable;

  /// No description provided for @learnSubPracticeQuestionsAreNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Practice questions are not available for this topic yet.'**
  String get learnSubPracticeQuestionsAreNotAvailable;

  /// No description provided for @learnSubUnableToLoadPracticeQuestions.
  ///
  /// In en, this message translates to:
  /// **'Unable to load practice questions right now. Your Learn progress is safe.'**
  String get learnSubUnableToLoadPracticeQuestions;

  /// No description provided for @learnSubSubmitPractice.
  ///
  /// In en, this message translates to:
  /// **'Submit practice?'**
  String get learnSubSubmitPractice;

  /// No description provided for @learnSubKeepPracticing.
  ///
  /// In en, this message translates to:
  /// **'Keep practicing'**
  String get learnSubKeepPracticing;

  /// No description provided for @learnSubSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get learnSubSubmit;

  /// No description provided for @learnSubBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get learnSubBack;

  /// No description provided for @learnSubPracticeResult.
  ///
  /// In en, this message translates to:
  /// **'Practice result'**
  String get learnSubPracticeResult;

  /// No description provided for @learnSubAllTopics.
  ///
  /// In en, this message translates to:
  /// **'All topics'**
  String get learnSubAllTopics;

  /// No description provided for @learnSubSuggestedNextTopic.
  ///
  /// In en, this message translates to:
  /// **'Suggested next topic'**
  String get learnSubSuggestedNextTopic;

  /// No description provided for @learnSub20QuestionsUntimedInstantExplanations.
  ///
  /// In en, this message translates to:
  /// **'20 questions · Untimed · Instant explanations'**
  String get learnSub20QuestionsUntimedInstantExplanations;
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
