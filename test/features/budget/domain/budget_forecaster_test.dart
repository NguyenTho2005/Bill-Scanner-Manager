import 'package:bill_tracker/features/budget/domain/services/budget_forecaster.dart';
import 'package:flutter_test/flutter_test.dart';

/// June 2026: 30 days (periodStart Jun 1, periodEnd Jun 30 23:59:59.999).
final periodStart = DateTime(2026, 6, 1);
final periodEnd =
    DateTime(2026, 7, 1).subtract(const Duration(milliseconds: 1));

void main() {
  const forecaster = BudgetForecaster();

  group('BudgetForecaster — mid-period projections', () {
    test('projects linear average daily spend to end of month', () {
      final forecast = forecaster.forecast(
        spentAmount: 200000, // ~13.793đ/day after 14.5 elapsed days.
        amountLimit: 600000,
        periodStart: periodStart,
        periodEnd: periodEnd,
        now: DateTime(2026, 6, 15, 12), // 14.5 days elapsed.
      );

      expect(forecast.daysElapsed, closeTo(14.5, 0.01));
      expect(forecast.totalDays, closeTo(30, 0.01));
      expect(forecast.avgDailySpend, closeTo(200000 / 14.5, 1));
      expect(
        forecast.projectedTotal,
        closeTo((200000 / 14.5) * 30, 20),
      );
      expect(forecast.projectedOverspend, 0);
      expect(forecast.severity, BudgetForecastSeverity.onTrack);
    });

    test('marks likelyExceed with the expected overspend amount', () {
      final forecast = forecaster.forecast(
        spentAmount: 450000,
        amountLimit: 500000,
        periodStart: periodStart,
        periodEnd: periodEnd,
        now: DateTime(2026, 6, 15, 12),
      );

      expect(forecast.severity, BudgetForecastSeverity.likelyExceed);
      expect(forecast.projectedOverspend, greaterThan(0));
      expect(
        forecast.projectedTotal,
        closeTo(forecast.amountLimit + forecast.projectedOverspend, 1),
      );
    });

    test('flags nearLimit when projected spend passes the threshold', () {
      final forecast = forecaster.forecast(
        spentAmount: 450000,
        amountLimit: 580000, // projection ≈ 870.000 → over; use a limit
        periodStart: periodStart,
        periodEnd: periodEnd,
        now: DateTime(2026, 6, 15, 12),
      );

      // Projection (~871k) > limit, so likelyExceed dominates.
      expect(forecast.severity, BudgetForecastSeverity.likelyExceed);
    });

    test('flags nearLimit for a budget projected just under the limit', () {
      final forecast = forecaster.forecast(
        spentAmount: 193000,
        amountLimit: 400000,
        periodStart: DateTime(2026, 6, 1, 0, 0),
        periodEnd:
            DateTime(2026, 6, 2).subtract(const Duration(milliseconds: 1)),
        now: DateTime(2026, 6, 1, 12),
      );

      // 1-day period, half day elapsed: avg = 193.000/0.5 = 386.000,
      // projected = 386.000 = 96.5% of limit → nearLimit, not exceed.
      expect(forecast.severity, BudgetForecastSeverity.nearLimit);
      expect(forecast.projectedOverspend, 0);
      expect(forecast.projectedTotal, closeTo(386000, 1));
    });
  });

  group('BudgetForecaster — edge periods', () {
    test('finished period projects the actual spend', () {
      final forecast = forecaster.forecast(
        spentAmount: 800000,
        amountLimit: 500000,
        periodStart: periodStart,
        periodEnd: periodEnd,
        now: DateTime(2026, 7, 3),
      );

      expect(forecast.projectedTotal, 800000);
      expect(forecast.projectedOverspend, 300000);
      expect(forecast.daysElapsed, forecast.totalDays);
      expect(forecast.severity, BudgetForecastSeverity.likelyExceed);
    });

    test('period not started projects zero spend', () {
      final forecast = forecaster.forecast(
        spentAmount: 0,
        amountLimit: 500000,
        periodStart: periodStart,
        periodEnd: periodEnd,
        now: DateTime(2026, 5, 20),
      );

      expect(forecast.projectedTotal, 0);
      expect(forecast.projectedOverspend, 0);
      expect(forecast.severity, BudgetForecastSeverity.onTrack);
    });

    test('zero spend mid-period stays on track', () {
      final forecast = forecaster.forecast(
        spentAmount: 0,
        amountLimit: 500000,
        periodStart: periodStart,
        periodEnd: periodEnd,
        now: DateTime(2026, 6, 15),
      );

      expect(forecast.avgDailySpend, 0);
      expect(forecast.projectedTotal, 0);
      expect(forecast.severity, BudgetForecastSeverity.onTrack);
    });

    test('finished period exactly at limit is at least nearLimit', () {
      final forecast = forecaster.forecast(
        spentAmount: 500000,
        amountLimit: 500000,
        periodStart: periodStart,
        periodEnd: periodEnd,
        now: DateTime(2026, 7, 2),
      );

      expect(forecast.severity, isNot(BudgetForecastSeverity.onTrack));
      expect(forecast.projectedOverspend, lessThan(0.01));
    });

    test('avoid divide-by-zero on degenerate one-millisecond period', () {
      final forecast = forecaster.forecast(
        spentAmount: 100000,
        amountLimit: 500000,
        periodStart: DateTime(2026, 6, 10),
        periodEnd: DateTime(2026, 6, 10),
        now: DateTime(2026, 6, 10, 12),
      );

      expect(forecast.totalDays, greaterThan(0));
      expect(forecast.avgDailySpend.isFinite, isTrue);
    });
  });
}
