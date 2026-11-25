import 'package:bill_tracker/features/transaction/domain/entities/recurring_rule.dart';
import 'package:bill_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:bill_tracker/features/transaction/domain/entities/transaction_media.dart';
import 'package:drift/drift.dart';

/// Maps [RecurringFrequency] to/from snake_case DB values.
const Map<RecurringFrequency, String> _frequencyToDb = {
  RecurringFrequency.daily: 'daily',
  RecurringFrequency.weekly: 'weekly',
  RecurringFrequency.monthly: 'monthly',
};

/// Maps snake_case DB values back to [RecurringFrequency] (default: daily).
const Map<String, RecurringFrequency> _dbToFrequency = {
  'daily': RecurringFrequency.daily,
  'weekly': RecurringFrequency.weekly,
  'monthly': RecurringFrequency.monthly,
};

/// Converter for [RecurringFrequency] (snake_case in DB).
class RecurringFrequencyConverter
    extends TypeConverter<RecurringFrequency, String> {
  const RecurringFrequencyConverter();

  @override
  RecurringFrequency fromSql(String fromDb) =>
      _dbToFrequency[fromDb] ?? RecurringFrequency.daily;

  @override
  String toSql(RecurringFrequency mapToDb) =>
      _frequencyToDb[mapToDb] ?? mapToDb.name;
}

/// TypeConverters that keep domain enums in Dart but store snake_case strings
/// in the database (fixes enum-name inconsistency, see PROJECT_CONTEXT §4.6 #6).
///
/// Dart callers continue to pass `Enum` instances; only the persisted value
/// changes to the canonical `snake_case` form.

/// Maps Dart enum names ↔ snake_case DB values (A.1.1).
const Map<TransactionSource, String> _sourceToDb = {
  TransactionSource.productSnap: 'product_snap',
  TransactionSource.receiptScan: 'receipt_scan',
  TransactionSource.manual: 'manual',
  TransactionSource.import_: 'import',
};
const Map<String, TransactionSource> _dbToSource = {
  'product_snap': TransactionSource.productSnap,
  'receipt_scan': TransactionSource.receiptScan,
  'manual': TransactionSource.manual,
  'import': TransactionSource.import_,
  'recurring': TransactionSource.recurring,
  // Backwards compatibility for data stored before the converter (A.2.2).
  'productSnap': TransactionSource.productSnap,
  'receiptScan': TransactionSource.receiptScan,
  'import_': TransactionSource.import_,
};

/// TransactionType values are the same on both sides ('expense'/'income').
class TransactionTypeConverter extends TypeConverter<TransactionType, String> {
  const TransactionTypeConverter();

  @override
  TransactionType fromSql(String fromDb) =>
      TransactionType.values.byName(fromDb);

  @override
  String toSql(TransactionType mapToDb) => mapToDb.name;
}

class TransactionSourceConverter
    extends TypeConverter<TransactionSource, String> {
  const TransactionSourceConverter();

  @override
  TransactionSource fromSql(String fromDb) =>
      _dbToSource[fromDb] ?? TransactionSource.manual;

  @override
  String toSql(TransactionSource mapToDb) =>
      _sourceToDb[mapToDb] ?? mapToDb.name;
}

class TransactionStatusConverter
    extends TypeConverter<TransactionStatus, String> {
  const TransactionStatusConverter();

  @override
  TransactionStatus fromSql(String fromDb) => switch (fromDb) {
        'draft' => TransactionStatus.draft,
        'confirmed' => TransactionStatus.confirmed,
        'needs_review' => TransactionStatus.needsReview,
        'failed' => TransactionStatus.failed,
        'needsReview' => TransactionStatus.needsReview,
        _ => TransactionStatus.confirmed,
      };

  @override
  String toSql(TransactionStatus mapToDb) => switch (mapToDb) {
        TransactionStatus.draft => 'draft',
        TransactionStatus.confirmed => 'confirmed',
        TransactionStatus.needsReview => 'needs_review',
        TransactionStatus.failed => 'failed',
      };
}

class PaymentMethodConverter extends TypeConverter<PaymentMethod, String> {
  const PaymentMethodConverter();

  @override
  PaymentMethod fromSql(String fromDb) => PaymentMethod.values.byName(fromDb);

  @override
  String toSql(PaymentMethod mapToDb) => mapToDb.name;
}

class MediaTypeConverter extends TypeConverter<MediaType, String> {
  const MediaTypeConverter();

  @override
  MediaType fromSql(String fromDb) => MediaType.values.byName(fromDb);

  @override
  String toSql(MediaType mapToDb) => mapToDb.name;
}
