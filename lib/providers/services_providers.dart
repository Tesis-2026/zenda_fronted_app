import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/auth_api_service.dart';
import '../core/services/education_api_service.dart';
import '../core/services/insights_api_service.dart';

/// Centralized API service providers.
///
/// Feature-scoped providers (e.g. budgetServiceProvider, goalsServiceProvider,
/// educationServiceProvider) remain declared inside their feature file for
/// historical reasons; this file holds the providers used across multiple
/// features or by code that has no natural feature home.

final authApiServiceProvider = Provider<AuthApiService>((_) => AuthApiService());

final feedbackApiServiceProvider =
    Provider<FeedbackApiService>((_) => FeedbackApiService());

final insightsApiServiceProvider =
    Provider<InsightsApiService>((_) => InsightsApiService());
