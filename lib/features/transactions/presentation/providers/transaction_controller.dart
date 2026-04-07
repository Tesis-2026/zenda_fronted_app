import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/category.dart';
import '../../data/datasources/transaction_remote_datasource.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/create_category_usecase.dart';
import '../../domain/usecases/create_transaction_usecase.dart';
import '../../../auth/presentation/providers/auth_controller.dart'; // To get ApiClient

// --- DEPENDENCY INJECTION ---

final transactionRemoteDataSourceProvider = Provider<TransactionRemoteDataSource>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return TransactionRemoteDataSource(dio: apiClient.dio);
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepositoryImpl(
    remoteDataSource: ref.read(transactionRemoteDataSourceProvider),
  );
});

final getCategoriesUseCaseProvider = Provider<GetCategoriesUseCase>((ref) {
  return GetCategoriesUseCase(ref.read(transactionRepositoryProvider));
});

final createCategoryUseCaseProvider = Provider<CreateCategoryUseCase>((ref) {
  return CreateCategoryUseCase(ref.read(transactionRepositoryProvider));
});

final createTransactionUseCaseProvider = Provider<CreateTransactionUseCase>((ref) {
  return CreateTransactionUseCase(ref.read(transactionRepositoryProvider));
});

// --- STATE MANAGEMENT ---

class TransactionState {
  final List<Category> categories;
  final bool isLoadingCategories;
  final bool isCreatingTransaction;
  final String? error;
  
  const TransactionState({
    this.categories = const [],
    this.isLoadingCategories = false,
    this.isCreatingTransaction = false,
    this.error,
  });

  TransactionState copyWith({
    List<Category>? categories,
    bool? isLoadingCategories,
    bool? isCreatingTransaction,
    String? error,
    bool clearError = false,
  }) {
    return TransactionState(
      categories: categories ?? this.categories,
      isLoadingCategories: isLoadingCategories ?? this.isLoadingCategories,
      isCreatingTransaction: isCreatingTransaction ?? this.isCreatingTransaction,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class TransactionNotifier extends Notifier<TransactionState> {
  @override
  TransactionState build() {
    // Auto fetch categories initially
    Future.microtask(() => fetchCategories());
    return const TransactionState();
  }

  Future<void> fetchCategories() async {
    state = state.copyWith(isLoadingCategories: true, clearError: true);
    try {
      final getUsecase = ref.read(getCategoriesUseCaseProvider);
      final list = await getUsecase();
      state = state.copyWith(isLoadingCategories: false, categories: list);
    } on Failure catch (e) {
      state = state.copyWith(isLoadingCategories: false, error: e.message);
    }
  }

  Future<Category?> createCategory(String name) async {
    state = state.copyWith(isCreatingTransaction: true, clearError: true);
    try {
      final createUsecase = ref.read(createCategoryUseCaseProvider);
      final newCat = await createUsecase(name: name);
      // Actualizamos listado local agregando la nueva categoria
      state = state.copyWith(
        isCreatingTransaction: false,
        categories: [...state.categories, newCat],
      );
      return newCat;
    } on Failure catch (e) {
      state = state.copyWith(isCreatingTransaction: false, error: e.message);
    }
    return null;
  }

  Future<bool> createTransaction({
    required String categoryId,
    required double amount,
    required String description,
    required String type, // 'expense' or 'income'
    String currency = 'PEN',
    DateTime? occurredAt,
  }) async {
    state = state.copyWith(isCreatingTransaction: true, clearError: true);
    try {
      final createTxUsecase = ref.read(createTransactionUseCaseProvider);
      await createTxUsecase(
        categoryId: categoryId,
        amount: amount,
        description: description,
        type: type,
        currency: currency,
        occurredAt: occurredAt ?? DateTime.now(),
      );
      
      state = state.copyWith(isCreatingTransaction: false);
      return true; // Éxito
    } on Failure catch (e) {
      state = state.copyWith(isCreatingTransaction: false, error: e.message);
      return false; // Fallo
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

// Global UI Provider
final transactionNotifierProvider = NotifierProvider<TransactionNotifier, TransactionState>(TransactionNotifier.new);
