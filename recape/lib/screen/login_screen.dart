import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:recape/apItTermsAndConditions.dart';
import 'package:recape/firebase/firebase_service.dart';
import 'package:recape/screen/classroom.dart';
import 'package:recape/screen/record.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isChecked = false;

  void _navigateToNavbarPage() async {
    if (_isChecked) {
      if (FirebaseServices().isUserLoggedIn()) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        bool isFirstLogin = prefs.getBool('isFirstLogin') ?? true;
        if (isFirstLogin) {
          // Navigate to Recorder page if it's the first login
          await prefs.setBool('isFirstLogin', false);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Recorder()),
          );
        } else {
          // Navigate to Navbar if already logged in
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Navbar()),
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: "Please sign in to proceed",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: "Please accept the terms and conditions",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  void _showTermsAndConditions() {
    // Navigate to the terms and conditions page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CapItTermsAndConditions()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Color checkboxColor = _isChecked ? Colors.blue : Colors.grey;
    Color buttonColor = _isChecked
        ? const Color.fromARGB(255, 163, 214, 255)
        : const Color.fromARGB(255, 255, 255, 255);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(250.0),
        child: AppBar(
          title: const Text(
            'Capit',
            style: TextStyle(
              fontFamily: 'NotoSans_Condensed',
              fontSize: 50,
              color: Colors.blue,
            ),
          ),
          centerTitle: true,
          toolbarHeight: 300,
          backgroundColor: const Color(0x00fafafa),
          elevation: 0,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              width: MediaQuery.of(context).size.width * 0.95,
              height: MediaQuery.of(context).size.width * 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.2,
                    child: Image.asset(
                      'assets/images/logocapit.png',
                      height: 300,
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: FloatingActionButton.extended(
                      onPressed: _isChecked
                          ? () async {
                              await FirebaseServices().signInWithGoogle();
                              _navigateToNavbarPage();
                            }
                          : null, // Disable button when terms and conditions are not checked
                      icon: Image.asset(
                        "assets/images/g.png",
                        height: 32,
                        width: 32,
                      ),
                      label: const Text('Sign in with Google'),
                      backgroundColor: buttonColor,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.grey, fontSize: 17.0),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Agree with our Terms and conditions?',
                      style: const TextStyle(color: Colors.black),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          setState(() {
                            _showTermsAndConditions(); // Toggle checkbox status
                          });
                        },
                    ),
                  ],
                ),
              ),
              value: _isChecked,
              onChanged: (bool? value) {
                setState(() {
                  _isChecked = value ?? false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
