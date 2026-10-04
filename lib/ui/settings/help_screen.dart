import 'package:flutter/material.dart';

import '../../app/support.dart';
import '../../theme/tokens.dart';
import '../widgets/kit.dart';

/// N3 Help & feedback.
class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

const _faq = [
  (
    'Does Steady use the internet?',
    'No. Steady has no account, no cloud and no tracking. Everything you enter stays on this phone.',
  ),
  (
    'How is my daily number calculated?',
    'Money you have now, minus bills due before payday and goal set-asides, divided by the days left. '
        'What you spend today comes off that.',
  ),
  (
    'What if I forget to log for a few days?',
    'Your number becomes an estimate until you catch up. Tap Add or Nothing for each missed day.',
  ),
  (
    'How do I move to a new phone?',
    'Create a backup file in Settings, move it to the new phone, then choose Restore from backup file.',
  ),
];

class _HelpScreenState extends State<HelpScreen> {
  int _open = 0;
  String? _toast;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SteadyPage(
      title: 'Help & feedback',
      bottom: Text(
        'Steady 1.0 · Works fully offline',
        textAlign: TextAlign.center,
        style: SteadyType.caption.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: c.muted,
        ),
      ),
      children: [
        GroupedList(
          children: [
            for (var i = 0; i < _faq.length; i++)
              Semantics(
                expanded: _open == i,
                child: InkWell(
                  onTap: () => setState(() => _open = _open == i ? -1 : i),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: SteadySpace.s2,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 40),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _faq[i].$1,
                                  style: SteadyType.body.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Text(
                                _open == i ? '−' : '+',
                                style: SteadyType.heading.copyWith(
                                  fontSize: 22,
                                  color: c.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AnimatedSize(
                          duration: SteadyMotion.reduced,
                          child: _open == i
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: SteadySpace.s2,
                                  ),
                                  child: Text(
                                    _faq[i].$2,
                                    style: SteadyType.body.copyWith(
                                      fontSize: 14,
                                      height: 1.5,
                                      color: c.mutedStrong,
                                    ),
                                  ),
                                )
                              : const SizedBox(width: double.infinity),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Send feedback',
                style: SteadyType.heading.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Text(
                'Opens your own email app with a blank message to us. Steady itself never sends anything, and no app data is attached.',
                style: SteadyType.caption.copyWith(
                  fontWeight: FontWeight.w500,
                  color: c.muted,
                ),
              ),
              const SizedBox(height: 10),
              SteadyButton(
                'Open email app',
                height: 48,
                onPressed: () async {
                  final result = await openFeedbackEmail();
                  if (!mounted) return;
                  setState(
                    () => _toast = switch (result) {
                      FeedbackResult.opened => null,
                      FeedbackResult.copied =>
                        'No email app found. Our address is copied: $supportEmail',
                      FeedbackResult.notSetUp =>
                        "Feedback email isn't set up yet.",
                    },
                  );
                },
              ),
            ],
          ),
        ),
        StatusToast(message: _toast, icon: Icons.mail_outline_rounded),
      ],
    );
  }
}
