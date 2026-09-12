import 'package:bill_tracker/core/di/injection_container.dart';
import 'package:bill_tracker/features/reports/domain/entities/report_data.dart';
import 'package:bill_tracker/features/reports/domain/repositories/report_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for [ReportRepository] from DI locator.
final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return getIt<ReportRepository>();
});

/// Currently selected month for visual reports.
final selectedReportMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});

/// Reactive stream of [ReportSummary] for the selected month.
final monthlyReportProvider = StreamProvider.autoDispose<ReportSummary>((ref) {
  final repo = ref.watch(reportRepositoryProvider);
  final month = ref.watch(selectedReportMonthProvider);
  return repo.watchMonthlyReport(month);
});
