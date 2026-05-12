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

  /// No description provided for @commonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

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

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @deleteConfirmYes.
  ///
  /// In en, this message translates to:
  /// **'Yes, delete'**
  String get deleteConfirmYes;

  /// No description provided for @commonLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get commonLater;

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
  /// **'At least 12 characters'**
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

  /// No description provided for @authWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get authWelcomeBack;

  /// No description provided for @authLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your account'**
  String get authLoginSubtitle;

  /// No description provided for @authEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// No description provided for @authEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get authEmailHint;

  /// No description provided for @authPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// No description provided for @authPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordHint;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get authForgotPassword;

  /// No description provided for @authForgotLink.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotLink;

  /// No description provided for @authSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignIn;

  /// No description provided for @authSignInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get authSignInButton;

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
  /// **'Get Started'**
  String get onboardingStart;

  /// No description provided for @onboardingHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get onboardingHaveAccount;

  /// No description provided for @onboardingFeature1.
  ///
  /// In en, this message translates to:
  /// **'Track spending with the 50/30/20 rule'**
  String get onboardingFeature1;

  /// No description provided for @onboardingFeature2.
  ///
  /// In en, this message translates to:
  /// **'Set and achieve your savings goals'**
  String get onboardingFeature2;

  /// No description provided for @onboardingFeature3.
  ///
  /// In en, this message translates to:
  /// **'AI insights tailored for students'**
  String get onboardingFeature3;

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

  /// No description provided for @dashboardPostSurveyBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Post-survey ready'**
  String get dashboardPostSurveyBannerTitle;

  /// No description provided for @dashboardPostSurveyBannerBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ve been using Zenda for 30 days — complete the post-survey to measure your progress.'**
  String get dashboardPostSurveyBannerBody;

  /// No description provided for @dashboardNavHome.
  ///
  /// In en, this message translates to:
  /// **'HOME'**
  String get dashboardNavHome;

  /// No description provided for @dashboardNavTransactions.
  ///
  /// In en, this message translates to:
  /// **'TXNS'**
  String get dashboardNavTransactions;

  /// No description provided for @dashboardNavAi.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get dashboardNavAi;

  /// No description provided for @dashboardNavGoals.
  ///
  /// In en, this message translates to:
  /// **'GOALS'**
  String get dashboardNavGoals;

  /// No description provided for @dashboardNavProfile.
  ///
  /// In en, this message translates to:
  /// **'PROFILE'**
  String get dashboardNavProfile;

  /// No description provided for @dashboardNavEducation.
  ///
  /// In en, this message translates to:
  /// **'EDUC.'**
  String get dashboardNavEducation;

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

  /// No description provided for @dashboardNoAccounts.
  ///
  /// In en, this message translates to:
  /// **'No accounts yet'**
  String get dashboardNoAccounts;

  /// No description provided for @dashboardAddFirstAccount.
  ///
  /// In en, this message translates to:
  /// **'Add your first account'**
  String get dashboardAddFirstAccount;

  /// No description provided for @accountAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Account'**
  String get accountAddTitle;

  /// No description provided for @accountNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Account name'**
  String get accountNameLabel;

  /// No description provided for @accountNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. BCP Savings'**
  String get accountNameHint;

  /// No description provided for @accountTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Account type'**
  String get accountTypeLabel;

  /// No description provided for @accountTypeCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get accountTypeCash;

  /// No description provided for @accountTypeDebit.
  ///
  /// In en, this message translates to:
  /// **'Debit'**
  String get accountTypeDebit;

  /// No description provided for @accountTypeCredit.
  ///
  /// In en, this message translates to:
  /// **'Credit card'**
  String get accountTypeCredit;

  /// No description provided for @accountInitialBalance.
  ///
  /// In en, this message translates to:
  /// **'Initial balance (S/)'**
  String get accountInitialBalance;

  /// No description provided for @accountCreditLimit.
  ///
  /// In en, this message translates to:
  /// **'Credit limit (S/)'**
  String get accountCreditLimit;

  /// No description provided for @accountAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add account'**
  String get accountAddButton;

  /// No description provided for @accountDebt.
  ///
  /// In en, this message translates to:
  /// **'Debt:'**
  String get accountDebt;

  /// No description provided for @accountAvail.
  ///
  /// In en, this message translates to:
  /// **'Avail:'**
  String get accountAvail;

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

  /// No description provided for @txAddButton.
  ///
  /// In en, this message translates to:
  /// **'+ Add'**
  String get txAddButton;

  /// No description provided for @txAddCustomCategory.
  ///
  /// In en, this message translates to:
  /// **'New category'**
  String get txAddCustomCategory;

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

  /// No description provided for @txListEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap + Add to record your first transaction'**
  String get txListEmptySubtitle;

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

  /// No description provided for @txFilterAdvanced.
  ///
  /// In en, this message translates to:
  /// **'More filters'**
  String get txFilterAdvanced;

  /// No description provided for @txFilterCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get txFilterCategory;

  /// No description provided for @txFilterAllCategories.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get txFilterAllCategories;

  /// No description provided for @txFilterMinAmount.
  ///
  /// In en, this message translates to:
  /// **'Min amount (S/)'**
  String get txFilterMinAmount;

  /// No description provided for @txFilterMaxAmount.
  ///
  /// In en, this message translates to:
  /// **'Max amount (S/)'**
  String get txFilterMaxAmount;

  /// No description provided for @txFilterClear.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get txFilterClear;

  /// No description provided for @txFilterApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get txFilterApply;

  /// No description provided for @txFilterActiveCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 filter active} other{{count} filters active}}'**
  String txFilterActiveCount(int count);

  /// No description provided for @txBudgetAlert80.
  ///
  /// In en, this message translates to:
  /// **'{category} budget is at {pct}% — almost at the limit!'**
  String txBudgetAlert80(String category, String pct);

  /// No description provided for @txAnomalyAlert.
  ///
  /// In en, this message translates to:
  /// **'Unusual spending in {category} — above your monthly average by more than 20%'**
  String txAnomalyAlert(String category);

  /// No description provided for @aiCardSeeRecommendations.
  ///
  /// In en, this message translates to:
  /// **'See recommendations'**
  String get aiCardSeeRecommendations;

  /// No description provided for @txDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete transaction?'**
  String get txDeleteConfirmTitle;

  /// No description provided for @txDeleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently remove the transaction from your history. This cannot be undone.'**
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

  /// No description provided for @profileEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get profileEdit;

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
  /// **'e.g. Coffee shops'**
  String get catMgmtAddHint;

  /// No description provided for @catMgmtRenameTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get catMgmtRenameTitle;

  /// No description provided for @catSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save category'**
  String get catSaveButton;

  /// No description provided for @catSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get catSaveChanges;

  /// No description provided for @catDeleteItemLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete category'**
  String get catDeleteItemLabel;

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

  /// No description provided for @catDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete category?'**
  String get catDeleteTitle;

  /// No description provided for @catDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Transactions linked to it will keep their data. This cannot be undone.'**
  String get catDeleteMessage;

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

  /// No description provided for @catMgmtAddButton.
  ///
  /// In en, this message translates to:
  /// **'+ Add'**
  String get catMgmtAddButton;

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

  /// No description provided for @reportsTabDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get reportsTabDay;

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

  /// No description provided for @profileSectionFinance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get profileSectionFinance;

  /// No description provided for @profileSectionLearnGrow.
  ///
  /// In en, this message translates to:
  /// **'Learn & Grow'**
  String get profileSectionLearnGrow;

  /// No description provided for @profileSectionSurveys.
  ///
  /// In en, this message translates to:
  /// **'Surveys'**
  String get profileSectionSurveys;

  /// No description provided for @profileSectionSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get profileSectionSupport;

  /// No description provided for @profileSendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get profileSendFeedback;

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

  /// No description provided for @budgetDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete budget?'**
  String get budgetDeleteTitle;

  /// No description provided for @budgetDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'This budget will be permanently removed. This cannot be undone.'**
  String get budgetDeleteMessage;

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

  /// No description provided for @goalDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete goal?'**
  String get goalDeleteTitle;

  /// No description provided for @goalDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'All your progress will be lost. This cannot be undone.'**
  String get goalDeleteMessage;

  /// No description provided for @goalsDueDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Due date (optional)'**
  String get goalsDueDateLabel;

  /// No description provided for @goalsMarkComplete.
  ///
  /// In en, this message translates to:
  /// **'Mark complete'**
  String get goalsMarkComplete;

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

  /// No description provided for @authVerifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter verification code'**
  String get authVerifyTitle;

  /// No description provided for @authVerifySubtitle.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to {email}. It expires in 15 minutes.'**
  String authVerifySubtitle(String email);

  /// No description provided for @authVerifyResend.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get authVerifyResend;

  /// No description provided for @authVerifyResendCooldown.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String authVerifyResendCooldown(int seconds);

  /// No description provided for @authBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get authBack;

  /// No description provided for @authCodeNotReceived.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive a code?'**
  String get authCodeNotReceived;

  /// No description provided for @authVerifyResendAvailable.
  ///
  /// In en, this message translates to:
  /// **'Resend available in {time}'**
  String authVerifyResendAvailable(String time);

  /// No description provided for @authVerifyButton.
  ///
  /// In en, this message translates to:
  /// **'Verify code'**
  String get authVerifyButton;

  /// No description provided for @authVerifyInvalidCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired code. Please try again.'**
  String get authVerifyInvalidCode;

  /// No description provided for @authLockedAccount.
  ///
  /// In en, this message translates to:
  /// **'Account locked. Try again in 15 minutes.'**
  String get authLockedAccount;

  /// No description provided for @authLockedCountdown.
  ///
  /// In en, this message translates to:
  /// **'Account locked. Try again in {time}.'**
  String authLockedCountdown(String time);

  /// No description provided for @authAttemptsRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 attempt remaining before lockout} other{{count} attempts remaining before lockout}}'**
  String authAttemptsRemaining(int count);

  /// No description provided for @goalsCompletedSection.
  ///
  /// In en, this message translates to:
  /// **'Completed goals'**
  String get goalsCompletedSection;

  /// No description provided for @goalsActiveSection.
  ///
  /// In en, this message translates to:
  /// **'Active goals'**
  String get goalsActiveSection;

  /// No description provided for @goalsDueDate.
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String goalsDueDate(String date);

  /// No description provided for @goalsDaysLeft.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 day left} other{{days} days left}}'**
  String goalsDaysLeft(int days);

  /// No description provided for @goalsOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get goalsOverdue;

  /// No description provided for @goalsCelebrate.
  ///
  /// In en, this message translates to:
  /// **'Goal achieved!'**
  String get goalsCelebrate;

  /// No description provided for @goalsCelebrateMessage.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! You reached your savings goal for \"{name}\".'**
  String goalsCelebrateMessage(String name);

  /// No description provided for @goalsMarkCompleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Mark this goal as completed?'**
  String get goalsMarkCompleteConfirm;

  /// No description provided for @goalsMarkCompleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This will close the goal and mark it as achieved.'**
  String get goalsMarkCompleteConfirmBody;

  /// No description provided for @goalsDetailDueDate.
  ///
  /// In en, this message translates to:
  /// **'Target date'**
  String get goalsDetailDueDate;

  /// No description provided for @goalsDetailDaysLeft.
  ///
  /// In en, this message translates to:
  /// **'Days remaining'**
  String get goalsDetailDaysLeft;

  /// No description provided for @goalsDetailMarkComplete.
  ///
  /// In en, this message translates to:
  /// **'Mark as achieved'**
  String get goalsDetailMarkComplete;

  /// No description provided for @goalsDetailDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete goal'**
  String get goalsDetailDelete;

  /// No description provided for @goalCompletedOn.
  ///
  /// In en, this message translates to:
  /// **'Completed on {date}'**
  String goalCompletedOn(String date);

  /// No description provided for @reportsCalendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Spending calendar'**
  String get reportsCalendarTitle;

  /// No description provided for @reportsCalendarNoData.
  ///
  /// In en, this message translates to:
  /// **'No spending on this day'**
  String get reportsCalendarNoData;

  /// No description provided for @reportsDayTotal.
  ///
  /// In en, this message translates to:
  /// **'S/ {total}'**
  String reportsDayTotal(String total);

  /// No description provided for @txAiSuggests.
  ///
  /// In en, this message translates to:
  /// **'Zenda suggests: {category}'**
  String txAiSuggests(String category);

  /// No description provided for @txAiApply.
  ///
  /// In en, this message translates to:
  /// **'Apply suggestion'**
  String get txAiApply;

  /// No description provided for @educationPersonalized.
  ///
  /// In en, this message translates to:
  /// **'Personalized for you'**
  String get educationPersonalized;

  /// No description provided for @educationPersonalizedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Topics ordered based on your spending patterns'**
  String get educationPersonalizedSubtitle;

  /// No description provided for @profileNumberFormat.
  ///
  /// In en, this message translates to:
  /// **'Number format'**
  String get profileNumberFormat;

  /// No description provided for @profileNumberFormatDot.
  ///
  /// In en, this message translates to:
  /// **'1,234.56 (dot decimal)'**
  String get profileNumberFormatDot;

  /// No description provided for @profileNumberFormatComma.
  ///
  /// In en, this message translates to:
  /// **'1.234,56 (comma decimal)'**
  String get profileNumberFormatComma;

  /// No description provided for @profileNumberFormatSaved.
  ///
  /// In en, this message translates to:
  /// **'Number format saved.'**
  String get profileNumberFormatSaved;

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

  /// No description provided for @predictionsLowConfidence.
  ///
  /// In en, this message translates to:
  /// **'Not enough data for a reliable prediction yet. Keep recording transactions to improve accuracy.'**
  String get predictionsLowConfidence;

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
  /// **'Not relevant'**
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

  /// No description provided for @challengesSectionActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get challengesSectionActive;

  /// No description provided for @challengesSectionAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get challengesSectionAvailable;

  /// No description provided for @challengesSectionCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get challengesSectionCompleted;

  /// No description provided for @challengesSectionExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get challengesSectionExpired;

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

  /// No description provided for @challengesCompleteButton.
  ///
  /// In en, this message translates to:
  /// **'Mark completed'**
  String get challengesCompleteButton;

  /// No description provided for @challengesCompleted.
  ///
  /// In en, this message translates to:
  /// **'Challenge completed!'**
  String get challengesCompleted;

  /// No description provided for @challengeAutoCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Challenge completed!'**
  String get challengeAutoCompletedTitle;

  /// No description provided for @challengeAutoCompletedBody.
  ///
  /// In en, this message translates to:
  /// **'You completed: {name}'**
  String challengeAutoCompletedBody(String name);

  /// No description provided for @challengeAutoCompletedDismiss.
  ///
  /// In en, this message translates to:
  /// **'Great!'**
  String get challengeAutoCompletedDismiss;

  /// No description provided for @challengeRewardBadge.
  ///
  /// In en, this message translates to:
  /// **'Reward: {badge} badge'**
  String challengeRewardBadge(String badge);

  /// No description provided for @challengeDaysLeft.
  ///
  /// In en, this message translates to:
  /// **'{days} days left'**
  String challengeDaysLeft(String days);

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

  /// No description provided for @surveyNextButton.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get surveyNextButton;

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

  /// No description provided for @surveyResultContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue to Dashboard'**
  String get surveyResultContinue;

  /// No description provided for @surveyImprovement.
  ///
  /// In en, this message translates to:
  /// **'Your financial knowledge improved by {points} points since the pre-survey!'**
  String surveyImprovement(String points);

  /// No description provided for @susSurveyTitle.
  ///
  /// In en, this message translates to:
  /// **'Usability Questionnaire'**
  String get susSurveyTitle;

  /// No description provided for @susSurveyDescription.
  ///
  /// In en, this message translates to:
  /// **'Rate each statement from 1 (Strongly Disagree) to 5 (Strongly Agree).'**
  String get susSurveyDescription;

  /// No description provided for @susSurveyStronglyDisagree.
  ///
  /// In en, this message translates to:
  /// **'Strongly Disagree'**
  String get susSurveyStronglyDisagree;

  /// No description provided for @susSurveyStronglyAgree.
  ///
  /// In en, this message translates to:
  /// **'Strongly Agree'**
  String get susSurveyStronglyAgree;

  /// No description provided for @susSurveySubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get susSurveySubmit;

  /// No description provided for @susSurveySubmitting.
  ///
  /// In en, this message translates to:
  /// **'Submitting...'**
  String get susSurveySubmitting;

  /// No description provided for @susSurveyAlreadyDone.
  ///
  /// In en, this message translates to:
  /// **'You have already submitted the usability questionnaire.'**
  String get susSurveyAlreadyDone;

  /// No description provided for @susSurveyErrorLoad.
  ///
  /// In en, this message translates to:
  /// **'Could not load the questionnaire. Please try again.'**
  String get susSurveyErrorLoad;

  /// No description provided for @susSurveyErrorSubmit.
  ///
  /// In en, this message translates to:
  /// **'Could not submit. Please try again.'**
  String get susSurveyErrorSubmit;

  /// No description provided for @susSurveyResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Usability Score'**
  String get susSurveyResultTitle;

  /// No description provided for @susSurveyResultScore.
  ///
  /// In en, this message translates to:
  /// **'Your SUS score: {score}/100'**
  String susSurveyResultScore(int score);

  /// No description provided for @susSurveyResultGrade.
  ///
  /// In en, this message translates to:
  /// **'Grade: {grade}'**
  String susSurveyResultGrade(String grade);

  /// No description provided for @susSurveyResultContinue.
  ///
  /// In en, this message translates to:
  /// **'Back to Profile'**
  String get susSurveyResultContinue;

  /// No description provided for @surveyComparisonPreLabel.
  ///
  /// In en, this message translates to:
  /// **'Pre-survey score'**
  String get surveyComparisonPreLabel;

  /// No description provided for @surveyComparisonPostLabel.
  ///
  /// In en, this message translates to:
  /// **'Post-survey score'**
  String get surveyComparisonPostLabel;

  /// No description provided for @surveyComparisonImprovementLabel.
  ///
  /// In en, this message translates to:
  /// **'Improvement'**
  String get surveyComparisonImprovementLabel;

  /// No description provided for @surveyComparisonGoalLabel.
  ///
  /// In en, this message translates to:
  /// **'Thesis target: ≥ 20 points'**
  String get surveyComparisonGoalLabel;

  /// No description provided for @surveyComparisonGoalMet.
  ///
  /// In en, this message translates to:
  /// **'Target reached!'**
  String get surveyComparisonGoalMet;

  /// No description provided for @surveyComparisonGoalNotMet.
  ///
  /// In en, this message translates to:
  /// **'Keep using the app to improve'**
  String get surveyComparisonGoalNotMet;

  /// No description provided for @surveyComparisonPending.
  ///
  /// In en, this message translates to:
  /// **'Complete both surveys to see your progress'**
  String get surveyComparisonPending;

  /// No description provided for @surveyComparisonPrePending.
  ///
  /// In en, this message translates to:
  /// **'Pre-survey not completed yet'**
  String get surveyComparisonPrePending;

  /// No description provided for @surveyComparisonPostPending.
  ///
  /// In en, this message translates to:
  /// **'Post-survey not completed yet'**
  String get surveyComparisonPostPending;

  /// No description provided for @surveyComparisonNavTitle.
  ///
  /// In en, this message translates to:
  /// **'Knowledge Progress'**
  String get surveyComparisonNavTitle;

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

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification Preferences'**
  String get notificationsTitle;

  /// No description provided for @notificationsErrorLoad.
  ///
  /// In en, this message translates to:
  /// **'Could not load preferences'**
  String get notificationsErrorLoad;

  /// No description provided for @notificationTypeBudgetAlert.
  ///
  /// In en, this message translates to:
  /// **'Budget alerts'**
  String get notificationTypeBudgetAlert;

  /// No description provided for @notificationTypeAnomalyAlert.
  ///
  /// In en, this message translates to:
  /// **'Unusual spending alerts'**
  String get notificationTypeAnomalyAlert;

  /// No description provided for @notificationTypePredictionReady.
  ///
  /// In en, this message translates to:
  /// **'Prediction ready'**
  String get notificationTypePredictionReady;

  /// No description provided for @notificationTypeChallengeReminder.
  ///
  /// In en, this message translates to:
  /// **'Challenge reminders'**
  String get notificationTypeChallengeReminder;

  /// No description provided for @notificationTypeDailyReminder.
  ///
  /// In en, this message translates to:
  /// **'Daily log reminder'**
  String get notificationTypeDailyReminder;

  /// No description provided for @notificationTypeBadgeEarned.
  ///
  /// In en, this message translates to:
  /// **'Badge earned'**
  String get notificationTypeBadgeEarned;

  /// No description provided for @consentTitle.
  ///
  /// In en, this message translates to:
  /// **'Your privacy matters'**
  String get consentTitle;

  /// No description provided for @consentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Before you start, please read how Zenda handles your financial data.'**
  String get consentSubtitle;

  /// No description provided for @consentBullet1.
  ///
  /// In en, this message translates to:
  /// **'Your data is encrypted and stored securely on Azure servers.'**
  String get consentBullet1;

  /// No description provided for @consentBullet2.
  ///
  /// In en, this message translates to:
  /// **'Your data is used only to generate personalized reports and AI predictions.'**
  String get consentBullet2;

  /// No description provided for @consentBullet3.
  ///
  /// In en, this message translates to:
  /// **'It is never shared with third parties. You can request deletion at any time.'**
  String get consentBullet3;

  /// No description provided for @consentBodyTitle.
  ///
  /// In en, this message translates to:
  /// **'What data do we collect?'**
  String get consentBodyTitle;

  /// No description provided for @consentBodyText.
  ///
  /// In en, this message translates to:
  /// **'Zenda collects your income and expense records, financial profile (age, university, income type), and app usage data to generate personalized predictions and recommendations. Your data is never shared with third parties and is stored securely.'**
  String get consentBodyText;

  /// No description provided for @consentLawNote.
  ///
  /// In en, this message translates to:
  /// **'This app complies with Peru\'s Personal Data Protection Law (Law 29733).'**
  String get consentLawNote;

  /// No description provided for @consentCheckbox.
  ///
  /// In en, this message translates to:
  /// **'I agree that my financial data will be processed to generate personalized reports and AI predictions.'**
  String get consentCheckbox;

  /// No description provided for @consentAcceptButton.
  ///
  /// In en, this message translates to:
  /// **'I agree — Let\'s get started'**
  String get consentAcceptButton;

  /// No description provided for @consentMustAccept.
  ///
  /// In en, this message translates to:
  /// **'You must accept to continue'**
  String get consentMustAccept;

  /// No description provided for @emailSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Account created!'**
  String get emailSentTitle;

  /// No description provided for @emailSentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Zenda, {name}'**
  String emailSentSubtitle(String name);

  /// No description provided for @emailSentBody.
  ///
  /// In en, this message translates to:
  /// **'A welcome email was sent to {email}. Now let\'s set up your financial profile.'**
  String emailSentBody(String email);

  /// No description provided for @emailSentContinue.
  ///
  /// In en, this message translates to:
  /// **'Set up my profile'**
  String get emailSentContinue;

  /// No description provided for @emailSentSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get emailSentSkip;

  /// No description provided for @profileSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us about yourself'**
  String get profileSetupTitle;

  /// No description provided for @profileSetupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Help Zenda personalize your experience. You can edit this anytime.'**
  String get profileSetupSubtitle;

  /// No description provided for @profileSetupStep.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String profileSetupStep(int step, int total);

  /// No description provided for @profileSetupSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get profileSetupSkip;

  /// No description provided for @profileSetupAge.
  ///
  /// In en, this message translates to:
  /// **'How old are you?'**
  String get profileSetupAge;

  /// No description provided for @profileSetupAgeHint.
  ///
  /// In en, this message translates to:
  /// **'This helps us understand your financial stage and tailor insights for you.'**
  String get profileSetupAgeHint;

  /// No description provided for @profileSetupUniversity.
  ///
  /// In en, this message translates to:
  /// **'Which university do you attend?'**
  String get profileSetupUniversity;

  /// No description provided for @profileSetupUniversityHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. PUCP, ULima, UNMSM...'**
  String get profileSetupUniversityHint;

  /// No description provided for @profileSetupUniversitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your campus location helps us suggest local financial resources.'**
  String get profileSetupUniversitySubtitle;

  /// No description provided for @profileSetupIncomeType.
  ///
  /// In en, this message translates to:
  /// **'What is your main income source?'**
  String get profileSetupIncomeType;

  /// No description provided for @profileSetupIncomeTypeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We use this to personalize your 50/30/20 budget recommendations.'**
  String get profileSetupIncomeTypeSubtitle;

  /// No description provided for @profileSetupMonthlyIncome.
  ///
  /// In en, this message translates to:
  /// **'What is your average monthly income?'**
  String get profileSetupMonthlyIncome;

  /// No description provided for @profileSetupMonthlyIncomeHint.
  ///
  /// In en, this message translates to:
  /// **'An estimate is fine. This calibrates your 50/30/20 budget targets.'**
  String get profileSetupMonthlyIncomeHint;

  /// No description provided for @profileSetupMonthlyIncomePerMonth.
  ///
  /// In en, this message translates to:
  /// **'per month'**
  String get profileSetupMonthlyIncomePerMonth;

  /// No description provided for @profileSetupNext.
  ///
  /// In en, this message translates to:
  /// **'Continue →'**
  String get profileSetupNext;

  /// No description provided for @profileSetupSave.
  ///
  /// In en, this message translates to:
  /// **'Finish setup →'**
  String get profileSetupSave;

  /// No description provided for @profileSetupCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'All set!'**
  String get profileSetupCompleteTitle;

  /// No description provided for @profileSetupCompleteTitleNamed.
  ///
  /// In en, this message translates to:
  /// **'All set, {name}!'**
  String profileSetupCompleteTitleNamed(String name);

  /// No description provided for @profileSetupCompleteBody.
  ///
  /// In en, this message translates to:
  /// **'Your profile is ready. Let\'s take control of your finances.'**
  String get profileSetupCompleteBody;

  /// No description provided for @profileSetupGoToDashboard.
  ///
  /// In en, this message translates to:
  /// **'Start using Zenda'**
  String get profileSetupGoToDashboard;

  /// No description provided for @incomeTypeScholarship.
  ///
  /// In en, this message translates to:
  /// **'Scholarship / Grant'**
  String get incomeTypeScholarship;

  /// No description provided for @incomeTypeScholarshipSub.
  ///
  /// In en, this message translates to:
  /// **'Scholarship, PRONABEC, university funding'**
  String get incomeTypeScholarshipSub;

  /// No description provided for @incomeTypePartTime.
  ///
  /// In en, this message translates to:
  /// **'Part-time / Freelance'**
  String get incomeTypePartTime;

  /// No description provided for @incomeTypePartTimeSub.
  ///
  /// In en, this message translates to:
  /// **'Job, gig work, side projects'**
  String get incomeTypePartTimeSub;

  /// No description provided for @incomeTypeFamily.
  ///
  /// In en, this message translates to:
  /// **'Family Support'**
  String get incomeTypeFamily;

  /// No description provided for @incomeTypeFamilySub.
  ///
  /// In en, this message translates to:
  /// **'Monthly allowance from family'**
  String get incomeTypeFamilySub;

  /// No description provided for @incomeTypeMixed.
  ///
  /// In en, this message translates to:
  /// **'Mixed'**
  String get incomeTypeMixed;

  /// No description provided for @incomeTypeMixedSub.
  ///
  /// In en, this message translates to:
  /// **'Combination of the above'**
  String get incomeTypeMixedSub;

  /// No description provided for @aiChatTitle.
  ///
  /// In en, this message translates to:
  /// **'Zenda AI'**
  String get aiChatTitle;

  /// No description provided for @aiChatSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Powered by your financial data'**
  String get aiChatSubtitle;

  /// No description provided for @aiChatInputHint.
  ///
  /// In en, this message translates to:
  /// **'Ask Zenda AI anything...'**
  String get aiChatInputHint;

  /// No description provided for @aiChatSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get aiChatSend;

  /// No description provided for @aiChatWelcome.
  ///
  /// In en, this message translates to:
  /// **'Hi! I\'m Zenda, your financial assistant. Ask me anything about budgets, savings, or expenses.'**
  String get aiChatWelcome;

  /// No description provided for @aiChatError.
  ///
  /// In en, this message translates to:
  /// **'Could not get a response. Please try again.'**
  String get aiChatError;

  /// No description provided for @aiChatNavLabel.
  ///
  /// In en, this message translates to:
  /// **'Zenda AI'**
  String get aiChatNavLabel;

  /// No description provided for @quizTitle.
  ///
  /// In en, this message translates to:
  /// **'Quiz'**
  String get quizTitle;

  /// No description provided for @quizQuestionOf.
  ///
  /// In en, this message translates to:
  /// **'Question {current} of {total}'**
  String quizQuestionOf(int current, int total);

  /// No description provided for @quizEmpty.
  ///
  /// In en, this message translates to:
  /// **'No quiz available for this topic yet.'**
  String get quizEmpty;

  /// No description provided for @quizSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get quizSubmit;

  /// No description provided for @quizCorrect.
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get quizCorrect;

  /// No description provided for @quizIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect'**
  String get quizIncorrect;

  /// No description provided for @quizResult.
  ///
  /// In en, this message translates to:
  /// **'You scored {score}%'**
  String quizResult(int score);

  /// No description provided for @quizFinish.
  ///
  /// In en, this message translates to:
  /// **'See results'**
  String get quizFinish;

  /// No description provided for @quizNext.
  ///
  /// In en, this message translates to:
  /// **'Next question'**
  String get quizNext;

  /// No description provided for @quizPersonalizedTitle.
  ///
  /// In en, this message translates to:
  /// **'Personalized Quiz'**
  String get quizPersonalizedTitle;

  /// No description provided for @quizPersonalizedButton.
  ///
  /// In en, this message translates to:
  /// **'Take personalized quiz'**
  String get quizPersonalizedButton;

  /// No description provided for @quizPersonalizedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'AI-generated questions based on your habits'**
  String get quizPersonalizedSubtitle;

  /// No description provided for @quizPersonalizedAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing your financial habits...'**
  String get quizPersonalizedAnalyzing;

  /// No description provided for @quizPersonalizedAttemptsLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 attempt left today} other{{count} attempts left today}}'**
  String quizPersonalizedAttemptsLeft(int count);

  /// No description provided for @quizPersonalizedLimitReached.
  ///
  /// In en, this message translates to:
  /// **'You reached the limit of 5 personalized quizzes for today.'**
  String get quizPersonalizedLimitReached;

  /// No description provided for @quizPersonalizedError.
  ///
  /// In en, this message translates to:
  /// **'Could not generate quiz. Please try again.'**
  String get quizPersonalizedError;

  /// No description provided for @educationRecommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get educationRecommended;

  /// No description provided for @reportsWeekDailyTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily activity'**
  String get reportsWeekDailyTitle;

  /// No description provided for @reportsProgressChipsTitle.
  ///
  /// In en, this message translates to:
  /// **'Changes vs previous month'**
  String get reportsProgressChipsTitle;

  /// No description provided for @reportsExpensesChip.
  ///
  /// In en, this message translates to:
  /// **'Expenses {sign}{pct}%'**
  String reportsExpensesChip(String sign, String pct);

  /// No description provided for @reportsSavingsChip.
  ///
  /// In en, this message translates to:
  /// **'Savings {sign}{pct}%'**
  String reportsSavingsChip(String sign, String pct);

  /// No description provided for @reportsBalanceChip.
  ///
  /// In en, this message translates to:
  /// **'Balance {sign}{pct}%'**
  String reportsBalanceChip(String sign, String pct);

  /// No description provided for @aiAdviceStartRecording.
  ///
  /// In en, this message translates to:
  /// **'Start recording expenses to receive personalized tips.'**
  String get aiAdviceStartRecording;

  /// No description provided for @aiAdviceReduceWants.
  ///
  /// In en, this message translates to:
  /// **'Your \'wants\' are running high ({pct}%). Consider cutting small habits like coffee or rides to rebalance.'**
  String aiAdviceReduceWants(String pct);

  /// No description provided for @aiAdviceSaveLow.
  ///
  /// In en, this message translates to:
  /// **'Your savings are low ({pct}%). Try setting aside a fixed amount at the start of each week, even if small.'**
  String aiAdviceSaveLow(String pct);

  /// No description provided for @aiAdviceOnTrack.
  ///
  /// In en, this message translates to:
  /// **'You\'re doing great! Your budget is balanced. Keep it up and consider investing your surplus.'**
  String get aiAdviceOnTrack;

  /// No description provided for @surveyResultDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Your results'**
  String get surveyResultDialogTitle;

  /// No description provided for @surveyResultDialogBody.
  ///
  /// In en, this message translates to:
  /// **'Your financial literacy level: {level} ({score}/100)'**
  String surveyResultDialogBody(String level, String score);

  /// No description provided for @surveyImprovementDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress measured!'**
  String get surveyImprovementDialogTitle;

  /// No description provided for @surveyImprovementDialogBody.
  ///
  /// In en, this message translates to:
  /// **'Score: {postScore}/100. Previous: {preScore}/100. You improved by {improvement} points!'**
  String surveyImprovementDialogBody(
    String postScore,
    String preScore,
    String improvement,
  );

  /// No description provided for @profileSectionPrivacy.
  ///
  /// In en, this message translates to:
  /// **'PRIVACY'**
  String get profileSectionPrivacy;

  /// No description provided for @profilePrivacyLaw.
  ///
  /// In en, this message translates to:
  /// **'Data protection — Ley 29733'**
  String get profilePrivacyLaw;

  /// No description provided for @profilePrivacyLawSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your data is protected under Peruvian law'**
  String get profilePrivacyLawSubtitle;

  /// No description provided for @profilePrivacyLawBody.
  ///
  /// In en, this message translates to:
  /// **'Zenda complies with Peru\'s Ley 29733 (Personal Data Protection). Your financial data is transmitted exclusively over HTTPS/TLS and stored securely. Access requires valid authentication at all times. You may revoke your consent at any time from this screen.'**
  String get profilePrivacyLawBody;

  /// No description provided for @profileRevokeConsent.
  ///
  /// In en, this message translates to:
  /// **'Revoke data consent'**
  String get profileRevokeConsent;

  /// No description provided for @profileRevokeConsentDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Revoke data consent?'**
  String get profileRevokeConsentDialogTitle;

  /// No description provided for @profileRevokeConsentDialogBody.
  ///
  /// In en, this message translates to:
  /// **'AI personalization features (predictions, recommendations) will be disabled. Your data will no longer be processed for AI. You can re-enable this in settings.'**
  String get profileRevokeConsentDialogBody;

  /// No description provided for @profileRevokeConsentConfirm.
  ///
  /// In en, this message translates to:
  /// **'Revoke'**
  String get profileRevokeConsentConfirm;

  /// No description provided for @profileRevokeConsentDone.
  ///
  /// In en, this message translates to:
  /// **'Data consent revoked. AI features are now disabled.'**
  String get profileRevokeConsentDone;

  /// No description provided for @profileConsentAlreadyRevoked.
  ///
  /// In en, this message translates to:
  /// **'Data consent has already been revoked.'**
  String get profileConsentAlreadyRevoked;

  /// No description provided for @reportsTabCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get reportsTabCategories;

  /// No description provided for @reportsPeriodWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get reportsPeriodWeek;

  /// No description provided for @reportsPeriodMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get reportsPeriodMonth;

  /// No description provided for @reportsPeriodQuarter.
  ///
  /// In en, this message translates to:
  /// **'Quarter'**
  String get reportsPeriodQuarter;

  /// No description provided for @reportsCategoryDrillTitle.
  ///
  /// In en, this message translates to:
  /// **'{category} transactions'**
  String reportsCategoryDrillTitle(String category);

  /// No description provided for @reportsCategoryNoTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions in this period'**
  String get reportsCategoryNoTransactions;

  /// No description provided for @txFilterCustomRange.
  ///
  /// In en, this message translates to:
  /// **'Date range'**
  String get txFilterCustomRange;

  /// No description provided for @txFilterDateFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get txFilterDateFrom;

  /// No description provided for @txFilterDateTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get txFilterDateTo;

  /// No description provided for @txFilterClearDates.
  ///
  /// In en, this message translates to:
  /// **'Clear dates'**
  String get txFilterClearDates;

  /// No description provided for @reportsEvolutionTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly evolution'**
  String get reportsEvolutionTitle;

  /// No description provided for @reportsEvolutionExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get reportsEvolutionExpenses;

  /// No description provided for @reportsEvolutionSavings.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get reportsEvolutionSavings;

  /// No description provided for @reportsEvolutionBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get reportsEvolutionBalance;

  /// No description provided for @reportsEvolutionNoData.
  ///
  /// In en, this message translates to:
  /// **'Add data for at least 2 months to see your evolution'**
  String get reportsEvolutionNoData;

  /// No description provided for @dashboardPostSurveyBannerAction.
  ///
  /// In en, this message translates to:
  /// **'Take survey'**
  String get dashboardPostSurveyBannerAction;

  /// No description provided for @authConfirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get authConfirmPasswordHint;

  /// No description provided for @validationPasswordsMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get validationPasswordsMismatch;

  /// No description provided for @dashboardTotalBalance.
  ///
  /// In en, this message translates to:
  /// **'Total Balance'**
  String get dashboardTotalBalance;

  /// No description provided for @dashboardViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get dashboardViewAll;

  /// No description provided for @dashboardMonthlyIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get dashboardMonthlyIncome;

  /// No description provided for @dashboardMonthlyExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get dashboardMonthlyExpense;

  /// No description provided for @dashboardCashDebitCredit.
  ///
  /// In en, this message translates to:
  /// **'Cash · Debit · Credit'**
  String get dashboardCashDebitCredit;

  /// No description provided for @goalsNewButton.
  ///
  /// In en, this message translates to:
  /// **'+ New'**
  String get goalsNewButton;

  /// No description provided for @goalsCreateButton.
  ///
  /// In en, this message translates to:
  /// **'Create goal'**
  String get goalsCreateButton;

  /// No description provided for @goalsContributeAddAction.
  ///
  /// In en, this message translates to:
  /// **'Add S/ {amount} to goal'**
  String goalsContributeAddAction(String amount);

  /// No description provided for @emailVerifTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get emailVerifTitle;

  /// No description provided for @emailVerifSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification link to {email}'**
  String emailVerifSubtitle(String email);

  /// No description provided for @emailVerifStep1.
  ///
  /// In en, this message translates to:
  /// **'Open the email from Zenda'**
  String get emailVerifStep1;

  /// No description provided for @emailVerifStep2.
  ///
  /// In en, this message translates to:
  /// **'Click the verification link'**
  String get emailVerifStep2;

  /// No description provided for @emailVerifStep3.
  ///
  /// In en, this message translates to:
  /// **'Return to the app to continue'**
  String get emailVerifStep3;

  /// No description provided for @emailVerifOpenApp.
  ///
  /// In en, this message translates to:
  /// **'Open Email App'**
  String get emailVerifOpenApp;

  /// No description provided for @emailVerifResendText.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive it?'**
  String get emailVerifResendText;

  /// No description provided for @emailVerifResendAction.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get emailVerifResendAction;

  /// No description provided for @txSavedTitle.
  ///
  /// In en, this message translates to:
  /// **'Transaction saved!'**
  String get txSavedTitle;

  /// No description provided for @txSavedBody.
  ///
  /// In en, this message translates to:
  /// **'Your expense has been recorded and your budget updated.'**
  String get txSavedBody;

  /// No description provided for @txSavedLabelAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get txSavedLabelAmount;

  /// No description provided for @txSavedLabelCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get txSavedLabelCategory;

  /// No description provided for @txSavedLabelDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get txSavedLabelDate;

  /// No description provided for @txSavedLabelBudget.
  ///
  /// In en, this message translates to:
  /// **'Budget impact'**
  String get txSavedLabelBudget;

  /// No description provided for @txSavedBackButton.
  ///
  /// In en, this message translates to:
  /// **'Back to Transactions'**
  String get txSavedBackButton;

  /// No description provided for @txSavedAddAnother.
  ///
  /// In en, this message translates to:
  /// **'Add Another'**
  String get txSavedAddAnother;

  /// No description provided for @authResetSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Password updated!'**
  String get authResetSuccessTitle;

  /// No description provided for @authResetSuccessBody.
  ///
  /// In en, this message translates to:
  /// **'Your password has been reset successfully. You can now sign in with your new password.'**
  String get authResetSuccessBody;

  /// No description provided for @authResetSuccessSecurity.
  ///
  /// In en, this message translates to:
  /// **'For your security, you\'ve been signed out of all devices.'**
  String get authResetSuccessSecurity;

  /// No description provided for @authResetSuccessButton.
  ///
  /// In en, this message translates to:
  /// **'Sign In Now'**
  String get authResetSuccessButton;

  /// No description provided for @authSetNewPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Set new password'**
  String get authSetNewPasswordTitle;

  /// No description provided for @authSetNewPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your new password must be at least 12 characters with 1 uppercase, 1 number.'**
  String get authSetNewPasswordSubtitle;

  /// No description provided for @authConfirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get authConfirmPasswordLabel;

  /// No description provided for @authPasswordStrengthWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get authPasswordStrengthWeak;

  /// No description provided for @authPasswordStrengthFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get authPasswordStrengthFair;

  /// No description provided for @authPasswordStrengthStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get authPasswordStrengthStrong;

  /// No description provided for @goalsDetailLeftToReach.
  ///
  /// In en, this message translates to:
  /// **'S/ {amount} left to reach your goal!'**
  String goalsDetailLeftToReach(String amount);

  /// No description provided for @goalsDetailAddContrib.
  ///
  /// In en, this message translates to:
  /// **'+ Add'**
  String get goalsDetailAddContrib;

  /// No description provided for @budgetByCategory.
  ///
  /// In en, this message translates to:
  /// **'By Category'**
  String get budgetByCategory;

  /// No description provided for @authForgotCodeExpiry.
  ///
  /// In en, this message translates to:
  /// **'The verification code expires in 15 minutes. Check your spam folder if you don\'t see it.'**
  String get authForgotCodeExpiry;

  /// No description provided for @aiChatQuickAnalyze.
  ///
  /// In en, this message translates to:
  /// **'Analyze spending'**
  String get aiChatQuickAnalyze;

  /// No description provided for @aiChatQuickBudget.
  ///
  /// In en, this message translates to:
  /// **'Budget tips'**
  String get aiChatQuickBudget;

  /// No description provided for @aiChatQuickGoal.
  ///
  /// In en, this message translates to:
  /// **'Goal progress'**
  String get aiChatQuickGoal;

  /// No description provided for @profileSetupAgeStepperLabel.
  ///
  /// In en, this message translates to:
  /// **'years old'**
  String get profileSetupAgeStepperLabel;

  /// No description provided for @profileSetupPopularUniversities.
  ///
  /// In en, this message translates to:
  /// **'Popular universities'**
  String get profileSetupPopularUniversities;

  /// No description provided for @profileSetupIncomeQuick500.
  ///
  /// In en, this message translates to:
  /// **'S/ 500'**
  String get profileSetupIncomeQuick500;

  /// No description provided for @profileSetupIncomeQuick1200.
  ///
  /// In en, this message translates to:
  /// **'S/ 1,200'**
  String get profileSetupIncomeQuick1200;

  /// No description provided for @profileSetupIncomeQuick2000.
  ///
  /// In en, this message translates to:
  /// **'S/ 2,000'**
  String get profileSetupIncomeQuick2000;

  /// No description provided for @educationSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search topics...'**
  String get educationSearchHint;

  /// No description provided for @educationTabLearn.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get educationTabLearn;

  /// No description provided for @educationTabChallenges.
  ///
  /// In en, this message translates to:
  /// **'Challenges'**
  String get educationTabChallenges;

  /// No description provided for @educationTabBadges.
  ///
  /// In en, this message translates to:
  /// **'Badges'**
  String get educationTabBadges;

  /// No description provided for @educationTabProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get educationTabProgress;

  /// No description provided for @educationTabPath.
  ///
  /// In en, this message translates to:
  /// **'Path'**
  String get educationTabPath;

  /// No description provided for @learningPathTitle.
  ///
  /// In en, this message translates to:
  /// **'My Learning Path'**
  String get learningPathTitle;

  /// No description provided for @educationFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get educationFilterAll;

  /// No description provided for @educationFilterBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get educationFilterBeginner;

  /// No description provided for @educationFilterIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get educationFilterIntermediate;

  /// No description provided for @educationFilterAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get educationFilterAdvanced;

  /// No description provided for @educationFeaturedLabel.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get educationFeaturedLabel;

  /// No description provided for @educationStartLabel.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get educationStartLabel;

  /// No description provided for @educationLearnGrow.
  ///
  /// In en, this message translates to:
  /// **'Learn & Grow'**
  String get educationLearnGrow;

  /// No description provided for @educationFilterBudgeting.
  ///
  /// In en, this message translates to:
  /// **'Budgeting'**
  String get educationFilterBudgeting;

  /// No description provided for @educationFilterSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving'**
  String get educationFilterSaving;

  /// No description provided for @educationFilterInvesting.
  ///
  /// In en, this message translates to:
  /// **'Investing'**
  String get educationFilterInvesting;

  /// No description provided for @educationTakeQuiz.
  ///
  /// In en, this message translates to:
  /// **'Take the Quiz'**
  String get educationTakeQuiz;

  /// No description provided for @educationMinRead.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min read'**
  String educationMinRead(int minutes);

  /// No description provided for @educationQuestions.
  ///
  /// In en, this message translates to:
  /// **'{count} questions'**
  String educationQuestions(int count);

  /// No description provided for @educationLocked.
  ///
  /// In en, this message translates to:
  /// **'Complete previous topics first'**
  String get educationLocked;

  /// No description provided for @quizAnswerRecorded.
  ///
  /// In en, this message translates to:
  /// **'Answer locked in. Tap Next to continue.'**
  String get quizAnswerRecorded;

  /// No description provided for @authSignUpLink.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get authSignUpLink;

  /// No description provided for @goalManualContribution.
  ///
  /// In en, this message translates to:
  /// **'Manual contribution'**
  String get goalManualContribution;

  /// No description provided for @goalTargetSuffix.
  ///
  /// In en, this message translates to:
  /// **'goal'**
  String get goalTargetSuffix;

  /// No description provided for @profileSetupSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save profile. Continuing anyway.'**
  String get profileSetupSaveError;

  /// No description provided for @profileSetupComplete40pct.
  ///
  /// In en, this message translates to:
  /// **'40% better predictions'**
  String get profileSetupComplete40pct;

  /// No description provided for @profileSetupCompleteImproves.
  ///
  /// In en, this message translates to:
  /// **'Completing your profile improves forecast accuracy.'**
  String get profileSetupCompleteImproves;

  /// No description provided for @budgetSelectPeriod.
  ///
  /// In en, this message translates to:
  /// **'Select period'**
  String get budgetSelectPeriod;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @profileCurrencyPEN.
  ///
  /// In en, this message translates to:
  /// **'PEN — Peruvian Sol (S/)'**
  String get profileCurrencyPEN;

  /// No description provided for @profileCurrencyUSD.
  ///
  /// In en, this message translates to:
  /// **'USD — US Dollar (\$)'**
  String get profileCurrencyUSD;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Your AI-powered finance companion'**
  String get splashTagline;

  /// No description provided for @splashFooter.
  ///
  /// In en, this message translates to:
  /// **'Made for Peruvian university students'**
  String get splashFooter;

  /// No description provided for @dashboardManageBudgets.
  ///
  /// In en, this message translates to:
  /// **'Tap to manage budgets'**
  String get dashboardManageBudgets;

  /// No description provided for @streakTapToView.
  ///
  /// In en, this message translates to:
  /// **'Tap to view progress'**
  String get streakTapToView;

  /// No description provided for @aiCardPredictionsChat.
  ///
  /// In en, this message translates to:
  /// **'Predictions & AI Chat'**
  String get aiCardPredictionsChat;

  /// No description provided for @aiCardViewForecast.
  ///
  /// In en, this message translates to:
  /// **'View forecast'**
  String get aiCardViewForecast;

  /// No description provided for @reportsVsLastMonth.
  ///
  /// In en, this message translates to:
  /// **'vs last month'**
  String get reportsVsLastMonth;

  /// No description provided for @reportsAiInsightsTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Insights'**
  String get reportsAiInsightsTitle;

  /// No description provided for @reportsAiInsightsSaved.
  ///
  /// In en, this message translates to:
  /// **'You saved more than last month. Great work!'**
  String get reportsAiInsightsSaved;

  /// No description provided for @reportsAiInsightsExceeded.
  ///
  /// In en, this message translates to:
  /// **'category exceeded limit.'**
  String get reportsAiInsightsExceeded;

  /// No description provided for @progressOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Month Overview'**
  String get progressOverviewTitle;

  /// No description provided for @progressTotalExpenses.
  ///
  /// In en, this message translates to:
  /// **'Total Expenses'**
  String get progressTotalExpenses;

  /// No description provided for @progressTotalSavings.
  ///
  /// In en, this message translates to:
  /// **'Total Savings'**
  String get progressTotalSavings;

  /// No description provided for @progressNetBalance.
  ///
  /// In en, this message translates to:
  /// **'Net Balance'**
  String get progressNetBalance;

  /// No description provided for @progressTrendTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly Trend'**
  String get progressTrendTitle;

  /// No description provided for @progressVsLabel.
  ///
  /// In en, this message translates to:
  /// **'vs'**
  String get progressVsLabel;

  /// No description provided for @progressSavingsLegend.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get progressSavingsLegend;

  /// No description provided for @badgesSectionEarned.
  ///
  /// In en, this message translates to:
  /// **'Earned'**
  String get badgesSectionEarned;

  /// No description provided for @badgesSectionLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get badgesSectionLocked;

  /// No description provided for @badgesEarnedLabel.
  ///
  /// In en, this message translates to:
  /// **'earned'**
  String get badgesEarnedLabel;

  /// No description provided for @predictionsProjectedBalance.
  ///
  /// In en, this message translates to:
  /// **'Projected Balance'**
  String get predictionsProjectedBalance;

  /// No description provided for @predictionsConfident.
  ///
  /// In en, this message translates to:
  /// **'confident'**
  String get predictionsConfident;

  /// No description provided for @predictionsBasedOnMonths.
  ///
  /// In en, this message translates to:
  /// **'Based on last 3 months'**
  String get predictionsBasedOnMonths;

  /// No description provided for @predictionsProjectedExpenses.
  ///
  /// In en, this message translates to:
  /// **'Projected expenses'**
  String get predictionsProjectedExpenses;

  /// No description provided for @predictionsTopCategories.
  ///
  /// In en, this message translates to:
  /// **'Top Expense Categories'**
  String get predictionsTopCategories;

  /// No description provided for @predictionsVsLastMonth.
  ///
  /// In en, this message translates to:
  /// **'8% vs last month'**
  String get predictionsVsLastMonth;

  /// No description provided for @recommendationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'3 personalized tips for you this week'**
  String get recommendationsSubtitle;

  /// No description provided for @recommendationsRateExperience.
  ///
  /// In en, this message translates to:
  /// **'Rate experience →'**
  String get recommendationsRateExperience;

  /// No description provided for @notificationsMasterTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get notificationsMasterTitle;

  /// No description provided for @notificationsMasterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive alerts and reminders'**
  String get notificationsMasterSubtitle;

  /// No description provided for @notificationsCategoriesLabel.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get notificationsCategoriesLabel;

  /// No description provided for @notificationSubtypeBudgetAlert.
  ///
  /// In en, this message translates to:
  /// **'When you reach 80% of your budget'**
  String get notificationSubtypeBudgetAlert;

  /// No description provided for @notificationSubtypeAnomalyAlert.
  ///
  /// In en, this message translates to:
  /// **'Unusual spending patterns detected'**
  String get notificationSubtypeAnomalyAlert;

  /// No description provided for @notificationSubtypePredictionReady.
  ///
  /// In en, this message translates to:
  /// **'Monthly prediction is ready'**
  String get notificationSubtypePredictionReady;

  /// No description provided for @notificationSubtypeChallengeReminder.
  ///
  /// In en, this message translates to:
  /// **'New challenges and badge earned'**
  String get notificationSubtypeChallengeReminder;

  /// No description provided for @notificationSubtypeDailyReminder.
  ///
  /// In en, this message translates to:
  /// **'Remind me to log transactions'**
  String get notificationSubtypeDailyReminder;

  /// No description provided for @notificationSubtypeBadgeEarned.
  ///
  /// In en, this message translates to:
  /// **'New badge earned'**
  String get notificationSubtypeBadgeEarned;

  /// No description provided for @surveySkipButton.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get surveySkipButton;

  /// No description provided for @surveyProgressOf.
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get surveyProgressOf;

  /// No description provided for @surveyCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Survey Complete!'**
  String get surveyCompleteTitle;

  /// No description provided for @surveyCompleteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Thanks for sharing! We\'ll use your answers to personalize Zenda for you.'**
  String get surveyCompleteSubtitle;

  /// No description provided for @surveyBadgeUnlocked.
  ///
  /// In en, this message translates to:
  /// **'badge unlocked!'**
  String get surveyBadgeUnlocked;

  /// No description provided for @surveyFinancialProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Financial Profile'**
  String get surveyFinancialProfileTitle;

  /// No description provided for @surveyFinancialProfileBody.
  ///
  /// In en, this message translates to:
  /// **'Based on your answers, Zenda has personalized your dashboard and recommendations to help you build better saving habits.'**
  String get surveyFinancialProfileBody;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSectionGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsSectionGeneral;

  /// No description provided for @settingsSectionResearch.
  ///
  /// In en, this message translates to:
  /// **'Research'**
  String get settingsSectionResearch;

  /// No description provided for @settingsCategoriesLabel.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get settingsCategoriesLabel;

  /// No description provided for @settingsNotificationsLabel.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotificationsLabel;

  /// No description provided for @settingsSurveysLabel.
  ///
  /// In en, this message translates to:
  /// **'Surveys'**
  String get settingsSurveysLabel;

  /// No description provided for @settingsSurveysSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Surveys'**
  String get settingsSurveysSheetTitle;

  /// No description provided for @settingsSurveyPreLabel.
  ///
  /// In en, this message translates to:
  /// **'Pre-Usage Survey'**
  String get settingsSurveyPreLabel;

  /// No description provided for @settingsSurveyPreSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Baseline financial literacy assessment'**
  String get settingsSurveyPreSubtitle;

  /// No description provided for @settingsSurveyPostLabel.
  ///
  /// In en, this message translates to:
  /// **'Post-Usage Survey'**
  String get settingsSurveyPostLabel;

  /// No description provided for @settingsSurveyPostSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Measure your progress after 30 days'**
  String get settingsSurveyPostSubtitle;

  /// No description provided for @settingsSurveySusLabel.
  ///
  /// In en, this message translates to:
  /// **'SUS Questionnaire'**
  String get settingsSurveySusLabel;

  /// No description provided for @settingsSurveySusSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Rate your experience with the app'**
  String get settingsSurveySusSubtitle;

  /// No description provided for @settingsSurveyComparisonLabel.
  ///
  /// In en, this message translates to:
  /// **'Knowledge Progress'**
  String get settingsSurveyComparisonLabel;

  /// No description provided for @settingsSurveyComparisonSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Compare your pre and post survey scores'**
  String get settingsSurveyComparisonSubtitle;

  /// No description provided for @settingsLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageLabel;

  /// No description provided for @settingsLanguageDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get settingsLanguageDialogTitle;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get settingsLanguageSpanish;

  /// No description provided for @aiChatOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get aiChatOnline;

  /// No description provided for @txListToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get txListToday;

  /// No description provided for @txListYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get txListYesterday;
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
