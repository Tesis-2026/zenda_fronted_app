import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:zenda_fronted/core/models/transaction.dart';
import 'package:zenda_fronted/core/models/user.dart';
import 'package:zenda_fronted/core/services/local_kv_store.dart';
import 'package:zenda_fronted/core/services/transactions_repository.dart';
import 'package:zenda_fronted/core/services/api_client.dart';
import 'package:zenda_fronted/core/services/pending_transaction_queue.dart';
import 'package:zenda_fronted/core/services/progress_api_service.dart';
import 'package:zenda_fronted/core/services/sync_service.dart';
import 'package:zenda_fronted/core/services/transaction_api_service.dart';
import 'package:zenda_fronted/features/auth/auth_controller.dart';
import 'package:zenda_fronted/features/dashboard/dashboard_providers.dart';
import 'package:zenda_fronted/features/progress/progress_screen.dart';
import 'package:zenda_fronted/l10n/app_localizations.dart';

class ReviewAuth extends AuthNotifier {
  @override
  AuthState build() => AuthState.authenticated(
    User(id: 'b', name: 'B', email: 'b@example.test'),
  );

  void switchUser(String id) {
    state = AuthState.authenticated(
      User(id: id, name: id, email: '$id@example.test'),
    );
  }
}

String token(String owner) =>
    'header.${base64Url.encode(utf8.encode(jsonEncode({'sub': owner})))}.signature';

