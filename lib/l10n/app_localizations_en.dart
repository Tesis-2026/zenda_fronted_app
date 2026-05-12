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
  String get commonOk => 'OK';

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
  String get commonDelete => 'Delete';

  @override
  String get deleteConfirmYes => 'Yes, delete';

  @override
  String get commonLater => 'Later';

  @override
  String get validationEnterEmail => 'Enter your email';

  @override
  String get validationInvalidEmail => 'Invalid email';

  @override
  String get validationEnterPassword => 'Enter your password';

  @override
  String get validationMinPassword => 'At least 12 characters';

  @override
  String get validationEnterName => 'Enter your name';

  @override
  String get validationEnterCode => 'Enter the code';

  @override
  String get validationEnterNewPassword => 'Enter your new password';

  @override
  String get authLoginTitle => 'Welcome to Zenda';

  @override
  String get authWelcomeBack => 'Welcome back';

  @override
  String get authLoginSubtitle => 'Sign in to your account';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authEmailHint => 'Email address';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authPasswordHint => 'Password';

  @override
  String get authForgotPassword => 'Forgot your password?';

  @override
  String get authForgotLink => 'Forgot password?';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authSignInButton => 'Sign In';

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
  String get onboardingStart => 'Get Started';

  @override
  String get onboardingHaveAccount => 'Already have an account? Sign in';

  @override
  String get onboardingFeature1 => 'Track spending with the 50/30/20 rule';

  @override
  String get onboardingFeature2 => 'Set and achieve your savings goals';

  @override
  String get onboardingFeature3 => 'AI insights tailored for students';

  @override
  String dashboardGreeting(String name) {
    return 'Hi, $name';
  }

  @override
  String get dashboardMotivation => 'Let\'s improve your finances today.';

  @override
  String get dashboardPostSurveyBannerTitle => 'Post-survey ready';

  @override
  String get dashboardPostSurveyBannerBody =>
      'You\'ve been using Zenda for 30 days — complete the post-survey to measure your progress.';

  @override
  String get dashboardNavHome => 'HOME';

  @override
  String get dashboardNavTransactions => 'TXNS';

  @override
  String get dashboardNavAi => 'AI';

  @override
  String get dashboardNavGoals => 'GOALS';

  @override
  String get dashboardNavProfile => 'PROFILE';

  @override
  String get dashboardNavEducation => 'EDUC.';

  @override
  String get dashboardRecord => 'Record';

  @override
  String get dashboardMyAccounts => 'My Accounts';

  @override
  String get dashboardNoAccounts => 'No accounts yet';

  @override
  String get dashboardAddFirstAccount => 'Add your first account';

  @override
  String get accountAddTitle => 'Add Account';

  @override
  String get accountNameLabel => 'Account name';

  @override
  String get accountNameHint => 'e.g. BCP Savings';

  @override
  String get accountTypeLabel => 'Account type';

  @override
  String get accountTypeCash => 'Cash';

  @override
  String get accountTypeDebit => 'Debit';

  @override
  String get accountTypeCredit => 'Credit card';

  @override
  String get accountInitialBalance => 'Initial balance (S/)';

  @override
  String get accountCreditLimit => 'Credit limit (S/)';

  @override
  String get accountAddButton => 'Add account';

  @override
  String get accountDebt => 'Debt:';

  @override
  String get accountAvail => 'Avail:';

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
  String get txAddButton => '+ Add';

  @override
  String get txAddCustomCategory => 'New category';

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
  String get txListEmptySubtitle =>
      'Tap + Add to record your first transaction';

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
  String get txFilterAdvanced => 'More filters';

  @override
  String get txFilterCategory => 'Category';

  @override
  String get txFilterAllCategories => 'All categories';

  @override
  String get txFilterMinAmount => 'Min amount (S/)';

  @override
  String get txFilterMaxAmount => 'Max amount (S/)';

  @override
  String get txFilterClear => 'Clear filters';

  @override
  String get txFilterApply => 'Apply';

  @override
  String txFilterActiveCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count filters active',
      one: '1 filter active',
    );
    return '$_temp0';
  }

  @override
  String txBudgetAlert80(String category, String pct) {
    return '$category budget is at $pct% — almost at the limit!';
  }

  @override
  String txAnomalyAlert(String category) {
    return 'Unusual spending in $category — above your monthly average by more than 20%';
  }

  @override
  String get aiCardSeeRecommendations => 'See recommendations';

  @override
  String get txDeleteConfirmTitle => 'Delete transaction?';

  @override
  String get txDeleteConfirmMessage =>
      'This will permanently remove the transaction from your history. This cannot be undone.';

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
  String get profileEdit => 'Edit';

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
  String get catMgmtAddHint => 'e.g. Coffee shops';

  @override
  String get catMgmtRenameTitle => 'Edit category';

  @override
  String get catSaveButton => 'Save category';

  @override
  String get catSaveChanges => 'Save changes';

  @override
  String get catDeleteItemLabel => 'Delete category';

  @override
  String get catMgmtDeleteConfirm =>
      'Delete this category? Transactions using it will keep their data.';

  @override
  String get catMgmtDeleteAction => 'Delete';

  @override
  String get catDeleteTitle => 'Delete category?';

  @override
  String get catDeleteMessage =>
      'Transactions linked to it will keep their data. This cannot be undone.';

  @override
  String get catMgmtErrorLoad => 'Could not load categories';

  @override
  String get catMgmtErrorSave => 'Could not save. Try again.';

  @override
  String get catMgmtAddButton => '+ Add';

  @override
  String get reportsTitle => 'Reports';

  @override
  String get reportsTabMonth => 'Month';

  @override
  String get reportsTabWeek => 'Week';

  @override
  String get reportsTabCompare => 'Compare';

  @override
  String get reportsTabDay => 'Day';

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
  String get profileSectionFinance => 'Finance';

  @override
  String get profileSectionLearnGrow => 'Learn & Grow';

  @override
  String get profileSectionSurveys => 'Surveys';

  @override
  String get profileSectionSupport => 'Support';

  @override
  String get profileSendFeedback => 'Send feedback';

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
  String get budgetDeleteTitle => 'Delete budget?';

  @override
  String get budgetDeleteMessage =>
      'This budget will be permanently removed. This cannot be undone.';

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
  String get goalDeleteTitle => 'Delete goal?';

  @override
  String get goalDeleteMessage =>
      'All your progress will be lost. This cannot be undone.';

  @override
  String get goalsDueDateLabel => 'Due date (optional)';

  @override
  String get goalsMarkComplete => 'Mark complete';

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
  String get authVerifyTitle => 'Enter verification code';

  @override
  String authVerifySubtitle(String email) {
    return 'We sent a 6-digit code to $email. It expires in 15 minutes.';
  }

  @override
  String get authVerifyResend => 'Resend code';

  @override
  String authVerifyResendCooldown(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get authBack => 'Back';

  @override
  String get authCodeNotReceived => 'Didn\'t receive a code?';

  @override
  String authVerifyResendAvailable(String time) {
    return 'Resend available in $time';
  }

  @override
  String get authVerifyButton => 'Verify code';

  @override
  String get authVerifyInvalidCode =>
      'Invalid or expired code. Please try again.';

  @override
  String get authLockedAccount => 'Account locked. Try again in 15 minutes.';

  @override
  String authLockedCountdown(String time) {
    return 'Account locked. Try again in $time.';
  }

  @override
  String authAttemptsRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count attempts remaining before lockout',
      one: '1 attempt remaining before lockout',
    );
    return '$_temp0';
  }

  @override
  String get goalsCompletedSection => 'Completed goals';

  @override
  String get goalsActiveSection => 'Active goals';

  @override
  String goalsDueDate(String date) {
    return 'Due $date';
  }

  @override
  String goalsDaysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days left',
      one: '1 day left',
    );
    return '$_temp0';
  }

  @override
  String get goalsOverdue => 'Overdue';

  @override
  String get goalsCelebrate => 'Goal achieved!';

  @override
  String goalsCelebrateMessage(String name) {
    return 'Congratulations! You reached your savings goal for \"$name\".';
  }

  @override
  String get goalsMarkCompleteConfirm => 'Mark this goal as completed?';

  @override
  String get goalsMarkCompleteConfirmBody =>
      'This will close the goal and mark it as achieved.';

  @override
  String get goalsDetailDueDate => 'Target date';

  @override
  String get goalsDetailDaysLeft => 'Days remaining';

  @override
  String get goalsDetailMarkComplete => 'Mark as achieved';

  @override
  String get goalsDetailDelete => 'Delete goal';

  @override
  String goalCompletedOn(String date) {
    return 'Completed on $date';
  }

  @override
  String get reportsCalendarTitle => 'Spending calendar';

  @override
  String get reportsCalendarNoData => 'No spending on this day';

  @override
  String reportsDayTotal(String total) {
    return 'S/ $total';
  }

  @override
  String txAiSuggests(String category) {
    return 'Zenda suggests: $category';
  }

  @override
  String get txAiApply => 'Apply suggestion';

  @override
  String get educationPersonalized => 'Personalized for you';

  @override
  String get educationPersonalizedSubtitle =>
      'Topics ordered based on your spending patterns';

  @override
  String get profileNumberFormat => 'Number format';

  @override
  String get profileNumberFormatDot => '1,234.56 (dot decimal)';

  @override
  String get profileNumberFormatComma => '1.234,56 (comma decimal)';

  @override
  String get profileNumberFormatSaved => 'Number format saved.';

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
  String get predictionsConfidence => 'Confidence';

  @override
  String get predictionsErrorLoad => 'Could not load predictions';

  @override
  String get predictionsDisclaimer =>
      'Predictions are estimates based on your spending history. Actual results may vary.';

  @override
  String get predictionsLowConfidence =>
      'Not enough data for a reliable prediction yet. Keep recording transactions to improve accuracy.';

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
  String get recommendationsReject => 'Not relevant';

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
  String get challengesSectionActive => 'Active';

  @override
  String get challengesSectionAvailable => 'Available';

  @override
  String get challengesSectionCompleted => 'Completed';

  @override
  String get challengesSectionExpired => 'Expired';

  @override
  String get challengesEmpty => 'No challenges available right now.';

  @override
  String get challengesErrorLoad => 'Could not load challenges';

  @override
  String get challengesAcceptButton => 'Accept challenge';

  @override
  String get challengesAccepted => 'Challenge accepted!';

  @override
  String get challengesCompleteButton => 'Mark completed';

  @override
  String get challengesCompleted => 'Challenge completed!';

  @override
  String get challengeAutoCompletedTitle => 'Challenge completed!';

  @override
  String challengeAutoCompletedBody(String name) {
    return 'You completed: $name';
  }

  @override
  String get challengeAutoCompletedDismiss => 'Great!';

  @override
  String challengeRewardBadge(String badge) {
    return 'Reward: $badge badge';
  }

  @override
  String challengeDaysLeft(String days) {
    return '$days days left';
  }

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
  String get surveyNextButton => 'Next';

  @override
  String get surveySubmitButton => 'Submit answers';

  @override
  String get surveySubmitError => 'Could not submit survey. Please try again.';

  @override
  String get surveyResultTitle => 'Your results';

  @override
  String get surveyResultContinue => 'Continue to Dashboard';

  @override
  String surveyImprovement(String points) {
    return 'Your financial knowledge improved by $points points since the pre-survey!';
  }

  @override
  String get susSurveyTitle => 'Usability Questionnaire';

  @override
  String get susSurveyDescription =>
      'Rate each statement from 1 (Strongly Disagree) to 5 (Strongly Agree).';

  @override
  String get susSurveyStronglyDisagree => 'Strongly Disagree';

  @override
  String get susSurveyStronglyAgree => 'Strongly Agree';

  @override
  String get susSurveySubmit => 'Submit';

  @override
  String get susSurveySubmitting => 'Submitting...';

  @override
  String get susSurveyAlreadyDone =>
      'You have already submitted the usability questionnaire.';

  @override
  String get susSurveyErrorLoad =>
      'Could not load the questionnaire. Please try again.';

  @override
  String get susSurveyErrorSubmit => 'Could not submit. Please try again.';

  @override
  String get susSurveyResultTitle => 'Usability Score';

  @override
  String susSurveyResultScore(int score) {
    return 'Your SUS score: $score/100';
  }

  @override
  String susSurveyResultGrade(String grade) {
    return 'Grade: $grade';
  }

  @override
  String get susSurveyResultContinue => 'Back to Profile';

  @override
  String get surveyComparisonPreLabel => 'Pre-survey score';

  @override
  String get surveyComparisonPostLabel => 'Post-survey score';

  @override
  String get surveyComparisonImprovementLabel => 'Improvement';

  @override
  String get surveyComparisonGoalLabel => 'Thesis target: ≥ 20 points';

  @override
  String get surveyComparisonGoalMet => 'Target reached!';

  @override
  String get surveyComparisonGoalNotMet => 'Keep using the app to improve';

  @override
  String get surveyComparisonPending =>
      'Complete both surveys to see your progress';

  @override
  String get surveyComparisonPrePending => 'Pre-survey not completed yet';

  @override
  String get surveyComparisonPostPending => 'Post-survey not completed yet';

  @override
  String get surveyComparisonNavTitle => 'Knowledge Progress';

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

  @override
  String get consentTitle => 'Your privacy matters';

  @override
  String get consentSubtitle =>
      'Before you start, please read how Zenda handles your financial data.';

  @override
  String get consentBullet1 =>
      'Your data is encrypted and stored securely on Azure servers.';

  @override
  String get consentBullet2 =>
      'Your data is used only to generate personalized reports and AI predictions.';

  @override
  String get consentBullet3 =>
      'It is never shared with third parties. You can request deletion at any time.';

  @override
  String get consentBodyTitle => 'What data do we collect?';

  @override
  String get consentBodyText =>
      'Zenda collects your income and expense records, financial profile (age, university, income type), and app usage data to generate personalized predictions and recommendations. Your data is never shared with third parties and is stored securely.';

  @override
  String get consentLawNote =>
      'This app complies with Peru\'s Personal Data Protection Law (Law 29733).';

  @override
  String get consentCheckbox =>
      'I agree that my financial data will be processed to generate personalized reports and AI predictions.';

  @override
  String get consentAcceptButton => 'I agree — Let\'s get started';

  @override
  String get consentMustAccept => 'You must accept to continue';

  @override
  String get emailSentTitle => 'Account created!';

  @override
  String emailSentSubtitle(String name) {
    return 'Welcome to Zenda, $name';
  }

  @override
  String emailSentBody(String email) {
    return 'A welcome email was sent to $email. Now let\'s set up your financial profile.';
  }

  @override
  String get emailSentContinue => 'Set up my profile';

  @override
  String get emailSentSkip => 'Skip for now';

  @override
  String get profileSetupTitle => 'Tell us about yourself';

  @override
  String get profileSetupSubtitle =>
      'Help Zenda personalize your experience. You can edit this anytime.';

  @override
  String profileSetupStep(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String get profileSetupSkip => 'Skip';

  @override
  String get profileSetupAge => 'How old are you?';

  @override
  String get profileSetupAgeHint =>
      'This helps us understand your financial stage and tailor insights for you.';

  @override
  String get profileSetupUniversity => 'Which university do you attend?';

  @override
  String get profileSetupUniversityHint => 'e.g. PUCP, ULima, UNMSM...';

  @override
  String get profileSetupUniversitySubtitle =>
      'Your campus location helps us suggest local financial resources.';

  @override
  String get profileSetupIncomeType => 'What is your main income source?';

  @override
  String get profileSetupIncomeTypeSubtitle =>
      'We use this to personalize your 50/30/20 budget recommendations.';

  @override
  String get profileSetupMonthlyIncome =>
      'What is your average monthly income?';

  @override
  String get profileSetupMonthlyIncomeHint =>
      'An estimate is fine. This calibrates your 50/30/20 budget targets.';

  @override
  String get profileSetupMonthlyIncomePerMonth => 'per month';

  @override
  String get profileSetupNext => 'Continue →';

  @override
  String get profileSetupSave => 'Finish setup →';

  @override
  String get profileSetupCompleteTitle => 'All set!';

  @override
  String profileSetupCompleteTitleNamed(String name) {
    return 'All set, $name!';
  }

  @override
  String get profileSetupCompleteBody =>
      'Your profile is ready. Let\'s take control of your finances.';

  @override
  String get profileSetupGoToDashboard => 'Start using Zenda';

  @override
  String get incomeTypeScholarship => 'Scholarship / Grant';

  @override
  String get incomeTypeScholarshipSub =>
      'Scholarship, PRONABEC, university funding';

  @override
  String get incomeTypePartTime => 'Part-time / Freelance';

  @override
  String get incomeTypePartTimeSub => 'Job, gig work, side projects';

  @override
  String get incomeTypeFamily => 'Family Support';

  @override
  String get incomeTypeFamilySub => 'Monthly allowance from family';

  @override
  String get incomeTypeMixed => 'Mixed';

  @override
  String get incomeTypeMixedSub => 'Combination of the above';

  @override
  String get aiChatTitle => 'Zenda AI';

  @override
  String get aiChatSubtitle => 'Powered by your financial data';

  @override
  String get aiChatInputHint => 'Ask Zenda AI anything...';

  @override
  String get aiChatSend => 'Send';

  @override
  String get aiChatWelcome =>
      'Hi! I\'m Zenda, your financial assistant. Ask me anything about budgets, savings, or expenses.';

  @override
  String get aiChatError => 'Could not get a response. Please try again.';

  @override
  String get aiChatNavLabel => 'Zenda AI';

  @override
  String get quizTitle => 'Quiz';

  @override
  String quizQuestionOf(int current, int total) {
    return 'Question $current of $total';
  }

  @override
  String get quizEmpty => 'No quiz available for this topic yet.';

  @override
  String get quizSubmit => 'Submit';

  @override
  String get quizCorrect => 'Correct!';

  @override
  String get quizIncorrect => 'Incorrect';

  @override
  String quizResult(int score) {
    return 'You scored $score%';
  }

  @override
  String get quizFinish => 'See results';

  @override
  String get quizNext => 'Next question';

  @override
  String get quizPersonalizedTitle => 'Personalized Quiz';

  @override
  String get quizPersonalizedButton => 'Take personalized quiz';

  @override
  String get quizPersonalizedSubtitle =>
      'AI-generated questions based on your habits';

  @override
  String get quizPersonalizedAnalyzing => 'Analyzing your financial habits...';

  @override
  String quizPersonalizedAttemptsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count attempts left today',
      one: '1 attempt left today',
    );
    return '$_temp0';
  }

  @override
  String get quizPersonalizedLimitReached =>
      'You reached the limit of 5 personalized quizzes for today.';

  @override
  String get quizPersonalizedError =>
      'Could not generate quiz. Please try again.';

  @override
  String get educationRecommended => 'Recommended';

  @override
  String get reportsWeekDailyTitle => 'Daily activity';

  @override
  String get reportsProgressChipsTitle => 'Changes vs previous month';

  @override
  String reportsExpensesChip(String sign, String pct) {
    return 'Expenses $sign$pct%';
  }

  @override
  String reportsSavingsChip(String sign, String pct) {
    return 'Savings $sign$pct%';
  }

  @override
  String reportsBalanceChip(String sign, String pct) {
    return 'Balance $sign$pct%';
  }

  @override
  String get aiAdviceStartRecording =>
      'Start recording expenses to receive personalized tips.';

  @override
  String aiAdviceReduceWants(String pct) {
    return 'Your \'wants\' are running high ($pct%). Consider cutting small habits like coffee or rides to rebalance.';
  }

  @override
  String aiAdviceSaveLow(String pct) {
    return 'Your savings are low ($pct%). Try setting aside a fixed amount at the start of each week, even if small.';
  }

  @override
  String get aiAdviceOnTrack =>
      'You\'re doing great! Your budget is balanced. Keep it up and consider investing your surplus.';

  @override
  String get surveyResultDialogTitle => 'Your results';

  @override
  String surveyResultDialogBody(String level, String score) {
    return 'Your financial literacy level: $level ($score/100)';
  }

  @override
  String get surveyImprovementDialogTitle => 'Progress measured!';

  @override
  String surveyImprovementDialogBody(
    String postScore,
    String preScore,
    String improvement,
  ) {
    return 'Score: $postScore/100. Previous: $preScore/100. You improved by $improvement points!';
  }

  @override
  String get profileSectionPrivacy => 'PRIVACY';

  @override
  String get profilePrivacyLaw => 'Data protection — Ley 29733';

  @override
  String get profilePrivacyLawSubtitle =>
      'Your data is protected under Peruvian law';

  @override
  String get profilePrivacyLawBody =>
      'Zenda complies with Peru\'s Ley 29733 (Personal Data Protection). Your financial data is transmitted exclusively over HTTPS/TLS and stored securely. Access requires valid authentication at all times. You may revoke your consent at any time from this screen.';

  @override
  String get profileRevokeConsent => 'Revoke data consent';

  @override
  String get profileRevokeConsentDialogTitle => 'Revoke data consent?';

  @override
  String get profileRevokeConsentDialogBody =>
      'AI personalization features (predictions, recommendations) will be disabled. Your data will no longer be processed for AI. You can re-enable this in settings.';

  @override
  String get profileRevokeConsentConfirm => 'Revoke';

  @override
  String get profileRevokeConsentDone =>
      'Data consent revoked. AI features are now disabled.';

  @override
  String get profileConsentAlreadyRevoked =>
      'Data consent has already been revoked.';

  @override
  String get reportsTabCategories => 'Categories';

  @override
  String get reportsPeriodWeek => 'Week';

  @override
  String get reportsPeriodMonth => 'Month';

  @override
  String get reportsPeriodQuarter => 'Quarter';

  @override
  String reportsCategoryDrillTitle(String category) {
    return '$category transactions';
  }

  @override
  String get reportsCategoryNoTransactions => 'No transactions in this period';

  @override
  String get txFilterCustomRange => 'Date range';

  @override
  String get txFilterDateFrom => 'From';

  @override
  String get txFilterDateTo => 'To';

  @override
  String get txFilterClearDates => 'Clear dates';

  @override
  String get reportsEvolutionTitle => 'Monthly evolution';

  @override
  String get reportsEvolutionExpenses => 'Expenses';

  @override
  String get reportsEvolutionSavings => 'Savings';

  @override
  String get reportsEvolutionBalance => 'Balance';

  @override
  String get reportsEvolutionNoData =>
      'Add data for at least 2 months to see your evolution';

  @override
  String get dashboardPostSurveyBannerAction => 'Take survey';

  @override
  String get authConfirmPasswordHint => 'Confirm password';

  @override
  String get validationPasswordsMismatch => 'Passwords do not match';

  @override
  String get dashboardTotalBalance => 'Total Balance';

  @override
  String get dashboardViewAll => 'View all';

  @override
  String get dashboardMonthlyIncome => 'Income';

  @override
  String get dashboardMonthlyExpense => 'Expense';

  @override
  String get dashboardCashDebitCredit => 'Cash · Debit · Credit';

  @override
  String get goalsNewButton => '+ New';

  @override
  String get goalsCreateButton => 'Create goal';

  @override
  String goalsContributeAddAction(String amount) {
    return 'Add S/ $amount to goal';
  }

  @override
  String get emailVerifTitle => 'Check your email';

  @override
  String emailVerifSubtitle(String email) {
    return 'We sent a verification link to $email';
  }

  @override
  String get emailVerifStep1 => 'Open the email from Zenda';

  @override
  String get emailVerifStep2 => 'Click the verification link';

  @override
  String get emailVerifStep3 => 'Return to the app to continue';

  @override
  String get emailVerifOpenApp => 'Open Email App';

  @override
  String get emailVerifResendText => 'Didn\'t receive it?';

  @override
  String get emailVerifResendAction => 'Resend';

  @override
  String get txSavedTitle => 'Transaction saved!';

  @override
  String get txSavedBody =>
      'Your expense has been recorded and your budget updated.';

  @override
  String get txSavedLabelAmount => 'Amount';

  @override
  String get txSavedLabelCategory => 'Category';

  @override
  String get txSavedLabelDate => 'Date';

  @override
  String get txSavedLabelBudget => 'Budget impact';

  @override
  String get txSavedBackButton => 'Back to Transactions';

  @override
  String get txSavedAddAnother => 'Add Another';

  @override
  String get authResetSuccessTitle => 'Password updated!';

  @override
  String get authResetSuccessBody =>
      'Your password has been reset successfully. You can now sign in with your new password.';

  @override
  String get authResetSuccessSecurity =>
      'For your security, you\'ve been signed out of all devices.';

  @override
  String get authResetSuccessButton => 'Sign In Now';

  @override
  String get authSetNewPasswordTitle => 'Set new password';

  @override
  String get authSetNewPasswordSubtitle =>
      'Your new password must be at least 12 characters with 1 uppercase, 1 number.';

  @override
  String get authConfirmPasswordLabel => 'Confirm password';

  @override
  String get authPasswordStrengthWeak => 'Weak';

  @override
  String get authPasswordStrengthFair => 'Fair';

  @override
  String get authPasswordStrengthStrong => 'Strong';

  @override
  String goalsDetailLeftToReach(String amount) {
    return 'S/ $amount left to reach your goal!';
  }

  @override
  String get goalsDetailAddContrib => '+ Add';

  @override
  String get budgetByCategory => 'By Category';

  @override
  String get authForgotCodeExpiry =>
      'The verification code expires in 15 minutes. Check your spam folder if you don\'t see it.';

  @override
  String get aiChatQuickAnalyze => 'Analyze spending';

  @override
  String get aiChatQuickBudget => 'Budget tips';

  @override
  String get aiChatQuickGoal => 'Goal progress';

  @override
  String get profileSetupAgeStepperLabel => 'years old';

  @override
  String get profileSetupPopularUniversities => 'Popular universities';

  @override
  String get profileSetupIncomeQuick500 => 'S/ 500';

  @override
  String get profileSetupIncomeQuick1200 => 'S/ 1,200';

  @override
  String get profileSetupIncomeQuick2000 => 'S/ 2,000';

  @override
  String get educationSearchHint => 'Search topics...';

  @override
  String get educationTabLearn => 'Learn';

  @override
  String get educationTabChallenges => 'Challenges';

  @override
  String get educationTabBadges => 'Badges';

  @override
  String get educationTabProgress => 'Progress';

  @override
  String get educationTabPath => 'Path';

  @override
  String get learningPathTitle => 'My Learning Path';

  @override
  String get educationFilterAll => 'All';

  @override
  String get educationFilterBeginner => 'Beginner';

  @override
  String get educationFilterIntermediate => 'Intermediate';

  @override
  String get educationFilterAdvanced => 'Advanced';

  @override
  String get educationFeaturedLabel => 'Featured';

  @override
  String get educationStartLabel => 'Start';

  @override
  String get educationLearnGrow => 'Learn & Grow';

  @override
  String get educationFilterBudgeting => 'Budgeting';

  @override
  String get educationFilterSaving => 'Saving';

  @override
  String get educationFilterInvesting => 'Investing';

  @override
  String get educationTakeQuiz => 'Take the Quiz';

  @override
  String educationMinRead(int minutes) {
    return '$minutes min read';
  }

  @override
  String educationQuestions(int count) {
    return '$count questions';
  }

  @override
  String get educationLocked => 'Complete previous topics first';

  @override
  String get quizAnswerRecorded => 'Answer locked in. Tap Next to continue.';

  @override
  String get authSignUpLink => 'Sign up';

  @override
  String get goalManualContribution => 'Manual contribution';

  @override
  String get goalTargetSuffix => 'goal';

  @override
  String get profileSetupSaveError =>
      'Could not save profile. Continuing anyway.';

  @override
  String get profileSetupComplete40pct => '40% better predictions';

  @override
  String get profileSetupCompleteImproves =>
      'Completing your profile improves forecast accuracy.';

  @override
  String get budgetSelectPeriod => 'Select period';

  @override
  String get commonDone => 'Done';

  @override
  String get profileCurrencyPEN => 'PEN — Peruvian Sol (S/)';

  @override
  String get profileCurrencyUSD => 'USD — US Dollar (\$)';

  @override
  String get splashTagline => 'Your AI-powered finance companion';

  @override
  String get splashFooter => 'Made for Peruvian university students';

  @override
  String get dashboardManageBudgets => 'Tap to manage budgets';

  @override
  String get streakTapToView => 'Tap to view progress';

  @override
  String get aiCardPredictionsChat => 'Predictions & AI Chat';

  @override
  String get aiCardViewForecast => 'View forecast';

  @override
  String get reportsVsLastMonth => 'vs last month';

  @override
  String get reportsAiInsightsTitle => 'AI Insights';

  @override
  String get reportsAiInsightsSaved =>
      'You saved more than last month. Great work!';

  @override
  String get reportsAiInsightsExceeded => 'category exceeded limit.';

  @override
  String get progressOverviewTitle => 'Month Overview';

  @override
  String get progressTotalExpenses => 'Total Expenses';

  @override
  String get progressTotalSavings => 'Total Savings';

  @override
  String get progressNetBalance => 'Net Balance';

  @override
  String get progressTrendTitle => 'Monthly Trend';

  @override
  String get progressVsLabel => 'vs';

  @override
  String get progressSavingsLegend => 'Savings';

  @override
  String get badgesSectionEarned => 'Earned';

  @override
  String get badgesSectionLocked => 'Locked';

  @override
  String get badgesEarnedLabel => 'earned';

  @override
  String get predictionsProjectedBalance => 'Projected Balance';

  @override
  String get predictionsConfident => 'confident';

  @override
  String get predictionsBasedOnMonths => 'Based on last 3 months';

  @override
  String get predictionsProjectedExpenses => 'Projected expenses';

  @override
  String get predictionsTopCategories => 'Top Expense Categories';

  @override
  String get predictionsVsLastMonth => '8% vs last month';

  @override
  String get recommendationsSubtitle => '3 personalized tips for you this week';

  @override
  String get recommendationsRateExperience => 'Rate experience →';

  @override
  String get notificationsMasterTitle => 'Enable Notifications';

  @override
  String get notificationsMasterSubtitle => 'Receive alerts and reminders';

  @override
  String get notificationsCategoriesLabel => 'Categories';

  @override
  String get notificationSubtypeBudgetAlert =>
      'When you reach 80% of your budget';

  @override
  String get notificationSubtypeAnomalyAlert =>
      'Unusual spending patterns detected';

  @override
  String get notificationSubtypePredictionReady =>
      'Monthly prediction is ready';

  @override
  String get notificationSubtypeChallengeReminder =>
      'New challenges and badge earned';

  @override
  String get notificationSubtypeDailyReminder =>
      'Remind me to log transactions';

  @override
  String get notificationSubtypeBadgeEarned => 'New badge earned';

  @override
  String get surveySkipButton => 'Skip';

  @override
  String get surveyProgressOf => 'of';

  @override
  String get surveyCompleteTitle => 'Survey Complete!';

  @override
  String get surveyCompleteSubtitle =>
      'Thanks for sharing! We\'ll use your answers to personalize Zenda for you.';

  @override
  String get surveyBadgeUnlocked => 'badge unlocked!';

  @override
  String get surveyFinancialProfileTitle => 'Your Financial Profile';

  @override
  String get surveyFinancialProfileBody =>
      'Based on your answers, Zenda has personalized your dashboard and recommendations to help you build better saving habits.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionGeneral => 'General';

  @override
  String get settingsSectionResearch => 'Research';

  @override
  String get settingsCategoriesLabel => 'Categories';

  @override
  String get settingsNotificationsLabel => 'Notifications';

  @override
  String get settingsSurveysLabel => 'Surveys';

  @override
  String get settingsSurveysSheetTitle => 'Surveys';

  @override
  String get settingsSurveyPreLabel => 'Pre-Usage Survey';

  @override
  String get settingsSurveyPreSubtitle =>
      'Baseline financial literacy assessment';

  @override
  String get settingsSurveyPostLabel => 'Post-Usage Survey';

  @override
  String get settingsSurveyPostSubtitle =>
      'Measure your progress after 30 days';

  @override
  String get settingsSurveySusLabel => 'SUS Questionnaire';

  @override
  String get settingsSurveySusSubtitle => 'Rate your experience with the app';

  @override
  String get settingsSurveyComparisonLabel => 'Knowledge Progress';

  @override
  String get settingsSurveyComparisonSubtitle =>
      'Compare your pre and post survey scores';

  @override
  String get settingsLanguageLabel => 'Language';

  @override
  String get settingsLanguageDialogTitle => 'Select Language';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageSpanish => 'Spanish';

  @override
  String get aiChatOnline => 'Online';

  @override
  String get txListToday => 'Today';

  @override
  String get txListYesterday => 'Yesterday';
}
