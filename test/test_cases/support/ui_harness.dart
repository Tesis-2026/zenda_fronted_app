// UI harness for the thesis test cases (TP202610012_Casos_De_Prueba).
//
// Each case pumps the real screen with the app's mock services, then calls
// [CaseRecorder.step] after every action. A step captures a PNG of the screen
// plus its caption into build/test_recordings/<CP>/, so every run leaves a
// step-by-step recording (tool/test_recordings turns them into GIFs + report).
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zenda_fronted/core/mock/demo_data.dart';
import 'package:zenda_fronted/core/mock/demo_overrides.dart';
import 'package:zenda_fronted/core/models/user.dart';
import 'package:zenda_fronted/core/services/money_format.dart';
import 'package:zenda_fronted/core/theme/app_theme.dart';
import 'package:zenda_fronted/features/auth/auth_controller.dart';
import 'package:zenda_fronted/features/dashboard/dashboard_providers.dart';
import 'package:zenda_fronted/l10n/app_localizations.dart';

/// Phone-sized logical viewport used for every recording.
const Size kPhoneSize = Size(390, 844);
const double _kPixelRatio = 2;

final _rootKey = GlobalKey();
bool _fontsLoaded = false;

String get _flutterRoot {
  final fromEnv = Platform.environment['FLUTTER_ROOT'];
  if (fromEnv != null && fromEnv.isNotEmpty) return fromEnv;
  // flutter_tester runs from <flutter>/bin/cache/artifacts/engine/<platform>.
  final exe = File(Platform.resolvedExecutable).parent;
  return exe.parent.parent.parent.parent.parent.path;
}

/// Loads Roboto + Material Icons so recordings show real text instead of the
/// test font's boxes. Call from setUpAll.
Future<void> loadRecordingFonts() async {
  if (_fontsLoaded) return;
  final fonts = '$_flutterRoot/bin/cache/artifacts/material_fonts';
  Future<void> load(String family, List<String> files) async {
    final loader = FontLoader(family);
    for (final f in files) {
      final file = File('$fonts/$f');
      if (!file.existsSync()) continue;
      final bytes = file.readAsBytesSync();
      loader.addFont(Future.value(ByteData.sublistView(bytes)));
    }
    await loader.load();
  }

  const roboto = [
    'roboto-regular.ttf',
    'roboto-medium.ttf',
    'roboto-bold.ttf',
    'roboto-black.ttf',
    'roboto-light.ttf',
  ];
  await load('Roboto', roboto);
  // The app requests Inter (Google Fonts, fetched at runtime in the app);
  // offline tests render it with Roboto metrics instead.
  await load('Inter', roboto);
  await load('MaterialIcons', ['materialicons-regular.otf']);
  _fontsLoaded = true;
}

/// Authenticated demo session (profile complete) unless [user] says otherwise.
class FixedAuthNotifier extends AuthNotifier {
  FixedAuthNotifier(this.user);
  final User? user;

  @override
  AuthState build() => user == null
      ? const AuthState.unauthenticated()
      : AuthState.authenticated(user!);

  @override
  void updateCurrentUser(User user) {
    state = AuthState.authenticated(user);
  }
}

/// Records one test case: screenshots + captions per step.
class CaseRecorder {
  CaseRecorder(this.tester, this.caseId, this.title)
    : _dir = Directory('build/test_recordings/$caseId') {
    if (_dir.existsSync()) _dir.deleteSync(recursive: true);
    _dir.createSync(recursive: true);
  }

  final WidgetTester tester;
  final String caseId;
  final String title;
  final Directory _dir;
  final List<Map<String, String>> _steps = [];

  /// Settles the UI, then captures the screen with [description].
  Future<void> step(String description) async {
    await settle(tester);
    final index = (_steps.length + 1).toString().padLeft(2, '0');
    final file = 'step_$index.png';
    final boundary =
        _rootKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    await tester.runAsync(() async {
      final ui.Image screen = await boundary.toImage(pixelRatio: _kPixelRatio);
      final framed = _withCaption(screen, '$caseId · $title', description);
      final data = await framed.toByteData(format: ui.ImageByteFormat.png);
      File('${_dir.path}/$file').writeAsBytesSync(data!.buffer.asUint8List());
      screen.dispose();
      framed.dispose();
    });
    _steps.add({'n': index, 'description': description, 'image': file});
    File('${_dir.path}/steps.json').writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert({
        'caseId': caseId,
        'title': title,
        'steps': _steps,
      }),
    );
  }
}

const double _kCaptionHeight = 150;

ui.Paragraph _paragraph(String text, double size, Color color, double width,
    {FontWeight weight = FontWeight.w400}) {
  final builder =
      ui.ParagraphBuilder(
          ui.ParagraphStyle(fontFamily: 'Roboto', fontSize: size, maxLines: 2),
        )
        ..pushStyle(ui.TextStyle(color: color, fontWeight: weight))
        ..addText(text);
  return builder.build()..layout(ui.ParagraphConstraints(width: width));
}