PendingSyncEntry entry(String id, String? owner) => PendingSyncEntry(
  txId: id,
  userId: owner,
  kind: TransactionKind.expense,
  amount: 12.50,
  category: TransactionCategory.comida,
  occurredAt: DateTime.utc(2026, 9, 1),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(
    () => FlutterSecureStorage.setMockInitialValues({
      'zenda.access_token': token('b'),
      'zenda.refresh_token': 'refresh-b',
    }),
  );

  test(
    'recommendations and local financial rows are isolated after switching user',
    () async {
      final container = ProviderContainer(
        overrides: [authNotifierProvider.overrideWith(ReviewAuth.new)],
      );
      addTearDown(container.dispose);
      await TransactionsRepository(LocalKvStore()).saveTransactions([
        for (final owner in ['a', 'b'])
          TransactionModel.fromApiJson({
            'id': '$owner-tx',
            'userId': owner,
            'amount': 12.5,
            'occurredAt': '2026-09-01T12:00:00Z',
          }),
      ]);
      await http.runWithClient(
        () async {
          container.listen(transactionsProvider, (_, _) {});
          container.listen(recommendationsProvider, (_, _) {});
          expect(
            (await container.read(transactionsProvider.future)).single.userId,
            'b',
          );
          expect(
            (await container.read(recommendationsProvider.future)).single.id,
            'b-rec',
          );
          await ApiClient.saveTokens(
            accessToken: token('a'),
            refreshToken: 'refresh-a',
          );
          (container.read(authNotifierProvider.notifier) as ReviewAuth)
              .switchUser('a');
          expect(
            (await container.read(transactionsProvider.future)).single.userId,
            'a',
          );
          expect(
            (await container.read(recommendationsProvider.future)).single.id,
            'a-rec',
          );
        },
        () => MockClient((request) async {
          final owner =
              request.headers['authorization'] == 'Bearer ${token('b')}'
              ? 'b'
              : 'a';
          return http.Response(
            '[{"id":"$owner-rec","message":"Private recommendation"}]',
            200,
          );
        }),
      );
    },
  );

  testWidgets(
    'current progress cannot be relabelled as an unqueried historical month',
    (tester) async {
      await initializeDateFormatting('es');
      const month = MonthFinancials(
        income: 51,
        expenses: 21,
        balance: 30,
        savings: 30,
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            progressProvider.overrideWith(
              (ref) async => const FinancialProgress(
                currentMonth: month,
                previousMonth: month,
              ),
            ),
          ],
          child: const MaterialApp(
            locale: Locale('es'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: ProgressScreen(embedded: true)),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.chevron_left_rounded), findsNothing);
      expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'progress failure displays retry without fabricated financial totals',
    (tester) async {
      var calls = 0;
      await tester.pumpWidget(
        ProviderScope(
          retry: (_, _) => null,
          overrides: [
            progressProvider.overrideWith((ref) async {
              calls++;
              throw const SocketException('offline');
            }),
          ],
          child: const MaterialApp(
            locale: Locale('es'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: ProgressScreen(embedded: true)),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text(
          'No se pudo cargar tu progreso financiero. Intenta nuevamente.',
        ),
        findsOneWidget,
      );
      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.textContaining('760'), findsNothing);
      expect(find.textContaining('1,240'), findsNothing);
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      expect(calls, 2);
    },
  );

  test(
    'sync sends only current owner and preserves foreign and legacy entries',
    () async {
      final queue = PendingTransactionQueue();
      await Future.wait([
        queue.enqueue(entry('a-1', 'a')),
        queue.enqueue(entry('b-1', 'b')),
        queue.enqueue(entry('legacy', null)),
      ]);
      var writes = 0;
      final client = MockClient((request) async {
        if (request.method == 'GET') {
          return http.Response(
            '[{"id":"food","name":"Food","transactionType":"EXPENSE"}]',
            200,
          );
        }
        writes++;
        expect(request.headers['authorization'], 'Bearer ${token('b')}');
        expect(request.headers['idempotency-key'], 'b-1');
        return http.Response('{"id":"server-b-1"}', 201);
      });
      await http.runWithClient(() async {
        final sync = SyncService(queue, TransactionApiService());
        await Future.wait([sync.flushPending(), sync.flushPending()]);
      }, () => client);
      expect(writes, 1);
      expect((await queue.getAll()).map((e) => e.txId), ['a-1', 'legacy']);
    },
  );

  test(
    'session change during category lookup cannot post previous owner data',
    () async {
      final queue = PendingTransactionQueue();
      await queue.enqueue(entry('b-1', 'b'));
      var writes = 0;
      final client = MockClient((request) async {
        if (request.method == 'GET') {
          await ApiClient.saveTokens(
            accessToken: token('c'),
            refreshToken: 'refresh-c',
          );
          return http.Response('[]', 200);
        }
        writes++;
        return http.Response('{}', 201);
      });
      await http.runWithClient(
        () => SyncService(queue, TransactionApiService()).flushPending(),
        () => client,
      );
      expect(writes, 0);
      expect(await queue.getAll(), hasLength(1));
    },
  );

  test(
    'offline entries survive exhausted retries and can sync after restart',
    () async {
      final queue = PendingTransactionQueue();
      await queue.enqueue(entry('b-1', 'b'));
      final sync = SyncService(queue, TransactionApiService());
      await http.runWithClient(() async {
        for (var i = 0; i < 4; i++) {
          await sync.flushPending();
        }
      }, () => MockClient((_) async => throw const SocketException('offline')));
      expect(await queue.getAll(), hasLength(1));
      await http.runWithClient(
        () => SyncService(queue, TransactionApiService()).flushPending(),
        () => MockClient(
          (request) async => http.Response(
            request.method == 'GET' ? '[]' : '{"id":"saved"}',
            request.method == 'GET' ? 200 : 201,
          ),
        ),
      );
      expect(await queue.getAll(), isEmpty);
    },
  );

  for (final status in [200, 401]) {
    test(
      'late refresh $status cannot replace or clear a new session',
      () async {
        final started = Completer<void>();
        final response = Completer<http.Response>();
        await http.runWithClient(
          () async {
            final refresh = ApiClient.refreshSession();
            await started.future;
            await ApiClient.saveTokens(
              accessToken: token('c'),
              refreshToken: 'refresh-c',
            );
            response.complete(
              http.Response(
                '{"accessToken":"old-refreshed","refreshToken":"old-refresh"}',
                status,
              ),
            );
            expect(await refresh, isFalse);
            expect(await ApiClient.getToken(), token('c'));
            expect(await ApiClient.getRefreshToken(), 'refresh-c');
          },
          () => MockClient((_) {
            started.complete();
            return response.future;
          }),
        );
      },
    );
  }

  test('owner guard also applies after automatic token refresh', () async {
    var writes = 0;
    await http.runWithClient(
      () async {
        await expectLater(
          ApiClient.post(
            '/transactions',
            {'amount': 12.5},
            authenticated: true,
            expectedUserId: 'b',
            idempotencyKey: 'b-1',
          ),
          throwsA(isA<ApiException>()),
        );
      },
      () => MockClient((request) async {
        if (request.url.path.endsWith('/auth/refresh')) {
          return http.Response(
            jsonEncode({
              'accessToken': token('c'),
              'refreshToken': 'refresh-c',
            }),
            200,
          );
        }
        writes++;
        return http.Response('{}', 401);
      }),
    );
    expect(writes, 1);
  });
}
