import 'package:bill_tracker/core/ai/mlkit_product_classifier.dart';
import 'package:bill_tracker/core/ai/mlkit_receipt_ocr_service.dart';
import 'package:bill_tracker/core/ai/product_classifier.dart';
import 'package:bill_tracker/core/ai/receipt_ocr_service.dart';
import 'package:bill_tracker/core/analytics/analytics_service.dart';
import 'package:bill_tracker/core/database/app_database.dart';
import 'package:bill_tracker/core/database/database_connection.dart';
import 'package:bill_tracker/core/notifications/notification_service.dart';
import 'package:bill_tracker/core/storage/data_management_service.dart';
import 'package:bill_tracker/core/storage/image_storage_service.dart';
import 'package:bill_tracker/core/storage/local_image_storage_service.dart';
import 'package:bill_tracker/features/budget/data/repositories/budget_repository_impl.dart';
import 'package:bill_tracker/features/budget/domain/repositories/budget_repository.dart';
import 'package:bill_tracker/features/reports/data/repositories/report_repository_impl.dart';
import 'package:bill_tracker/features/reports/domain/repositories/report_repository.dart';
import 'package:bill_tracker/features/transaction/data/repositories/category_repository_impl.dart';
import 'package:bill_tracker/features/transaction/data/repositories/transaction_repository_impl.dart';
import 'package:bill_tracker/features/transaction/domain/repositories/category_repository.dart';
import 'package:bill_tracker/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:get_it/get_it.dart';

/// Global GetIt service locator instance.
final GetIt getIt = GetIt.instance;

/// Configure core service locator dependencies.
Future<void> configureDependencies({String? environment}) async {
  // Database instance
  if (!getIt.isRegistered<AppDatabase>()) {
    getIt.registerLazySingleton<AppDatabase>(
      DatabaseConnection.create,
    );
  }

  // Notification service
  if (!getIt.isRegistered<NotificationService>()) {
    getIt.registerLazySingleton<NotificationService>(
      LocalNotificationService.new,
    );
  }

  // Category repository
  if (!getIt.isRegistered<CategoryRepository>()) {
    getIt.registerLazySingleton<CategoryRepository>(
      () => CategoryRepositoryImpl(getIt<AppDatabase>()),
    );
  }

  // Transaction repository
  if (!getIt.isRegistered<TransactionRepository>()) {
    getIt.registerLazySingleton<TransactionRepository>(
      () => TransactionRepositoryImpl(
        getIt<AppDatabase>(),
        getIt<BudgetRepository>(),
      ),
    );
  }

  // Image storage service
  if (!getIt.isRegistered<ImageStorageService>()) {
    getIt.registerLazySingleton<ImageStorageService>(
      LocalImageStorageService.new,
    );
  }

  // Product classifier (on-device ML Kit)
  if (!getIt.isRegistered<ProductClassifier>()) {
    getIt.registerLazySingleton<ProductClassifier>(
      MlKitProductClassifier.new,
    );
  }

  // Receipt OCR service (on-device ML Kit)
  if (!getIt.isRegistered<ReceiptOcrService>()) {
    getIt.registerLazySingleton<ReceiptOcrService>(
      MlKitReceiptOcrService.new,
    );
  }

  // Analytics service (Console in dev)
  if (!getIt.isRegistered<AnalyticsService>()) {
    getIt.registerLazySingleton<AnalyticsService>(
      ConsoleAnalyticsService.new,
    );
  }

  // Budget repository
  if (!getIt.isRegistered<BudgetRepository>()) {
    getIt.registerLazySingleton<BudgetRepository>(
      () => BudgetRepositoryImpl(
        db: getIt<AppDatabase>(),
        notificationService: getIt<NotificationService>(),
        analyticsService: getIt<AnalyticsService>(),
      ),
    );
  }

  // Report repository
  if (!getIt.isRegistered<ReportRepository>()) {
    getIt.registerLazySingleton<ReportRepository>(
      () => ReportRepositoryImpl(getIt<AppDatabase>()),
    );
  }

  // Data management service
  if (!getIt.isRegistered<DataManagementService>()) {
    getIt.registerLazySingleton<DataManagementService>(
      () => DataManagementService(
        db: getIt<AppDatabase>(),
        imageStorage: getIt<ImageStorageService>(),
      ),
    );
  }
}

/// Environment name constants for DI.
abstract class Env {
  /// Development environment.
  static const dev = 'dev';

  /// Production environment.
  static const prod = 'prod';

  /// Test environment.
  static const test = 'test';
}
