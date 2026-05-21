import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Owns the login lockout countdown applied after repeated failed logins.
///
/// State is the number of seconds remaining (0 = not locked out). The expiry
/// is persisted in SharedPreferences so the lockout survives app restarts.
class LoginLockoutNotifier extends Notifier<int> {
  static const _lockoutKey = 'zenda.auth.lockout_until';
  static const _lockoutDuration = Duration(minutes: 15);

  Timer? _timer;

  @override
  int build() {
    ref.onDispose(() => _timer?.cancel());
    _restore();
    return 0;
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final storedMs = prefs.getInt(_lockoutKey);
    if (storedMs == null) return;
    final expiresAt = DateTime.fromMillisecondsSinceEpoch(storedMs);
    final remaining = expiresAt.difference(DateTime.now()).inSeconds;
    if (remaining > 0) {
      state = remaining;
      _startTimer();
    } else {
      await prefs.remove(_lockoutKey);
    }
  }

  /// Starts a fresh lockout window and persists its expiry.
  Future<void> lock() async {
    _timer?.cancel();
    final expiresAt = DateTime.now().add(_lockoutDuration);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lockoutKey, expiresAt.millisecondsSinceEpoch);
    state = _lockoutDuration.inSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (state > 0) {
        state = state - 1;
      } else {
        t.cancel();
        SharedPreferences.getInstance().then((p) => p.remove(_lockoutKey));
      }
    });
  }
}

final loginLockoutProvider =
    NotifierProvider<LoginLockoutNotifier, int>(LoginLockoutNotifier.new);
