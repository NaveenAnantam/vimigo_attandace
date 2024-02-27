import 'package:vimigo_attandace/screens/login_screen/login_screen.dart';
import 'package:vimigo_attandace/screens/splash_screen/splash_screen.dart';
import 'package:flutter/cupertino.dart';
//import 'package:vimigo_attandace/screens/home_screen/home_screen.dart';
//import 'screens/home_screen/home_screen.dart';

//Manifest for screens
Map<String, WidgetBuilder> routes = {
  SplashScreen.routeName : (context) => SplashScreen(),
  LogInScreen.routeName : (context) => LogInScreen(),
  //HomeScreen.routeName : (context) => HomeScreen(),
};