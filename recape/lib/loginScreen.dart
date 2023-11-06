import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:recape/terms.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();

  Widget build(BuildContext context) {
    TextStyle defaultStyle = TextStyle(color: Colors.grey, fontSize: 17.0);
    TextStyle linkStyle = TextStyle(color: Colors.blue);
    return RichText(
      text: TextSpan(
        style: defaultStyle,
        children: <TextSpan>[
          TextSpan(text: 'Agree with our'),
          TextSpan(
              text: ' Terms and conditions',
              style: linkStyle,
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TermsPage()),
                  );
                }),
        ],
      ),
    );
  }
}

class _LoginPageState extends State<LoginPage> {
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(250.0), // here the desired height
        child: AppBar(
          title: Text(
            'Welcome to CapIt!',
            style: TextStyle(
              fontSize: 35,
              color: Colors.blue,
            ),
          ),
          centerTitle: true,
          toolbarHeight: 300, // Adjust the height as needed
          backgroundColor: Color(0xfafafa),
          elevation: 0,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              width: MediaQuery.of(context).size.width * 0.95,
              height: MediaQuery.of(context).size.width * 1,
              /* decoration: BoxDecoration(
                // Background color
                borderRadius: BorderRadius.circular(8), // Rounded edges

                boxShadow: [
                  BoxShadow(color: Colors.blue, blurRadius: 1, spreadRadius: 0),
                  BoxShadow(
                      color: Colors.white, blurRadius: 100, spreadRadius: 0),
                ],
              ),*/
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Replace with your logo widget
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.2,
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 300,
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: FloatingActionButton.extended(
                      onPressed: () async {
                        Null;
                      },
                      icon: Image.asset(
                        "assets/images/g.png",
                        height: 32,
                        width: 32,
                      ),
                      label: const Text('Sign in with Google'),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            CheckboxListTile(
              title: LoginPage().build(context),
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
