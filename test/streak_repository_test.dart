import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zenda_fronted/core/services/local_kv_store.dart';
import 'package:zenda_fronted/core/services/streak_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StreakRepository repository;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    repository = StreakRepository(LocalKvStore());
  });

  test('keeps streak state isolated between users', () async {
    final today = DateTime(2026, 9, 22, 10);

    await repository.updateOnTransaction('user-a', today, now: today);

    expect((await repository.getStreak('user-a', now: today)).currentDays, 1);
    expect((await repository.getStreak('user-b', now: today)).currentDays, 0);
  });

  test('advances consecutive days and preserves the best streak', () async {
    final today = DateTime(2026, 9, 22, 10);
    final yesterday = today.subtract(const Duration(days: 1));

    await repository.updateOnTransaction('user-a', yesterday, now: today);
    final streak = await repository.updateOnTransaction(
      'user-a',
      today,
      now: today,
    );

    expect(streak.currentDays, 2);
    expect(streak.bestDays, 2);
    expect(streak.isActiveToday(today), isTrue);
    expect(streak.nextMilestone, 3);
  });

  test('older transactions do not move the streak backwards', () async {
    final today = DateTime(2026, 9, 22, 10);
    await repository.updateOnTransaction('user-a', today, now: today);

    final streak = await repository.updateOnTransaction(
      'user-a',
      today.subtract(const Duration(days: 5)),
      now: today,
    );

    expect(streak.currentDays, 1);
    expect(streak.lastActiveDate, DateTime(2026, 9, 22));
  });

  test('expires a broken current streak but keeps the record', () async {
    final activityDay = DateTime(2026, 9, 20, 10);
    await repository.updateOnTransaction(
      'user-a',
      activityDay,
      now: activityDay,
    );

    final expired = await repository.getStreak(
      'user-a',
      now: DateTime(2026, 9, 22, 10),
    );

    expect(expired.currentDays, 0);
    expect(expired.bestDays, 1);
  });
}
