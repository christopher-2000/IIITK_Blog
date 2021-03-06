import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:iiitk_app/newpost.dart';
import 'package:iiitk_app/home_page.dart';
import 'package:iiitk_app/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:iiitk_app/upload_photo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Montserrat'),
      title: 'IIITK Blog',
      home: LoginHere(),
    );
  }
}
