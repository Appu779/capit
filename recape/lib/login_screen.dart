import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();

  Widget build(BuildContext context) {
    TextStyle defaultStyle =
        const TextStyle(color: Colors.grey, fontSize: 17.0);
    TextStyle linkStyle = const TextStyle(color: Colors.blue);
    return RichText(
      text: TextSpan(
        style: defaultStyle,
        children: <TextSpan>[
          const TextSpan(text: 'Agree with our'),
          TextSpan(
              text: ' Terms and conditions?',
              style: linkStyle,
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => TermsPage()),
                  // );
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
        preferredSize: const Size.fromHeight(250.0), // here the desired height
        child: AppBar(
          title: const Text(
            'Welcome to CapIt!',
            style: TextStyle(
              fontSize: 35,
              color: Colors.blue,
            ),
          ),
          centerTitle: true,
          toolbarHeight: 300, // Adjust the height as needed
          backgroundColor: const Color(0xfafafa),
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
                  // Replace with your logo widget
                  Container(
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
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const LoginPage().build(context),
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
