import 'package:firebase_demo/navigation_bar.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // initializing firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(FirebaseDemo());
}

class FirebaseDemo extends StatefulWidget {
  FirebaseDemo({Key? key}) : super(key: key);

  @override
  State<FirebaseDemo> createState() => _FirebaseDemoState();
}

class _FirebaseDemoState extends State<FirebaseDemo> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Firebase Demo",
      theme: ThemeData(primarySwatch: Colors.teal, brightness: Brightness.dark),
      home: NavigationBarScreen(),
    );
  }
}
