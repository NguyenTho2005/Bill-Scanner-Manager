import 'package:bill_tracker/features/reports/domain/entities/report_data.dart';

/// Repository interface for generating analytics and visual report data.
abstract class ReportRepository {
  /// Computes a [ReportSummary] for the given [month].
  Future<ReportSummary> getMonthlyReport(DateTime month);

  /// Watches a [ReportSummary] stream for the given [month] reactively.
  Stream<ReportSummary> watchMonthlyReport(DateTime month);
}
