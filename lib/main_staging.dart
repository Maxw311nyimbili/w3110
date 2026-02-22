import 'package:cap_project/app/view/app.dart';
import 'package:cap_project/app/view/app_config.dart';
import 'package:cap_project/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:landing_repository/landing_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Local Preferences
  final localPreferences = LocalPreferences();
  await localPreferences.initialize();

  runApp(
    App(
      config: AppConfig.staging(),
      localPreferences: localPreferences,
    ),
  );
}
