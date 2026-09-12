import 'package:drift/drift.dart';

/// Receipt line items table for itemized expense tracking.
@DataClassName('ReceiptLineItemRow')
class ReceiptLineItems extends Table {
  /// Unique identifier.
  TextColumn get id => text()();

  /// Foreign key to Transactions.id.
  TextColumn get transactionId => text()();

  /// Line item description / product name.
  TextColumn get name => text()();

  /// Quantity purchased.
  RealColumn get quantity => real().nullable()();

  /// Price per unit.
  RealColumn get unitPrice => real().nullable()();

  /// Line item total amount.
  RealColumn get total => real()();

  /// AI-suggested category ID for this line item.
  TextColumn get categorySuggestion => text().nullable()();

  /// OCR confidence for this line.
  RealColumn get confidence => real().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}
