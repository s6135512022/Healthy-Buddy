import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cal_tracker1/app/landing_page.dart';
import 'package:cal_tracker1/services/auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider<AuthBase>(
      create: (context) => Auth(),
      child: MaterialApp(
        title: 'Calories Tracker',
        theme: ThemeData(
          primarySwatch: Colors.red,
        ),
        home: LandingPage(),
      ),
    );
  }
}
