import 'package:browser_agevole/utils.dart/nav_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

Color mainColor = const Color(0xFFF8E5D6);
Color darkColor = const Color(0xFFD45C00);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  if (FirebaseAuth.instance.currentUser == null) {
    await FirebaseAuth.instance.signInAnonymously();
  }

  runApp(MyApp());

  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

  OneSignal.initialize("21d960a1-718e-4c33-94b6-2b12d599cd26");

  OneSignal.Notifications.requestPermission(true);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Website Zone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFF8E5D6),
      ),
      home: const NavBar(initialIndex: 0),
    );
  }
}
