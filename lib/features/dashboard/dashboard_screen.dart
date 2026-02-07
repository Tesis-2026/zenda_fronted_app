import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txService = ref.watch(transactionsStateProvider);
    final breakdown = txService.calculateBreakdown();
    final streak = ref.watch(streakNotifierProvider);
    final ai = ref.watch(aiServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zenda'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text("Hola, ${ref.watch(authStateProvider).name ?? 'Usuario'} 👋", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Resumen de gastos', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Total (último mes): S/ ${breakdown.total.toStringAsFixed(2)}'),
                ]),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('50/30/20', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Necesidades: S/ ${breakdown.totalNecesidades.toStringAsFixed(2)} (${breakdown.percentNecesidades().toStringAsFixed(0)}%)'),
                  Text('Deseos: S/ ${breakdown.totalDeseos.toStringAsFixed(2)} (${breakdown.percentDeseos().toStringAsFixed(0)}%)'),
                  Text('Ahorro: S/ ${breakdown.totalAhorro.toStringAsFixed(2)} (${breakdown.percentAhorro().toStringAsFixed(0)}%)'),
                ]),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Racha', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('🔥 Llevas ${streak.streak.currentStreakDays} días seguidos registrando gastos'),
                  Text('Máxima racha: ${streak.streak.longestStreakDays} días'),
                ]),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FutureBuilder<String>(
                  future: ai.generateAdvice(breakdown),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(height: 40, child: Center(child: CircularProgressIndicator()));
                    }
                    final text = snapshot.data ?? 'Zenda te dará consejos cuando registres gastos.';
                    return Text(text);
                  },
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed('/add-transaction'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
