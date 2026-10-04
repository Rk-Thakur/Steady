import 'package:flutter/material.dart';

import 'app/biometrics.dart';
import 'app/bootstrap.dart';
import 'app/notifications.dart';

export 'app/steady_app.dart' show SteadyApp;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Notifications.instance = LocalNotifications();
  Biometrics.instance = DeviceBiometrics();
  runApp(const SteadyBootstrap());
}
