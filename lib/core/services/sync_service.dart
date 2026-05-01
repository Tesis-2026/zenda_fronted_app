import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import 'pending_transaction_queue.dart';
import 'transaction_api_service.dart';

class SyncService {
  SyncService(this._queue, this._apiService);

  final PendingTransactionQueue _queue;
  final TransactionApiService _apiService;
  StreamSubscription<List<ConnectivityResult>>? _sub;

  void startListening() {
    _sub = Connectivity().onConnectivityChanged.listen((results) {
      if (_hasConnectivity(results)) {
        _flush();
      }
    });
    // Also attempt immediately — may already be online with queued items
    _flushIfOnline();
  }

  void dispose() {
    _sub?.cancel();
    _sub = null;
  }

  bool _hasConnectivity(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);

  Future<void> _flushIfOnline() async {
    final results = await Connectivity().checkConnectivity();
    if (_hasConnectivity(results)) {
      await _flush();
    }
  }

  Future<void> _flush() async {
    final pending = await _queue.getAll();
    if (pending.isEmpty) return;

    for (final entry in pending) {
      try {
        await _apiService.create(
          kind: entry.kind,
          amount: entry.amount,
          category: entry.category,
          occurredAt: entry.occurredAt,
          description: entry.description,
          customCategoryName: entry.customCategoryName,
        );
        await _queue.remove(entry.txId);
      } catch (_) {
        // Still unreachable or server error — leave in queue for next event
      }
    }
  }
}
