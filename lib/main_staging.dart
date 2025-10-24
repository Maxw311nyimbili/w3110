// lib/main_staging.dart

import 'package:cap_project/app/app.dart';
import 'package:cap_project/app/view/app_config.dart';
import 'package:cap_project/bootstrap.dart';

void main() {
  bootstrap(() {
    // Staging configuration
    final config = AppConfig.staging();

    return App(config: config);
  });
}