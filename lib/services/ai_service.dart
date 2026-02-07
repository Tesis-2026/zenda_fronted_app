import '../core/models/breakdown_503020.dart';

abstract class AiAdviceService {
  Future<String> generateAdvice(BudgetBreakdown503020 breakdown);
}

class AiAdviceServiceFake implements AiAdviceService {
  @override
  Future<String> generateAdvice(BudgetBreakdown503020 breakdown) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (breakdown.total == 0) {
      return 'Registra algunos gastos para que Zenda pueda darte consejos útiles.';
    }
    final needs = breakdown.percentNecesidades();
    final wants = breakdown.percentDeseos();
    final savings = breakdown.percentAhorro();
    return 'En el último mes: Necesidades ${needs.toStringAsFixed(0)}%, Deseos ${wants.toStringAsFixed(0)}%, Ahorro ${savings.toStringAsFixed(0)}%. Considera reducir deseos un 10% y aumentar ahorro.';
  }
}

