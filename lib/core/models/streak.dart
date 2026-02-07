class Streak {
  final int currentStreakDays;
  final int longestStreakDays;
  final DateTime? lastActivityDate; // fecha (solo fecha relevante)

  Streak({
    required this.currentStreakDays,
    required this.longestStreakDays,
    required this.lastActivityDate,
  });

  Streak.initial()
      : currentStreakDays = 0,
        longestStreakDays = 0,
        lastActivityDate = null;

  Streak copyWith({int? currentStreakDays, int? longestStreakDays, DateTime? lastActivityDate}) {
    return Streak(
      currentStreakDays: currentStreakDays ?? this.currentStreakDays,
      longestStreakDays: longestStreakDays ?? this.longestStreakDays,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
    );
  }
}

