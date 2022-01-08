import 'package:flutter/material.dart';
// import 'package:learnster_academy_notes/onBording/select_semester.dart';
import 'package:learnster_academy_notes/onBording/select_university.dart';
import 'package:learnster_academy_notes/subject.dart';
import 'package:shared_preferences/shared_preferences.dart';

onbordOrSubject(context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.getBool("isCompleted")== true) {
    return Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (builder) {
      return const SelectSubject();
    }));
  } else {
    return Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (builder) {
      return const SelectUniversity();
    }));
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    
    super.initState();
    onbordOrSubject(context);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("Loading...")),
    );
  }
}
