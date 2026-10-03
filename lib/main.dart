import 'package:flutter/material.dart';

import 'app/bootstrap.dart';

export 'app/steady_app.dart' show SteadyApp;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SteadyBootstrap());
}
