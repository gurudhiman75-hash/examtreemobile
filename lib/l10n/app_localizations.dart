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
