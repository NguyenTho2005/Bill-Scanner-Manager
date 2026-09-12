import 'dart:ui';
import 'package:equatable/equatable.dart';

/// Domain entity representing a transaction category.
class Category extends Equatable {
  /// Creates a [Category].
  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.colorValue,
    this.parentId,
    this.isSystem = false,
    this.sortOrder = 0,
  });

  /// Unique identifier (e.g. "food_drinks").
  final String id;

  /// Optional parent category ID for hierarchical categories.
  final String? parentId;

  /// Human-readable name (e.g. "Ăn uống").
  final String name;

  /// Material icon name or emoji identifier.
  final String icon;

  /// Color hex code as integer (e.g. 0xFFFF6B35).
  final int colorValue;

  /// Whether this is a predefined system category (cannot be deleted).
  final bool isSystem;

  /// Display sort order.
  final int sortOrder;

  /// Color converted to [Color] object.
  Color get color => Color(colorValue);

  @override
  List<Object?> get props => [
        id,
        parentId,
        name,
        icon,
        colorValue,
        isSystem,
        sortOrder,
      ];
}
