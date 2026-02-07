import '../models/breakdown_503020.dart';

abstract class AiAdviceService {
  Future<String> generateAdvice(BudgetBreakdown503020 breakdown);
}

class FakeAiAdviceService implements AiAdviceService {
  @override
  Future<String> generateAdvice(BudgetBreakdown503020 breakdown) async {
    await Future.delayed(const Duration(milliseconds: 400));
    // Mensaje simple basado en porcentajes
    if (breakdown.percentDeseos() > 40) {
      return 'Veo que gastas bastante en deseos. ¿Podrías reducir un 10% y moverlo a ahorro?';
    } else if (breakdown.percentAhorro() < 15) {
      return 'Buen inicio. Intenta destinar al menos 10-15% a ahorro esta próxima semana.';
    } else {
      return '¡Bien! Mantén el hábito. Has registrado tus gastos de forma consistente.';
    }
  }
}
