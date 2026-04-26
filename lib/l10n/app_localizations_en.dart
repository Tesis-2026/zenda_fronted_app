// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Zenda';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonOr => 'or';

  @override
  String get commonNotSet => 'Not set';

  @override
  String get commonUnknownError => 'Unknown error';

  @override
  String get commonSignOut => 'Sign out';

  @override
  String get validationEnterEmail => 'Enter your email';

  @override
  String get validationInvalidEmail => 'Invalid email';

  @override
  String get validationEnterPassword => 'Enter your password';

  @override
  String get validationMinPassword => 'At least 8 characters';

  @override
  String get validationEnterName => 'Enter your name';

  @override
  String get validationEnterCode => 'Enter the code';

  @override
  String get validationEnterNewPassword => 'Enter your new password';

  @override
  String get authLoginTitle => 'Welcome to Zenda';

  @override
  String get authLoginSubtitle => 'Sign in to continue';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authEmailHint => 'you@email.com';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authPasswordHint => 'At least 8 characters';

  @override
  String get authForgotPassword => 'Forgot your password?';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authNoAccount => 'Don\'t have an account?';

  @override
  String get authSignUp => 'Create account';

  @override
  String get authPrivacyNote =>
      'Zenda does not connect to banks. Your data is private.';

  @override
  String get authAccountNotFound => 'Account not found';

  @override
  String get authAccountNotFoundMessage =>
      'No account exists with this email. Would you like to create a new account?';

  @override
  String get authContinueGoogle => 'Continue with Google (Demo)';

  @override
  String get authRegisterTitle => 'Create account';

  @override
  String get authRegisterSubtitle =>
      'Join Zenda and take control of your finances';

  @override
  String get authFullNameLabel => 'Full name';

  @override
  String get authFullNameHint => 'John Doe';

  @override
  String get authHaveAccount => 'Already have an account?';

  @override
  String get authDataSecure => 'Your data is secure';

  @override
  String get authDataSecureRegister =>
      'Zenda does not connect to banks. All your information is stored locally on your device.';

  @override
  String get authForgotTitle => 'Recover password';

  @override
  String get authForgotSubtitle =>
      'Enter your email and we will send you a recovery code.';

  @override
  String get authSendCode => 'Send code';

  @override
  String get authHaveCode => 'I already have a code';

  @override
  String get authCheckEmail => 'Check your email';

  @override
  String get authCheckEmailMessage =>
      'If your email is registered, you will receive a recovery code within minutes.\n\nEnter the code on the next screen.';

  @override
  String get authEnterCode => 'Enter code';

  @override
  String get authResetTitle => 'New password';

  @override
  String get authResetSubtitle =>
      'Enter the code you received by email and your new password.';

  @override
  String get authResetCodeLabel => 'Recovery code';

  @override
  String get authResetCodeHint => 'Paste the code from the email';

  @override
  String get authNewPasswordLabel => 'New password';

  @override
  String get authResetButton => 'Reset password';

  @override
  String get authPasswordUpdated => 'Password updated. Sign in.';

  @override
  String get authOnboardingReset =>
      'To reset onboarding, reinstall the app or clear data.';

  @override
  String get onboardingPage1Title => 'Record your expenses in seconds';

  @override
  String get onboardingPage1Subtitle =>
      'Log with a tap or scan a receipt (demo).';

  @override
  String get onboardingPage1Micro => 'Less friction, more control.';

  @override
  String get onboardingPage2Title => 'Understand your money with 50/30/20';

  @override
  String get onboardingPage2Subtitle =>
      'Zenda shows you if you are balanced: needs, wants and savings.';

  @override
  String get onboardingPage2Micro => 'Learn without overcomplicating it.';

  @override
  String get onboardingPage3Title => 'Keep your streak and improve every day';

  @override
  String get onboardingPage3Subtitle =>
      'Build consistency by logging daily and tracking your progress.';

  @override
  String get onboardingPage3Micro =>
      'The important thing is coming back tomorrow.';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingRegister => 'Sign up';

  @override
  String get onboardingStart => 'Get started';

  @override
  String get onboardingHaveAccount => 'I already have an account';

  @override
  String dashboardGreeting(String name) {
    return 'Hi, $name';
  }

  @override
  String get dashboardMotivation => 'Let\'s improve your finances today.';

  @override
  String get dashboardNavHome => 'Home';

  @override
  String get dashboardNavTransactions => 'Txns';

  @override
  String get dashboardNavBudget => 'Budget';

  @override
  String get dashboardNavProfile => 'Profile';

  @override
  String get dashboardRecord => 'Record';

  @override
  String get dashboardMyAccounts => 'My Accounts';

  @override
  String get dashboardBudgetTitle => 'Your 50/30/20 Budget';

  @override
  String get dashboardBudgetSubtitle =>
      'Based on your spending in the last 30 days';

  @override
  String get dashboardTransactions => 'Transactions';

  @override
  String get dashboardNoTransactions => 'No transactions yet.';

  @override
  String get dashboardNeeds => 'Needs';

  @override
  String get dashboardWants => 'Wants';

  @override
  String get dashboardSavings => 'Savings';

  @override
  String get dashboardUserFallback => 'User';

  @override
  String get dashboardSignOutConfirm => 'Are you sure you want to sign out?';

  @override
  String dashboardErrorAccounts(String error) {
    return 'Error loading accounts: $error';
  }

  @override
  String dashboardErrorTransactions(String error) {
    return 'Error loading transactions: $error';
  }

  @override
  String get summaryTodayLabel => 'Today\'s Spend';

  @override
  String get summaryWeekLabel => 'This Week';

  @override
  String streakLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count-day streak',
      one: '1-day streak',
    );
    return '$_temp0';
  }

  @override
  String get budgetNoExpenses => 'No expenses recorded';

  @override
  String get aiCardTitle => 'Zenda Tip';

  @override
  String get txNewTitle => 'New transaction';

  @override
  String get txScanReceipt => 'Scan receipt (demo)';

  @override
  String get txExpense => 'Expense';

  @override
  String get txIncome => 'Income';

  @override
  String get txTransfer => 'Transfer';

  @override
  String get txAccountLabel => 'Account';

  @override
  String get txSourceLabel => 'Source';

  @override
  String get txDestLabel => 'Destination';

  @override
  String get txAmountLabel => 'Amount (PEN)';

  @override
  String get txAmountHint => '0.00';

  @override
  String get txCategoryLabel => 'Category';

  @override
  String get txNoteLabel => 'Note (optional)';

  @override
  String get txNoteHint => 'e.g. Coffee shop';

  @override
  String get txDateLabel => 'Date';

  @override
  String get txSaveButton => 'Save transaction';

  @override
  String get txSaved => 'Saved';

  @override
  String txErrorPrefix(String error) {
    return 'Error: $error';
  }

  @override
  String get txNeed => 'Need';

  @override
  String get txWant => 'Want';

  @override
  String get txSavingBucket => 'Saving';

  @override
  String get txCategoryFood => 'Food';

  @override
  String get txCategoryTransport => 'Transport';

  @override
  String get txCategoryHousing => 'Housing';

  @override
  String get txCategoryUtilities => 'Utilities';

  @override
  String get txCategoryHealth => 'Health';

  @override
  String get txCategoryEntertainment => 'Entertainment';

  @override
  String get txCategoryShopping => 'Shopping';

  @override
  String get txCategorySubscriptions => 'Subscriptions';

  @override
  String get txCategoryCravings => 'Cravings';

  @override
  String get txCategorySavings => 'Savings';

  @override
  String get txCategoryOther => 'Other';

  @override
  String get txListTitle => 'Transactions';

  @override
  String get txListEmpty => 'No transactions yet';

  @override
  String get txListFilterAll => 'All';

  @override
  String get txListFilterExpenses => 'Expenses';

  @override
  String get txListFilterIncome => 'Income';

  @override
  String get txListFilterThisWeek => 'This week';

  @override
  String get txListFilterThisMonth => 'This month';

  @override
  String get txListFilterAllTime => 'All time';

  @override
  String get txDeleteConfirmTitle => 'Delete transaction';

  @override
  String get txDeleteConfirmMessage => 'This action cannot be undone.';

  @override
  String get txDeleteAction => 'Delete';

  @override
  String get txDeleteError => 'Could not delete transaction. Please try again.';

  @override
  String get txEditTitle => 'Edit transaction';

  @override
  String get txUpdateButton => 'Save changes';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileSignOutTooltip => 'Sign out';

  @override
  String get profileSignOutDialogTitle => 'Sign out';

  @override
  String get profileSignOutDialogContent =>
      'Are you sure you want to sign out?';

  @override
  String get profileErrorLoad => 'Could not load profile';

  @override
  String get profileErrorSave =>
      'Could not save changes. Check your connection.';

  @override
  String get profileAge => 'Age';

  @override
  String get profileUniversity => 'University';

  @override
  String get profileCurrency => 'Currency';

  @override
  String get profileIncomeType => 'Income type';

  @override
  String get profileMonthlyIncome => 'Monthly income';

  @override
  String get profileFinancialLiteracy => 'Financial literacy';

  @override
  String get profileEditButton => 'Edit profile';

  @override
  String get profileFullNameLabel => 'Full name';

  @override
  String get profileAgeLabel => 'Age';

  @override
  String get profileUniversityLabel => 'University';

  @override
  String get profileManageCategories => 'Manage categories';

  @override
  String get catMgmtTitle => 'My Categories';

  @override
  String get catMgmtSystemSection => 'Default categories';

  @override
  String get catMgmtCustomSection => 'Custom categories';

  @override
  String get catMgmtEmpty => 'No custom categories yet';

  @override
  String get catMgmtAddTitle => 'New category';

  @override
  String get catMgmtAddHint => 'Category name';

  @override
  String get catMgmtRenameTitle => 'Rename category';

  @override
  String get catMgmtDeleteConfirm =>
      'Delete this category? Transactions using it will keep their data.';

  @override
  String get catMgmtDeleteAction => 'Delete';

  @override
  String get catMgmtErrorLoad => 'Could not load categories';

  @override
  String get catMgmtErrorSave => 'Could not save. Try again.';

  @override
  String get reportsTitle => 'Reports';

  @override
  String get reportsTabMonth => 'Month';

  @override
  String get reportsTabWeek => 'Week';

  @override
  String get reportsTabCompare => 'Compare';

  @override
  String get reportsTopCategories => 'Top Categories';

  @override
  String get reportsNoCategoryData => 'No expense data for this period';

  @override
  String get reportsIncome => 'Income';

  @override
  String get reportsExpense => 'Expense';

  @override
  String get reportsBalance => 'Balance';

  @override
  String reportsCompareMonths(int count) {
    return 'Last $count months';
  }

  @override
  String get reportsNoComparisonData => 'No data available';

  @override
  String get reportsErrorLoad => 'Could not load report data';

  @override
  String get reportsTotalIncome => 'Total Income';

  @override
  String get reportsTotalExpense => 'Total Expense';

  @override
  String get reportsNetBalance => 'Net Balance';

  @override
  String reportsWeekLabel(int week, int year) {
    return 'Week $week, $year';
  }

  @override
  String reportsMonthLabel(String month, int year) {
    return '$month $year';
  }

  @override
  String get reportsExportPdf => 'Export PDF';

  @override
  String get reportsExportPdfError => 'Could not generate PDF';

  @override
  String get profileBudgets => 'Budgets';

  @override
  String get profileGoals => 'Savings Goals';

  @override
  String get budgetTitle => 'Budgets';

  @override
  String get budgetEmptyTitle => 'No budgets yet';

  @override
  String get budgetEmptySubtitle =>
      'Create a budget to track your spending by category';

  @override
  String get budgetAddTitle => 'New Budget';

  @override
  String get budgetCategoryAll => 'All categories';

  @override
  String get budgetAmountLabel => 'Spending limit (S/)';

  @override
  String get budgetMonthLabel => 'Month';

  @override
  String get budgetYearLabel => 'Year';

  @override
  String budgetSpentOf(String spent, String limit) {
    return 'S/ $spent of S/ $limit';
  }

  @override
  String budgetPercentUsed(String percent) {
    return '$percent% used';
  }

  @override
  String get budgetErrorLoad => 'Could not load budgets';

  @override
  String get budgetDeleteConfirm => 'Delete this budget?';

  @override
  String get budgetDuplicate =>
      'A budget for this category and period already exists';

  @override
  String get budgetEditTitle => 'Edit Budget';

  @override
  String get goalsTitle => 'Savings Goals';

  @override
  String get goalsEmptyTitle => 'No goals yet';

  @override
  String get goalsEmptySubtitle =>
      'Create a savings goal to track your progress';

  @override
  String get goalsAddTitle => 'New Goal';

  @override
  String get goalsNameLabel => 'Goal name';

  @override
  String get goalsNameHint => 'e.g. Emergency fund';

  @override
  String get goalsTargetLabel => 'Target amount (S/)';

  @override
  String get goalsContributeTitle => 'Add contribution';

  @override
  String get goalsContributeLabel => 'Amount (S/)';

  @override
  String goalsProgressLabel(String current, String target) {
    return 'S/ $current of S/ $target';
  }

  @override
  String get goalsErrorLoad => 'Could not load goals';

  @override
  String get goalsDeleteConfirm => 'Delete this goal?';

  @override
  String get goalsDeleteLabel => 'Delete';

  @override
  String get goalsDetailTitle => 'Goal Detail';

  @override
  String get goalsDetailContributionHistory => 'Contribution history';

  @override
  String get goalsDetailNoContributions => 'No contributions yet';

  @override
  String goalsDetailProjection(String date) {
    return 'At this pace you\'ll complete your goal on $date';
  }

  @override
  String goalsDetailAlert(String date) {
    return 'At this pace you won\'t meet your deadline of $date';
  }

  @override
  String get goalsDetailProgressChart => 'Cumulative progress';

  @override
  String get errorAuthInvalidCredentials => 'Incorrect email or password.';

  @override
  String get errorAuthEmailTaken => 'This email is already registered.';

  @override
  String get errorAuthTokenExpired => 'Reset link is invalid or has expired.';

  @override
  String get errorAuthBadRequest => 'Check your details and try again.';

  @override
  String get errorServerError => 'Unexpected error. Please try again.';

  @override
  String get errorNoConnection => 'Could not connect to the server.';

  @override
  String get errorTxNoSourceAccount => 'Select a source account.';

  @override
  String get errorTxInvalidAmount => 'Enter an amount greater than 0.';

  @override
  String get errorTxNoCategory => 'Select a category.';

  @override
  String get errorTxNoDestAccount => 'Select a destination account.';

  @override
  String get errorTxSameAccount => 'Destination must be a different account.';

  @override
  String get errorTxInvalidSourceAccount => 'Source account not found.';

  @override
  String get errorTxInvalidDestAccount => 'Destination account not found.';

  @override
  String get errorTxCreditTransferNotSupported =>
      'Transfers from a credit card are not available.';

  @override
  String get errorTxSaveFailed =>
      'Could not save the transaction. Please try again.';

  @override
  String get predictionsTitle => 'AI Predictions';

  @override
  String get predictionsExpenseTitle => 'Next month expenses';

  @override
  String get predictionsIncomeTitle => 'Next month income';

  @override
  String get predictionsConfidence => 'Confidence';

  @override
  String get predictionsErrorLoad => 'Could not load predictions';

  @override
  String get predictionsDisclaimer =>
      'Predictions are estimates based on your spending history. Actual results may vary.';

  @override
  String get recommendationsTitle => 'Recommendations';

  @override
  String get recommendationsEmpty =>
      'No recommendations available yet. Add more transactions to get personalized tips.';

  @override
  String get recommendationsErrorLoad => 'Could not load recommendations';

  @override
  String get recommendationsAccept => 'Helpful';

  @override
  String get recommendationsReject => 'Not helpful';

  @override
  String get educationTitle => 'Financial Education';

  @override
  String get educationErrorLoad => 'Could not load topics';

  @override
  String educationProgressLabel(int completed, int total) {
    return '$completed of $total topics completed';
  }

  @override
  String get educationTopicDetailTitle => 'Topic';

  @override
  String get educationMarkComplete => 'Mark as completed';

  @override
  String get educationTopicCompleted => 'Topic completed!';

  @override
  String get challengesTitle => 'Challenges';

  @override
  String get challengesEmpty => 'No challenges available right now.';

  @override
  String get challengesErrorLoad => 'Could not load challenges';

  @override
  String get challengesAcceptButton => 'Accept challenge';

  @override
  String get challengesAccepted => 'Challenge accepted!';

  @override
  String get badgesTitle => 'Badges';

  @override
  String get badgesErrorLoad => 'Could not load badges';

  @override
  String badgesEarnedCount(int earned, int total) {
    return '$earned of $total badges earned';
  }

  @override
  String get progressTitle => 'Financial Progress';

  @override
  String get progressErrorLoad => 'Could not load progress data';

  @override
  String get progressCurrentMonth => 'Current month';

  @override
  String get progressPreviousMonth => 'Previous month';

  @override
  String get progressChangesTitle => 'Month-over-month changes';

  @override
  String get progressExpensesChange => 'Expenses';

  @override
  String get progressSavingsChange => 'Savings';

  @override
  String get progressBalanceChange => 'Balance';

  @override
  String get progressNoData => 'No data';

  @override
  String get surveyPreTitle => 'Pre-Usage Survey';

  @override
  String get surveyPostTitle => 'Post-Usage Survey';

  @override
  String get surveyErrorLoad => 'Could not load survey';

  @override
  String get surveyAnswerAll => 'Please answer all questions before submitting';

  @override
  String get surveySubmitButton => 'Submit answers';

  @override
  String get surveySubmitError => 'Could not submit survey. Please try again.';

  @override
  String get surveyResultTitle => 'Your results';

  @override
  String surveyImprovement(String points) {
    return 'Your financial knowledge improved by $points points since the pre-survey!';
  }

  @override
  String get feedbackTitle => 'Send feedback';

  @override
  String get feedbackTypeLabel => 'Type';

  @override
  String get feedbackRatingLabel => 'Rating';

  @override
  String get feedbackMessageLabel => 'Message';

  @override
  String get feedbackMessageHint => 'Tell us what you think...';

  @override
  String get feedbackSubmitButton => 'Send feedback';

  @override
  String get feedbackThanks => 'Thank you for your feedback!';

  @override
  String get feedbackMessageRequired => 'Please enter a message';

  @override
  String get feedbackSubmitError =>
      'Could not send feedback. Please try again.';

  @override
  String get notificationsTitle => 'Notification Preferences';

  @override
  String get notificationsErrorLoad => 'Could not load preferences';

  @override
  String get notificationTypeBudgetAlert => 'Budget alerts';

  @override
  String get notificationTypeAnomalyAlert => 'Unusual spending alerts';

  @override
  String get notificationTypePredictionReady => 'Prediction ready';

  @override
  String get notificationTypeChallengeReminder => 'Challenge reminders';

  @override
  String get notificationTypeDailyReminder => 'Daily log reminder';

  @override
  String get notificationTypeBadgeEarned => 'Badge earned';
}
