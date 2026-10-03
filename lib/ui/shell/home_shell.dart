import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import '../today/today_screen.dart';
import '../../core/money.dart';
import '../../data/store_scope.dart';
import '../bills/bills_screen.dart';
import '../insights/insights_screen.dart';
import '../routes.dart';
import '../vault/vault_screen.dart';
import '../widgets/kit.dart';

enum ShellTab { today, bills, vault, insights }

/// Switches the shell to [tab] from anywhere: closes pushed screens and
/// selects the tab (e.g. "Save to Vault" lands on the Vault tab).
void goToTab(BuildContext context, ShellTab tab) {
  HomeShell.tab.value = tab;
  Navigator.of(context).popUntil((r) => r.isFirst);
}

/// Main shell with the floating tab bar: Today · Bills · (+) · Vault · Insights.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  /// The selected tab; shared so other screens can switch it.
  static final tab = ValueNotifier(ShellTab.today);

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  ShellTab get _tab => HomeShell.tab.value;

  void _select(ShellTab tab) => HomeShell.tab.value = tab;

  void _onTab() => setState(() {});

  @override
  void initState() {
    super.initState();
    HomeShell.tab.addListener(_onTab);
  }

  @override
  void dispose() {
    HomeShell.tab.removeListener(_onTab);
    super.dispose();
  }

  void _openLogSpend() => Navigator.of(context).pushNamed(Routes.logSpend);

  /// Long-press +: quick amounts from the last 3 different spends.
  void _quickAmounts() {
    final store = StoreScope.of(context);
    final seen = <String>{};
    final recent = [
      for (final e in store.history)
        if (e.isSpend &&
            e.categoryId != 'bills' &&
            seen.add('${e.merchant}|${e.amountCents}'))
          e,
    ].take(3).toList();
    if (recent.isEmpty) return _openLogSpend();
    showModalBottomSheet<void>(
      context: context,
      builder: (sheet) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            SteadySpace.s5,
            0,
            SteadySpace.s5,
            SteadySpace.s4,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Log again', style: SteadyType.title.copyWith(fontSize: 24)),
              const SizedBox(height: SteadySpace.s2),
              for (final e in recent)
                NavRow(
                  label:
                      e.merchant ??
                      store.categoryById(e.categoryId)?.name ??
                      'Spend',
                  value: formatMoney(e.amountCents, symbol: store.symbol),
                  onTap: () {
                    Navigator.of(sheet).pop();
                    Navigator.of(context).pushNamed(
                      Routes.logSpend,
                      arguments: LogSpendArgs(
                        amountCents: e.amountCents,
                        merchant: e.merchant,
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: IndexedStack(
              index: _tab.index,
              children: [
                TodayScreen(
                  onLogSpend: _openLogSpend,
                  onOpenBills: () => _select(ShellTab.bills),
                ),
                const BillsScreen(),
                const VaultScreen(),
                const InsightsScreen(),
              ],
            ),
          ),
          Positioned(
            left: SteadySize.tabBarInset,
            right: SteadySize.tabBarInset,
            bottom: SteadySize.tabBarOffset(MediaQuery.paddingOf(context)),
            child: _TabBar(
              current: _tab,
              onSelect: _select,
              onAdd: _openLogSpend,
              onAddLongPress: _quickAmounts,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({
    required this.current,
    required this.onSelect,
    required this.onAdd,
    required this.onAddLongPress,
  });

  final ShellTab current;
  final ValueChanged<ShellTab> onSelect;
  final VoidCallback onAdd;
  final VoidCallback onAddLongPress;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Widget item(ShellTab tab, String label, IconData icon) => _TabItem(
      label: label,
      icon: icon,
      active: current == tab,
      onTap: () => onSelect(tab),
    );

    return Semantics(
      container: true,
      label: 'Main',
      child: Container(
        height: SteadySize.tabBarHeight,
        padding: const EdgeInsets.symmetric(horizontal: SteadySpace.s2),
        decoration: BoxDecoration(
          color: c.surface,
          border: Border.all(color: c.line),
          borderRadius: BorderRadius.circular(SteadyRadius.xl),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            item(ShellTab.today, 'Today', Icons.home_outlined),
            item(ShellTab.bills, 'Bills', Icons.calendar_today_outlined),
            Semantics(
              button: true,
              label: 'Log spend',
              excludeSemantics: true,
              child: Material(
                color: c.fab,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onAdd,
                  onLongPress: onAddLongPress,
                  child: SizedBox.square(
                    dimension: SteadySize.fab,
                    child: Icon(Icons.add_rounded, size: 26, color: c.onFab),
                  ),
                ),
              ),
            ),
            item(ShellTab.vault, 'Vault', Icons.savings_outlined),
            item(ShellTab.insights, 'Insights', Icons.bar_chart_rounded),
          ],
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = active ? c.tabActive : c.muted;
    return Semantics(
      button: true,
      selected: active,
      label: label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: 32,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(height: 3),
              Text(
                label,
                style: SteadyType.tab.copyWith(
                  color: color,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
