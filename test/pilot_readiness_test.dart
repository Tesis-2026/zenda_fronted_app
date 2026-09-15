import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:zenda_fronted/core/models/transaction.dart';
import 'package:zenda_fronted/core/services/api_client.dart';
import 'package:zenda_fronted/core/services/local_kv_store.dart';
import 'package:zenda_fronted/core/services/telemetry_policy.dart';
import 'package:zenda_fronted/core/services/transaction_api_service.dart';
import 'package:zenda_fronted/core/services/transactions_repository.dart';
import 'package:zenda_fronted/features/transactions/controllers/new_transaction_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({
      'zenda.access_token': 'test',
      'zenda.refresh_token': 'refresh-test',
    });
  });

  test(
    'clearing the amount does not retain the previous transaction value',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final controller = container.read(
        newTransactionControllerProvider.notifier,
      );
      controller.setAmountFromText('51');
      expect(container.read(newTransactionControllerProvider).amount, 51);
      controller.setAmountFromText('');
      expect(container.read(newTransactionControllerProvider).amount, isNull);
    },
  );
  for (final value in ['-5', '0x51', 'abc', '5.001', 'NaN', 'Infinity']) {
    test('reject malformed amount $value', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container
          .read(newTransactionControllerProvider.notifier)
          .setAmountFromText(value);
      expect(container.read(newTransactionControllerProvider).amount, isNull);
    });
  }
  test('comma decimal input preserves cents', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container
        .read(newTransactionControllerProvider.notifier)
        .setAmountFromText('51,25');
    expect(container.read(newTransactionControllerProvider).amount, 51.25);
  });
  test('POST keeps idempotency header after refreshing access token', () async {
    var posts = 0;
    final client = MockClient((request) async {
      if (request.url.path.endsWith('/auth/refresh')) {
        return http.Response(
          jsonEncode({
            'accessToken': 'new-test',
            'refreshToken': 'new-refresh',
          }),
          200,
        );
      }
      expect(request.headers['idempotency-key'], 'draft-1');
      return http.Response(
        posts++ == 0 ? '{}' : '{"id":"tx-1"}',
        posts == 1 ? 401 : 201,
      );
    });
    await http.runWithClient(() async {
      final result = await ApiClient.post(
        '/transactions',
        {'amount': 51},
        authenticated: true,
        idempotencyKey: 'draft-1',
      );
      expect(result['id'], 'tx-1');
    }, () => client);
  });
  test('concurrent refresh requests share one token rotation', () async {
    var calls = 0;
    final client = MockClient((request) async {
      calls++;
      await Future<void>.delayed(const Duration(milliseconds: 10));
      return http.Response(
        '{"accessToken":"next","refreshToken":"next-refresh"}',
        200,
      );
    });
    await http.runWithClient(() async {
      expect(
        await Future.wait([
          ApiClient.refreshSession(),
          ApiClient.refreshSession(),
        ]),
        [true, true],
      );
      expect(calls, 1);
    }, () => client);
  });
  test('network error during refresh preserves stored credentials', () async {
    final client = MockClient(
      (_) async => throw const SocketException('offline'),
    );
    await http.runWithClient(() async {
      await expectLater(
        ApiClient.refreshSession(),
        throwsA(isA<ApiException>()),
      );
      expect(await ApiClient.getRefreshToken(), 'refresh-test');
    }, () => client);
  });
  test(
    'history reads past 100 transactions with filters on every page',
    () async {
      final client = MockClient((request) async {
        expect(request.url.queryParameters['type'], 'EXPENSE');
        expect(request.url.queryParameters['minAmount'], '5.00');
        final skip = int.parse(request.url.queryParameters['skip']!);
        return http.Response(
          jsonEncode(
            List.generate(skip == 0 ? 100 : 1, (i) => {'id': '${skip + i}'}),
          ),
          200,
        );
      });
      await http.runWithClient(() async {
        expect(
          await TransactionApiService().getAll(type: 'EXPENSE', minAmount: 5),
          hasLength(101),
        );
      }, () => client);
    },
  );
  test(
    'telemetry cannot contain notes, email, amounts or arbitrary objects',
    () {
      expect(
        safeTelemetryParameters({
          'note': 'private',
          'email': 'private',
          'amount': 51,
          'latency_ms': 12,
          'source': 'ocr',
          'other': Object(),
        }),
        {'latency_ms': 12, 'source': 'ocr'},
      );
    },
  );

  test('TransactionModel.fromApiJson parses UTC ISO date into local DateTime', () {
    final model = TransactionModel.fromApiJson({
      'id': 'tx-local-1',
      'amount': '42.50',
      'type': 'EXPENSE',
      'category': 'FOOD',
      'description': 'Almuerzo',
      'date': '2026-09-13T18:30:00.000Z',
    });
    expect(model.id, 'tx-local-1');
    expect(model.amount, 42.50);
    expect(model.timestamp.isUtc, isFalse);
    expect(model.timestamp.toUtc(), DateTime.utc(2026, 9, 13, 18, 30));
  });

  test('TransactionsRepository.deleteTransaction removes matching id from store', () async {
    final repo = TransactionsRepository(LocalKvStore());
    final tx1 = TransactionModel.fromApiJson({
      'id': 'tx-to-delete',
      'amount': '25.0',
      'type': 'EXPENSE',
      'category': 'FOOD',
      'description': 'Borrar',
      'date': DateTime.now().toIso8601String(),
    });
    final tx2 = TransactionModel.fromApiJson({
      'id': 'tx-to-keep',
      'amount': '50.0',
      'type': 'INCOME',
      'category': 'SALARY',
      'description': 'Mantener',
      'date': DateTime.now().toIso8601String(),
    });

    await repo.saveTransactions([tx1, tx2]);
    var list = await repo.getTransactions();
    expect(list.any((t) => t.id == 'tx-to-delete'), isTrue);

    await repo.deleteTransaction('tx-to-delete');
    list = await repo.getTransactions();
    expect(list.any((t) => t.id == 'tx-to-delete'), isFalse);
    expect(list.any((t) => t.id == 'tx-to-keep'), isTrue);
  });
}
