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
}

class StreakRepository {
  StreakRepository(this._store);

  final LocalKvStore _store;

  Future<StreakState> getStreak() async {
    final json = await _store.readJsonMap(_store.streakKey);
    if (json == null) return StreakState.initial();
    return StreakState.fromJson(json);
  }

  Future<void> saveStreak(StreakState state) async {
    await _store.writeJsonMap(_store.streakKey, state.toJson());
  }

  Future<StreakState> updateOnTransaction(DateTime txDate) async {
    final existing = await getStreak();
    final day = DateTime(txDate.year, txDate.month, txDate.day);

    final last = existing.lastActiveDate;
    if (last == null) {
      final next = StreakState(
        lastActiveDate: day,
        currentDays: 1,
        bestDays: 1,
      );
      await saveStreak(next);
      return next;
    }

    final lastDay = DateTime(last.year, last.month, last.day);

    if (_isSameDay(lastDay, day)) {
      return existing;
    }

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
    await saveStreak(next);
    return next;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
