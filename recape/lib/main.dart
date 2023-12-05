import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:recape/firebase/firebase_options.dart';
import 'package:recape/screen/audio.dart';
import 'package:recape/screen/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false, home: VideoSplashScreen());
  }
}
