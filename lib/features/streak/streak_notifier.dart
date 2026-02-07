import 'package:flutter/material.dart';
import '../../core/models/streak.dart';

class StreakNotifier extends ChangeNotifier {
  Streak _streak = Streak.initial();

  Streak get streak => _streak;

  void registerActivity(DateTime timestamp) {
    // Normalize to date (ignore time)
    final date = DateTime(timestamp.year, timestamp.month, timestamp.day);
    final last = _streak.lastActivityDate == null
        ? null
        : DateTime(_streak.lastActivityDate!.year, _streak.lastActivityDate!.month, _streak.lastActivityDate!.day);

    if (last == null) {
      _streak = Streak(currentStreakDays: 1, longestStreakDays: 1, lastActivityDate: date);
    } else {
      final difference = date.difference(last).inDays;
      if (difference == 0) {
        // same day: no change
      } else if (difference == 1) {
        final newCurrent = _streak.currentStreakDays + 1;
        final newLongest = newCurrent > _streak.longestStreakDays ? newCurrent : _streak.longestStreakDays;
        _streak = Streak(currentStreakDays: newCurrent, longestStreakDays: newLongest, lastActivityDate: date);
      } else if (difference > 1) {
        // reset streak
        _streak = Streak(currentStreakDays: 1, longestStreakDays: _streak.longestStreakDays, lastActivityDate: date);
      }
    }
    notifyListeners();
  }

  void reset() {
    _streak = Streak.initial();
    notifyListeners();
  }
}
