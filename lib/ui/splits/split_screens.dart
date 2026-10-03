import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/date_format.dart';
import '../../core/money.dart';
import '../../data/budget_store.dart';
import '../../data/store_scope.dart';
import '../../domain/models/models.dart';
import '../../theme/tokens.dart';
import '../routes.dart';
import '../widgets/kit.dart';

String _methodLabel(ExpenseSplit s) => switch (s.method) {
  SplitMethod.even => '50 / 50',
  SplitMethod.byIncome =>
    'Split by income · ${s.yourSharePercent} / ${s.theirSharePercent}',
  SplitMethod.perExpense => 'Per expense',
};

/// "Alex owes you" / "You owe Alex" / "All square".
String _balanceLabel(BudgetStore store) {
  final s = store.split!;
  final b = store.splitBalanceCents;
  if (b > 0) return '${s.personName} owes you';
  if (b < 0) return 'You owe ${s.personName}';
  return 'All square';
}

// ─── H1 Split setup ────────────────────────────────────────────────────────

class SplitSetupScreen extends StatefulWidget {
  const SplitSetupScreen({super.key});

  @override
  State<SplitSetupScreen> createState() => _SplitSetupScreenState();
}

class _SplitSetupScreenState extends State<SplitSetupScreen> {
  TextEditingController? _name;
  final _yours = TextEditingController();
  final _theirs = TextEditingController();
  SplitMethod _method = SplitMethod.byIncome;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_name != null) return;
    final s = StoreScope.of(context).split;
    _name = TextEditingController(text: s?.personName ?? '');
    _method = s?.method ?? SplitMethod.byIncome;
    _yours.text = '\$1,200';
    _theirs.text = '\$800';
  }

  @override
  void dispose() {
    _name?.dispose();
    _yours.dispose();
    _theirs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final c = context.colors;
    final person = _name!.text.trim();
    final yours = parseCents(_yours.text) ?? 0;
    final theirs = parseCents(_theirs.text) ?? 0;
    final yourPct = switch (_method) {
      SplitMethod.byIncome when yours + theirs > 0 =>
        (yours * 100 / (yours + theirs)).round(),
      _ => 50,
    };

    void start() {
      final existing = store.split;
      store.setSplit(
        ExpenseSplit(
          id: existing?.id ?? store.newId('split'),
          personName: person,
          yourSharePercent: yourPct,
          method: _method,
          lastSettled: existing?.lastSettled,
        ),
      );
      Navigator.of(context).pushReplacementNamed(Routes.splits);
    }

    return SteadyPage(
      title: 'Split expenses',
      gap: 18,
      bottom: SteadyButton(
        store.split == null ? 'Start splitting' : 'Save',
        onPressed: person.isEmpty ? null : start,
      ),
      children: [
        Text(
          "Track what you and someone else owe each other. They don't need the app, and nothing leaves this phone.",
          style: SteadyType.body.copyWith(color: c.muted, height: 1.5),
        ),
        SteadyField(
          label: 'Who do you split with?',
          controller: _name,
          hint: 'Their name',
          onChanged: (_) => setState(() {}),
        ),
        ChipGroup<SplitMethod>(
          label: 'How do you split?',
          options: SplitMethod.values,
          selected: _method,
          labelOf: (m) => switch (m) {
            SplitMethod.even => '50 / 50',
            SplitMethod.byIncome => 'By income',
            SplitMethod.perExpense => 'Per expense',
          },
          onSelected: (m) => setState(() => _method = m),
        ),
        if (_method == SplitMethod.byIncome) ...[
          Row(
            children: [
              Expanded(
                child: SteadyField(
                  label: 'Your monthly income',
                  controller: _yours,
                  emphasis: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: SteadySpace.s3),
              Expanded(
                child: SteadyField(
                  label: '${person.isEmpty ? 'Their' : "$person's"} income',
                  controller: _theirs,
                  emphasis: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DefaultTextStyle(
                  style: SteadyType.body.copyWith(fontSize: 14, color: c.ink),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text: 'You ',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                            TextSpan(text: '$yourPct%'),
                          ],
                        ),
                      ),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '${person.isEmpty ? 'Them' : person} ',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            TextSpan(text: '${100 - yourPct}%'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                SplitBar(
                  fraction: yourPct / 100,
                  left: c.primary,
                  right: c.highlight,
                ),
              ],
            ),
          ),
        ],
        const SoftBanner(
          icon: Icons.lock_outline_rounded,
          child: Text(
            'Only you see this. To share a balance, use Copy summary and paste it into any message.',
          ),
        ),
      ],
    );
  }
}

// ─── H2 Splits ─────────────────────────────────────────────────────────────

