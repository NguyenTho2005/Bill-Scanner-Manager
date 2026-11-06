import 'package:equatable/equatable.dart';

/// Severity of a budget forecast warning.
enum BudgetForecastSeverity {
  /// Projected total stays within 80% of the limit.
  onTrack,

  /// Projected total reaches between 80% and 100% of the limit.
  nearLimit,

  /// Projected total is expected to exceed the limit.
  likelyExceed,
}

/// Result of a local budget projection. Pure math — no AI/cloud involved.
class BudgetForecast extends Equatable {
  /// Creates [BudgetForecast].
  const BudgetForecast({
    required this.spentSoFar,
    required this.amountLimit,
    required this.avgDailySpend,
    required this.projectedTotal,
    required this.projectedOverspend,
    required this.daysElapsed,
    required this.totalDays,
    required this.severity,
  });

  /// Total spent from period start up to the reference time.
  final double spentSoFar;

  /// The budget's spending limit.
  final double amountLimit;

  /// Average spend per day so far in the period.
  final double avgDailySpend;

  /// Projection of the total spent by the end of the period.
  final double projectedTotal;

  /// How much the projection exceeds the limit (0 when it does not).
  final double projectedOverspend;

  /// Number of days elapsed in the period (fractional, min 1 day).
  final double daysElapsed;

  /// Total number of days in the period.
  final double totalDays;

  /// Severity classification for UI coloring/messaging.
  final BudgetForecastSeverity severity;

  @override
  List<Object?> get props => [
        spentSoFar,
        amountLimit,
        avgDailySpend,
        projectedTotal,
        projectedOverspend,
        daysElapsed,
        totalDays,
        severity,
      ];
}

/// Forecasts end-of-period spending from average daily behaviour.
///
/// Works entirely on-device from already-available numbers, so budgets can
/// show a friendly "you may overshoot by X" warning without any remote API.
class BudgetForecaster {
  /// Creates [BudgetForecaster].
  const BudgetForecaster({this.nearLimitFraction = 0.8});

  /// Fraction of the limit at which the warning becomes "at risk".
  final double nearLimitFraction;

  /// Projects the total spend for a budget period.
  ///
  /// [spentAmount] is everything spent between [periodStart] and [now].
  /// When [now] is past [periodEnd] the period is treated as finished and
  /// the projection equals the actual spend.
  BudgetForecast forecast({
    required double spentAmount,
    required double amountLimit,
    required DateTime periodStart,
    required DateTime periodEnd,
    required DateTime now,
  }) {
    final periodMinutes = periodEnd.difference(periodStart).inMinutes.abs();
    final rawTotalDays = periodMinutes / Duration.minutesPerDay;
    final totalDays = rawTotalDays < 1 ? 1.0 : rawTotalDays;

    // Period not started yet: nothing spent, nothing to project.
    if (now.isBefore(periodStart)) {
      return _build(
        spentAmount: 0,
        amountLimit: amountLimit,
        daysElapsed: 0,
        totalDays: totalDays,
      );
    }

    // Period finished: the projection is simply the actual spend.
    if (now.isAfter(periodEnd)) {
      return _build(
        spentAmount: spentAmount,
        amountLimit: amountLimit,
        daysElapsed: totalDays,
        totalDays: totalDays,
      );
    }

    final minutesElapsed =
        now.difference(periodStart).inMinutes / Duration.minutesPerDay;
    final daysElapsed = minutesElapsed < 0.5 ? 0.5 : minutesElapsed;

    return _build(
      spentAmount: spentAmount,
      amountLimit: amountLimit,
      daysElapsed: daysElapsed,
      totalDays: totalDays,
    );
  }

  BudgetForecast _build({
    required double spentAmount,
    required double amountLimit,
    required double daysElapsed,
    required double totalDays,
  }) {
    final avgDailySpend = daysElapsed > 0 ? spentAmount / daysElapsed : 0.0;
    final projectedTotal =
        daysElapsed > 0 ? avgDailySpend * totalDays : spentAmount;
    final projectedOverspend =
        projectedTotal > amountLimit ? projectedTotal - amountLimit : 0.0;

    BudgetForecastSeverity severity;
    if (projectedOverspend > 0) {
      severity = BudgetForecastSeverity.likelyExceed;
    } else if (projectedTotal >= amountLimit * nearLimitFraction) {
      severity = BudgetForecastSeverity.nearLimit;
    } else {
      severity = BudgetForecastSeverity.onTrack;
    }

    return BudgetForecast(
      spentSoFar: spentAmount,
      amountLimit: amountLimit,
      avgDailySpend: avgDailySpend,
      projectedTotal: projectedTotal,
      projectedOverspend: projectedOverspend,
      daysElapsed: daysElapsed,
      totalDays: totalDays,
      severity: severity,
    );
  }
}
