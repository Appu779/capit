import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:recape/firebase/firebase_service.dart';
import 'package:recape/screen/navbar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isChecked = false;

  void _navigateToNavbarPage() {
    if (_isChecked) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Navbar()),
      );
    } else {
      // Show an alert or toast indicating that terms and conditions should be accepted.
      // You can use packages like 'fluttertoast' or 'flushbar' for this purpose.
    }
  }

  @override
  Widget build(BuildContext context) {
    Color checkboxColor = _isChecked ? Colors.blue : Colors.grey;
    Color buttonColor = _isChecked ? const Color.fromARGB(255, 163, 214, 255) : const Color.fromARGB(255, 255, 255, 255);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(250.0),
        child: AppBar(
          title: const Text(
            'Welcome to CapIt!',
            style: TextStyle(
              fontSize: 35,
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
                    const TextSpan(text: 'Agree with our'),
                    TextSpan(
                      text: ' Terms and conditions?',
                      style: TextStyle(color: checkboxColor),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          setState(() {
                            _isChecked = !_isChecked; // Toggle checkbox status
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
