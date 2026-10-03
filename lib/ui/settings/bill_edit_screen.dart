import 'package:flutter/material.dart';

import '../../core/date_format.dart';
import '../../core/local_date.dart';
import '../../core/money.dart';
import '../../domain/schedule.dart';
import '../../data/store_scope.dart';
import '../../domain/models/models.dart';
import '../../theme/tokens.dart';
import '../routes.dart';
import '../widgets/kit.dart';

/// N5 Add a bill (or edit one when [billId] is given).
class BillEditScreen extends StatefulWidget {
  const BillEditScreen({super.key, this.billId, this.prefill});
  final String? billId;
  final BillPrefill? prefill;

  @override
  State<BillEditScreen> createState() => _BillEditScreenState();
}

class _BillEditScreenState extends State<BillEditScreen> {
  late final TextEditingController _name;
  late final TextEditingController _amount;
  late LocalDate _due;
  Recurrence _recurrence = Recurrence.monthly;
  bool _estimate = false;
  Bill? _existing;
  bool _init = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_init) return;
    _init = true;
    final store = StoreScope.of(context);
    for (final b in store.bills) {
      if (b.id == widget.billId) _existing = b;
    }
    final pre = widget.prefill;
    _name = TextEditingController(text: _existing?.name ?? pre?.name ?? '');
    _amount = TextEditingController(
      text: _existing != null
          ? centsToField(_existing!.amountCents)
          : pre?.amountCents != null
          ? centsToField(pre!.amountCents!)
          : '',
    );
    _due = _existing?.dueDate ?? store.today.addDays(pre?.dueInDays ?? 3);
    _recurrence = _existing?.recurrence ?? Recurrence.monthly;
    _estimate = _existing?.isEstimate ?? false;
  }

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    super.dispose();
  }

  Future<void> _pickDue() async {
    final today = StoreScope.of(context).today;
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(_due.year, _due.month, _due.day),
      firstDate: DateTime(
        today.year,
        today.month,
        today.day,
      ).subtract(const Duration(days: 31)),
      lastDate: DateTime(today.year + 1, today.month, today.day),
    );
    if (picked != null) setState(() => _due = LocalDate.fromDateTime(picked));
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final cents = parseCents(_amount.text);
    final name = _name.text.trim();

    void save() {
      final bill = Bill(
        id: _existing?.id ?? store.newId('bill'),
        name: name,
        amountCents: cents!,
        recurrence: _recurrence,
        dueDate: _due,
        isEstimate: _estimate,
        isSubscription:
            _existing?.isSubscription ?? widget.prefill?.subscription ?? false,
        lastPaidOn: _existing?.lastPaidOn,
      );
      _existing == null ? store.addBill(bill) : store.updateBill(bill);
      Navigator.of(context).pop();
    }

    return SteadyPage(
      title: _existing == null ? 'Add a bill' : 'Edit bill',
      gap: 18,
      bottom: SteadyButton(
        'Save bill',
        onPressed: name.isEmpty || cents == null || cents <= 0 ? null : save,
      ),
      children: [
        if (_existing != null) _PayCard(bill: _existing!),
        SteadyField(
          label: 'Bill name',
          controller: _name,
          hint: 'e.g. Phone',
          onChanged: (_) => setState(() {}),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SteadyField(
                label: 'Amount',
                controller: _amount,
                emphasis: true,
                hint: '${store.symbol}0.00',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: SteadySpace.s3),
            Expanded(
              child: SteadyField(
                key: ValueKey(_due),
                label: 'Next due',
                initialValue: formatShortDate(_due),
                emphasis: true,
                readOnly: true,
                onTap: _pickDue,
              ),
            ),
          ],
        ),
        ChipGroup<Recurrence>(
          label: 'Repeats',
          options: Recurrence.values,
          selected: _recurrence,
          labelOf: (r) => switch (r) {
            Recurrence.weekly => 'Weekly',
            Recurrence.everyTwoWeeks => 'Every 2 weeks',
            Recurrence.monthly => 'Monthly',
            Recurrence.yearly => 'Yearly',
          },
          onSelected: (r) => setState(() => _recurrence = r),
        ),
        Panel(
          padding: const EdgeInsets.symmetric(
            horizontal: SteadySpace.s4,
            vertical: 14,
          ),
          child: SwitchRow(
            title: 'Amount changes',
            subtitle: 'Mark as an estimate (like electric)',
            value: _estimate,
            onChanged: (v) => setState(() => _estimate = v),
          ),
        ),
      ],
    );
  }
}

