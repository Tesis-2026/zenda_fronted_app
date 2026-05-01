import 'package:flutter/material.dart';
import '../core/errors/error_codes.dart';
import 'app_localizations.dart';

extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

extension ErrorL10n on AppLocalizations {
  /// Resolves an [ErrorCode] string to a localized, user-facing message.
  ///
  /// Some codes carry a payload after a `|` separator (e.g. raw backend
  /// message for [AuthErrorCode.badRequest]). The resolver extracts it when
  /// present. Unknown codes fall back to [errorServerError].
  String resolveError(String code) {
    // Codes with optional payload: "auth.badRequest|<message>"
    final parts = code.split('|');
    final base = parts[0];
    final payload = parts.length > 1 ? parts[1] : null;

    return switch (base) {
      // ── Auth ────────────────────────────────────────────────────────────
      AuthErrorCode.invalidCredentials => errorAuthInvalidCredentials,
      AuthErrorCode.emailTaken => errorAuthEmailTaken,
      AuthErrorCode.tokenExpired => errorAuthTokenExpired,
      AuthErrorCode.badRequest => payload ?? errorAuthBadRequest,
      AuthErrorCode.serverError => errorServerError,
      AuthErrorCode.noConnection => errorNoConnection,
      AuthErrorCode.accountLocked => authLockedAccount,
      // ── Transactions ────────────────────────────────────────────────────
      TxErrorCode.noSourceAccount => errorTxNoSourceAccount,
      TxErrorCode.invalidAmount => errorTxInvalidAmount,
      TxErrorCode.noCategory => errorTxNoCategory,
      TxErrorCode.noDestAccount => errorTxNoDestAccount,
      TxErrorCode.sameAccount => errorTxSameAccount,
      TxErrorCode.invalidSourceAccount => errorTxInvalidSourceAccount,
      TxErrorCode.invalidDestAccount => errorTxInvalidDestAccount,
      TxErrorCode.creditTransferNotSupported => errorTxCreditTransferNotSupported,
      TxErrorCode.saveFailed => errorTxSaveFailed,
      // ── Fallback ────────────────────────────────────────────────────────
      _ => errorServerError,
    };
  }
}
