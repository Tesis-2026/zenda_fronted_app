import 'local_kv_store.dart';

class StreakState {
  final DateTime? lastActiveDate;
  final int currentDays;
  final int bestDays;

  const StreakState({
    required this.lastActiveDate,
    required this.currentDays,
    required this.bestDays,
  });

  factory StreakState.initial() =>
      const StreakState(lastActiveDate: null, currentDays: 0, bestDays: 0);

  StreakState copyWith({
    DateTime? lastActiveDate,
    int? currentDays,
    int? bestDays,
  }) {
    return StreakState(
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      currentDays: currentDays ?? this.currentDays,
      bestDays: bestDays ?? this.bestDays,
    );
  }

  factory StreakState.fromJson(Map<String, dynamic> json) {
    final last = json['lastActiveDate'] as String?;
    return StreakState(
      lastActiveDate: last == null ? null : DateTime.parse(last),
      currentDays: (json['currentDays'] as num?)?.toInt() ?? 0,
      bestDays: (json['bestDays'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lastActiveDate': lastActiveDate?.toIso8601String(),
      'currentDays': currentDays,
      'bestDays': bestDays,
    };
  }

  bool isActiveToday(DateTime now) {
    final last = lastActiveDate;
    return last != null && _isSameDay(last, now);
  }

  int get nextMilestone {
    for (final milestone in const [3, 7, 14, 30, 60, 100]) {
      if (currentDays < milestone) return milestone;
    }
    return ((currentDays ~/ 100) + 1) * 100;
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class StreakRepository {
  StreakRepository(this._store);

  final LocalKvStore _store;

  Future<StreakState> getStreak(String userId, {DateTime? now}) async {
    final key = _store.streakKeyForUser(userId);
    final json = await _store.readJsonMap(key);
    if (json == null) return StreakState.initial();
    final stored = StreakState.fromJson(json);
    final last = stored.lastActiveDate;
    if (last == null) return stored;

    final today = _dateOnly(now ?? DateTime.now());
    final lastDay = _dateOnly(last);
    if (lastDay.isAfter(today) || today.difference(lastDay).inDays > 1) {
      final expired = stored.copyWith(currentDays: 0);
      await _store.writeJsonMap(key, expired.toJson());
      return expired;
    }
    return stored;
  }

  Future<void> saveStreak(String userId, StreakState state) async {
    await _store.writeJsonMap(_store.streakKeyForUser(userId), state.toJson());
  }

  Future<StreakState> updateOnTransaction(
    String userId,
    DateTime txDate, {
    DateTime? now,
  }) async {
    final today = _dateOnly(now ?? DateTime.now());
    final day = _dateOnly(txDate);
    final existing = await getStreak(userId, now: today);

    // Future-dated entries never earn streak credit.
    if (day.isAfter(today)) return existing;

    final last = existing.lastActiveDate;
    if (last == null) {
      final next = StreakState(
        lastActiveDate: day,
        currentDays: 1,
        bestDays: 1,
      );
      await saveStreak(userId, next);
      return next;
    }

    final lastDay = DateTime(last.year, last.month, last.day);

    if (_isSameDay(lastDay, day)) {
      return existing;
    }

    // Adding an older transaction must not move the streak backwards.
    if (day.isBefore(lastDay)) return existing;

    final yesterday = day.subtract(const Duration(days: 1));
    int nextCurrent;
    if (_isSameDay(lastDay, yesterday)) {
      nextCurrent = existing.currentDays + 1;
    } else {
      nextCurrent = 1;
    }

    final nextBest = nextCurrent > existing.bestDays
        ? nextCurrent
        : existing.bestDays;
    final next = existing.copyWith(
      lastActiveDate: day,
      currentDays: nextCurrent,
      bestDays: nextBest,
    );
    await saveStreak(userId, next);
    return next;
  }

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
