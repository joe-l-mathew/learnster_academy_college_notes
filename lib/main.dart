import 'package:flutter/material.dart';
import 'package:learnster_academy_notes/onBording/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';

// import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      // options: DefaultFirebaseOptions.currentPlatform,
      );
  runApp(const MyMaterial());
}

class MyMaterial extends StatelessWidget {
  const MyMaterial({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      home: const SplashScreen(),
    );
  }
}