class SplitsScreen extends StatelessWidget {
  const SplitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final s = store.split;
    if (s == null) return const SplitSetupScreen();
    final c = context.colors;
    String m(int cents) => formatMoney(cents, symbol: store.symbol);
    final since = s.lastSettled == null
        ? ''
        : ' · since last settle-up on ${formatShortDate(s.lastSettled!)}';
    final expenses = store.sharedExpenses.toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return SteadyPage(
      title: 'You & ${s.personName}',
      subtitle: 'Split expenses · on this phone only',
      trailing: LinkText(
        'Edit',
        onTap: () => Navigator.of(context).pushNamed(Routes.splitSetup),
      ),
      bottom: ButtonRow(
        children: [
          SteadyButton(
            'Settle up',
            kind: ButtonKind.highlight,
            onPressed: () => Navigator.of(context).pushNamed(Routes.settleUp),
          ),
          SteadyButton(
            'Add shared',
            kind: ButtonKind.secondary,
            onPressed: () => Navigator.of(context).pushNamed(
              Routes.logSpend,
              arguments: const LogSpendArgs(shared: true),
            ),
          ),
        ],
      ),
      children: [
        Container(
          padding: const EdgeInsets.all(SteadySpace.s5),
          decoration: BoxDecoration(
            color: c.inverse,
            borderRadius: BorderRadius.circular(SteadyRadius.xl),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _balanceLabel(store),
                style: SteadyType.body.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: c.onInverseMuted,
                ),
              ),
              const SizedBox(height: SteadySpace.s2),
              Text(
                m(store.splitBalanceCents.abs()),
                style: SteadyType.amountXl.copyWith(
                  fontSize: 52,
                  color: c.highlight,
                ),
              ),
              const SizedBox(height: SteadySpace.s2),
              Text(
                '${_methodLabel(s)}$since',
                style: SteadyType.caption.copyWith(
                  fontWeight: FontWeight.w500,
                  color: c.onInverseMuted,
                ),
              ),
            ],
          ),
        ),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Shared expenses',
                      style: SteadyType.body.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    'Since last settle-up',
                    style: SteadyType.caption.copyWith(
                      fontWeight: FontWeight.w500,
                      color: c.muted,
                    ),
                  ),
                ],
              ),
              if (expenses.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    'Nothing shared yet. Tap Add shared after you pay for something together.',
                    style: SteadyType.body.copyWith(
                      fontSize: 14,
                      color: c.muted,
                    ),
                  ),
                ),
              for (final e in expenses)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: e.paidByYou ? c.hero : c.highlight,
                        child: Text(
                          e.paidByYou
                              ? 'Y'
                              : s.personName.characters.first.toUpperCase(),
                          style: SteadyType.caption.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: e.paidByYou ? c.onHero : c.onHighlight,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e.name,
                              style: SteadyType.body.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                height: 1.3,
                              ),
                            ),
                            Text(
                              '${e.paidByYou ? 'You' : s.personName} paid · ${formatShortDate(e.date)}',
                              style: SteadyType.caption.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: c.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        m(e.amountCents),
                        style: SteadyType.body.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── H3 Settle up ──────────────────────────────────────────────────────────

class SettleUpScreen extends StatefulWidget {
  const SettleUpScreen({super.key});

  @override
  State<SettleUpScreen> createState() => _SettleUpScreenState();
}

class _SettleUpScreenState extends State<SettleUpScreen> {
  String? _toast;
  bool _settled = false;

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final s = store.split;
    if (s == null) return const SplitSetupScreen();
    final c = context.colors;
    String m(int cents) => formatMoney(cents, symbol: store.symbol);
    final balance = store.splitBalanceCents;
    final expenses = store.sharedExpenses;

    String summary() {
      final lines = [
        'Steady split summary · ${_methodLabel(s)}',
        for (final e in expenses)
          '${e.name} (${formatShortDate(e.date)}): ${e.paidByYou ? 'I' : s.personName} paid ${m(e.amountCents)}',
        balance >= 0
            ? '${s.personName} owes me ${m(balance)}'
            : 'I owe ${s.personName} ${m(-balance)}',
      ];
      return lines.join('\n');
    }

    return SteadyPage(
      title: 'Settle up',
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          StatusToast(message: _toast),
          if (_toast != null) const SizedBox(height: 10),
          if (!_settled)
            SteadyButton(
              'Record as settled',
              onPressed: expenses.isEmpty
                  ? null
                  : () {
                      store.settleUp();
                      setState(() {
                        _settled = true;
                        _toast =
                            'Recorded as settled. Balance reset to ${m(0)}.';
                      });
                    },
            )
          else
            SteadyButton(
              'Back to splits',
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          const SizedBox(height: 10),
          SteadyButton(
            'Copy summary',
            kind: ButtonKind.secondary,
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: summary()));
              setState(
                () => _toast = 'Summary copied. Paste it into any message.',
              );
            },
          ),
        ],
      ),
      children: [
        Container(
          padding: const EdgeInsets.all(SteadySpace.s5),
          decoration: BoxDecoration(
            color: c.primarySoft,
            borderRadius: BorderRadius.circular(SteadyRadius.xl),
          ),
          child: Column(
            children: [
              Text(
                _balanceLabel(store),
                style: SteadyType.body.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: c.mutedStrong,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                m(balance.abs()),
                style: SteadyType.amountXl.copyWith(fontSize: 48),
              ),
              const SizedBox(height: 6),
              Text(
                _methodLabel(s),
                style: SteadyType.caption.copyWith(
                  fontWeight: FontWeight.w500,
                  color: c.mutedStrong,
                ),
              ),
            ],
          ),
        ),
        GroupedList(
          padding: const EdgeInsets.symmetric(horizontal: SteadySpace.s4),
          children: [
            for (final e in expenses)
              ValueRow(
                label: e.name,
                labelWidget: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.name,
                      style: SteadyType.body.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                    Text(
                      '${formatShortDate(e.date)} · ${e.paidByYou ? 'You' : s.personName} paid ${m(e.amountCents)}',
                      style: SteadyType.caption.copyWith(
                        fontWeight: FontWeight.w500,
                        color: c.muted,
                      ),
                    ),
                  ],
                ),
                value: m(e.balanceEffectCents(s)),
              ),
            ValueRow(
              label: 'Net',
              value: balance >= 0
                  ? '${m(balance)} to you'
                  : '${m(-balance)} to ${s.personName}',
              valueColor: c.positive,
            ),
          ],
        ),
        Text(
          "Steady doesn't move money. Pay each other however you like, then record it here.",
          style: SteadyType.caption.copyWith(
            fontWeight: FontWeight.w500,
            color: c.muted,
          ),
        ),
      ],
    );
  }
}
