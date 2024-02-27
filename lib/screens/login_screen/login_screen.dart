import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vimigo_attandace/screens/login_screen/signUpScreen.dart';

import '../home_screen/homeScreen.dart';

class LogInScreen extends StatefulWidget {
  static String routeName = 'LogInScreen';
  const LogInScreen({Key? key}) : super(key: key);

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  TextEditingController idController = TextEditingController();
  TextEditingController passController = TextEditingController();
  double screenHeight = 0;
  double screenWidth = 0;
  Color primary = Color(0xfff5b438);

  late SharedPreferences sharedPreferences;

  // Add these to your state variables
  bool _isLoading = false;
  Color _indicatorColor = Colors.transparent;

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardVisible = KeyboardVisibilityProvider.isKeyboardVisible(
        context);
    screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [

          isKeyboardVisible ? SizedBox(height: screenHeight / 16,) : Container(
            height: screenHeight / 2.7,
            width: screenWidth,
            decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                )),
            child: Center(
              child: Image.network(
                'https://www.vimigoapp.com/wp-content/uploads/2021/10/vimigo_logo_vertical_color.png',
                width: screenWidth / 2,
                height: screenWidth / 2,
                fit: BoxFit.cover,
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) return child;
                  return CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                        : null,
                  );
                },
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              top: screenHeight / 20,
              bottom: screenHeight / 23,
            ),
            child: Text(
              "Login",
              style: TextStyle(
                fontSize: screenWidth / 12,
                fontFamily: "NexaBold",
              ),
            ),
          ),
          Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  fieldTitle("Employee ID"),
                  customField('Enter Your Email', idController, false),
                  fieldTitle("Password"),
                  passwordField('Enter Your Password', passController),
                  GestureDetector(
                    onTap: () async {
                      setState(() {
                        _isLoading = true;
                        _indicatorColor =
                            Colors.orange; // Set to orange while loading
                      });

                      FocusScope.of(context).unfocus();
                      String id = idController.text.trim();
                      String password = passController.text.trim();

                      if (id.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Employee ID is still empty!"),
                            ));
                      } else if (password.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Password is still empty!"),
                            ));
                      } else {
                        QuerySnapshot snap = await FirebaseFirestore.instance
                            .collection("Employee").where(
                            'email', isEqualTo: id).get();

                        try {
                          if (password == snap.docs[0]['password']) {
                            sharedPreferences =
                            await SharedPreferences.getInstance();
                            sharedPreferences.setString('employeeID', id).then((
                                _) {
                              Navigator.pushReplacement(context,
                                  MaterialPageRoute(
                                      builder: (context) => HomeScreen())
                              );
                            });
                            sharedPreferences.setString('userName', snap
                                .docs[0]['name']);
                            sharedPreferences.setString('userID', snap
                                .docs[0]['workerId']);

                            setState(() {
                              _indicatorColor = Colors
                                  .green; // Set to green if login is successful
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Incorrect Password!'),
                                ));

                            setState(() {
                              _indicatorColor =
                                  Colors.red; // Set to red if login fails
                            });
                          }
                        } catch (e) {
                          String error = " ";
                          if (e.toString() ==
                              "RangeError (index): Invalid value: Valid value range is empty: 0") {
                            setState(() {
                              error = "Incorrect Employee ID!";
                            });
                          } else {
                            setState(() {
                              error = "Error Occured";
                            });
                          }
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(error),
                          ));

                          setState(() {
                            _indicatorColor =
                                Colors.red; // Set to red if login fails
                          });
                        }
                      }

                      setState(() {
                        _isLoading = false;
                      });
                    },

                    child: Column(
                      children: [
                        Container(
                          height: 60,
                          width: screenWidth,
                          margin: EdgeInsets.only(top: screenHeight / 40),
                          decoration: BoxDecoration(
                            color: primary,
                            borderRadius: const BorderRadius.all(Radius
                                .circular(30)),
                          ),
                          child: Center(
                            child: Text('LOGIN',
                              style: TextStyle(
                                fontFamily: "NexaBold",
                                fontSize: screenWidth / 26,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SignUpScreen()),
                                );
                              },
                              child: Container(
                                margin: EdgeInsets.only(top: screenHeight / 40),
                                child: Text(
                                  'Not registered? Create an account',
                                  style: TextStyle(
                                    color: primary,
                                    fontSize: screenWidth / 26,
                                    fontFamily: "NexaBold",
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              )
          ),
          // Add this to your widget tree
          if (_isLoading)
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(_indicatorColor),
            ),
        ],
      ),
    );
  }


  // Class Calling
  Widget fieldTitle(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: screenWidth / 26,
          fontFamily: "NexaRegular",
        ),
      ),
    );
  }

  Widget customField(String hint, TextEditingController controller,
      bool obscure,) {
    return Container(
      margin: EdgeInsets.only(bottom: screenHeight / 50),
      width: screenWidth,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: screenWidth / 6,
            child: Icon(
              Icons.person,
              color: primary,
              size: screenWidth / 15,
            ),
          ),
          Expanded(
            child: Padding(padding: EdgeInsets.only(right: screenWidth / 12),
              child: TextFormField(
                controller: controller,
                enableSuggestions: false,
                autocorrect: false,
                decoration: InputDecoration(
                  contentPadding:
                  EdgeInsets.symmetric(vertical: screenHeight / 35),
                  border: InputBorder.none,
                  hintText: hint,
                ),
                maxLines: 1,
                obscureText: obscure,
              ),
            ),
          ),
        ],
      ),
    );
  }


// Password Field
  Widget passwordField(String hint, TextEditingController controller) {
    bool _obscureText = true;
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Container(
            margin: EdgeInsets.only(bottom: screenHeight / 50),
            width: screenWidth,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(12)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: screenWidth / 6,
                  child: Icon(
                    Icons.lock,
                    color: primary,
                    size: screenWidth / 15,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: screenWidth / 12),
                    child: TextFormField(
                      controller: controller,
                      enableSuggestions: false,
                      autocorrect: false,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        contentPadding:
                        EdgeInsets.symmetric(vertical: screenHeight / 35),
                        border: InputBorder.none,
                        hintText: hint,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText ? Icons.visibility_off : Icons
                                .visibility,
                            color: primary,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                      ),
                      maxLines: 1,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
    );
  }
}