/// The bill's current occurrence, with "Mark as paid".
class _PayCard extends StatelessWidget {
  const _PayCard({required this.bill});
  final Bill bill;

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final c = context.colors;
    final latest =
        store.bills.where((b) => b.id == bill.id).firstOrNull ?? bill;
    final overdue = latest.isOverdueOn(store.today);
    final amount =
        '${latest.isEstimate ? '~' : ''}${formatMoney(latest.amountCents, symbol: store.symbol)}';
    return Panel(
      borderColor: overdue ? c.dangerFg : null,
      borderWidth: overdue ? 2 : 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      overdue
                          ? 'Overdue since ${formatShortDay(latest.dueDate)}'
                          : 'Next due ${formatShortDay(latest.dueDate)}',
                      style: SteadyType.caption.copyWith(
                        color: overdue ? c.dangerFg : c.muted,
                      ),
                    ),
                    Text(
                      amount,
                      style: SteadyType.title.copyWith(fontSize: 24),
                    ),
                  ],
                ),
              ),
              SteadyButton(
                'Mark as paid',
                height: SteadySize.buttonCompact,
                expand: false,
                onPressed: () => _confirmPayment(context, latest),
              ),
            ],
          ),
          if (latest.lastPaidOn != null) ...[
            const SizedBox(height: SteadySpace.s2),
            Text(
              'Last paid ${formatShortDay(latest.lastPaidOn!)}',
              style: SteadyType.caption.copyWith(
                fontWeight: FontWeight.w500,
                color: c.muted,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static Future<void> _confirmPayment(BuildContext context, Bill bill) async {
    final store = StoreScope.of(context);
    final controller = TextEditingController(
      text: centsToField(bill.amountCents),
    );
    final paid = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      builder: (sheet) => Padding(
        padding: EdgeInsets.fromLTRB(
          SteadySpace.s5,
          0,
          SteadySpace.s5,
          MediaQuery.viewInsetsOf(sheet).bottom + SteadySpace.s6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Pay ${bill.name}',
              style: SteadyType.title.copyWith(fontSize: 24),
            ),
            const SizedBox(height: SteadySpace.s2),
            Text(
              bill.isEstimate
                  ? 'Enter the real amount. It becomes the estimate for next time.'
                  : 'Logged as a spend today. The bill moves to its next due date.',
              style: SteadyType.body.copyWith(
                fontSize: 14,
                color: sheet.colors.muted,
              ),
            ),
            const SizedBox(height: SteadySpace.s4),
            SteadyField(
              label: 'Amount paid',
              amount: true,
              controller: controller,
              autofocus: bill.isEstimate,
            ),
            const SizedBox(height: SteadySpace.s4),
            SteadyButton(
              'Mark as paid',
              onPressed: () {
                final cents = parseCents(controller.text);
                if (cents != null && cents > 0) Navigator.of(sheet).pop(cents);
              },
            ),
          ],
        ),
      ),
    ).whenComplete(controller.dispose);
    if (paid == null || !context.mounted) return;
    store.payBill(bill, amountCents: paid);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${bill.name} paid. Next due ${formatShortDay(nextOccurrence(bill.dueDate, bill.recurrence))}.',
        ),
      ),
    );
  }
}
