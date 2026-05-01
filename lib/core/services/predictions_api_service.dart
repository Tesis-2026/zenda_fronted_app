import 'api_client.dart';

class PredictionResult {
  final String period;
  final double predictedAmount;
  final double confidenceLevel;
  final String? narrative;
  final String? modelVersion;

  const PredictionResult({
    required this.period,
    required this.predictedAmount,
    required this.confidenceLevel,
    this.narrative,
    this.modelVersion,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    return PredictionResult(
      period: json['period'] as String,
      predictedAmount: (json['predictedAmount'] as num).toDouble(),
      confidenceLevel: (json['confidenceLevel'] as num? ?? 0.5).toDouble(),
      narrative: json['narrative'] as String?,
      modelVersion: json['modelVersion'] as String?,
    );
  }
}

class PredictionsApiService {
  Future<PredictionResult> getExpensePrediction() async {
    final data = await ApiClient.get('/predictions/expenses');
    return PredictionResult.fromJson(data);
  }

}
