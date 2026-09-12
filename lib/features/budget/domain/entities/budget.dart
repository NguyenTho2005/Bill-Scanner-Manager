import 'package:bill_tracker/features/transaction/domain/entities/category.dart';
import 'package:equatable/equatable.dart';

/// Domain entity representing a category spending budget.
class Budget extends Equatable {
  /// Creates a [Budget].
  const Budget({
    required this.id,
    required this.categoryId,
    required this.amountLimit,
    required this.periodStart,
    required this.periodEnd,
    this.period = 'monthly',
    this.alertThresholds = const [0.8, 1.0, 1.2],
    this.alertSentAt80 = false,
    this.alertSentAt100 = false,
    this.category,
  });

  /// Unique budget identifier.
  final String id;

  /// Target category ID.
  final String categoryId;

  /// Budget period identifier (e.g. 'monthly', 'weekly').
  final String period;

  /// Maximum spending limit amount (in VND).
  final double amountLimit;

  /// Threshold fractions for warnings (e.g. [0.8, 1.0, 1.2]).
  final List<double> alertThresholds;

  /// Whether warning alert (80%) was already dispatched this period.
  final bool alertSentAt80;

  /// Whether limit reached alert (100%) was already dispatched this period.
  final bool alertSentAt100;

  /// Period start timestamp.
  final DateTime periodStart;

  /// Period end timestamp.
  final DateTime periodEnd;

  /// Associated category entity (when populated via join).
  final Category? category;

  /// Creates a copy with replaced fields.
  Budget copyWith({
    String? id,
    String? categoryId,
    String? period,
    double? amountLimit,
    List<double>? alertThresholds,
    bool? alertSentAt80,
    bool? alertSentAt100,
    DateTime? periodStart,
    DateTime? periodEnd,
    Category? category,
  }) {
    return Budget(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      period: period ?? this.period,
      amountLimit: amountLimit ?? this.amountLimit,
      alertThresholds: alertThresholds ?? this.alertThresholds,
      alertSentAt80: alertSentAt80 ?? this.alertSentAt80,
      alertSentAt100: alertSentAt100 ?? this.alertSentAt100,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      category: category ?? this.category,
    );
  }

  @override
  List<Object?> get props => [
        id,
        categoryId,
        period,
        amountLimit,
        alertThresholds,
        alertSentAt80,
        alertSentAt100,
        periodStart,
        periodEnd,
        category,
      ];
}
