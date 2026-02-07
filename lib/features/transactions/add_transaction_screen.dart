import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/transaction.dart';
import '../../services/transactions_service.dart';
import '../../providers/providers.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _amountController = TextEditingController();
  TransactionCategory _category = TransactionCategory.comida;

  @override
  Widget build(BuildContext context) {
    final txService = ref.watch(transactionsStateProvider);
    final streak = ref.read(streakNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Registrar gasto')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Monto (S/)'),
            ),
            const SizedBox(height: 12),
            DropdownButton<TransactionCategory>(
              value: _category,
              items: TransactionCategory.values
                  .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                  .toList(),
              onChanged: (v) => setState(() {
                if (v != null) _category = v;
              }),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(_amountController.text) ?? 0.0;
                if (amount <= 0) return;
                txService.addTransaction(userId: 'user-1', amount: amount, category: _category, source: TransactionSource.manual);
                streak.registerActivity(DateTime.now());
                Navigator.of(context).pop();
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
