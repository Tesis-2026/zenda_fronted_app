import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/models/breakdown_503020.dart';

class BudgetPieChart extends StatelessWidget {
  final BudgetBreakdown503020 breakdown;

  const BudgetPieChart({required this.breakdown, super.key});

  @override
  Widget build(BuildContext context) {
    // Si no hay gasto, mostrar algo vacío o placeholder
    if (breakdown.total == 0) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'Sin gastos registrados',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 1.3,
      child: PieChart(
        PieChartData(
          sectionsSpace: 4,
          centerSpaceRadius: 40,
          sections: [
            PieChartSectionData(
              color: const Color(0xFF34D399),
              value: breakdown.totalNecesidades,
              title: '${breakdown.percentNecesidades().toStringAsFixed(0)}%',
              radius: 50,
              titleStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              color: const Color(0xFFC084FC),
              value: breakdown.totalDeseos,
              title: '${breakdown.percentDeseos().toStringAsFixed(0)}%',
              radius: 50,
              titleStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              color: const Color(0xFFFCD34D),
              value: breakdown.totalAhorro,
              title: '${breakdown.percentAhorro().toStringAsFixed(0)}%',
              radius: 50,
              titleStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Ahorro color might need dark text
                shadows: [Shadow(color: Colors.black45, blurRadius: 2)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
