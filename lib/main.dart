import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

import 'screens/splashscreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  //for binding
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidAlarmManager.initialize();
  //for app to be in fullscreen mode
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  //for initialization of firebase
  _initializeFirebase();
  //running the app
  runApp(const Myapp());
  await AndroidAlarmManager.periodic(
      const Duration(minutes: 1), 0, backgroundtask);
}

void backgroundtask() {
  print("running in background");
}

class Myapp extends StatelessWidget {
  const Myapp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false, home: Splashscreen());
  }
}

// ...
_initializeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}
