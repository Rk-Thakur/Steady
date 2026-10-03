import 'package:flutter/material.dart';

import '../../core/date_format.dart';
import '../../core/local_date.dart';
import '../../data/store_scope.dart';
import '../../domain/models/models.dart';
import '../../theme/tokens.dart';
import '../widgets/kit.dart';

/// N2 Profile.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late AppSettings _s;
  late final TextEditingController _name;
  late final TextEditingController _rate;
  bool _init = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_init) return;
    _init = true;
    _s = StoreScope.of(context).settings;
    _name = TextEditingController(text: _s.displayName ?? '');
    _rate = TextEditingController(
      text: _s.hourlyRateCents == null ? '' : centsToField(_s.hourlyRateCents!),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _rate.dispose();
    super.dispose();
  }

  Future<void> _pickPayday() async {
    final today = StoreScope.of(context).today;
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(
        _s.nextPayday.year,
        _s.nextPayday.month,
        _s.nextPayday.day,
      ),
      firstDate: DateTime(today.year, today.month, today.day),
      lastDate: DateTime(today.year + 1, today.month, today.day),
    );
    if (picked != null) {
      setState(
        () => _s = _s.copyWith(nextPayday: LocalDate.fromDateTime(picked)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    void save() {
      final name = _name.text.trim();
      final rate = parseCents(_rate.text);
      store.updateSettings(
        _s.copyWith(
          displayName: () => name.isEmpty ? null : name,
          hourlyRateCents: () => rate == null || rate <= 0 ? null : rate,
        ),
      );
      Navigator.of(context).pop();
    }

    return SteadyPage(
      title: 'Profile',
      gap: 18,
      bottom: SteadyButton('Save', onPressed: save),
      children: [
        SteadyField(
          label: 'Name',
          controller: _name,
          hint: 'What should we call you?',
        ),
        SteadyField(
          key: ValueKey(_s.nextPayday),
          label: 'Next payday',
          initialValue: formatShortDay(_s.nextPayday),
          emphasis: true,
          readOnly: true,
          onTap: _pickPayday,
        ),
        ChipGroup<PayFrequency>(
          label: 'Paid',
          options: PayFrequency.values,
          selected: _s.payFrequency,
          labelOf: (f) => f.label,
          onSelected: (f) => setState(() => _s = _s.copyWith(payFrequency: f)),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SteadyField(
              label: 'Hourly pay (optional)',
              controller: _rate,
              emphasis: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              hint: '${_s.currencySymbol}0.00',
            ),
            const SizedBox(height: 6),
            Text(
              'Shows "hours of work" in Can I afford it?. Leave blank to hide it.',
              style: SteadyType.caption.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: context.colors.muted,
              ),
            ),
          ],
        ),
        ChipGroup<int>(
          label: 'Week starts on',
          options: const [DateTime.sunday, DateTime.monday],
          selected: _s.weekStartsOn,
          labelOf: (d) => d == DateTime.sunday ? 'Sun' : 'Mon',
          onSelected: (d) => setState(() => _s = _s.copyWith(weekStartsOn: d)),
        ),
        ChipGroup<Currency>(
          label: 'Currency',
          options: Currency.values,
          selected: _s.currency,
          labelOf: (c) => c.code,
          onSelected: (c) => setState(() => _s = _s.copyWith(currency: c)),
        ),
      ],
    );
  }
}
