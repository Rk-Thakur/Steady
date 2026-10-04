import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/biometrics.dart';
import '../../data/store_scope.dart';
import '../../theme/tokens.dart';
import '../onboarding/onboarding_screens.dart';
import '../widgets/kit.dart';

const _pinLength = 4;

/// Four dots and a 3×4 number pad. Calls [onComplete] when 4 digits are in.
class PinPad extends StatefulWidget {
  const PinPad({super.key, required this.onComplete, this.error});

  /// Return false to shake and clear (wrong PIN).
  final bool Function(String pin) onComplete;
  final String? error;

  @override
  State<PinPad> createState() => _PinPadState();
}

class _PinPadState extends State<PinPad> with SingleTickerProviderStateMixin {
  String _pin = '';
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 360),
  );

  Timer? _clear;

  @override
  void dispose() {
    _clear?.cancel();
    _shake.dispose();
    super.dispose();
  }

  void _tap(String digit) {
    if (_pin.length >= _pinLength) return;
    HapticFeedback.selectionClick();
    setState(() => _pin += digit);
    if (_pin.length == _pinLength) {
      final ok = widget.onComplete(_pin);
      if (!ok) {
        HapticFeedback.heavyImpact();
        _shake.forward(from: 0);
        _clear = Timer(const Duration(milliseconds: 360), () {
          if (mounted) setState(() => _pin = '');
        });
      }
    }
  }

  void _back() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Widget key(
      String label, {
      VoidCallback? onTap,
      Widget? child,
      String? semantics,
    }) => Semantics(
      button: true,
      label: semantics ?? label,
      excludeSemantics: true,
      child: Material(
        color: child == null ? c.surface : Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox.square(
            dimension: 72,
            child: Center(
              child:
                  child ??
                  Text(label, style: SteadyType.title.copyWith(fontSize: 28)),
            ),
          ),
        ),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _shake,
          builder: (context, child) {
            final t = _shake.value;
            final dx = t == 0
                ? 0.0
                : 10 * (1 - t) * (((t * 8).floor().isEven) ? 1 : -1);
            return Transform.translate(offset: Offset(dx, 0), child: child);
          },
          child: Semantics(
            label: '${_pin.length} of $_pinLength digits entered',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < _pinLength; i++) ...[
                  if (i > 0) const SizedBox(width: SteadySpace.s4),
                  AnimatedContainer(
                    duration: SteadyMotion.reduced,
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i < _pin.length
                          ? (widget.error != null ? c.dangerFg : c.primary)
                          : Colors.transparent,
                      border: Border.all(
                        color: widget.error != null
                            ? c.dangerFg
                            : c.inputBorder,
                        width: 2,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        SizedBox(
          height: 40,
          child: Center(
            child: widget.error == null
                ? null
                : Text(
                    widget.error!,
                    style: SteadyType.caption.copyWith(color: c.dangerFg),
                  ),
          ),
        ),
        for (final row in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ]) ...[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < 3; i++) ...[
                if (i > 0) const SizedBox(width: 24),
                key(row[i], onTap: () => _tap(row[i])),
              ],
            ],
          ),
          const SizedBox(height: SteadySpace.s4),
        ],
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox.square(dimension: 72),
            const SizedBox(width: 24),
            key('0', onTap: () => _tap('0')),
            const SizedBox(width: 24),
            key(
              '',
              onTap: _back,
              semantics: 'Delete digit',
              child: Icon(Icons.backspace_outlined, color: c.ink),
            ),
          ],
        ),
      ],
    );
  }
}

