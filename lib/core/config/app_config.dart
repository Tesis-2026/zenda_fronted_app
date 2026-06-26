/// Centralized build-time configuration, resolved from `--dart-define`s.
///
/// Values are injected per flavor via `--dart-define-from-file`:
///   flutter run --flavor dev  --dart-define-from-file=dart_defines/dev.json
///   flutter run --flavor prod --dart-define-from-file=dart_defines/prod.json
///   flutter run --dart-define=API_BASE_URL=http://localhost:3000/api
///
/// All getters are `const` so they can be used in const contexts and are
/// tree-shaken to a single literal per release build.
library;

/// The three known build environments.
enum AppEnv { dev, prod }

class AppConfig {
  const AppConfig._();

  /// Raw environment name. Defaults to `prod` so a plain `flutter build`
  /// without a flavor file behaves as production.
  static const String _envName = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'prod',
  );

  /// Parsed environment. Anything other than `dev` is treated as `prod`.
  static AppEnv get env => _envName == 'dev' ? AppEnv.dev : AppEnv.prod;

  static bool get isDev => env == AppEnv.dev;
  static bool get isProd => env == AppEnv.prod;

  /// Backend base URL. Falls back to localhost so a no-flavor run still works
  /// against a local backend.
  static const String _apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  // Backwards-compatible alias used by earlier local run commands.
  static const String _legacyZendaApiBaseUrl = String.fromEnvironment(
    'ZENDA_API_BASE_URL',
    defaultValue: '',
  );

  static const String apiBaseUrl = _apiBaseUrl != ''
      ? _apiBaseUrl
      : (_legacyZendaApiBaseUrl != ''
            ? _legacyZendaApiBaseUrl
            : 'http://localhost:3000/api');

  /// Identifier of the beta distributed to pilot testers. It is attached to
  /// analytics events so thesis exports can separate cohorts/builds.
  static const String betaDistributionId = String.fromEnvironment(
    'BETA_DISTRIBUTION_ID',
    defaultValue: 'local',
  );

  /// When true, every API service is replaced by an in-memory mock (no backend).
  static const bool isDemo = bool.fromEnvironment('DEMO', defaultValue: false);
}
