import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'package:connectivity_plus/connectivity_plus.dart';

import 'pending_transaction_queue.dart';
import 'transaction_api_service.dart';

/// Maximum number of attempts per pending entry before it is dropped.
const _kMaxRetries = 3;

class SyncService {
  SyncService(this._queue, this._apiService);

  final PendingTransactionQueue _queue;
  final TransactionApiService _apiService;
  StreamSubscription<List<ConnectivityResult>>? _sub;

  /// In-memory retry counters — reset on app restart (acceptable for this scope).
  final Map<String, int> _retryCount = {};

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
      final retries = _retryCount[entry.txId] ?? 0;

      if (retries >= _kMaxRetries) {
        // Drop the entry after max retries — do not keep retrying indefinitely.
        debugPrint('SyncService: max retries reached for ${entry.txId}');
        await _queue.remove(entry.txId);
        _retryCount.remove(entry.txId);
        continue;
      }

      // Exponential backoff: wait 2^retries seconds, capped at 30 s.
      if (retries > 0) {
        final delaySecs = min(30, pow(2, retries).toInt());
        await Future<void>.delayed(Duration(seconds: delaySecs));
      }

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
        _retryCount.remove(entry.txId);
      } catch (_) {
        // Still unreachable or server error — increment retry counter.
        _retryCount[entry.txId] = retries + 1;
      }
    }
  }
}