/// App lock: enter the PIN to open Steady. Pops with true when unlocked.
class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  String? _error;
  int _attempts = 0;

  /// "Face ID" etc. when biometric unlock is on and available. It's offered
  /// above the PIN pad and only asked for when tapped.
  String? _biometric;
  bool _asking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!StoreScope.read(context).settings.biometricUnlock) return;
      final name = await Biometrics.instance.availableName();
      if (mounted && name != null) setState(() => _biometric = name);
    });
  }

  Future<void> _askBiometric() async {
    if (_asking) return;
    setState(() => _asking = true);
    final ok = await Biometrics.instance.authenticate('Unlock Steady');
    if (!mounted) return;
    setState(() => _asking = false);
    if (ok) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final c = context.colors;
    final biometric = _biometric;
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(SteadySpace.s5),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SteadyLogo(size: 64),
                  const SizedBox(height: SteadySpace.s5),
                  Text('Steady is locked', style: SteadyType.title),
                  const SizedBox(height: SteadySpace.s2),
                  Text(
                    'Enter your PIN to see your numbers.',
                    style: SteadyType.body.copyWith(color: c.muted),
                  ),
                  const SizedBox(height: SteadySpace.s6),
                  // Just above the PIN pad: the quicker way in, on request.
                  if (biometric != null)
                    _BiometricOption(
                      name: biometric,
                      busy: _asking,
                      onTap: _askBiometric,
                    )
                  else
                    const SizedBox(height: 44),
                  const SizedBox(height: SteadySpace.s4),
                  PinPad(
                    error: _error,
                    onComplete: (pin) {
                      if (pin == store.settings.pin) {
                        Navigator.of(context).pop(true);
                        return true;
                      }
                      setState(() {
                        _attempts++;
                        _error = _attempts >= 3
                            ? 'Wrong PIN. Take your time.'
                            : 'Wrong PIN. Try again.';
                      });
                      return false;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Turning App lock on: choose a PIN, then confirm it. Pops with true when set.
class SetPinScreen extends StatefulWidget {
  const SetPinScreen({super.key});

  @override
  State<SetPinScreen> createState() => _SetPinScreenState();
}

class _SetPinScreenState extends State<SetPinScreen> {
  String? _first;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final c = context.colors;
    return SteadyPage(
      title: 'App lock',
      children: [
        Text(
          _first == null ? 'Choose a 4-digit PIN' : 'Enter it again to confirm',
          style: SteadyType.title.copyWith(fontSize: 22),
          textAlign: TextAlign.center,
        ),
        Text(
          'Steady asks for it when you open the app and after a minute in the background. '
          'The PIN never leaves this phone.',
          textAlign: TextAlign.center,
          style: SteadyType.body.copyWith(fontSize: 14, color: c.muted),
        ),
        const SizedBox(height: SteadySpace.s2),
        Center(
          child: PinPad(
            key: ValueKey(_first == null),
            error: _error,
            onComplete: (pin) {
              if (_first == null) {
                setState(() {
                  _first = pin;
                  _error = null;
                });
                return true;
              }
              if (pin == _first) {
                store.updateSettings(
                  store.settings.copyWith(appLockEnabled: true, pin: () => pin),
                );
                Navigator.of(context).pop(true);
                return true;
              }
              setState(() {
                _first = null;
                _error = "PINs didn't match. Start again.";
              });
              return false;
            },
          ),
        ),
      ],
    );
  }
}

/// "You can also unlock with Face ID" (iOS) / "…with your fingerprint"
/// (Android), shown just above the PIN pad.
class _BiometricOption extends StatelessWidget {
  const _BiometricOption({
    required this.name,
    required this.busy,
    required this.onTap,
  });

  final String name;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final face = name.toLowerCase().startsWith('face');
    // Product names stay as they are; "fingerprint" reads as "your fingerprint".
    final what = name[0] == name[0].toUpperCase() ? name : 'your $name';
    return Semantics(
      button: true,
      enabled: !busy,
      child: Material(
        color: c.primarySoft,
        borderRadius: BorderRadius.circular(SteadyRadius.pill),
        child: InkWell(
          borderRadius: BorderRadius.circular(SteadyRadius.pill),
          onTap: busy ? null : onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SteadySpace.s4,
                vertical: 10,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    face ? Icons.face_outlined : Icons.fingerprint_rounded,
                    size: 22,
                    color: c.primary,
                  ),
                  const SizedBox(width: SteadySpace.s2),
                  Flexible(
                    child: Text(
                      'You can also unlock with $what',
                      style: SteadyType.body.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: c.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
