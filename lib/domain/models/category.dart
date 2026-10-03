import 'package:flutter/foundation.dart';

/// Which token pair a category's icon tile uses. Maps to theme colors in the UI.
/// Order matches the color swatches on the Edit category screen.
enum CategoryTone { primary, warning, info, danger, neutral }

@immutable
class BudgetCategory {
  const BudgetCategory({
    required this.id,
    required this.name,
    this.tone = CategoryTone.primary,
    this.monthlyLimitCents,
  });

  final String id;
  final String name;
  final CategoryTone tone;

  /// Warn as spending gets close. Null = no limit.
  final int? monthlyLimitCents;

  BudgetCategory copyWith({
    String? name,
    CategoryTone? tone,
    int? Function()? monthlyLimitCents,
  }) {
    return BudgetCategory(
      id: id,
      name: name ?? this.name,
      tone: tone ?? this.tone,
      monthlyLimitCents: monthlyLimitCents != null
          ? monthlyLimitCents()
          : this.monthlyLimitCents,
    );
  }
}
