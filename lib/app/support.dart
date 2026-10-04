import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Where "Send feedback" goes (Help & feedback). Shown to every user.
/// Set before release; while empty, the button says it isn't set up yet.
const supportEmail = '';

enum FeedbackResult { opened, copied, notSetUp }

/// Opens the user's own email app with a blank message to [supportEmail].
/// Steady sends nothing itself and attaches no app data. Without an email
/// app, the address is copied so it can be pasted anywhere.
Future<FeedbackResult> openFeedbackEmail() async {
  if (supportEmail.isEmpty) return FeedbackResult.notSetUp;
  final uri = Uri(
    scheme: 'mailto',
    path: supportEmail,
    query: 'subject=${Uri.encodeComponent('Steady feedback')}',
  );
  try {
    if (await launchUrl(uri)) return FeedbackResult.opened;
  } catch (_) {
    // No email app: fall through to copying the address.
  }
  await Clipboard.setData(const ClipboardData(text: supportEmail));
  return FeedbackResult.copied;
}
