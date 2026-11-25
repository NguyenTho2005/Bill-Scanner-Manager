import 'package:bill_tracker/core/ai/price_text_extractor.dart';
import 'package:bill_tracker/core/ai/product_classifier.dart';
import 'package:bill_tracker/core/ai/receipt_ocr_service.dart';
import 'package:bill_tracker/features/assistant/domain/entities/assistant_settings.dart';
import 'package:bill_tracker/features/assistant/domain/entities/chat_message.dart';
import 'package:bill_tracker/features/assistant/domain/repositories/assistant_repository.dart';
import 'package:bill_tracker/features/assistant/domain/services/llm_client.dart';
import 'package:bill_tracker/features/budget/domain/entities/budget.dart';
import 'package:bill_tracker/features/budget/domain/entities/category_budget_progress.dart';
import 'package:bill_tracker/features/budget/domain/repositories/budget_repository.dart';
import 'package:bill_tracker/features/reports/domain/entities/report_data.dart';
import 'package:bill_tracker/features/reports/domain/repositories/report_repository.dart';
import 'package:bill_tracker/features/transaction/domain/entities/category.dart';
import 'package:bill_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:bill_tracker/features/transaction/domain/entities/transaction_media.dart';
import 'package:bill_tracker/features/transaction/domain/repositories/category_repository.dart';
import 'package:bill_tracker/features/transaction/domain/repositories/transaction_repository.dart';

/// Shared test categories mirroring the seeded system set.
const testCategories = <Category>[
  Category(
    id: 'food_drinks',
    name: 'Ăn uống',
    icon: 'restaurant',
    colorValue: 0xFFFF6B35,
  ),
  Category(
    id: 'transport',
    name: 'Di chuyển',
    icon: 'directions_car',
    colorValue: 0xFF2196F3,
  ),
  Category(
    id: 'shopping',
    name: 'Mua sắm',
    icon: 'shopping_bag',
    colorValue: 0xFF9C27B0,
  ),
  Category(
    id: 'other',
    name: 'Khác',
    icon: 'category',
    colorValue: 0xFF9E9E9E,
  ),
];

Transaction buildTransaction({
  required String id,
  required double amount,
  required String categoryId,
  required DateTime occurredAt,
  TransactionType type = TransactionType.expense,
  String? merchant,
  String? note,
}) {
  final category = testCategories.firstWhere((item) => item.id == categoryId);
  return Transaction(
    id: id,
    type: type,
    amount: amount,
    currency: 'VND',
    categoryId: categoryId,
    occurredAt: occurredAt,
    source: TransactionSource.manual,
    status: TransactionStatus.confirmed,
    createdAt: occurredAt,
    updatedAt: occurredAt,
    merchant: merchant,
    note: note,
    category: category,
  );
}

/// In-memory [TransactionRepository] for assistant tests.
class FakeTransactionRepository implements TransactionRepository {
  /// Creates the fake with an initial list.
  FakeTransactionRepository([List<Transaction>? initial])
      : transactions = [...?initial];

  /// Mutable store used by tests.
  final List<Transaction> transactions;

  List<Transaction> _apply(TransactionFilter? filter) {
    var result = [...transactions];
    if (filter != null) {
      if (filter.startDate != null) {
        result = result
            .where((item) => !item.occurredAt.isBefore(filter.startDate!))
            .toList();
      }
      if (filter.endDate != null) {
        result = result
            .where((item) => !item.occurredAt.isAfter(filter.endDate!))
            .toList();
      }
      if (filter.categoryId != null) {
        result = result
            .where((item) => item.categoryId == filter.categoryId)
            .toList();
      }
      if (filter.minAmount != null) {
        result =
            result.where((item) => item.amount >= filter.minAmount!).toList();
      }
      if (filter.maxAmount != null) {
        result =
            result.where((item) => item.amount <= filter.maxAmount!).toList();
      }
    }
    result.sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    return result;
  }

  @override
  Future<List<Transaction>> getTransactions({
    TransactionFilter? filter,
  }) async =>
      _apply(filter);

  @override
  Stream<List<Transaction>> watchTransactions({
    TransactionFilter? filter,
  }) =>
      Stream.value(_apply(filter));

  @override
  Future<Transaction?> getTransactionById(String id) async {
    for (final item in transactions) {
      if (item.id == id) return item;
    }
    return null;
  }

  @override
  Future<void> createTransaction(
    Transaction transaction, {
    TransactionMedia? media,
  }) async {
    transactions.add(transaction);
  }

  @override
  Future<void> updateTransaction(Transaction transaction) async {
    final index = transactions.indexWhere((item) => item.id == transaction.id);
    if (index >= 0) transactions[index] = transaction;
  }

  @override
  Future<void> deleteTransaction(String id) async {
    transactions.removeWhere((item) => item.id == id);
  }

  @override
  Future<List<TransactionMedia>> getMediasForTransaction(
    String transactionId,
  ) async =>
      const [];

  @override
  Future<void> saveReceiptScanData({
    required String transactionId,
    required ReceiptExtractionResult extraction,
    required List<ParsedLineItem> lineItems,
  }) async {}

  @override
  Future<void> saveProductSnapInference({
    required String mediaId,
    required ProductClassificationResult classification,
    PriceOcrResult? priceOcr,
    String? priceOcrModelVersion,
  }) async {}
}

/// In-memory [CategoryRepository].
class FakeCategoryRepository implements CategoryRepository {
  /// Creates the fake with [categories].
  FakeCategoryRepository([List<Category>? categories])
      : categories = categories ?? testCategories;

