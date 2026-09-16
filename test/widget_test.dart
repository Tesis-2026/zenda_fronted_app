import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:zenda_fronted/app.dart';

void main() {
  testWidgets('Zenda app renders', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
