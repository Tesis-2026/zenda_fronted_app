import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

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
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Zenda'**
  String get appTitle;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonOr.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get commonOr;

  /// No description provided for @commonNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get commonNotSet;

  /// No description provided for @commonUnknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get commonUnknownError;

  /// No description provided for @commonSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get commonSignOut;

  /// No description provided for @validationEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get validationEnterEmail;

  /// No description provided for @validationInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get validationInvalidEmail;

  /// No description provided for @validationEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get validationEnterPassword;

  /// No description provided for @validationMinPassword.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get validationMinPassword;

  /// No description provided for @validationEnterName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get validationEnterName;

  /// No description provided for @validationEnterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the code'**
  String get validationEnterCode;

  /// No description provided for @validationEnterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your new password'**
  String get validationEnterNewPassword;

  /// No description provided for @authLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Zenda'**
  String get authLoginTitle;

  /// No description provided for @authLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get authLoginSubtitle;

  /// No description provided for @authEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// No description provided for @authEmailHint.
  ///
  /// In en, this message translates to:
  /// **'you@email.com'**
  String get authEmailHint;

  /// No description provided for @authPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// No description provided for @authPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get authPasswordHint;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get authForgotPassword;

  /// No description provided for @authSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignIn;

  /// No description provided for @authNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get authNoAccount;

  /// No description provided for @authSignUp.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authSignUp;

  /// No description provided for @authPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'Zenda does not connect to banks. Your data is private.'**
  String get authPrivacyNote;

  /// No description provided for @authAccountNotFound.
  ///
  /// In en, this message translates to:
  /// **'Account not found'**
  String get authAccountNotFound;

  /// No description provided for @authAccountNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'No account exists with this email. Would you like to create a new account?'**
  String get authAccountNotFoundMessage;

  /// No description provided for @authContinueGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google (Demo)'**
  String get authContinueGoogle;

  /// No description provided for @authRegisterTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authRegisterTitle;

  /// No description provided for @authRegisterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join Zenda and take control of your finances'**
  String get authRegisterSubtitle;

  /// No description provided for @authFullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get authFullNameLabel;

  /// No description provided for @authFullNameHint.
  ///
  /// In en, this message translates to:
  /// **'John Doe'**
  String get authFullNameHint;

  /// No description provided for @authHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get authHaveAccount;

  /// No description provided for @authDataSecure.
  ///
  /// In en, this message translates to:
  /// **'Your data is secure'**
  String get authDataSecure;

  /// No description provided for @authDataSecureRegister.
  ///
  /// In en, this message translates to:
  /// **'Zenda does not connect to banks. All your information is stored locally on your device.'**
  String get authDataSecureRegister;

  /// No description provided for @authForgotTitle.
  ///
  /// In en, this message translates to:
  /// **'Recover password'**
  String get authForgotTitle;

  /// No description provided for @authForgotSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we will send you a recovery code.'**
  String get authForgotSubtitle;

  /// No description provided for @authSendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get authSendCode;

  /// No description provided for @authHaveCode.
  ///
  /// In en, this message translates to:
  /// **'I already have a code'**
  String get authHaveCode;

  /// No description provided for @authCheckEmail.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get authCheckEmail;

  /// No description provided for @authCheckEmailMessage.
  ///
  /// In en, this message translates to:
  /// **'If your email is registered, you will receive a recovery code within minutes.\n\nEnter the code on the next screen.'**
  String get authCheckEmailMessage;

  /// No description provided for @authEnterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter code'**
  String get authEnterCode;

  /// No description provided for @authResetTitle.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get authResetTitle;

  /// No description provided for @authResetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the code you received by email and your new password.'**
  String get authResetSubtitle;

  /// No description provided for @authResetCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Recovery code'**
  String get authResetCodeLabel;

  /// No description provided for @authResetCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Paste the code from the email'**
  String get authResetCodeHint;

  /// No description provided for @authNewPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get authNewPasswordLabel;

  /// No description provided for @authResetButton.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get authResetButton;

  /// No description provided for @authPasswordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated. Sign in.'**
  String get authPasswordUpdated;

  /// No description provided for @authOnboardingReset.
  ///
  /// In en, this message translates to:
  /// **'To reset onboarding, reinstall the app or clear data.'**
  String get authOnboardingReset;

  /// No description provided for @onboardingPage1Title.
  ///
  /// In en, this message translates to:
  /// **'Record your expenses in seconds'**
  String get onboardingPage1Title;

  /// No description provided for @onboardingPage1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Log with a tap or scan a receipt (demo).'**
  String get onboardingPage1Subtitle;

  /// No description provided for @onboardingPage1Micro.
  ///
  /// In en, this message translates to:
  /// **'Less friction, more control.'**
  String get onboardingPage1Micro;

  /// No description provided for @onboardingPage2Title.
  ///
  /// In en, this message translates to:
  /// **'Understand your money with 50/30/20'**
  String get onboardingPage2Title;

  /// No description provided for @onboardingPage2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Zenda shows you if you are balanced: needs, wants and savings.'**
  String get onboardingPage2Subtitle;

  /// No description provided for @onboardingPage2Micro.
  ///
  /// In en, this message translates to:
  /// **'Learn without overcomplicating it.'**
  String get onboardingPage2Micro;

  /// No description provided for @onboardingPage3Title.
  ///
  /// In en, this message translates to:
  /// **'Keep your streak and improve every day'**
  String get onboardingPage3Title;

  /// No description provided for @onboardingPage3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Build consistency by logging daily and tracking your progress.'**
  String get onboardingPage3Subtitle;

  /// No description provided for @onboardingPage3Micro.
  ///
  /// In en, this message translates to:
  /// **'The important thing is coming back tomorrow.'**
  String get onboardingPage3Micro;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingRegister.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get onboardingRegister;

  /// No description provided for @onboardingStart.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingStart;

  /// No description provided for @onboardingHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get onboardingHaveAccount;

  /// No description provided for @dashboardGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}'**
  String dashboardGreeting(String name);

  /// No description provided for @dashboardMotivation.
  ///
  /// In en, this message translates to:
  /// **'Let\'s improve your finances today.'**
  String get dashboardMotivation;

  /// No description provided for @dashboardNavHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get dashboardNavHome;

  /// No description provided for @dashboardNavTransactions.
  ///
  /// In en, this message translates to:
  /// **'Txns'**
  String get dashboardNavTransactions;

  /// No description provided for @dashboardNavBudget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get dashboardNavBudget;

  /// No description provided for @dashboardNavProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get dashboardNavProfile;

  /// No description provided for @dashboardRecord.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get dashboardRecord;

  /// No description provided for @dashboardMyAccounts.
  ///
  /// In en, this message translates to:
  /// **'My Accounts'**
  String get dashboardMyAccounts;

  /// No description provided for @dashboardBudgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Your 50/30/20 Budget'**
  String get dashboardBudgetTitle;

  /// No description provided for @dashboardBudgetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Based on your spending in the last 30 days'**
  String get dashboardBudgetSubtitle;

  /// No description provided for @dashboardTransactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get dashboardTransactions;

  /// No description provided for @dashboardNoTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet.'**
  String get dashboardNoTransactions;

  /// No description provided for @dashboardNeeds.
  ///
  /// In en, this message translates to:
  /// **'Needs'**
  String get dashboardNeeds;

  /// No description provided for @dashboardWants.
  ///
  /// In en, this message translates to:
  /// **'Wants'**
  String get dashboardWants;

  /// No description provided for @dashboardSavings.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get dashboardSavings;

  /// No description provided for @dashboardUserFallback.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get dashboardUserFallback;

  /// No description provided for @dashboardSignOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get dashboardSignOutConfirm;

  /// No description provided for @dashboardErrorAccounts.
  ///
  /// In en, this message translates to:
  /// **'Error loading accounts: {error}'**
  String dashboardErrorAccounts(String error);

  /// No description provided for @dashboardErrorTransactions.
  ///
  /// In en, this message translates to:
  /// **'Error loading transactions: {error}'**
  String dashboardErrorTransactions(String error);

  /// No description provided for @summaryTodayLabel.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Spend'**
  String get summaryTodayLabel;

  /// No description provided for @summaryWeekLabel.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get summaryWeekLabel;

  /// No description provided for @streakLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1-day streak} other{{count}-day streak}}'**
  String streakLabel(int count);

  /// No description provided for @budgetNoExpenses.
  ///
  /// In en, this message translates to:
  /// **'No expenses recorded'**
  String get budgetNoExpenses;

  /// No description provided for @aiCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Zenda Tip'**
  String get aiCardTitle;

  /// No description provided for @txNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New transaction'**
  String get txNewTitle;

  /// No description provided for @txScanReceipt.
  ///
  /// In en, this message translates to:
  /// **'Scan receipt (demo)'**
  String get txScanReceipt;

  /// No description provided for @txExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get txExpense;

  /// No description provided for @txIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get txIncome;

  /// No description provided for @txTransfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get txTransfer;

  /// No description provided for @txAccountLabel.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get txAccountLabel;

  /// No description provided for @txSourceLabel.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get txSourceLabel;

  /// No description provided for @txDestLabel.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get txDestLabel;

  /// No description provided for @txAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount (PEN)'**
  String get txAmountLabel;

  /// No description provided for @txAmountHint.
  ///
  /// In en, this message translates to:
  /// **'0.00'**
  String get txAmountHint;

  /// No description provided for @txCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get txCategoryLabel;

  /// No description provided for @txNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get txNoteLabel;

  /// No description provided for @txNoteHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Coffee shop'**
  String get txNoteHint;

  /// No description provided for @txDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get txDateLabel;

  /// No description provided for @txSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save transaction'**
  String get txSaveButton;

  /// No description provided for @txSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get txSaved;

  /// No description provided for @txErrorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String txErrorPrefix(String error);

  /// No description provided for @txNeed.
  ///
  /// In en, this message translates to:
  /// **'Need'**
  String get txNeed;

  /// No description provided for @txWant.
  ///
  /// In en, this message translates to:
  /// **'Want'**
  String get txWant;

  /// No description provided for @txSavingBucket.
  ///
  /// In en, this message translates to:
  /// **'Saving'**
  String get txSavingBucket;

  /// No description provided for @txCategoryFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get txCategoryFood;

  /// No description provided for @txCategoryTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get txCategoryTransport;

  /// No description provided for @txCategoryHousing.
  ///
  /// In en, this message translates to:
  /// **'Housing'**
  String get txCategoryHousing;

  /// No description provided for @txCategoryUtilities.
  ///
  /// In en, this message translates to:
  /// **'Utilities'**
  String get txCategoryUtilities;

  /// No description provided for @txCategoryHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get txCategoryHealth;

  /// No description provided for @txCategoryEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get txCategoryEntertainment;

  /// No description provided for @txCategoryShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get txCategoryShopping;

  /// No description provided for @txCategorySubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get txCategorySubscriptions;

  /// No description provided for @txCategoryCravings.
  ///
  /// In en, this message translates to:
  /// **'Cravings'**
  String get txCategoryCravings;

  /// No description provided for @txCategorySavings.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get txCategorySavings;

  /// No description provided for @txCategoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get txCategoryOther;

  /// No description provided for @txListTitle.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get txListTitle;

  /// No description provided for @txListEmpty.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get txListEmpty;

  /// No description provided for @txListFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get txListFilterAll;

  /// No description provided for @txListFilterExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get txListFilterExpenses;

  /// No description provided for @txListFilterIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get txListFilterIncome;

  /// No description provided for @txListFilterThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get txListFilterThisWeek;

  /// No description provided for @txListFilterThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get txListFilterThisMonth;

  /// No description provided for @txListFilterAllTime.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get txListFilterAllTime;

  /// No description provided for @txDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete transaction'**
  String get txDeleteConfirmTitle;

  /// No description provided for @txDeleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get txDeleteConfirmMessage;

  /// No description provided for @txDeleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get txDeleteAction;

  /// No description provided for @txDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Could not delete transaction. Please try again.'**
  String get txDeleteError;

  /// No description provided for @txEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit transaction'**
  String get txEditTitle;

  /// No description provided for @txUpdateButton.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get txUpdateButton;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileSignOutTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get profileSignOutTooltip;

  /// No description provided for @profileSignOutDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get profileSignOutDialogTitle;

  /// No description provided for @profileSignOutDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get profileSignOutDialogContent;

  /// No description provided for @profileErrorLoad.
  ///
  /// In en, this message translates to:
  /// **'Could not load profile'**
  String get profileErrorLoad;

  /// No description provided for @profileErrorSave.
  ///
  /// In en, this message translates to:
  /// **'Could not save changes. Check your connection.'**
  String get profileErrorSave;

  /// No description provided for @profileAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get profileAge;

  /// No description provided for @profileUniversity.
  ///
  /// In en, this message translates to:
  /// **'University'**
  String get profileUniversity;

  /// No description provided for @profileCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get profileCurrency;

  /// No description provided for @profileIncomeType.
  ///
  /// In en, this message translates to:
  /// **'Income type'**
  String get profileIncomeType;

  /// No description provided for @profileMonthlyIncome.
  ///
  /// In en, this message translates to:
  /// **'Monthly income'**
  String get profileMonthlyIncome;

  /// No description provided for @profileFinancialLiteracy.
  ///
  /// In en, this message translates to:
  /// **'Financial literacy'**
  String get profileFinancialLiteracy;

  /// No description provided for @profileEditButton.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profileEditButton;

  /// No description provided for @profileFullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get profileFullNameLabel;

  /// No description provided for @profileAgeLabel.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get profileAgeLabel;

  /// No description provided for @profileUniversityLabel.
  ///
  /// In en, this message translates to:
  /// **'University'**
  String get profileUniversityLabel;

  /// No description provided for @profileManageCategories.
  ///
  /// In en, this message translates to:
  /// **'Manage categories'**
  String get profileManageCategories;

  /// No description provided for @catMgmtTitle.
  ///
  /// In en, this message translates to:
  /// **'My Categories'**
  String get catMgmtTitle;

  /// No description provided for @catMgmtSystemSection.
  ///
  /// In en, this message translates to:
  /// **'Default categories'**
  String get catMgmtSystemSection;

  /// No description provided for @catMgmtCustomSection.
  ///
  /// In en, this message translates to:
  /// **'Custom categories'**
  String get catMgmtCustomSection;

  /// No description provided for @catMgmtEmpty.
  ///
  /// In en, this message translates to:
  /// **'No custom categories yet'**
  String get catMgmtEmpty;

  /// No description provided for @catMgmtAddTitle.
  ///
  /// In en, this message translates to:
  /// **'New category'**
  String get catMgmtAddTitle;

  /// No description provided for @catMgmtAddHint.
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get catMgmtAddHint;

  /// No description provided for @catMgmtRenameTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename category'**
  String get catMgmtRenameTitle;

  /// No description provided for @catMgmtDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this category? Transactions using it will keep their data.'**
  String get catMgmtDeleteConfirm;

  /// No description provided for @catMgmtDeleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get catMgmtDeleteAction;

  /// No description provided for @catMgmtErrorLoad.
  ///
  /// In en, this message translates to:
  /// **'Could not load categories'**
  String get catMgmtErrorLoad;

  /// No description provided for @catMgmtErrorSave.
  ///
  /// In en, this message translates to:
  /// **'Could not save. Try again.'**
  String get catMgmtErrorSave;

  /// No description provided for @reportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reportsTitle;

  /// No description provided for @reportsTabMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get reportsTabMonth;

  /// No description provided for @reportsTabWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get reportsTabWeek;

  /// No description provided for @reportsTabCompare.
  ///
  /// In en, this message translates to:
  /// **'Compare'**
  String get reportsTabCompare;

  /// No description provided for @reportsTopCategories.
  ///
  /// In en, this message translates to:
  /// **'Top Categories'**
  String get reportsTopCategories;

  /// No description provided for @reportsNoCategoryData.
  ///
  /// In en, this message translates to:
  /// **'No expense data for this period'**
  String get reportsNoCategoryData;

  /// No description provided for @reportsIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get reportsIncome;

  /// No description provided for @reportsExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get reportsExpense;

  /// No description provided for @reportsBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get reportsBalance;

  /// No description provided for @reportsCompareMonths.
  ///
  /// In en, this message translates to:
  /// **'Last {count} months'**
  String reportsCompareMonths(int count);

  /// No description provided for @reportsNoComparisonData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get reportsNoComparisonData;

  /// No description provided for @reportsErrorLoad.
  ///
  /// In en, this message translates to:
  /// **'Could not load report data'**
  String get reportsErrorLoad;

  /// No description provided for @reportsTotalIncome.
  ///
  /// In en, this message translates to:
  /// **'Total Income'**
  String get reportsTotalIncome;

  /// No description provided for @reportsTotalExpense.
  ///
  /// In en, this message translates to:
  /// **'Total Expense'**
  String get reportsTotalExpense;

  /// No description provided for @reportsNetBalance.
  ///
  /// In en, this message translates to:
  /// **'Net Balance'**
  String get reportsNetBalance;

  /// No description provided for @reportsWeekLabel.
  ///
  /// In en, this message translates to:
  /// **'Week {week}, {year}'**
  String reportsWeekLabel(int week, int year);

  /// No description provided for @reportsMonthLabel.
  ///
  /// In en, this message translates to:
  /// **'{month} {year}'**
  String reportsMonthLabel(String month, int year);

  /// No description provided for @reportsExportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get reportsExportPdf;

  /// No description provided for @reportsExportPdfError.
  ///
  /// In en, this message translates to:
  /// **'Could not generate PDF'**
  String get reportsExportPdfError;

  /// No description provided for @profileBudgets.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get profileBudgets;

  /// No description provided for @profileGoals.
  ///
  /// In en, this message translates to:
  /// **'Savings Goals'**
  String get profileGoals;

  /// No description provided for @budgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get budgetTitle;

  /// No description provided for @budgetEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No budgets yet'**
  String get budgetEmptyTitle;

  /// No description provided for @budgetEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a budget to track your spending by category'**
  String get budgetEmptySubtitle;

  /// No description provided for @budgetAddTitle.
  ///
  /// In en, this message translates to:
  /// **'New Budget'**
  String get budgetAddTitle;

  /// No description provided for @budgetCategoryAll.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get budgetCategoryAll;

  /// No description provided for @budgetAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Spending limit (S/)'**
  String get budgetAmountLabel;

  /// No description provided for @budgetMonthLabel.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get budgetMonthLabel;

  /// No description provided for @budgetYearLabel.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get budgetYearLabel;

  /// No description provided for @budgetSpentOf.
  ///
  /// In en, this message translates to:
  /// **'S/ {spent} of S/ {limit}'**
  String budgetSpentOf(String spent, String limit);

  /// No description provided for @budgetPercentUsed.
  ///
  /// In en, this message translates to:
  /// **'{percent}% used'**
  String budgetPercentUsed(String percent);

  /// No description provided for @budgetErrorLoad.
  ///
  /// In en, this message translates to:
  /// **'Could not load budgets'**
  String get budgetErrorLoad;

  /// No description provided for @budgetDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this budget?'**
  String get budgetDeleteConfirm;

  /// No description provided for @budgetDuplicate.
  ///
  /// In en, this message translates to:
  /// **'A budget for this category and period already exists'**
  String get budgetDuplicate;

  /// No description provided for @budgetEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Budget'**
  String get budgetEditTitle;

  /// No description provided for @goalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Savings Goals'**
  String get goalsTitle;

  /// No description provided for @goalsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No goals yet'**
  String get goalsEmptyTitle;

  /// No description provided for @goalsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a savings goal to track your progress'**
  String get goalsEmptySubtitle;

  /// No description provided for @goalsAddTitle.
  ///
  /// In en, this message translates to:
  /// **'New Goal'**
  String get goalsAddTitle;

  /// No description provided for @goalsNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Goal name'**
  String get goalsNameLabel;

  /// No description provided for @goalsNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Emergency fund'**
  String get goalsNameHint;

  /// No description provided for @goalsTargetLabel.
  ///
  /// In en, this message translates to:
  /// **'Target amount (S/)'**
  String get goalsTargetLabel;

  /// No description provided for @goalsContributeTitle.
  ///
  /// In en, this message translates to:
  /// **'Add contribution'**
  String get goalsContributeTitle;

  /// No description provided for @goalsContributeLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount (S/)'**
  String get goalsContributeLabel;

  /// No description provided for @goalsProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'S/ {current} of S/ {target}'**
  String goalsProgressLabel(String current, String target);

  /// No description provided for @goalsErrorLoad.
  ///
  /// In en, this message translates to:
  /// **'Could not load goals'**
  String get goalsErrorLoad;

  /// No description provided for @goalsDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this goal?'**
  String get goalsDeleteConfirm;

  /// No description provided for @goalsDeleteLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get goalsDeleteLabel;

  /// No description provided for @goalsDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Goal Detail'**
  String get goalsDetailTitle;

  /// No description provided for @goalsDetailContributionHistory.
  ///
  /// In en, this message translates to:
  /// **'Contribution history'**
  String get goalsDetailContributionHistory;

  /// No description provided for @goalsDetailNoContributions.
  ///
  /// In en, this message translates to:
  /// **'No contributions yet'**
  String get goalsDetailNoContributions;

  /// No description provided for @goalsDetailProjection.
  ///
  /// In en, this message translates to:
  /// **'At this pace you\'ll complete your goal on {date}'**
  String goalsDetailProjection(String date);

  /// No description provided for @goalsDetailAlert.
  ///
  /// In en, this message translates to:
  /// **'At this pace you won\'t meet your deadline of {date}'**
  String goalsDetailAlert(String date);

  /// No description provided for @goalsDetailProgressChart.
  ///
  /// In en, this message translates to:
  /// **'Cumulative progress'**
  String get goalsDetailProgressChart;

  /// No description provided for @errorAuthInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password.'**
  String get errorAuthInvalidCredentials;

  /// No description provided for @errorAuthEmailTaken.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered.'**
  String get errorAuthEmailTaken;

  /// No description provided for @errorAuthTokenExpired.
  ///
  /// In en, this message translates to:
  /// **'Reset link is invalid or has expired.'**
  String get errorAuthTokenExpired;

  /// No description provided for @errorAuthBadRequest.
  ///
  /// In en, this message translates to:
  /// **'Check your details and try again.'**
  String get errorAuthBadRequest;

  /// No description provided for @errorServerError.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error. Please try again.'**
  String get errorServerError;

  /// No description provided for @errorNoConnection.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to the server.'**
  String get errorNoConnection;

  /// No description provided for @errorTxNoSourceAccount.
  ///
  /// In en, this message translates to:
  /// **'Select a source account.'**
  String get errorTxNoSourceAccount;

  /// No description provided for @errorTxInvalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount greater than 0.'**
  String get errorTxInvalidAmount;

  /// No description provided for @errorTxNoCategory.
  ///
  /// In en, this message translates to:
  /// **'Select a category.'**
  String get errorTxNoCategory;

  /// No description provided for @errorTxNoDestAccount.
  ///
  /// In en, this message translates to:
  /// **'Select a destination account.'**
  String get errorTxNoDestAccount;

  /// No description provided for @errorTxSameAccount.
  ///
  /// In en, this message translates to:
  /// **'Destination must be a different account.'**
  String get errorTxSameAccount;

  /// No description provided for @errorTxInvalidSourceAccount.
  ///
  /// In en, this message translates to:
  /// **'Source account not found.'**
  String get errorTxInvalidSourceAccount;

  /// No description provided for @errorTxInvalidDestAccount.
  ///
  /// In en, this message translates to:
  /// **'Destination account not found.'**
  String get errorTxInvalidDestAccount;

  /// No description provided for @errorTxCreditTransferNotSupported.
  ///
  /// In en, this message translates to:
  /// **'Transfers from a credit card are not available.'**
  String get errorTxCreditTransferNotSupported;

  /// No description provided for @errorTxSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save the transaction. Please try again.'**
  String get errorTxSaveFailed;

  /// No description provided for @predictionsTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Predictions'**
  String get predictionsTitle;

  /// No description provided for @predictionsExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Next month expenses'**
  String get predictionsExpenseTitle;

  /// No description provided for @predictionsIncomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Next month income'**
  String get predictionsIncomeTitle;

  /// No description provided for @predictionsConfidence.
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get predictionsConfidence;

  /// No description provided for @predictionsErrorLoad.
  ///
  /// In en, this message translates to:
  /// **'Could not load predictions'**
  String get predictionsErrorLoad;

  /// No description provided for @predictionsDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Predictions are estimates based on your spending history. Actual results may vary.'**
  String get predictionsDisclaimer;

  /// No description provided for @recommendationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Recommendations'**
  String get recommendationsTitle;

  /// No description provided for @recommendationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No recommendations available yet. Add more transactions to get personalized tips.'**
  String get recommendationsEmpty;

  /// No description provided for @recommendationsErrorLoad.
  ///
  /// In en, this message translates to:
  /// **'Could not load recommendations'**
  String get recommendationsErrorLoad;

  /// No description provided for @recommendationsAccept.
  ///
  /// In en, this message translates to:
  /// **'Helpful'**
  String get recommendationsAccept;

  /// No description provided for @recommendationsReject.
  ///
  /// In en, this message translates to:
  /// **'Not helpful'**
  String get recommendationsReject;

  /// No description provided for @educationTitle.
  ///
  /// In en, this message translates to:
  /// **'Financial Education'**
  String get educationTitle;

  /// No description provided for @educationErrorLoad.
  ///
  /// In en, this message translates to:
  /// **'Could not load topics'**
  String get educationErrorLoad;

  /// No description provided for @educationProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} topics completed'**
  String educationProgressLabel(int completed, int total);

  /// No description provided for @educationTopicDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Topic'**
  String get educationTopicDetailTitle;

  /// No description provided for @educationMarkComplete.
  ///
  /// In en, this message translates to:
  /// **'Mark as completed'**
  String get educationMarkComplete;

  /// No description provided for @educationTopicCompleted.
  ///
  /// In en, this message translates to:
  /// **'Topic completed!'**
  String get educationTopicCompleted;

  /// No description provided for @challengesTitle.
  ///
  /// In en, this message translates to:
  /// **'Challenges'**
  String get challengesTitle;

  /// No description provided for @challengesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No challenges available right now.'**
  String get challengesEmpty;

  /// No description provided for @challengesErrorLoad.
  ///
  /// In en, this message translates to:
  /// **'Could not load challenges'**
  String get challengesErrorLoad;

  /// No description provided for @challengesAcceptButton.
  ///
  /// In en, this message translates to:
  /// **'Accept challenge'**
  String get challengesAcceptButton;

  /// No description provided for @challengesAccepted.
  ///
  /// In en, this message translates to:
  /// **'Challenge accepted!'**
  String get challengesAccepted;

  /// No description provided for @badgesTitle.
  ///
  /// In en, this message translates to:
  /// **'Badges'**
  String get badgesTitle;

  /// No description provided for @badgesErrorLoad.
  ///
  /// In en, this message translates to:
  /// **'Could not load badges'**
  String get badgesErrorLoad;

  /// No description provided for @badgesEarnedCount.
  ///
  /// In en, this message translates to:
  /// **'{earned} of {total} badges earned'**
  String badgesEarnedCount(int earned, int total);

  /// No description provided for @progressTitle.
  ///
  /// In en, this message translates to:
  /// **'Financial Progress'**
  String get progressTitle;

  /// No description provided for @progressErrorLoad.
  ///
  /// In en, this message translates to:
  /// **'Could not load progress data'**
  String get progressErrorLoad;

  /// No description provided for @progressCurrentMonth.
  ///
  /// In en, this message translates to:
  /// **'Current month'**
  String get progressCurrentMonth;

  /// No description provided for @progressPreviousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get progressPreviousMonth;

  /// No description provided for @progressChangesTitle.
  ///
  /// In en, this message translates to:
  /// **'Month-over-month changes'**
  String get progressChangesTitle;

  /// No description provided for @progressExpensesChange.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get progressExpensesChange;

  /// No description provided for @progressSavingsChange.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get progressSavingsChange;

  /// No description provided for @progressBalanceChange.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get progressBalanceChange;

  /// No description provided for @progressNoData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get progressNoData;

  /// No description provided for @surveyPreTitle.
  ///
  /// In en, this message translates to:
  /// **'Pre-Usage Survey'**
  String get surveyPreTitle;

  /// No description provided for @surveyPostTitle.
  ///
  /// In en, this message translates to:
  /// **'Post-Usage Survey'**
  String get surveyPostTitle;

  /// No description provided for @surveyErrorLoad.
  ///
  /// In en, this message translates to:
  /// **'Could not load survey'**
  String get surveyErrorLoad;

  /// No description provided for @surveyAnswerAll.
  ///
  /// In en, this message translates to:
  /// **'Please answer all questions before submitting'**
  String get surveyAnswerAll;

  /// No description provided for @surveySubmitButton.
  ///
  /// In en, this message translates to:
  /// **'Submit answers'**
  String get surveySubmitButton;

  /// No description provided for @surveySubmitError.
  ///
  /// In en, this message translates to:
  /// **'Could not submit survey. Please try again.'**
  String get surveySubmitError;

  /// No description provided for @surveyResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Your results'**
  String get surveyResultTitle;

  /// No description provided for @surveyImprovement.
  ///
  /// In en, this message translates to:
  /// **'Your financial knowledge improved by {points} points since the pre-survey!'**
  String surveyImprovement(String points);

  /// No description provided for @feedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get feedbackTitle;

  /// No description provided for @feedbackTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get feedbackTypeLabel;

  /// No description provided for @feedbackRatingLabel.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get feedbackRatingLabel;

  /// No description provided for @feedbackMessageLabel.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get feedbackMessageLabel;

  /// No description provided for @feedbackMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Tell us what you think...'**
  String get feedbackMessageHint;

  /// No description provided for @feedbackSubmitButton.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get feedbackSubmitButton;

  /// No description provided for @feedbackThanks.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your feedback!'**
  String get feedbackThanks;

  /// No description provided for @feedbackMessageRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a message'**
  String get feedbackMessageRequired;

  /// No description provided for @feedbackSubmitError.
  ///
  /// In en, this message translates to:
  /// **'Could not send feedback. Please try again.'**
  String get feedbackSubmitError;
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
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
