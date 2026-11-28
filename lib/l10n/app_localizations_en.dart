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

  @override
  String get learnCurrentAffairs => 'Current affairs';

  @override
  String get learnCurrentAffairsSubtitle =>
      'Fresh published updates for quick revision.';

  @override
  String get learnFreePractice => 'Free practice';

  @override
  String get learnFreePracticeSubtitle =>
      'Turn reading into an immediate test session.';

  @override
  String get learnAllTests => 'All tests';

  @override
  String get learnNotes => 'Notes & formula sheets';

  @override
  String get learnNotesSubtitle => 'Focused material published for your exams.';

  @override
  String get learnHeroTitle => 'Learn for your exams';

  @override
  String get learnHeroBody =>
      'Current affairs, notes and free practice selected from what is actually published for you.';

  @override
  String get learnArticle => 'Article';

  @override
  String learnMinFree(int minutes) {
    return '$minutes min · Free';
  }

  @override
  String get learnLoadFailed => 'Unable to load free learning';

  @override
  String get learnEmpty =>
      'No free learning resources are published yet. Published material will appear here automatically.';

  @override
  String get learnPartialRefresh =>
      'Some learning content could not be refreshed. The items shown above are still available.';

  @override
  String get learnOpenFailed => 'This resource could not be opened.';

  @override
  String get learnSelectedExams => 'Selected exams';

  @override
  String get homeExamCategories => 'Exam Categories';

  @override
  String get homeSeeAll => 'See All';

  @override
  String get homeCategoriesFailed => 'Exam categories could not be loaded';

  @override
  String get homeNoCategories => 'No exam categories are published right now.';

  @override
  String get homeFeaturedSeries => 'Featured Test Series';

  @override
  String get homeSeriesFailed => 'Test series could not be loaded';

  @override
  String get homeContinueLearning => 'Continue Learning';

  @override
  String get homeRecommendedLearning => 'Recommended Learning';

  @override
  String get homeCurrentAffairs => 'Current Affairs';

  @override
  String get homeProgressUnavailable => 'Progress is temporarily unavailable';

  @override
  String get familyPunjab => 'Punjab Govt.';

  @override
  String get familyBanking => 'Banking';

  @override
  String get familyRailway => 'Railway';

  @override
  String get familyTeaching => 'Teaching';

  @override
  String get familyDefence => 'Defence';

  @override
  String get familyStatePcs => 'State PCS';

  @override
  String get familyOther => 'Other Exams';

  @override
  String get homeExplore => 'Explore';

  @override
  String get homeTests => 'Tests';

  @override
  String get homeMins => 'Mins';

  @override
  String get homeMarks => 'Marks';

  @override
  String get homeQuestions => 'Questions';

  @override
  String get homeDuration => 'Duration';

  @override
  String minutesShort(int minutes) {
    return '$minutes min';
  }

  @override
  String get homeHeroTitle => 'Your Preparation\nStarts Here';

  @override
  String get homeHeroBody =>
      'Mock tests, learning and exam-focused practice in one place.';

  @override
  String get homeSearchHint => 'Search exams, test series, topics...';

  @override
  String get homeContinueUnavailable =>
      'Continue learning is temporarily unavailable';

  @override
  String get homeKeepGoing => 'Keep Going!';

  @override
  String homeTestsCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tests completed so far.',
      one: '1 test completed so far.',
    );
    return '$_temp0';
  }

  @override
  String get homeSearchTests => 'Search tests';

  @override
  String get homeOpenProfile => 'Open profile';

  @override
  String homeNotificationsUnreadA11y(int count) {
    return 'Notifications, $count unread';
  }

  @override
  String get homeNotificationsNoneA11y => 'Notifications, no unread updates';

  @override
  String homeNotificationsUnread(int count) {
    return 'Notifications ($count unread)';
  }

  @override
  String get homeNotifications => 'Notifications';

  @override
  String get homeNextActionFailed => 'Your next action could not be prepared';

  @override
  String get homeLearn => 'Learn';

  @override
  String get homeRevision => 'Revision';

  @override
  String get homeStore => 'Store';

  @override
  String get homeStrongMomentum => 'Strong momentum';

  @override
  String get homeKeepConsistency => 'Keep building consistency';

  @override
  String get homeFocusAccuracy => 'Focus on accuracy first';

  @override
  String get homeAvgScore => 'Avg score';

  @override
  String get homePerQuestion => 'Per question';

  @override
  String homeQs(int count) {
    return '$count Qs';
  }

  @override
  String get homeNoTests => 'No tests are published right now.';

  @override
  String get homeCaughtUp => 'You are caught up on current recommendations.';

  @override
  String get homeBrowse => 'Browse';

  @override
  String homeScorePct(int value) {
    return '$value% score';
  }

  @override
  String homeAccuracyPct(int value) {
    return '$value% accuracy';
  }

  @override
  String homeDue(int count) {
    return '$count due';
  }

  @override
  String get homeStudent => 'Student';

  @override
  String get homeGoodMorning => 'Good morning';

  @override
  String get homeGoodAfternoon => 'Good afternoon';

  @override
  String get homeGoodEvening => 'Good evening';

  @override
  String get storeEnterCoupon => 'Enter a coupon code first.';

  @override
  String storeCouponApplied(String amount) {
    return 'Coupon applied • Save $amount';
  }

  @override
  String get storeChoosePlan => 'Choose Plan';

  @override
  String get storePlansFailed => 'Unable to load plans';

  @override
  String get storeAlreadyActive => 'This test series is already active.';

  @override
  String get storeOpenTestSeries => 'Open Test Series';

  @override
  String get storeNoPlan => 'No purchase plan is available right now.';

  @override
  String storePremiumFree(int premium, int free) {
    return '$premium premium tests • $free free';
  }

  @override
  String get storeChooseAccessPlan => 'Choose your access plan';

  @override
  String get storePublishedOnly => 'Only currently published plans are shown.';

  @override
  String get storeHaveCoupon => 'Have a coupon?';

  @override
  String get storeCouponHint => 'Enter coupon code';

  @override
  String get storeApply => 'Apply';

  @override
  String get storeSelectedPlan => 'Selected plan';

  @override
  String get continueLabel => 'Continue';

  @override
  String storeTestsIncluded(int count) {
    return '$count series tests included';
  }

  @override
  String storePercentOff(int percent) {
    return '$percent% OFF';
  }

  @override
  String get storeOpenPaymentFailed => 'Unable to open secure payment.';

  @override
  String get storeIncompleteConfirmation =>
      'Payment returned incomplete confirmation details. Please verify again.';

  @override
  String get storePaymentNotCompleted => 'Payment was not completed.';

  @override
  String get storeContinueWallet =>
      'Continue in your wallet to complete payment.';

  @override
  String storeContinueInWallet(String wallet) {
    return 'Continue in $wallet to complete payment.';
  }

  @override
  String get storeActivationProcessing =>
      'Payment was received but activation is still processing. Tap Verify Payment.';

  @override
  String get storeCheckout => 'Checkout';

  @override
  String get storeCheckoutFailed => 'Unable to load checkout';

  @override
  String get storePlanUnavailable => 'This plan is no longer available.';

  @override
  String get storeReviewPay => 'Review & Pay';

  @override
  String get storeCouponRevalidate =>
      'Coupon could not be revalidated. Go back and apply it again.';

  @override
  String get storeVerifyPayment => 'Verify Payment';

  @override
  String storePayAmount(String amount) {
    return 'Pay $amount';
  }

  @override
  String get storeOrderSummary => 'Order Summary';

  @override
  String storeAccess(String validity) {
    return '$validity access';
  }

  @override
  String get storePlanPrice => 'Plan price';

  @override
  String get storeCouponDiscount => 'Coupon discount';

  @override
  String get storeTotalPayable => 'Total Payable';

  @override
  String get storeUpiCards => 'UPI, Cards & More';

  @override
  String get storeRazorpayBody =>
      'Choose UPI, card, net banking or wallet in secure Razorpay Checkout.';

  @override
  String storeCouponSaved(String code, String amount) {
    return '$code applied • You save $amount';
  }

  @override
  String get storeActivating => 'Activating your test series…';

  @override
  String get storeKeepOpen =>
      'Please keep this screen open while we verify your payment.';

  @override
  String get storeRazorpayNote =>
      'Payment is processed securely by Razorpay. Examtree never stores your card or UPI credentials.';

  @override
  String get validityAsPublished => 'Validity as published';

  @override
  String validityMonths(int count) {
    return '$count Months';
  }

  @override
  String validityDays(int count) {
    return '$count Days';
  }

  @override
  String get paySuccessTitle => 'Payment Successful!';

  @override
  String get paySuccessBody =>
      'Your test series has been unlocked and is ready for your preparation.';

  @override
  String get payAccessActive => 'Access Active';

  @override
  String get payActive => 'Active';

  @override
  String get payMockTests => 'Mock Tests';

  @override
  String get payMockTestsBody => 'Full access to your purchased series';

  @override
  String get payAnalysis => 'Detailed Analysis';

  @override
  String get payAnalysisBody => 'Track attempts, accuracy and progress';

  @override
  String get payBilingual => 'Bilingual Content';

  @override
  String get payBilingualBody =>
      'Use supported languages throughout the series';

  @override
  String get paySolutions => 'Detailed Solutions';

  @override
  String get paySolutionsBody => 'Review explanations after every attempt';

  @override
  String get paySafe => 'Your Progress is Safe';

  @override
  String get paySafeBody =>
      'Attempts, analytics and bookmarks are preserved with your access.';

  @override
  String get payStart => 'Start Learning Now';

  @override
  String get payStartBody =>
      'Continue from where you left off and keep your preparation on track.';

  @override
  String get payOrder => 'Order';

  @override
  String get payViewReceipt => 'View Receipt';

  @override
  String get readyTitle => 'You’re All Set!';

  @override
  String get readyBody =>
      'Your ExamTree test series is active and ready to use.';

  @override
  String get readyOpen => 'Open your Test Series';

  @override
  String get readyOpenBody =>
      'Your purchased series now appears in My Test Series.';

  @override
  String get readyChoose => 'Choose a test';

  @override
  String get readyChooseBody =>
      'Start with a full mock, sectional, PYQ or topic-wise test.';

  @override
  String get readyTrack => 'Track your performance';

  @override
  String get readyTrackBody =>
      'Review scores, accuracy, attempts and progress from your Profile.';

  @override
  String get readyGoMySeries => 'Go to My Test Series';

  @override
  String get readyViewOrder => 'View Order Details';

  @override
  String get seriesLockedTitle => 'This Test is Locked';

  @override
  String seriesFreeAvailable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count free tests are available in this series.',
      one: '1 free test is available in this series.',
    );
    return '$_temp0';
  }

  @override
  String get seriesTryFree => 'Try Free Test';

  @override
  String get seriesViewPlansUnlock => 'View Plans & Unlock';

  @override
  String get seriesMaybeLater => 'Maybe Later';

  @override
  String seriesStructuredPractice(String exam) {
    return 'Structured mock-test practice for $exam.';
  }

  @override
  String get seriesComingSoon => 'COMING SOON';

  @override
  String get seriesActive => 'ACTIVE';

  @override
  String get seriesUnavailable => 'UNAVAILABLE';

  @override
  String get seriesInPreparation => 'Content in preparation';

  @override
  String seriesPercentComplete(int percent) {
    return '$percent% complete';
  }

  @override
  String seriesTestsFraction(int done, int total) {
    return '$done/$total tests';
  }

  @override
  String get seriesPracticeTime => 'Practice time';

  @override
  String get seriesProgress => 'Progress';

  @override
  String get seriesTabOverview => 'Overview';

  @override
  String get seriesTabTestList => 'Test List';

  @override
  String get seriesTabSyllabus => 'Syllabus';

  @override
  String get seriesTabPattern => 'Exam Pattern';

  @override
  String get seriesTabReviews => 'Reviews';

  @override
  String get seriesTabFaqs => 'FAQs';

  @override
  String get seriesSequential => 'Sequential progression';

  @override
  String get seriesScoreGated => 'Score-gated progression';

  @override
  String get seriesOpenProgression => 'Open progression';

  @override
  String get seriesAbout => 'About this series';

  @override
  String seriesOrganisedFor(String exam) {
    return 'This series is organised for structured $exam practice.';
  }

  @override
  String get seriesIncluded => 'What’s included';

  @override
  String seriesRequired(int count) {
    return '$count required';
  }

  @override
  String get seriesWhyChoose => 'Why choose this series';

  @override
  String get seriesWhyProgress => 'Progress tracking';

  @override
  String get seriesWhyProgressBody =>
      'Completed tests and your next eligible test stay visible.';

  @override
  String get seriesWhyUnlock => 'Clear unlock rules';

  @override
  String get seriesWhyUnlockBody =>
      'Scheduled and progression-based locks are shown before you open a test.';

  @override
  String get seriesWhyInstructions => 'Instructions before attempt';

  @override
  String get seriesWhyInstructionsBody =>
      'Each unlocked test opens its details and instructions before the timer starts.';

  @override
  String get seriesNoTests =>
      'No tests are currently available in this series.';

  @override
  String seriesTypeCountA11y(String label, int count) {
    return '$label, $count tests';
  }

  @override
  String get seriesNoPattern => 'No test pattern is available yet.';

  @override
  String get seriesPattern => 'Series pattern';

  @override
  String seriesMinTotal(int minutes) {
    return '$minutes min total';
  }

  @override
  String get seriesBreakdown => 'Test-wise breakdown';

  @override
  String seriesSyllabusBody(String exam) {
    return 'Complete topic-wise preparation coverage for $exam. Test groups below are derived from the published series catalogue.';
  }

  @override
  String get seriesSyllabusEmpty =>
      'Syllabus will appear as tests are published.';

  @override
  String seriesPublishedTestsQuestions(int tests, int questions) {
    return '$tests published tests · $questions questions';
  }

  @override
  String get seriesReviewsEmpty =>
      'Learner reviews will appear here when published reviews are available.';

  @override
  String get seriesStudentReviews => 'Student Reviews';

  @override
  String seriesRatedReviews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rated reviews',
      one: '1 rated review',
    );
    return '$_temp0';
  }

  @override
  String get faqIncludedQ => 'What is included in this test series?';

  @override
  String faqIncludedA(int tests, int questions) {
    return '$tests published tests with $questions total questions, subject to the live catalogue and your access plan.';
  }

  @override
  String get faqExplanationsQ => 'Are explanations available?';

  @override
  String get faqExplanationsA =>
      'Completed attempts can be reviewed with the explanation and analysis supported by the test.';

  @override
  String get faqMultipleQ => 'Can I attempt a test multiple times?';

  @override
  String get faqMultipleA =>
      'Attempt limits are shown on the Test Instructions page and are enforced by the test configuration.';

  @override
  String get faqLanguageQ => 'Can I change the question language?';

  @override
  String get faqLanguageA =>
      'Supported languages are shown before starting the test. Availability depends on the published question content.';

  @override
  String get faqExpiryQ => 'What happens when my access expires?';

  @override
  String get faqExpiryA =>
      'You can renew the series from My Test Series. Existing progress and analytics remain tied to your account.';

  @override
  String get faqPreviousQ => 'Where can I see my previous attempts?';

  @override
  String get faqPreviousA =>
      'Use My Test Series, Profile or Results to revisit completed attempts and performance information.';

  @override
  String get seriesYourProgress => 'Your series progress';

  @override
  String seriesCompletedOf(int done, int total) {
    return '$done of $total tests completed';
  }

  @override
  String get typeFullTitle => 'Full Length Mock Tests';

  @override
  String get typeFullSubtitle => 'Latest pattern full syllabus tests';

  @override
  String get typeSectionalTitle => 'Sectional Tests';

  @override
  String get typeSectionalSubtitle => 'Subject-wise practice tests';

  @override
  String get typeTopicTitle => 'Topic-wise Tests';

  @override
  String get typeTopicSubtitle => 'Focused practice on important topics';

  @override
  String get typePyqTitle => 'Previous Year Papers';

  @override
  String get typePyqSubtitle => 'Previous exam papers with review';

  @override
  String get typeFullTab => 'Full';

  @override
  String get typeSectionalTab => 'Sectional';

  @override
  String get typeTopicTab => 'Topic-wise';

  @override
  String get typePyqTab => 'PYQs';

  @override
  String get seriesStateCompleted => 'Completed';

  @override
  String get seriesStatePremium => 'Premium';

  @override
  String get seriesStateReady => 'Ready';

  @override
  String get seriesStateLocked => 'Locked';

  @override
  String get seriesOptional => 'Optional';

  @override
  String get seriesRequiredTag => 'Required';

  @override
  String seriesBestScore(String score) {
    return 'Best score: $score';
  }

  @override
  String get seriesOpenAgain => 'Open test again';

  @override
  String get seriesViewInstructions => 'View instructions';

  @override
  String get seriesUnlockPremium => 'Unlock premium tests';

  @override
  String get seriesProgressLabel => 'Series progress';

  @override
  String get seriesStatus => 'Series status';

  @override
  String get seriesUpNext => 'Up next';

  @override
  String get seriesPremiumRequired => 'Premium access required';

  @override
  String seriesFromPrice(String price) {
    return 'From $price';
  }

  @override
  String get seriesAllCompleted => 'All tests completed';

  @override
  String get seriesNoneAvailable => 'No test is available yet';

  @override
  String get seriesViewPlans => 'View Plans';

  @override
  String get seriesReviewTests => 'Review Tests';

  @override
  String get seriesOpenTest => 'Open Test';

  @override
  String get seriesLoadFailed => 'Test series could not be loaded.';

  @override
  String get seriesCheckConnection => 'Check your connection and try again.';

  @override
  String get loginLetSBuildYourExam => 'Let’s build your exam success';

  @override
  String get loginMasterConceptsPracticeSmarterGet =>
      'Master concepts. Practice smarter. Get real results.';

  @override
  String get loginPracticeTheWayRealExams => 'Practice the way real exams ask';

  @override
  String get loginUseFocusedMockTestsAnd =>
      'Use focused mock tests and detailed solutions to turn preparation into exam readiness.';

  @override
  String get loginKnowWhatToReviseNext => 'Know what to revise next';

  @override
  String get loginContinueWhereYouLeftOff =>
      'Continue where you left off and use your progress to keep revision targeted.';

  @override
  String get loginTooManyVerificationAttemptsPlease =>
      'Too many verification attempts. Please wait a little and try again.';

  @override
  String get loginSmsVerificationIsTemporarilyUnavailable =>
      'SMS verification is temporarily unavailable. Please try again later.';

  @override
  String get loginThisExamtreeBuildIsNot =>
      'This ExamTree build is not authorized for phone sign-in.';

  @override
  String get loginPhoneVerificationCouldNotBe =>
      'Phone verification could not be confirmed. Please try again.';

  @override
  String get loginCouldNotReachTheVerification =>
      'Could not reach the verification service. Check your connection and try again.';

  @override
  String get loginThisVerificationSessionHasExpired =>
      'This verification session has expired. Request a new OTP.';

  @override
  String get loginPhoneSignInIsNot =>
      'Phone sign-in is not enabled for this ExamTree build.';

  @override
  String get loginGoogleSignInIsTemporarily =>
      'Google sign-in is temporarily unavailable. Please try again later.';

  @override
  String get loginThisEmailAlreadyHasAn =>
      'This email already has an ExamTree sign-in method. Sign in with that method first, then try Google again.';

  @override
  String get loginGoogleDidNotProvideA =>
      'Google did not provide a verified email for this account.';

  @override
  String get loginGoogleSignInCouldNot =>
      'Google sign-in could not reach the service. Check your connection and try again.';

  @override
  String get loginAppleSignInWasCanceled =>
      'Apple sign-in was canceled. Please try again.';

  @override
  String get loginAppleSignInIsTemporarily =>
      'Apple sign-in is temporarily unavailable. Please try again later.';

  @override
  String get loginThisEmailAlreadyHasAn2 =>
      'This email already has an ExamTree sign-in method. Sign in with that method first, then try Apple again.';

  @override
  String get loginAppleDidNotProvideA =>
      'Apple did not provide a usable verified email for this account.';

  @override
  String get loginAppleSignInCouldNot =>
      'Apple sign-in could not reach the service. Check your connection and try again.';

  @override
  String get loginResetPassword => 'Reset password';

  @override
  String get loginRecoverYourAccount => 'Recover your account';

  @override
  String get loginEnterTheEmailYouUse =>
      'Enter the email you use for ExamTree and we will send password-reset instructions.';

  @override
  String get loginEmail => 'Email';

  @override
  String get loginForPrivacyTheConfirmationScreen =>
      'For privacy, the confirmation screen does not reveal whether an email is registered.';

  @override
  String get loginBackToSignIn => 'Back to sign in';

  @override
  String get loginCheckYourEmail => 'Check your email';

  @override
  String get loginCheckYourSpamFolderToo =>
      'Check your spam folder too. For privacy, we do not confirm whether an email is registered.';

  @override
  String get loginSendingAnotherResetEmail => 'Sending another reset email…';

  @override
  String get loginUseAnotherEmail => 'Use another email';

  @override
  String get loginEnterAValidEmailAddress => 'Enter a valid email address.';

  @override
  String get loginEnterYourPassword => 'Enter your password.';

  @override
  String get loginPreparingSignIn => 'Preparing sign-in…';

  @override
  String get loginUnableToSignInPlease =>
      'Unable to sign in. Please try again.';

  @override
  String get loginEnterAValidMobileNumber => 'Enter a valid mobile number.';

  @override
  String get loginTheOtpYouEnteredIs => 'The OTP you entered is incorrect.';

  @override
  String get loginUnableToVerifyThisMobile =>
      'Unable to verify this mobile number. Please try again.';

  @override
  String get loginEnterAValid10Digit => 'Enter a valid 10-digit mobile number.';

  @override
  String get loginSendingOtp => 'Sending OTP…';

  @override
  String get loginUnableToSendTheOtp =>
      'Unable to send the OTP. Please try again.';

  @override
  String get loginRequestANewOtpFirst => 'Request a new OTP first.';

  @override
  String get loginEnterThe6DigitOtp => 'Enter the 6-digit OTP.';

  @override
  String get loginVerifyingOtp => 'Verifying OTP…';

  @override
  String get loginUnableToVerifyTheOtp =>
      'Unable to verify the OTP. Please try again.';

  @override
  String get loginSendingANewOtp => 'Sending a new OTP…';

  @override
  String get loginUnableToResendTheOtp =>
      'Unable to resend the OTP. Please try again.';

  @override
  String get loginPreparingGoogleSignIn => 'Preparing Google sign-in…';

  @override
  String get loginGoogleSignInWasCanceled =>
      'Google sign-in was canceled. Please try again.';

  @override
  String get loginGoogleSignInCouldNot2 =>
      'Google sign-in could not be completed. Please try again.';

  @override
  String get loginUnableToSignInWith =>
      'Unable to sign in with Google. Please try again.';

  @override
  String get loginPreparingAppleSignIn => 'Preparing Apple sign-in…';

  @override
  String get loginAppleSignInCouldNot2 =>
      'Apple sign-in could not be completed. Please try again.';

  @override
  String get loginUnableToSignInWith2 =>
      'Unable to sign in with Apple. Please try again.';

  @override
  String get loginEnterYourName => 'Enter your name.';

  @override
  String get loginNameMustBe80Characters =>
      'Name must be 80 characters or fewer.';

  @override
  String get loginUseAtLeast6Characters =>
      'Use at least 6 characters for your password.';

  @override
  String get loginPasswordsDoNotMatch => 'Passwords do not match.';

  @override
  String get loginPreparingAccountSetup => 'Preparing account setup…';

  @override
  String get loginUnableToCreateYourAccount =>
      'Unable to create your account. Please try again.';

  @override
  String get authCreateYourExamtreeAccount => 'Create your ExamTree account';

  @override
  String get authSetUpYourAccountAnd =>
      'Set up your account and keep your preparation synced.';

  @override
  String get authSecureSignInYourProgress =>
      'Secure sign-in. Your progress stays synced.';

  @override
  String get authLoginWithMobileNumber => 'Login with Mobile Number';

  @override
  String get authWeLlSendYouA => 'We’ll send you a one-time password (OTP)';

  @override
  String get authEnterMobileNumber => 'Enter mobile number';

  @override
  String get authGetOtp => 'Get OTP';

  @override
  String get authEnterOtp => 'Enter OTP';

  @override
  String get authChange => 'Change';

  @override
  String get authVerifyContinue => 'Verify & Continue';

  @override
  String get authContinueWithGoogle => 'Continue with Google';

  @override
  String get authContinueWithEmail => 'Continue with Email';

  @override
  String get authContinueWithApple => 'Continue with Apple';

  @override
  String get authSignInWithEmail => 'Sign in with Email';

  @override
  String get authName => 'Name';

  @override
  String get authPassword => 'Password';

  @override
  String get authConfirmPassword => 'Confirm password';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get caThisCurrentAffairsItemCould =>
      'This current-affairs item could not be opened.';

  @override
  String get caUnableToLoadCurrentAffairs => 'Unable to load current affairs';

  @override
  String get caLatestUpdates => 'Latest updates';

  @override
  String get caStayReadyForWhatChanged => 'Stay ready for what changed.';

  @override
  String get caReadPublishedUpdatesInYour =>
      'Read published updates in your preferred language and keep exam-relevant developments close at hand.';

  @override
  String get caNoCurrentAffairsArePublished =>
      'No current affairs are published yet.';

  @override
  String get caNewPublishedUpdatesWillAppear =>
      'New published updates will appear here automatically.';

  @override
  String get caNoPublishedItemsMatchThis =>
      'No published items match this format yet.';

  @override
  String get myExamsMyExams => 'My exams';

  @override
  String get myExamsUnableToLoadYourExam =>
      'Unable to load your exam catalogue';

  @override
  String get myExamsMyExamsUpdated => 'My exams updated.';

  @override
  String get myExamsUnableToSaveYourSelected =>
      'Unable to save your selected exams.';

  @override
  String get myExamsSearchExamsOrExamFamilies =>
      'Search exams or exam families';

  @override
  String get myExamsChooseWhatYouArePreparing =>
      'Choose what you are preparing for';

  @override
  String get myExamsExamtreeWillUseTheseChoices =>
      'ExamTree will use these choices to organise tests, free material and relevant updates. You can change them anytime.';

  @override
  String get myExamsClearSelection => 'Clear selection';

  @override
  String get myExamsNoExamsMatchThatSearch => 'No exams match that search.';

  @override
  String get myExamsTryTheExamNameCode =>
      'Try the exam name, code, or exam family.';

  @override
  String get dailyStudyPlanSavedButNotifications =>
      'Study plan saved, but notifications are disabled.';

  @override
  String get dailyUnableToSaveTheStudy => 'Unable to save the study plan.';

  @override
  String get dailyDailyCompanion => 'Daily Companion';

  @override
  String get dailyRefresh => 'Refresh';

  @override
  String get dailyQuickRevision => 'Quick revision';

  @override
  String get dailyStudyPlan => 'Study plan';

  @override
  String get dailyKeepYourDailyTargetAnd =>
      'Keep your daily target and local reminder realistic.';

  @override
  String get dailyDailyCompanionIsUnavailable =>
      'Daily Companion is unavailable';

  @override
  String get dailyYourSavedRevisionQueueIs =>
      'Your saved revision queue is still on this device. Try loading it again.';

  @override
  String get dailyRetryDailyCompanion => 'Retry Daily Companion';

  @override
  String get dailyTodaySRevision => 'Today’s revision';

  @override
  String get dailyExamDayMode => 'Exam-Day Mode';

  @override
  String get dailyCountdownLogisticsChecklistAndLocal =>
      'Countdown, logistics checklist and local reminders';

  @override
  String get dailyCompleteTestsToBuildA =>
      'Complete tests to build a private revision queue from wrong, skipped, flagged and unusually slow questions.';

  @override
  String get dailyMyStudyPlan => 'My study plan';

  @override
  String get dailySetARealisticDailyReview =>
      'Set a realistic daily review target and an optional local reminder.';

  @override
  String get dailyLocalStudyReminder => 'Local study reminder';

  @override
  String get dailyChangeReminderTime => 'Change reminder time';

  @override
  String get dailyDecreaseDailyQuestionGoal => 'Decrease daily question goal';

  @override
  String get dailyIncreaseDailyQuestionGoal => 'Increase daily question goal';

  @override
  String get dailyDailyQuestionGoal => 'Daily question goal';

  @override
  String get revisionUnableToSaveThisReview => 'Unable to save this review.';

  @override
  String get revisionRevisionQueueUnavailable => 'Revision queue unavailable';

  @override
  String get revisionTryLoadingYourSavedRevision =>
      'Try loading your saved revision questions again.';

  @override
  String get revisionReviewTheQuestion => 'Review the question';

  @override
  String get revisionShowAnswer => 'Show answer';

  @override
  String get revisionRecallFirstRevealTheStored =>
      'Recall first. Reveal the stored answer when you’re ready.';

  @override
  String get revisionCompareThisWithTheReasoning =>
      'Compare this with the reasoning you recalled.';

  @override
  String get revisionHowWellDidYouRemember => 'How well did you remember this?';

  @override
  String get revisionChooseGotItIfYou =>
      'Choose “Got it” if you could explain the answer now. Choose “Review again” to bring it back sooner.';

  @override
  String get revisionReviewAgain => 'Review again';

  @override
  String get revisionGotIt => 'Got it';

  @override
  String get notifAllNotificationsMarkedAsRead =>
      'All notifications marked as read.';

  @override
  String get notifUnableToMarkNotificationsAs =>
      'Unable to mark notifications as read.';

  @override
  String get notifMarkAllRead => 'Mark all read';

  @override
  String get notifImportantUpdatesInOnePlace =>
      'Important updates, in one place.';

  @override
  String get notifExamRemindersLearningUpdatesAnd =>
      'Exam reminders, learning updates and test announcements stay easy to find.';

  @override
  String get notifOpenLink => 'Open link';

  @override
  String get notifNoNotificationsYet => 'No notifications yet';

  @override
  String get notifImportantExamtreeUpdatesWillAppear =>
      'Important ExamTree updates will appear here when there is something worth your attention.';

  @override
  String get notifUnableToLoadNotifications => 'Unable to load notifications';

  @override
  String get notifTryAgain => 'Try again';

  @override
  String get profileMyProfile => 'My Profile';

  @override
  String get profileSettings => 'Settings';

  @override
  String get profileUnableToLoadYourPerformance =>
      'Unable to load your performance';

  @override
  String get profileAccount => 'Account';

  @override
  String get profilePreferencesPrivacyAndThisDevice =>
      'Preferences, privacy and this device session.';

  @override
  String get profileUsedInTestsAnswerReview =>
      'Used in tests, answer review and saved revision questions. English is used when a translation is unavailable.';

  @override
  String get profileUnableToSaveTheQuestion =>
      'Unable to save the question language on this device.';

  @override
  String get profileYourProfile => 'Your profile';

  @override
  String get profileMyProgress => 'My Progress';

  @override
  String get profileAccuracyAttemptsAndPerformance =>
      'Accuracy, attempts and performance';

  @override
  String get profileOfflineLearningResources => 'Offline learning resources';

  @override
  String get profileSavedRevisionItems => 'Saved revision items';

  @override
  String get profileTestHistory => 'Test History';

  @override
  String get profileCompletedAttemptsAndResults =>
      'Completed attempts and results';

  @override
  String get profileCouponsOffers => 'Coupons & Offers';

  @override
  String get profileApplyDiscountsDuringCheckout =>
      'Apply discounts during checkout';

  @override
  String get profileEditProfile => 'Edit Profile';

  @override
  String get profileUpdateYourLearnerName => 'Update your learner name';

  @override
  String get profileHelpSupport => 'Help & Support';

  @override
  String get profileCommonQuestionsAndAccountHelp =>
      'Common questions and account help';

  @override
  String get profilePerformance => 'Performance';

  @override
  String get profileYourCompletedTestSignalsAt =>
      'Your completed-test signals at a glance.';

  @override
  String get profileFullHistory => 'Full history';

  @override
  String get profileRecentTrend => 'Recent trend';

  @override
  String get profileYourLatestCompletedTests => 'Your latest completed tests.';

  @override
  String get profileAvgTime => 'Avg time';

  @override
  String get profileWhatToFocusOn => 'What to focus on';

  @override
  String get profileSectionDetailWillAppearAfter =>
      'Section detail will appear after reviewed questions are available.';

  @override
  String get profileStrongest => 'Strongest';

  @override
  String get profileNeedsAttention => 'Needs attention';

  @override
  String get profileReviewLatest => 'Review latest';

  @override
  String get profileYourPerformanceStartsWithYour =>
      'Your performance starts with your first test';

  @override
  String get profileCompleteATestToBuild =>
      'Complete a test to build score, accuracy, section and trend insights here.';

  @override
  String get profileBrowseTests => 'Browse tests';

  @override
  String get profileMyResults => 'My results';

  @override
  String get profileSearchAndReviewCompletedAttempts =>
      'Search and review completed attempts';

  @override
  String get profileSignOut => 'Sign out';

  @override
  String get profileEndThisDeviceSession => 'End this device session';

  @override
  String get auxYourProgressStartsWithYour =>
      'Your progress starts with your first test';

  @override
  String get auxCompleteAMockOrPractice =>
      'Complete a mock or practice test to build accuracy, score and section insights here.';

  @override
  String get auxOverallAccuracy => 'Overall Accuracy';

  @override
  String get auxAverageScore => 'Average Score';

  @override
  String get auxAppPreferences => 'App Preferences';

  @override
  String get auxLanguage => 'Language';

  @override
  String get auxLearning => 'Learning';

  @override
  String get auxProfileUpdated => 'Profile updated.';

  @override
  String get auxUnableToUpdateYourProfile =>
      'Unable to update your profile right now.';

  @override
  String get auxVerifiedContact => 'Verified contact';

  @override
  String get auxEmailAndPhoneChangesRequire =>
      'Email and phone changes require verification and are managed through your sign-in account.';

  @override
  String get auxApplyCouponsAtCheckout => 'Apply coupons at checkout';

  @override
  String get auxAvailableCouponCodesCanBe =>
      'Available coupon codes can be entered when choosing or renewing a test-series plan.';

  @override
  String get auxExploreTestSeries => 'Explore Test Series';

  @override
  String get accountAccountDeletionCouldNotBe =>
      'Account deletion could not be completed. Please try again.';

  @override
  String get accountSignInAgainToContinue => 'Sign in again to continue';

  @override
  String get accountYouWillReturnHereAfter =>
      'You will return here after signing in again.';

  @override
  String get accountCancel => 'Cancel';

  @override
  String get accountSignInAgain => 'Sign in again';

  @override
  String get accountDeleteYourExamtreeAccount =>
      'Delete your ExamTree account?';

  @override
  String get accountThisCannotBeUndoneType =>
      'This cannot be undone. Type DELETE MY ACCOUNT to continue.';

  @override
  String get accountConfirmation => 'Confirmation';

  @override
  String get accountKeepMyAccount => 'Keep my account';

  @override
  String get accountDeleteAccount => 'Delete account';

  @override
  String get accountThisPageCouldNotBe =>
      'This page could not be opened. Please try again later.';

  @override
  String get accountYourLearnerData => 'Your learner data';

  @override
  String get accountClearInformationAboutWhatExamtree =>
      'Clear information about what ExamTree uses and where to read the full policy.';

  @override
  String get accountLearningActivity => 'Learning activity';

  @override
  String get accountExamtreeUsesYourAccountInformation =>
      'ExamTree uses your account information to authenticate you, save test attempts, show results and provide learning analytics. We do not need your question answers for advertising.';

  @override
  String get accountPrivacyPolicy => 'Privacy policy';

  @override
  String get accountReadTheProductionPolicyCovering =>
      'Read the production policy covering data use, retention, deletion and privacy contact details.';

  @override
  String get accountOpenPrivacyPolicy => 'Open privacy policy';

  @override
  String get accountAccountDeletionOnTheWeb => 'Account deletion on the web';

  @override
  String get accountYouCanAlsoStartAn =>
      'You can also start an account-deletion request from ExamTree’s public web resource.';

  @override
  String get accountOpenDeletionPage => 'Open deletion page';

  @override
  String get accountYourPrivacyYourAccount => 'Your privacy, your account';

  @override
  String get accountReviewHowLearnerDataIs =>
      'Review how learner data is used and manage permanent account deletion.';

  @override
  String get accountDeletingYourAccountPermanentlyRemoves =>
      'Deleting your account permanently removes learner-owned attempts, results, profile data and active entitlements. An anonymized account record may remain solely where financial or security records must be retained.';

  @override
  String get accountYouWillBeAskedTo =>
      'You will be asked to type DELETE MY ACCOUNT before anything is removed.';

  @override
  String get examDayExamTargetSavedButNotification =>
      'Exam target saved, but notification permission is disabled.';

  @override
  String get examDayUnableToSaveTheExam => 'Unable to save the exam target.';

  @override
  String get examDayUnableToUpdateTheChecklist =>
      'Unable to update the checklist.';

  @override
  String get examDayAddChecklistItem => 'Add checklist item';

  @override
  String get examDayEGBusTicketSaved => 'e.g. Bus ticket saved offline';

  @override
  String get examDayAdd => 'Add';

  @override
  String get examDayRemoveExamTarget => 'Remove exam target?';

  @override
  String get examDayThisRemovesTheLocalCountdown =>
      'This removes the local countdown, checklist and scheduled exam-day reminders from this device. Test history is unchanged.';

  @override
  String get examDayRemoveTarget => 'Remove target';

  @override
  String get examDayUnableToRemoveTheExam =>
      'Unable to remove the exam target.';

  @override
  String get examDayEditTarget => 'Edit target';

  @override
  String get examDayExamDayModeIsUnavailable => 'Exam-Day Mode is unavailable';

  @override
  String get examDayTryLoadingYourSavedTarget =>
      'Try loading your saved target again.';

  @override
  String get examDayRetryExamDayMode => 'Retry Exam-Day Mode';

  @override
  String get examDaySetOneActiveExamTarget => 'Set one active exam target';

  @override
  String get examDayKeepAPrivateCountdownLogistics =>
      'Keep a private countdown, logistics checklist and optional local reminders on this phone.';

  @override
  String get examDaySetExamTarget => 'Set exam target';

  @override
  String get examDayYouProvideTheExamDetails => 'You provide the exam details';

  @override
  String get examDayExamtreeDoesNotInventExam =>
      'ExamTree does not invent exam dates, reporting times, venues or readiness scores. Always verify saved details against the official notice or admit card.';

  @override
  String get examDayReportingCountdown => 'Reporting countdown';

  @override
  String get examDayUsefulNow => 'Useful now';

  @override
  String get examDayKeepTheLastMileActions =>
      'Keep the last-mile actions focused and familiar.';

  @override
  String get examDaySavedLogistics => 'Saved logistics';

  @override
  String get examDayOnlyTheDetailsYouEntered =>
      'Only the details you entered for this target.';

  @override
  String get examDayEdit => 'Edit';

  @override
  String get examDayOfficialInstructionsRemainAuthoritative =>
      'Official instructions remain authoritative';

  @override
  String get examDayThisChecklistIsAPersonal =>
      'This checklist is a personal aid. Always use the official notice or admit card for reporting time, documents, permitted items and venue rules.';

  @override
  String get examDayExam => 'Exam';

  @override
  String get examDayReporting => 'Reporting';

  @override
  String get examDayVenueNote => 'Venue note';

  @override
  String get examDayExamDayChecklist => 'Exam-day checklist';

  @override
  String get examDayRemoveCustomItem => 'Remove custom item';

  @override
  String get examDayAddMyOwnItem => 'Add my own item';

  @override
  String get examDayChooseAFutureExamDate =>
      'Choose a future exam date and time.';

  @override
  String get examDayReportingTimeMustBeBefore =>
      'Reporting time must be before the exam time.';

  @override
  String get examDaySaveOnlyTheDetailsYou =>
      'Save only the details you want available on this device.';

  @override
  String get examDayExamName => 'Exam name';

  @override
  String get examDayEGSscCglTier => 'e.g. SSC CGL Tier I';

  @override
  String get examDayExamDate => 'Exam date';

  @override
  String get examDayExamTime => 'Exam time';

  @override
  String get examDayReportingTimeOptional => 'Reporting time (optional)';

  @override
  String get examDayClearReportingTime => 'Clear reporting time';

  @override
  String get examDayVenueNoteOptional => 'Venue note (optional)';

  @override
  String get examDaySaveTheVenueOrAddress =>
      'Save the venue or address exactly as you want to remember it';

  @override
  String get examDayExamDayReminders => 'Exam-day reminders';

  @override
  String get examDayRequestLocalNotificationsAbout24 =>
      'Request local notifications about 24 hours and 2 hours before the saved reporting or exam time.';

  @override
  String get examDaySaveExamTarget => 'Save exam target';

  @override
  String get accountReauthBody =>
      'For your security, account deletion requires a recent sign-in. You will return here after signing in again.';

  @override
  String get mySeriesMyTestSeries => 'My Test Series';

  @override
  String get mySeriesHelp => 'Help';

  @override
  String get mySeriesYouHavenTPurchasedAny =>
      'You haven’t purchased any Test Series yet';

  @override
  String get mySeriesGetFullLengthMockTests =>
      'Get full-length mock tests, sectional tests, previous year papers and detailed analysis to boost your preparation.';

  @override
  String get mySeriesYourAccessHasExpired => 'Your access has expired';

  @override
  String get mySeriesRenewToContinueTestsYour =>
      'Renew to continue tests. Your progress and analytics are preserved.';

  @override
  String get mySeriesTestsAttempted => 'Tests Attempted';

  @override
  String get mySeriesTopicTests => 'Topic Tests';

  @override
  String get mySeriesMySeries => 'My Series';

  @override
  String get mySeriesDownloads => 'Downloads';

  @override
  String get mySeriesHistory => 'History';

  @override
  String get mySeriesUnableToLoadYourTest => 'Unable to load your test series.';

  @override
  String get orderOrderDetails => 'Order Details';

  @override
  String get orderPaymentSuccessful => 'Payment Successful';

  @override
  String get orderYourTestSeriesIsNow => 'Your Test Series is now active!';

  @override
  String get orderTransactionDetails => 'Transaction Details';

  @override
  String get orderOrderId => 'Order ID';

  @override
  String get orderTransactionId => 'Transaction ID';

  @override
  String get orderStatus => 'Status';

  @override
  String get orderIncludedInYourAccess => 'Included in your access';

  @override
  String get renewContinueYourPractice => 'Continue your practice';

  @override
  String get renewGetLatestUpdates => 'Get latest updates';

  @override
  String get renewKeepYourProgress => 'Keep your progress';

  @override
  String get renewDetailedSolutions => 'Detailed solutions';

  @override
  String get storeBatchesAreNotPublishedYet => 'Batches are not published yet';

  @override
  String get storeExamtreeWillShowBatchesHere =>
      'ExamTree will show batches here only after real batch products, schedules and access rules are available.';

  @override
  String get storePreparationProducts => 'Preparation products';

  @override
  String get storePublishedTestSeriesAndFuture =>
      'Published test series and future batches, clearly separated.';

  @override
  String get storeTestSeries => 'Test series';

  @override
  String get storeBatches => 'Batches';

  @override
  String get storeStoreCatalogueUnavailable => 'Store catalogue unavailable';

  @override
  String get storeExamtreeCouldNotLoadPublished =>
      'ExamTree could not load published products right now.';

  @override
  String get storeNoTestProductsOnSale => 'No test products on sale';

  @override
  String get storeThereAreNoActiveProducts =>
      'There are no active products in the published catalogue right now. Free and already-accessible tests remain available under Tests.';

  @override
  String get storeViewTests => 'View tests';

  @override
  String get storePricesValidityAndAvailabilityCome =>
      'Prices, validity and availability come from the published ExamTree catalogue. Mobile checkout is not connected yet, so this screen does not create a purchase action.';

  @override
  String get learnSubReadyLessons => 'Ready lessons';

  @override
  String get learnSubChapters => 'Chapters';

  @override
  String get learnSubReading => 'Reading';

  @override
  String get learnSubModuleUnavailable => 'Module unavailable';

  @override
  String get learnSubChooseATopicArea => 'Choose a topic area';

  @override
  String get learnSubOpenAnAreaToContinue =>
      'Open an area to continue learning and practice.';

  @override
  String get learnSubUntimed => 'Untimed';

  @override
  String get learnSubComingSoon => 'Coming soon';

  @override
  String get learnSubSubModuleUnavailable => 'Sub-module unavailable';

  @override
  String get learnSubVocabulary => 'Vocabulary';

  @override
  String get learnSubBuildStrongerWordPowerWith =>
      'Build stronger word power with focused practice.';

  @override
  String get learnSubBuildVocabularyWithShortUntimed =>
      'Build vocabulary with short untimed sessions. Every answer is checked immediately and followed by an explanation.';

  @override
  String get learnSubPracticeMappingForThisSub =>
      'Practice mapping for this sub-module is being connected to Question Studio.';

  @override
  String get learnSubPolity => 'Polity';

  @override
  String get learnSubIndianConstitutionInstitutionsAndGovernance =>
      'Indian Constitution, institutions and governance.';

  @override
  String get learnSubChooseAChapterToRead =>
      'Choose a chapter to read the notes or start a short untimed practice session. Answers and explanations appear immediately after each question.';

  @override
  String get learnSub1520QuestionsUntimed => '15–20 questions · Untimed';

  @override
  String get learnSubReviewLesson => 'Review lesson';

  @override
  String get learnSubPracticeTopicUnavailable => 'Practice topic unavailable';

  @override
  String get learnSubPracticeQuestionsAreNotAvailable =>
      'Practice questions are not available for this topic yet.';

  @override
  String get learnSubUnableToLoadPracticeQuestions =>
      'Unable to load practice questions right now. Your Learn progress is safe.';

  @override
  String get learnSubSubmitPractice => 'Submit practice?';

  @override
  String get learnSubKeepPracticing => 'Keep practicing';

  @override
  String get learnSubSubmit => 'Submit';

  @override
  String get learnSubBack => 'Back';

  @override
  String get learnSubPracticeResult => 'Practice result';

  @override
  String get learnSubAllTopics => 'All topics';

  @override
  String get learnSubSuggestedNextTopic => 'Suggested next topic';

  @override
  String get learnSub20QuestionsUntimedInstantExplanations =>
      '20 questions · Untimed · Instant explanations';
}
