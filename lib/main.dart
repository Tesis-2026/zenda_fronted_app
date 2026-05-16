import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/mock/demo_overrides.dart';

const bool _kDemoMode = true;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Keep status bar and system navigation bar visible, and reserve their
  // space so they never overlay app content (Android 15+ defaults to
  // edge-to-edge, which would otherwise draw under the nav bar).
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: SystemUiOverlay.values,
  );
  runApp(
    ProviderScope(
      overrides: _kDemoMode ? buildDemoOverrides() : const [],
      child: const App(),
    ),
  );
}

