import 'dart:typed_data';
import '../models/transaction.dart';

class OcrResult {
  final double amount;
  final TransactionCategory category;
  final String? note;
  OcrResult({required this.amount, required this.category, this.note});
}

abstract class OcrService {
  Future<OcrResult> parseReceipt(Uint8List imageBytes);
}

class FakeOcrService implements OcrService {
  @override
  Future<OcrResult> parseReceipt(Uint8List imageBytes) async {
    // Simula un parseo de boleta
    await Future.delayed(const Duration(seconds: 1));
    return OcrResult(amount: 12.50, category: TransactionCategory.comida, note: 'Boleta simulada');
  }
}
