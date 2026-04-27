import 'package:flutter/material.dart';
import 'package:paytonpieper/app.dart';
import 'package:paytonpieper/core/utils/mapbox_config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initializeMapbox();
  runApp(const Paytonpieper());
}
