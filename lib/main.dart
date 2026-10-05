import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:steady/firebase_options.dart';

import 'app/biometrics.dart';
import 'app/bootstrap.dart';
import 'app/notifications.dart';

export 'app/steady_app.dart' show SteadyApp;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Notifications.instance = LocalNotifications();
  Biometrics.instance = DeviceBiometrics();
  runApp(const SteadyBootstrap());
}
