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

  @override
  String get attemptNoQuestions => 'No questions available';

  @override
  String get attemptSignInRequired => 'Sign in required. Redirecting...';

  @override
  String get attemptPurchaseRequired =>
      'Purchase required to access this test.';

  @override
  String attemptLoadFailed(String error) {
    return 'Unable to load test: $error';
  }

  @override
  String get attemptRecoveredLocal =>
      'Unsynced progress was recovered from this device. Syncing it to ExamTree now.';

  @override
  String get attemptRestoredServer => 'Saved progress restored from ExamTree.';

  @override
  String get attemptTenMinutes => '10 minutes remaining';

  @override
  String get attemptFiveMinutes => '5 minutes remaining';

  @override
  String get attemptOneMinute => '1 minute remaining. Finish your review now.';

  @override
  String attemptSecondsRemaining(int seconds) {
    return '$seconds seconds remaining';
  }

  @override
  String get attemptTimeOverSubmitting =>
      'Time is over. Your test is being submitted.';

  @override
  String get attemptChangedElsewhere =>
      'This test changed on another device. The latest server progress was loaded.';

  @override
  String get attemptSavedNotSynced =>
      'Progress is saved on this device but has not reached ExamTree yet.';

  @override
  String get attemptTimeOverRetry =>
      'Time is over. Your answers are safe on this device; reconnect and retry submission.';

  @override
  String get attemptSubmitFailed =>
      'Unable to submit right now. Your answers remain saved; try again.';

  @override
  String get attemptStillOpen =>
      'The test remains open because the latest progress could not be saved.';

  @override
  String get attemptPreparing => 'Preparing your secure test session...';

  @override
  String get attemptUnableToStart => 'Unable to start test';

  @override
  String get attemptSessionNotCreated =>
      'The attempt session could not be created.';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get attemptTimeExpiredSubmitting =>
      'Time expired — submitting your test';

  @override
  String get attemptSubmittingTest => 'Submitting your test';

  @override
  String get attemptLockedPending =>
      'Time expired. Answers are locked and submission is pending.';

  @override
  String get attemptRetrySubmit => 'Retry submit';

  @override
  String get attemptSaveAnswer => 'Save answer';

  @override
  String get attemptSaveNext => 'Save & next';

  @override
  String attemptPaletteLeft(int count) {
    return 'Palette · $count left';
  }

  @override
  String get attemptSubmitting => 'Submitting…';

  @override
  String get attemptSubmitTest => 'Submit test';

  @override
  String attemptQuestionOf(int number, int total) {
    return 'Question $number of $total';
  }

  @override
  String get attemptNotSavedRetry => 'Progress not saved. Retry.';

  @override
  String get attemptSavingProgress => 'Saving progress';

  @override
  String get attemptSaveExit => 'Save and exit';

  @override
  String attemptQuestionNumber(int number) {
    return 'Question $number';
  }

  @override
  String get attemptMarkedForReview => 'Marked for review';

  @override
  String attemptOptionLabel(String letter, String text) {
    return 'Option $letter: $text';
  }

  @override
  String get attemptPrevious => 'Previous';

  @override
  String get attemptClear => 'Clear';

  @override
  String get attemptReview => 'Review';

  @override
  String get attemptSubmitQuestion => 'Submit test?';

  @override
  String attemptUnansweredLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count unanswered questions are still left. You can review them before submitting.',
      one:
          '1 unanswered question is still left. You can review it before submitting.',
    );
    return '$_temp0';
  }

  @override
  String get attemptCannotChange =>
      'After submission, answers cannot be changed.';

  @override
  String get attemptReviewUnanswered => 'Review unanswered';

  @override
  String get attemptSubmitNow => 'Submit now';

  @override
  String get attemptContinueTest => 'Continue test';

  @override
  String get attemptAnswered => 'Answered';

  @override
  String get attemptUnanswered => 'Unanswered';

  @override
  String get attemptAnsweredMarked => 'Answered + marked';

  @override
  String get attemptSyncNeededTitle => 'Progress still needs to sync';

  @override
  String get attemptSyncNeededBody =>
      'Your latest answers are safe on this device, but they have not reached ExamTree yet. Retry saving before leaving.';

  @override
  String get attemptSavingTitle => 'Saving your progress';

  @override
  String get attemptSavingBody =>
      'ExamTree is still saving your latest changes. Keep the test open until this save finishes.';

  @override
  String get attemptLeaveTitle => 'Save and leave test?';

  @override
  String get attemptLeaveBody =>
      'Your attempt will stay active and can be resumed later from this device or the ExamTree website.';

  @override
  String get attemptRetrySave => 'Retry save';

  @override
  String get attemptSaveLeave => 'Save and leave';

  @override
  String get attemptStay => 'Stay';

  @override
  String get attemptSavingEllipsis => 'Saving progress…';

  @override
  String get attemptWaitingSync =>
      'Saved on this device. Waiting to sync with ExamTree.';

  @override
  String get attemptNotSyncedYet =>
      'Latest changes are safe on this device but not synced yet.';

  @override
  String get paletteTitle => 'Question palette';

  @override
  String get paletteClose => 'Close palette';

  @override
  String get paletteMarked => 'Marked';

  @override
  String paletteUnansweredCount(int count) {
    return 'Unanswered $count';
  }

  @override
  String paletteMarkedCount(int count) {
    return 'Marked $count';
  }

  @override
  String get paletteHint => 'Tap a number to jump directly to that question.';

  @override
  String get paletteNoMatch => 'No questions match this filter.';

  @override
  String get paletteShowAll => 'Show all questions';

  @override
  String get resultTitle => 'Result';

  @override
  String get resultLoadFailed => 'Unable to load this result';

  @override
  String get resultTestResult => 'Test result';

  @override
  String resultQuestionsCount(int count) {
    return '$count questions';
  }

  @override
  String resultMarks(String marks) {
    return '$marks marks';
  }

  @override
  String get resultRank => 'Rank';

  @override
  String get resultAccuracy => 'Accuracy';

  @override
  String resultXofY(int x, int y) {
    return '$x of $y';
  }

  @override
  String get resultTime => 'Time';

  @override
  String get resultSpent => 'spent';

  @override
  String get resultAttempted => 'Attempted';

  @override
  String resultOfTotal(int total) {
    return 'of $total';
  }

  @override
  String resultScoreA11y(String score, String max) {
    return 'Score $score out of $max.';
  }

  @override
  String resultDelta(String delta) {
    return '$delta pts vs your last attempt';
  }

  @override
  String resultLastAttempts(int count) {
    return 'Your last $count attempts';
  }

  @override
  String get resultTrendSubtitle => 'Score as a percentage of the maximum.';

  @override
  String get resultCorrect => 'Correct';

  @override
  String get resultWrong => 'Wrong';

  @override
  String get resultSkipped => 'Skipped';

  @override
  String resultHowWent(int total) {
    return 'How your $total questions went';
  }

  @override
  String resultQuickestWin(String section) {
    return 'Quickest win: $section. ';
  }

  @override
  String resultSkippedMost(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'You skipped $count questions there, more than in any other section.',
      one: 'You skipped 1 question there, more than in any other section.',
    );
    return '$_temp0';
  }

  @override
  String resultAccuracyValue(String value) {
    return 'Accuracy $value';
  }

  @override
  String resultTimeShare(String section, int share) {
    return '$section took $share% of your time.';
  }

  @override
  String resultTimeShareAccuracy(String section, int share, int accuracy) {
    return '$section took $share% of your time at $accuracy% accuracy.';
  }

  @override
  String resultLowestAccuracy(String section, int accuracy) {
    return '$section had your lowest accuracy, $accuracy%.';
  }

  @override
  String resultLowestAccuracyShare(String section, int accuracy, int share) {
    return '$section had your lowest accuracy, $accuracy%, on $share% of your time.';
  }

  @override
  String get resultAccuracyVsTime => 'Accuracy vs time spent';

  @override
  String get resultAccuracyVsTimeSubtitle =>
      'Is your time going where your marks are?';

  @override
  String get resultShareOfTime => 'Share of your time';

  @override
  String get resultTimePerQuestion => 'Time per question';

  @override
  String get resultTimePerQuestionSubtitle =>
      'One bar per question, in the order of the paper.';

  @override
  String resultSlowest(String section, int number, String time) {
    return 'Slowest question: $section Q$number at $time.';
  }

  @override
  String get resultQuestionMap => 'Question map';

  @override
  String get resultReviewSolutions => 'Review solutions';

  @override
  String get resultReviseMistakes => 'Revise mistakes (5 min)';

  @override
  String get resultRetake => 'Retake test';

  @override
  String get resultsHistoryLoadFailed => 'Unable to load your attempt history';

  @override
  String get resultsSearchHint => 'Search tests or exam categories';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get resultsAttemptHistory => 'Attempt history';

  @override
  String get resultsAverageScore => 'Average score';

  @override
  String resultsAttemptsCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count attempts completed',
      one: '1 attempt completed',
    );
    return '$_temp0';
  }

  @override
  String get resultsBestScore => 'Best score';

  @override
  String get resultsFindAttempt => 'Find an attempt';

  @override
  String get resultsFindHint =>
      'Review mistakes before deciding what to retake.';

  @override
  String get reset => 'Reset';

  @override
  String get resultsAllExams => 'All exams';

  @override
  String get resultsSort => 'Sort results';

  @override
  String get resultsSortNewest => 'Newest';

  @override
  String get resultsSortHighestScore => 'Highest score';

  @override
  String get resultsSortHighestAccuracy => 'Highest accuracy';

  @override
  String get resultsReviewMistakes => 'Review mistakes';

  @override
  String get resultsReviewAnswers => 'Review answers';

  @override
  String get resultsRetake => 'Retake';

  @override
  String resultsAccuracyPct(String value) {
    return '$value% accuracy';
  }

  @override
  String resultsCorrectCount(int count) {
    return '$count correct';
  }

  @override
  String resultsIncorrectCount(int count) {
    return '$count incorrect';
  }

  @override
  String resultsSkippedCount(int count) {
    return '$count skipped';
  }

  @override
  String resultsScorePercentA11y(String value) {
    return 'Score $value percent';
  }

  @override
  String get resultsEmptyTitle => 'No completed attempts yet';

  @override
  String get resultsEmptyBody =>
      'Complete your first test to unlock score history, accuracy and answer review.';

  @override
  String get resultsExploreTests => 'Explore tests';

  @override
  String get resultsNoMatchTitle => 'No attempts match these filters';

  @override
  String get resultsNoMatchBody =>
      'Try another test name, category or sort order.';

  @override
  String get resultsResetFilters => 'Reset filters';

  @override
  String get dateUnavailable => 'Date unavailable';

  @override
  String get examsCategoriesLoadFailed => 'Unable to load exam categories';

  @override
  String get examsTitle => 'Exams';

  @override
  String get examsLoadFailed => 'Unable to load exams';

  @override
  String examsSearchIn(String category) {
    return 'Search $category exams';
  }

  @override
  String examsCategoryExams(String category) {
    return '$category Exams';
  }

  @override
  String examsAvailable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exams available',
      one: '1 exam available',
    );
    return '$_temp0';
  }

  @override
  String get examsTestSeries => 'Test Series';

  @override
  String get examsSeriesLoadFailed => 'Unable to load test series';

  @override
  String get examsAvailableSeries => 'Available Test Series';

  @override
  String get examsNoActiveSeries => 'No active test series yet';

  @override
  String examsSeriesAvailable(int count) {
    return '$count series available';
  }

  @override
  String get examsSearchCategories => 'Search exam categories';

  @override
  String get examsCategories => 'Exam Categories';

  @override
  String get examsChooseCategory =>
      'Choose a category to find the exam you are preparing for.';

  @override
  String get examsChoosePath => 'Choose your exam path';

  @override
  String get examsChoosePathBody =>
      'Open a category, choose your exam and continue to its test series.';

  @override
  String examsCategoriesCount(int count) {
    return '$count categories';
  }

  @override
  String examsExamsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exams',
      one: '1 exam',
    );
    return '$_temp0';
  }

  @override
  String examsSeriesCount(int count) {
    return '$count series';
  }

  @override
  String examsLiveTests(int count) {
    return '$count live tests';
  }

  @override
  String examsTestsCount(int count) {
    return '$count tests';
  }

  @override
  String examsTestSeriesCount(int count) {
    return '$count test series';
  }

  @override
  String examsFullMocks(int count) {
    return '$count full mocks';
  }

  @override
  String examsMinPerTest(int minutes) {
    return '~$minutes min/test';
  }

  @override
  String get examsViewTestSeries => 'View Test Series';

  @override
  String get examsNoQuestionsYet => 'No questions yet';

  @override
  String get examsViewDetails => 'View Details';

  @override
  String get examsViewSeries => 'View Series';

  @override
  String get examsEmptyCatalogueTitle =>
      'No exam categories are published yet.';

  @override
  String get examsEmptyCatalogueBody => 'Pull down to check again.';

  @override
  String get examsNoCategoryMatchTitle =>
      'No exam category matches your search.';

  @override
  String get examsNoCategoryMatchBody =>
      'Try another exam family or clear the search.';

  @override
  String get examsNoExamMatchTitle => 'No exams match this search.';

  @override
  String get examsNoExamMatchBody =>
      'Try a shorter exam name or clear the search.';

  @override
  String get examsCategoryUnavailableTitle => 'Exam category unavailable';

  @override
  String get examsCategoryUnavailableBody =>
      'Open the category again from the Exams page.';

  @override
  String get examsExamUnavailableTitle => 'Exam unavailable';

  @override
  String get examsExamUnavailableBody =>
      'Open the exam again from its category.';

  @override
  String examsNoneInCategoryTitle(String category) {
    return 'No $category exams are published yet.';
  }

  @override
  String get examsNoneInCategoryBody =>
      'New exams will appear here automatically when published.';

  @override
  String get examsNoSeriesTitle => 'No test series available yet';

  @override
  String get examsNoSeriesBody =>
      'Published test series for this exam will appear here automatically.';
}
