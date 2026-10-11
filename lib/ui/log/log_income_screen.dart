import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/money.dart';
import '../../data/store_scope.dart';
import '../../domain/models/models.dart';
import '../../theme/tokens.dart';
import '../routes.dart';
import '../shell/home_shell.dart';
import '../widgets/kit.dart';

/// V1 Log income: to the Paycheck Vault, or straight to the daily number.
class LogIncomeScreen extends StatefulWidget {
  const LogIncomeScreen({super.key});

  @override
  State<LogIncomeScreen> createState() => _LogIncomeScreenState();
}

enum _Source { paycheck, client, tips, other }

class _LogIncomeScreenState extends State<LogIncomeScreen> {
  final _amount = TextEditingController();
  final _from = TextEditingController();
  _Source _source = _Source.client;
  bool? _toVault;

  @override
  void dispose() {
    _amount.dispose();
    _from.dispose();
    super.dispose();
  }

  Entry? _draft(String id, bool toVault) {
    final cents = parseCents(_amount.text);
    if (cents == null || cents <= 0) return null;
    final from = _from.text.trim();
    return Entry(
      id: id,
      type: EntryType.income,
      amountCents: cents,
      localDate: StoreScope.of(context).today,
      createdAtUtc: DateTime.now().toUtc(),
      timeZoneId: DateTime.now().timeZoneName,
      merchant: from.isEmpty ? _labelOf(_source) : from,
      toVault: toVault,
    );
  }

  String _labelOf(_Source s) => switch (s) {
    _Source.paycheck => 'Paycheck',
    _Source.client => 'Client',
    _Source.tips => 'Tips',
    _Source.other => 'Other',
  };

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final symbol = store.symbol;
    // Irregular earners default to the Vault; salaried users to today.
    final toVault = _toVault ?? store.settings.incomeType != IncomeType.salary;
    final now = store.dailyNumber.safeToSpendCents;
    final preview = _draft('preview', false);
    final after = preview == null
        ? null
        : store.previewWith(preview).safeToSpendCents;
    final weekly = formatMoney(
      store.vault.steadyPayWeeklyCents,
      symbol: symbol,
      showCents: false,
    );

    void save() {
      final entry = _draft(store.newId('income'), toVault);
      if (entry == null) return;
      HapticFeedback.lightImpact();
      store.addEntry(entry);
      // Design: Save to Vault lands on the Vault; Save income on Today.
      goToTab(context, toVault ? ShellTab.vault : ShellTab.today);
    }

    return SteadyPage(
      title: 'Log income',
      leading: PageLeading.close,
      gap: 14,
      bottom: SteadyButton(
        toVault ? 'Save to Vault' : 'Save income',
        onPressed: preview == null ? null : save,
      ),
      children: [
        Segmented<bool>(
          options: const [true, false],
          selected: false,
          labelOf: (spend) => spend ? 'Spend' : 'Income',
          onSelected: (spend) {
            if (spend) {
              Navigator.of(context).pushReplacementNamed(Routes.logSpend);
            }
          },
        ),
        SteadyField(
          label: 'Amount received',
          amount: true,
          controller: _amount,
          hint: '${symbol}0.00',
          autofocus: true,
          onChanged: (_) => setState(() {}),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SteadyField(
                label: 'From',
                controller: _from,
                hint: 'Who paid you',
              ),
            ),
            const SizedBox(width: SteadySpace.s3),
            const Expanded(
              child: SteadyField(
                label: 'Date',
                initialValue: 'Today',
                readOnly: true,
              ),
            ),
          ],
        ),
        ChipGroup<_Source>(
          options: _Source.values,
          selected: _source,
          labelOf: _labelOf,
          onSelected: (s) => setState(() => _source = s),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const FieldLabel('Where should it go?'),
            const SizedBox(height: SteadySpace.s2),
            RadioCard(
              minHeight: 64,
              title: 'Paycheck Vault',
              subtitle: 'Smoothed into your $weekly weekly pay',
              selected: toVault,
              onTap: () => setState(() => _toVault = true),
            ),
            const SizedBox(height: SteadySpace.s2),
            RadioCard(
              minHeight: 64,
              title: 'Straight to my daily number',
              subtitle: after == null
                  ? 'Raises what you can spend each day until payday'
                  : '${formatMoney(now, symbol: symbol)} → ${formatMoney(after, symbol: symbol)} a day until payday',
              selected: !toVault,
              onTap: () => setState(() => _toVault = false),
            ),
          ],
        ),
      ],
    );
  }
}
