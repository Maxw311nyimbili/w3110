// lib/main_development.dart

import 'package:cap_project/app/app.dart';
import 'package:cap_project/app/view/app_config.dart';

import 'package:cap_project/bootstrap.dart';

void main() {
  bootstrap(() {
    // Development configuration
    final config = AppConfig.development();

    return App(config: config);
  });
}