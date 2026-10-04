import 'package:flutter/material.dart';

import '../../core/money.dart';
import '../../data/store_scope.dart';
import '../../domain/models/models.dart';
import '../../theme/tokens.dart';
import '../routes.dart';
import '../widgets/kit.dart';

/// 03 Log spend + mood. Amount is focused on open (Handoff 2 · Gestures).
class LogSpendScreen extends StatefulWidget {
  const LogSpendScreen({super.key, this.args = const LogSpendArgs()});
  final LogSpendArgs args;

  @override
  State<LogSpendScreen> createState() => _LogSpendScreenState();
}

class _LogSpendScreenState extends State<LogSpendScreen> {
  late final _amount = TextEditingController(
    text: widget.args.amountCents == null
        ? ''
        : centsToField(widget.args.amountCents!),
  );
  late final _where = TextEditingController(text: widget.args.merchant ?? '');
  String? _categoryId = 'food';
  Mood? _mood;
  bool _planned = false;

  @override
  void dispose() {
    _amount.dispose();
    _where.dispose();
    super.dispose();
  }

  Entry? _draft(String id) {
    final cents = parseCents(_amount.text);
    if (cents == null || cents <= 0) return null;
    final store = StoreScope.of(context);
    final merchant = _where.text.trim();
    return Entry(
      id: id,
      type: EntryType.spend,
      amountCents: cents,
      localDate: widget.args.date ?? store.today,
      createdAtUtc: DateTime.now().toUtc(),
      timeZoneId: DateTime.now().timeZoneName,
      merchant: merchant.isEmpty
          ? null
          : merchant.substring(
              0,
              merchant.length.clamp(0, Entry.maxMerchantLength),
            ),
      categoryId: _categoryId,
      mood: _mood,
      planned: _planned,
      splitId: widget.args.shared ? store.split?.id : null,
    );
  }

  void _save() {
    final store = StoreScope.of(context);
    final entry = _draft(store.newId('entry'));
    if (entry == null) return;
    store.addEntry(entry);
    if (widget.args.shared && store.split != null) {
      store.addSharedExpense(
        SharedExpense(
          id: store.newId('shared'),
          name: entry.merchant ?? 'Shared expense',
          amountCents: entry.amountCents,
          date: entry.localDate,
          paidByYou: true,
        ),
      );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final symbol = store.symbol;
    final draft = _draft('preview');
    final now = store.dailyNumber.safeToSpendCents;
    final after = draft == null
        ? null
        : store.previewWith(draft).safeToSpendCents;
    final categories = store.categories.where((c) => c.id != 'bills').toList();
    final split = store.split;

    return SteadyPage(
      title: 'Log spend',
      leading: PageLeading.close,
      gap: 14,
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SoftBanner(
            radius: SteadyRadius.md,
            child: Row(
              children: [
                const Expanded(child: Text('Safe to spend today')),
                Text(
                  after == null
                      ? formatMoney(now, symbol: symbol)
                      : '${formatMoney(now, symbol: symbol)} → ${formatMoney(after, symbol: symbol)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: after != null && after < 0
                        ? context.colors.dangerFg
                        : null,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: SteadySpace.s3),
          SteadyButton('Save', onPressed: draft == null ? null : _save),
        ],
      ),
      children: [
        Segmented<bool>(
          options: const [true, false],
          selected: true,
          labelOf: (spend) => spend ? 'Spend' : 'Income',
          onSelected: (spend) {
            if (!spend) {
              Navigator.of(context).pushReplacementNamed(Routes.logIncome);
            }
          },
        ),
        if (widget.args.shared && split != null)
          SoftBanner(
            icon: Icons.people_outline_rounded,
            child: Text(
              'Shared with ${split.personName} · you pay '
              '${split.yourSharePercent}%, they pay ${split.theirSharePercent}%',
            ),
          ),
        SteadyField(
          label: 'Amount',
          amount: true,
          controller: _amount,
          hint: '${symbol}0.00',
          autofocus: widget.args.amountCents == null,
          onChanged: (_) => setState(() {}),
        ),
        SteadyField(label: 'Where', controller: _where, hint: 'Shop or place'),
        ChipGroup<String>(
          label: 'Category',
          options: [for (final c in categories) c.id],
          selected: _categoryId,
          labelOf: (id) => store.categoryById(id)?.name ?? id,
          onSelected: (id) => setState(() => _categoryId = id),
        ),
        ChipGroup<Mood>(
          label: 'How are you feeling?',
          options: Mood.values,
          selected: _mood,
          labelOf: (m) => m.label,
          onSelected: (m) => setState(() => _mood = _mood == m ? null : m),
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                'Was this planned?',
                style: SteadyType.body.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            Segmented<bool>(
              expand: false,
              itemHeight: 40,
              options: const [true, false],
              selected: _planned,
              labelOf: (p) => p ? 'Yes' : 'No',
              onSelected: (p) => setState(() => _planned = p),
            ),
          ],
        ),
      ],
    );
  }
}
