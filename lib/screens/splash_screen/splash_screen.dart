import 'package:vimigo_attandace/screens/login_screen/login_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget{

  //Route name for the splash screen
  static String routeName = 'SplashScreen';
  @override
  Widget build(BuildContext context) {

    //timer
    Future.delayed(Duration(seconds: 5), (){
      Navigator.pushNamedAndRemoveUntil(context, LogInScreen.routeName, (route) => false);
    });
    return Scaffold(

        body:



        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child:
          Image.asset('assets/images/Splash_Screen.png' ,
            fit: BoxFit.fill,
          ),
        )
    );
  }
}