import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_controller.dart';
import 'features/notifications/notifications_inbox_providers.dart';
import 'l10n/app_localizations.dart';
import 'providers/repositories_providers.dart';
import 'routing/app_router.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  StreamSubscription<RemoteMessage>? _tapSub;

  @override
  void initState() {
    super.initState();
    // Open the inbox when the user taps a notification (background/terminated).
    final fcm = ref.read(fcmServiceProvider);
    _tapSub = fcm.onMessageTap.listen((_) {
      final router = ref.read(routerProvider);
      router.push('/notifications/inbox');
      // Refresh inbox so the just-arrived item is visible.
      ref.invalidate(notificationsInboxProvider);
    });
  }

  @override
  void dispose() {
    _tapSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Start the offline sync service once on app launch.
    ref.read(syncServiceProvider);

    // Auto-sync FCM token with the backend on auth transitions.
    ref.listen<AuthState>(authNotifierProvider, (prev, next) {
      final fcm = ref.read(fcmServiceProvider);
      final wasAuth = prev?.isAuthenticated ?? false;
      if (next.isAuthenticated && !wasAuth) {
        fcm.registerWithBackend();
      } else if (!next.isAuthenticated && wasAuth) {
        fcm.unregisterFromBackend();
      }
    });

    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Zenda',
      locale: const Locale('es'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es')],
      theme: AppTheme.lightTheme.copyWith(
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
      ),
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}
