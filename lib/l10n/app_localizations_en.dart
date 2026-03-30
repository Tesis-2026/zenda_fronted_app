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
}
