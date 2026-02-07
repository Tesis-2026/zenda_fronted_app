class BudgetBreakdown503020 {
  final double totalNecesidades;
  final double totalDeseos;
  final double totalAhorro;

  BudgetBreakdown503020({required this.totalNecesidades, required this.totalDeseos, required this.totalAhorro});

  double get total => totalNecesidades + totalDeseos + totalAhorro;

  double percentNecesidades() => total == 0 ? 0 : (totalNecesidades / total) * 100;
  double percentDeseos() => total == 0 ? 0 : (totalDeseos / total) * 100;
  double percentAhorro() => total == 0 ? 0 : (totalAhorro / total) * 100;
}