/// Stacks a caption band (case + step) above [screen] so every frame of a
/// recording explains itself.
ui.Image _withCaption(ui.Image screen, String header, String step) {
  final width = screen.width.toDouble();
  final height = screen.height + _kCaptionHeight;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(
    Rect.fromLTWH(0, 0, width, _kCaptionHeight),
    Paint()..color = const Color(0xFF1F2937),
  );
  canvas.drawParagraph(
    _paragraph(header, 24, const Color(0xFF34D399), width - 48,
        weight: FontWeight.w700),
    const Offset(24, 18),
  );
  canvas.drawParagraph(
    _paragraph(step, 28, Colors.white, width - 48, weight: FontWeight.w500),
    const Offset(24, 60),
  );
  canvas.drawImage(screen, const Offset(0, _kCaptionHeight), Paint());
  return recorder.endRecording().toImageSync(screen.width, height.toInt());
}

/// Declares one recorded test case. [body] receives the recorder; afterwards
/// the app is unmounted and pending timers (toasts, debounces) are flushed so
/// a case never leaks into the next.
void caseTest(
  String caseId,
  String title,
  Future<void> Function(WidgetTester tester, CaseRecorder rec) body,
) {
  testWidgets('$caseId: $title', (tester) async {
    final rec = CaseRecorder(tester, caseId, title);
    await body(tester, rec);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(minutes: 1));
  });
}

/// Pumps frames without waiting for endless animations (spinners, timers).
Future<void> settle(WidgetTester tester, {int frames = 12}) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Mounts [screen] at "/" inside the app shell (theme, Spanish l10n, money
/// format, GoRouter). Any other route renders a marker page so navigation can
/// be asserted with [find.text]('Ruta: /path').
Future<void> pumpScreen(
  WidgetTester tester,
  Widget screen, {
  List<Override> overrides = const [],
  User? user,
  bool authenticated = true,
  Map<String, Object> prefs = const {},
  List<RouteBase> extraRoutes = const [],
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  FlutterSecureStorage.setMockInitialValues({});
  tester.view.physicalSize = kPhoneSize * _kPixelRatio;
  tester.view.devicePixelRatio = _kPixelRatio;
  addTearDown(tester.view.reset);

  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => screen),
      ...extraRoutes,
      GoRoute(
        path: '/:path(.*)',
        builder: (_, state) => Scaffold(
          body: Center(child: Text('Ruta: ${state.uri.path}')),
        ),
      ),
    ],
  );

  final base = AppTheme.lightTheme;
  // The app gets Inter from Google Fonts at runtime; offline tests pin every
  // themed style to the bundled Roboto so recordings show real text.
  final theme = base.copyWith(
    textTheme: base.textTheme.apply(fontFamily: 'Roboto'),
    appBarTheme: base.appBarTheme.copyWith(
      titleTextStyle: base.appBarTheme.titleTextStyle?.copyWith(
        fontFamily: 'Roboto',
      ),
    ),
  );

  // Case-specific overrides replace the demo ones targeting the same provider
  // (a container refuses two overrides of one provider).
  final caseOverrides = [
    authNotifierProvider.overrideWith(
      () => FixedAuthNotifier(authenticated ? (user ?? DemoData.user) : null),
    ),
    ...overrides,
  ];
  // The app has no accounts concept any more; demo mode never mocked it.
  if (!caseOverrides.any((o) => o.origin == accountsProvider)) {
    caseOverrides.add(accountsProvider.overrideWith((ref) async => const []));
  }
  final taken = caseOverrides.map((o) => o.origin).toSet();
  final demo = buildDemoOverrides().where((o) => !taken.contains(o.origin));

  await tester.pumpWidget(
    ProviderScope(
      overrides: [...demo, ...caseOverrides],
      child: Consumer(
        builder: (context, ref, _) => RepaintBoundary(
          key: _rootKey,
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            locale: const Locale('es'),
            supportedLocales: const [Locale('es')],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: theme.copyWith(
              textTheme: theme.textTheme,
              primaryTextTheme: theme.primaryTextTheme.apply(
                fontFamily: 'Roboto',
              ),
            ),
            routerConfig: router,
            builder: (context, child) => MoneyScope(
              format: ref.watch(moneyFormatProvider),
              child: DefaultTextStyle.merge(
                style: const TextStyle(fontFamily: 'Roboto'),
                child: child ?? const SizedBox.shrink(),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await settle(tester);
}

/// Types [text] into the [index]-th TextField on screen.
Future<void> typeInto(WidgetTester tester, int index, String text) async {
  await tester.enterText(find.byType(TextField).at(index), text);
  await settle(tester, frames: 3);
}

/// Taps the first widget showing [text] (scrolling it into view first).
Future<void> tapText(WidgetTester tester, String text) async {
  final finder = find.text(text).first;
  await tester.ensureVisible(finder);
  await settle(tester, frames: 2);
  await tester.tap(finder);
  await settle(tester, frames: 4);
}
