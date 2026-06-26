import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'app.dart';
import 'core/config/app_config.dart';
import 'core/mock/demo_overrides.dart';
import 'core/services/fcm_service.dart';
import 'core/services/study_analytics_service.dart';
import 'core/services/user_api_service.dart';
import 'providers/repositories_providers.dart';

// Demo mode replaces every API service with an in-memory mock (no backend).
// Defaults to the REAL backend; enable via the flavor file or `--dart-define=DEMO=true`.
const bool _kDemoMode = AppConfig.isDemo;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // App is Spanish-only — make sure intl helpers (DateFormat, NumberFormat)
  // pick Spanish even when callers don't pass a locale explicitly.
  Intl.defaultLocale = 'es';
  await initializeDateFormatting('es');
  await StudyAnalyticsService.initialize(
    appEnv: AppConfig.env.name,
    betaDistributionId: AppConfig.betaDistributionId,
  );
  // Keep status bar and system navigation bar visible, and reserve their
  // space so they never overlay app content (Android 15+ defaults to
  // edge-to-edge, which would otherwise draw under the nav bar).
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: SystemUiOverlay.values,
  );

  final fcm = FcmService(NotificationsApiService());

  runApp(
    ProviderScope(
      overrides: [
        // Share the eager-initialized FCM instance with the rest of the app.
        fcmServiceProvider.overrideWithValue(fcm),
        if (_kDemoMode) ...buildDemoOverrides(),
      ],
      child: const App(),
    ),
  );

  // FCM is optional in local dev. Initialize it after the first frame so a
  // missing Firebase config can never block the app on a black native screen.
  unawaited(fcm.initialize());
}
