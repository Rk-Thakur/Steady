import 'package:flutter/widgets.dart';

import 'budget_store.dart';

/// Makes the [BudgetStore] available below it and rebuilds dependents when it changes.
class StoreScope extends InheritedNotifier<BudgetStore> {
  const StoreScope({
    super.key,
    required BudgetStore store,
    required super.child,
  }) : super(notifier: store);

  static BudgetStore of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<StoreScope>()!.notifier!;

  /// The store without subscribing to changes (for callbacks).
  static BudgetStore read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<StoreScope>()!.notifier!;
}
