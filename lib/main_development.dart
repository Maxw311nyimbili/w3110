import 'package:cap_project/app/view/app.dart';
import 'package:cap_project/app/view/app_config.dart';
import 'package:cap_project/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    App(
      config: AppConfig.development(),
    ),
  );
}