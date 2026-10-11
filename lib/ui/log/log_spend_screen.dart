import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/date_format.dart';
import '../../core/money.dart';
import '../../data/budget_store.dart';
import '../../data/store_scope.dart';
import '../../domain/bill_match.dart';
import '../../domain/category_cover.dart';
import '../../domain/models/models.dart';
import '../../theme/tokens.dart';
import '../routes.dart';
import '../settings/category_edit_screen.dart';
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
        : centsToField(
            widget.args.amountCents!,
            symbol: MoneySymbol.read(context),
          ),
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
      // Food is the default; it may have been deleted.
      categoryId: store.categoryById(_categoryId) == null ? null : _categoryId,
      mood: _mood,
      planned: _planned,
    );
  }

  Future<void> _save() async {
    final store = StoreScope.of(context);
    final entry = _draft(store.newId('entry'));
    if (entry == null) return;
    // A reserved bill logged as a spend would count twice.
    final bill = likelyBillFor(
      merchant: entry.merchant,
      amountCents: entry.amountCents,
      reservedBills: store.upcomingBills,
      today: store.today,
    );
    if (bill != null) {
      final choice = await _askAboutBill(store, bill, entry.amountCents);
      if (!mounted || choice == null) return;
      if (choice) {
        store.payBill(bill, amountCents: entry.amountCents);
        if (mounted) Navigator.of(context).pop();
        return;
      }
    }
    HapticFeedback.lightImpact();
    store.addEntry(entry);
    if (mounted) Navigator.of(context).pop();
  }

  /// True: mark the bill as paid. False: it's an ordinary spend. Null:
  /// dismissed (nothing saved).
  Future<bool?> _askAboutBill(BudgetStore store, Bill bill, int cents) {
    final symbol = store.symbol;
    String m(int c) => formatMoney(c, symbol: symbol);
    return showModalBottomSheet<bool>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            SteadySpace.s5,
            SteadySpace.s5,
            SteadySpace.s5,
            SteadySpace.s4,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Is this your ${bill.name} bill?',
                style: SteadyType.title.copyWith(fontSize: 22),
              ),
              const SizedBox(height: SteadySpace.s2),
              Text(
                '${bill.name} (${bill.isEstimate ? '~' : ''}${m(bill.amountCents)}, '
                'due ${formatShortDate(bill.dueDate)}) is already set aside. '
                'Mark it as paid so it isn\'t counted twice.',
                style: SteadyType.body.copyWith(
                  color: context.colors.muted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: SteadySpace.s5),
              SteadyButton(
                'Mark ${bill.name} as paid',
                onPressed: () => Navigator.of(context).pop(true),
              ),
              const SizedBox(height: 10),
              SteadyButton(
                'No, it\'s a normal spend',
                kind: ButtonKind.secondary,
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The category's monthly limit, as a warning inside the daily number:
  /// what's left, "getting close" from 80%, or how far over this spend goes.
  Widget? _limitLine(BudgetStore store, Entry? draft) {
    final category = store.categoryById(_categoryId);
    final limit = category?.monthlyLimitCents;
    if (category == null || limit == null) return null;
    final c = context.colors;
    String whole(int cents) =>
        formatMoney(cents, symbol: store.symbol, showCents: false);
    final left = store.leftThisMonth(
      category,
      on: widget.args.date ?? store.today,
    )!;
    final after = left - (draft?.amountCents ?? 0);
    final level = limitLevel(limitCents: limit, leftAfterCents: after);
    final name = category.name;
    final text = switch (level) {
      LimitLevel.over =>
        'This takes $name ${whole(-after)} over its ${whole(limit)} monthly '
            'limit. Just a warning: your daily number counts it as usual.',
      LimitLevel.close =>
        '$name: ${whole(after)} left of ${whole(limit)} this month'
            '${draft == null ? '' : ' after this'}. Getting close.',
      LimitLevel.fine =>
        '$name: ${whole(after)} left of ${whole(limit)} this month'
            '${draft == null ? '' : ' after this'}.',
    };
    final warn = level != LimitLevel.fine;
    return Semantics(
      liveRegion: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (warn) ...[
            Icon(Icons.warning_amber_rounded, size: 16, color: c.warningFg),
            const SizedBox(width: SteadySpace.s1),
          ],
          Expanded(
            child: Text(
              text,
              style: SteadyType.caption.copyWith(
                fontWeight: warn ? FontWeight.w700 : FontWeight.w500,
                color: warn ? c.warningFg : c.muted,
              ),
            ),
          ),
        ],
      ),
    );
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
        SteadyField(
          label: 'Amount',
          amount: true,
          controller: _amount,
          hint: '${symbol}0.00',
          autofocus: widget.args.amountCents == null,
          onChanged: (_) => setState(() {}),
        ),
        SteadyField(label: 'Where', controller: _where, hint: 'Shop or place'),
        Text(
          'Paying a bill? Mark it as paid in Bills instead, so it isn\'t '
          'counted twice.',
          style: SteadyType.caption.copyWith(color: context.colors.muted),
        ),
        ChipGroup<String>(
          label: 'Category',
          options: [for (final c in categories) c.id],
          selected: _categoryId,
          onLongPress: (id) async {
            final cat = store.categoryById(id);
            if (cat == null) return;
            // No Undo bar here: it would cover Save. The sheet asks first.
            final deleted = await deleteCategoryFlow(context, cat, undo: false);
            if (deleted && _categoryId == id && mounted) {
              setState(() => _categoryId = null);
            }
          },
          longPressHint: 'Delete category',
          labelOf: (id) => store.categoryById(id)?.name ?? id,
          onSelected: (id) => setState(() => _categoryId = id),
          trailing: AddChip(
            label: '+ New',
            onTap: () async {
              final id = await Navigator.of(context)
                  .pushNamed(Routes.categoryEdit);
              if (id is String && mounted) setState(() => _categoryId = id);
            },
          ),
        ),
        ?_limitLine(store, draft),
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
