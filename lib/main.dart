import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/mock/demo_overrides.dart';

const bool _kDemoMode = true;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ProviderScope(
      overrides: _kDemoMode ? buildDemoOverrides() : const [],
      child: const App(),
    ),
  );
}

