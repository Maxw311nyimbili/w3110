// lib/main_production.dart

import 'package:cap_project/app/app.dart';
import 'package:cap_project/app/view/app_config.dart';
import 'package:cap_project/bootstrap.dart';

void main() {
  bootstrap(() {
    // Production configuration
    final config = AppConfig.production();

    return App(config: config);
  });
}