import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/transactions_service.dart';
import '../services/ocr_service.dart';
import '../services/ai_service.dart';
import '../features/streak/streak_notifier.dart';

final authStateProvider = Provider<AuthService>((ref) => AuthService());
final transactionsStateProvider = Provider<TransactionsService>((ref) => TransactionsService());

final ocrServiceProvider = Provider<OcrService>((ref) => OcrServiceFake());
final aiServiceProvider = Provider<AiAdviceService>((ref) => AiAdviceServiceFake());

final streakNotifierProvider = Provider<StreakNotifier>((ref) => StreakNotifier());
