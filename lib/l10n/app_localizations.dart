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
