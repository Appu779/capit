import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class TeacherTile extends StatefulWidget {
  const TeacherTile({Key? key}) : super(key: key);

  @override
  _TeacherTileState createState() => _TeacherTileState();
}

class _TeacherTileState extends State<TeacherTile> {
  String quote = '';
  late Key quoteKey; // Key for AnimatedSwitcher
  late Timer _timer; // Declare timer variable

  @override
  void initState() {
    super.initState();
    quoteKey = UniqueKey(); // Initialize unique key for AnimatedSwitcher
    _initializeQuote();
  }

  // Initialize the quote and start the timer
  void _initializeQuote() {
    _generateRandomQuote();
    // Schedule periodic quote updates
    _timer = Timer.periodic(const Duration(minutes: 1), (Timer timer) {
      _generateRandomQuote();
    });
  }

  // Generate a new random quote
  void _generateRandomQuote() {
    List<String> quotes = [
      "Where Learning Comes to Life: Your Classroom, Your Adventure.",
      "Unlocking Minds, One Class at a Time.",
      "Embrace the Power of Education in Every Lesson.",
      // Add more quotes as needed
    ];
    setState(() {
      quoteKey = UniqueKey(); // Generate a new key for AnimatedSwitcher
      quote = quotes[Random().nextInt(quotes.length)];
    });
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 117, 3, 71),
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 111, 118, 124).withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'WELCOME!!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Text(
              quote,
              key: quoteKey,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

