/// Locale-agnostic error code constants.
///
/// Business logic (services, controllers) sets these codes on error state.
/// The UI layer resolves them to localized strings via [AppLocalizations]
/// (see [lib/l10n/l10n_extension.dart]).
///
/// Keeping codes here means the service layer has zero knowledge of locale,
/// and adding a new language only requires updating the ARB files.
abstract final class AuthErrorCode {
  /// Wrong email/password combination, or account does not exist.
  static const invalidCredentials = 'auth.invalidCredentials';

  /// Email is already registered.
  static const emailTaken = 'auth.emailTaken';

  /// Password-reset token is invalid or has expired.
  static const tokenExpired = 'auth.tokenExpired';

  /// Server returned a 400 with a specific validation message.
  /// The raw backend message is appended after a '|' separator so the UI
  /// can display it as-is: split on '|' and take index 1.
  static const badRequest = 'auth.badRequest';

  /// Unexpected server error (5xx or unknown status).
  static const serverError = 'auth.serverError';

  /// Network unreachable or connection timed out.
  static const noConnection = 'auth.noConnection';

  /// Account is temporarily locked after too many failed attempts.
  static const accountLocked = 'auth.accountLocked';
}

abstract final class TxErrorCode {
  /// No source account selected before saving.
  static const noSourceAccount = 'tx.noSourceAccount';

  /// Amount is zero, negative, or not entered.
  static const invalidAmount = 'tx.invalidAmount';

  /// No category selected.
  static const noCategory = 'tx.noCategory';

  /// Transfer requires a destination account.
  static const noDestAccount = 'tx.noDestAccount';

  /// Source and destination accounts are the same.
  static const sameAccount = 'tx.sameAccount';

  /// Resolved source account not found in local storage.
  static const invalidSourceAccount = 'tx.invalidSourceAccount';

  /// Resolved destination account not found in local storage.
  static const invalidDestAccount = 'tx.invalidDestAccount';

  /// Transferring FROM a credit card is not supported in the current demo.
  static const creditTransferNotSupported = 'tx.creditTransferNotSupported';

  /// Generic save failure; original exception message follows a '|' separator.
  static const saveFailed = 'tx.saveFailed';
}
