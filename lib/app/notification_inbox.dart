import 'package:flutter/foundation.dart';

import 'notifications.dart';

/// Reminders that arrived and haven't been seen in the app yet: the red dot
/// on Today's bell, and "New" on the Notifications screen.
///
/// The phone is the source of truth: whatever of Steady's is still in its
/// notification list. Tapping one there removes it; opening the
/// Notifications screen clears the rest.
class NotificationInbox extends ValueNotifier<List<DeliveredNotification>> {
  NotificationInbox._() : super(const []);

  static final instance = NotificationInbox._();

  /// Asks the phone again (at launch, on return to the app, and just after
  /// each reminder is due).
  Future<void> refresh() async {
    if (!Notifications.instance.enabled) return;
    try {
      value = await Notifications.instance.delivered();
    } catch (e) {
      debugPrint('Steady: could not read delivered reminders: $e');
    }
  }

  /// Seen in the app: clear the dot and the phone's notification list.
  Future<void> markRead() async {
    final ids = [for (final n in value) n.id];
    value = const [];
    if (ids.isEmpty) return;
    await Notifications.instance.clearDelivered(ids);
  }

  /// Tests: start empty.
  @visibleForTesting
  void reset() => value = const [];
}
