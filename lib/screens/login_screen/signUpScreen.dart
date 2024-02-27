import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController workerIdController = TextEditingController(); // Add this
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Builder(builder: (BuildContext context) {
        bool isKeyboardVisible = false;
        try {
          isKeyboardVisible = KeyboardVisibilityProvider.isKeyboardVisible(context);
        } catch (_) {
          // Handle exception here
        }
        double screenHeight = MediaQuery.of(context).size.height;
        double screenWidth = MediaQuery.of(context).size.width;
        Color primary = Color(0xfff5b438);

        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: isKeyboardVisible ? screenHeight / 3 : 0,
            ),
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    isKeyboardVisible ? SizedBox(height: screenHeight / 16,) : Container(
                      height: screenHeight / 2.8,
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
                          color: Colors.white,
                          width: screenWidth / 2,
                          height: screenWidth / 2,
                          fit: BoxFit.cover,
                          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) return child;
                            return CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                            );
                          },
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        top: screenHeight / 15,
                        bottom: screenHeight / 20,
                      ),
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                          fontSize: screenWidth / 15,
                          fontFamily: "NexaBold",
                        ),
                      ),
                    ),
                    customField('Enter Your Name', nameController, false, Icons.person), // Update this
                    customField('Enter Your Email', emailController, false, Icons.email), // Update this
                    customField('Enter Your Phone Number', phoneController, false, Icons.phone), // Update this
                    customField('Enter Your Worker ID', workerIdController, false, Icons.badge), // Add this
                    customField('Enter Your Password', passwordController, _obscurePassword, Icons.lock), // Update this
                    customField('Confirm Your Password', confirmPasswordController, _obscureConfirmPassword, Icons.lock), // Update this
                    ElevatedButton(
                      child: Text('Sign Up'),
                      onPressed: isKeyboardVisible ? null : () async {
                        if (_formKey.currentState!.validate()) {
                          // Insert data into Firestore
                          DocumentReference docRef = FirebaseFirestore.instance.collection('Employee').doc();

                          await docRef.set({
                            'name': nameController.text,
                            'email': emailController.text,
                            'phone': phoneController.text,
                            'workerId': workerIdController.text,
                            'password': passwordController.text,
                          });

                          DocumentSnapshot snapshot = await docRef.get();
                          Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
                          print('Saved data: $data');
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget customField(String hint, TextEditingController controller, bool obscure, IconData icon,) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    Color primary = Color(0xfff5b438);

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
                icon, // Use the icon passed as a parameter
                color: primary,
                size: screenWidth / 15,
              ),
            ),
            Expanded(
              child: Padding( padding: EdgeInsets.only(right: screenWidth/ 12),
                child: TextFormField(
                  controller: controller,
                  enableSuggestions: false,
                  autocorrect: false,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    if (obscure) {
                      if (value != passwordController.text) {
                        return 'Passwords do not match';
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      Pattern pattern =
                          r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$';
                      RegExp regex = new RegExp(pattern.toString());
                      if (!regex.hasMatch(value))
                        return 'Enter valid password';
                    }
                    if (hint == 'Enter Your Email') {
                      Pattern pattern =
                          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                      RegExp regex = new RegExp(pattern.toString());
                      if (!regex.hasMatch(value))
                        return 'Enter Valid Email';
                      else
                        return null;
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    contentPadding:
                    EdgeInsets.symmetric(vertical: screenHeight / 35),
                    border: InputBorder.none,
                    hintText: hint,
                    suffixIcon: obscure ? IconButton(
                      icon: Icon(
                        obscure ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          if (hint == 'Enter Your Password') {
                            _obscurePassword = !_obscurePassword;
                          } else if (hint == 'Confirm Your Password') {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          }
                        });
                      },
                    ) : null,
                  ),
                  maxLines: 1,
                  obscureText: obscure,
                ),
              ),
            ),
          ],
        )
    );
  }
}