  /// Stored categories.
  final List<Category> categories;

  @override
  Future<List<Category>> getAllCategories() async => categories;

  @override
  Stream<List<Category>> watchAllCategories() => Stream.value(categories);

  @override
  Future<Category?> getCategoryById(String id) async {
    for (final category in categories) {
      if (category.id == id) return category;
    }
    return null;
  }

  @override
  Future<void> createCategory(Category category) async =>
      categories.add(category);

  @override
  Future<void> updateCategory(Category category) async {}

  @override
  Future<void> deleteCategory(String id) async {}
}

/// Deterministic [ReportRepository] computing sums from a transaction list.
class FakeReportRepository implements ReportRepository {
  /// Creates the fake.
  FakeReportRepository(this.transactions, {this.categories = testCategories});

  /// Source transactions.
  final List<Transaction> transactions;

  /// Categories used for grouping.
  final List<Category> categories;

  @override
  Future<ReportSummary> getMonthlyReport(DateTime month) async => _build(month);

  @override
  Stream<ReportSummary> watchMonthlyReport(DateTime month) =>
      Stream.value(_build(month));

  ReportSummary _build(DateTime month) {
    final start = DateTime(month.year, month.month);
    final end = DateTime(month.year, month.month + 1);
    final inMonth = transactions
        .where(
          (item) =>
              !item.occurredAt.isBefore(start) && item.occurredAt.isBefore(end),
        )
        .toList();
    final expenses =
        inMonth.where((item) => item.type == TransactionType.expense).toList();
    final income = inMonth
        .where((item) => item.type == TransactionType.income)
        .fold<double>(0, (sum, item) => sum + item.amount);
    final totalExpense =
        expenses.fold<double>(0, (sum, item) => sum + item.amount);

    final grouped = <String, double>{};
    final counts = <String, int>{};
    for (final item in expenses) {
      grouped[item.categoryId] = (grouped[item.categoryId] ?? 0) + item.amount;
      counts[item.categoryId] = (counts[item.categoryId] ?? 0) + 1;
    }
    final spendings = grouped.entries.map((entry) {
      final category = categories.firstWhere(
        (item) => item.id == entry.key,
        orElse: () => testCategories.last,
      );
      return CategorySpending(
        category: category,
        amount: entry.value,
        percentage: totalExpense == 0 ? 0 : entry.value / totalExpense * 100,
        transactionCount: counts[entry.key] ?? 0,
      );
    }).toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    return ReportSummary(
      month: start,
      totalExpense: totalExpense,
      totalIncome: income,
      previousMonthExpense: 0,
      categorySpendings: spendings,
      topExpenses: expenses.take(5).toList(),
      monthlyTrends: const [],
    );
  }
}

/// In-memory [BudgetRepository] exposing a fixed progress list.
class FakeBudgetRepository implements BudgetRepository {
  /// Creates the fake with [progress].
  FakeBudgetRepository([this.progress = const []]);

  /// Progress rows returned for any month.
  final List<CategoryBudgetProgress> progress;

  @override
  Future<List<Budget>> getAllBudgets() async =>
      progress.map((item) => item.budget).toList();

  @override
  Stream<List<Budget>> watchAllBudgets() =>
      Stream.value(progress.map((item) => item.budget).toList());

  @override
  Future<Budget?> getBudgetById(String id) async => null;

  @override
  Future<Budget?> getBudgetByCategoryId(String categoryId) async => null;

  @override
  Stream<List<CategoryBudgetProgress>> watchBudgetProgressList({
    DateTime? month,
  }) =>
      Stream.value(progress);

  @override
  Future<void> saveBudget(Budget budget) async {}

  @override
  Future<void> deleteBudget(String id) async {}

  @override
  Future<void> checkAndTriggerAlerts() async {}
}

/// Builds a budget progress row for tests.
CategoryBudgetProgress buildProgress({
  required Category category,
  required double limit,
  required double spent,
}) {
  return CategoryBudgetProgress(
    budget: Budget(
      id: 'budget_${category.id}',
      categoryId: category.id,
      amountLimit: limit,
      periodStart: DateTime(2026, 11),
      periodEnd: DateTime(2026, 12),
      category: category,
    ),
    category: category,
    spentAmount: spent,
  );
}

/// In-memory [AssistantRepository] used by widget tests.
class FakeAssistantRepository implements AssistantRepository {
  /// Stored conversation.
  final List<ChatMessage> messages = [];

  /// Current settings.
  AssistantSettings settings = const AssistantSettings();

  @override
  Future<List<ChatMessage>> loadHistory({int limit = 200}) async =>
      [...messages];

  @override
  Future<void> saveMessage(ChatMessage message) async {
    final index = messages.indexWhere((item) => item.id == message.id);
    if (index >= 0) {
      messages[index] = message;
    } else {
      messages.add(message);
    }
  }

  @override
  Future<void> clearHistory() async => messages.clear();

  @override
  Future<AssistantSettings> loadSettings() async => settings;

  @override
  Future<void> saveSettings(AssistantSettings settings) async =>
      this.settings = settings;
}

/// Never reached in widget tests that keep cloud AI disabled.
class OfflineOnlyLlmClient implements LlmClient {
  @override
  Future<String> complete({
    required AssistantSettings settings,
    required List<LlmMessage> messages,
  }) async =>
      throw const LlmException('Cloud disabled in widget tests');
}
