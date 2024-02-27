import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vimigo_attandace/routes.dart';
import 'package:vimigo_attandace/screens/home_screen/homeScreen.dart';
import 'package:vimigo_attandace/screens/login_screen/login_screen.dart';
import 'package:vimigo_attandace/screens/login_screen/signUpScreen.dart';
import 'package:vimigo_attandace/screens/splash_screen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:vimigo_attandace/constants.dart';
import 'dart:io';

import 'model/user.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Platform.isAndroid
      ? await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: 'AIzaSyAWzz4Qu-5JXz7CMVBdUvKz7NSNJwSVdoM',
          appId: '1:993885389300:android:368f709b959f3c691c39a1',
          messagingSenderId: '993885389300',
          projectId: 'attandance-system-9d715'))
      : await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: const KeyboardVisibilityProvider(
        child: AuthCheck(),
      ),
      routes: {
        '/signUpScreen': (context) => SignUpScreen(),
      },
      localizationsDelegates: const[
        MonthYearPickerLocalizations.delegate
      ],
    );
  }
}

class AuthCheck extends StatefulWidget {
  const AuthCheck({Key? key}) : super(key: key);

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  bool userAvailable = false;
  late SharedPreferences sharedPreferences;

  @override
  void initState() {
    super.initState();

    _getCurrentUser();
  }

  void _getCurrentUser() async{
    sharedPreferences = await SharedPreferences.getInstance();

    try{
      if (sharedPreferences.getString('employeeID') != null) {
        setState(() async {
          User.employeeId = sharedPreferences.getString('employeeID')! ;
          userAvailable = true;
        });
      }
    }catch(e){
      setState(() {
        userAvailable = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return userAvailable ?   HomeScreen() :  LogInScreen();
  }
}