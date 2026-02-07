import 'dart:typed_data';

class OcrResult {
  final double amount;
  final String category;
  final String text;

  OcrResult({required this.amount, required this.category, required this.text});
}

abstract class OcrService {
  Future<OcrResult> parseReceipt(Uint8List imageBytes);
}

class OcrServiceFake implements OcrService {
  @override
  Future<OcrResult> parseReceipt(Uint8List imageBytes) async {
    // Simula un OCR simple
    await Future.delayed(const Duration(milliseconds: 500));
    return OcrResult(amount: 12.50, category: 'comida', text: 'Boleta simulada: S/12.50');
  }
}

