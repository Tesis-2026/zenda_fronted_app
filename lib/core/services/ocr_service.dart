import 'dart:typed_data';
import '../models/transaction.dart';

class OcrResult {
  final double amount;
  final TransactionCategory category;
  final String? note;
  const OcrResult({required this.amount, required this.category, this.note});
}

// OCR receipt scanning — real implementation deferred to US-0303.
abstract class OcrService {
  Future<OcrResult> parseReceipt(Uint8List imageBytes);
}
