Map<String, Object> safeTelemetryParameters(Map<String, Object?> values) {
  const numbers = {
    'duration_ms',
    'latency_ms',
    'score',
    'rating',
    'question_count',
  };
  const flags = {'has_account', 'has_budget', 'success', 'used_rag'};
  const enums = <String, Set<String>>{
    'kind': {'income', 'expense', 'transfer'},
    'source': {'manual', 'voice', 'ocr', 'resume', 'auth_transition'},
    'app_env': {'dev', 'prod', 'staging'},
    'screen': {
      'dashboard',
      'transactions',
      'reports',
      'education',
      'research',
      'profile',
      'goals',
      'budgets',
      'chat',
    },
    'field': {'amount', 'date', 'merchant', 'currency', 'category'},
  };
  final result = <String, Object>{};
  for (final entry in values.entries) {
    final v = entry.value;
    if (v is num &&
        v.isFinite &&
        v >= 0 &&
        v <= 86400000 &&
        numbers.contains(entry.key)) {
      result[entry.key] = v;
    }
    if (v is bool && flags.contains(entry.key)) result[entry.key] = v;
    if (v is String && (enums[entry.key]?.contains(v) ?? false)) {
      result[entry.key] = v;
    }
  }
  return result;
}
