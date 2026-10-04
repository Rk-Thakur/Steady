import 'package:flutter/material.dart';

import 'app/bootstrap.dart';
import 'app/notifications.dart';

export 'app/steady_app.dart' show SteadyApp;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Notifications.instance = LocalNotifications();
  runApp(const SteadyBootstrap());
}
