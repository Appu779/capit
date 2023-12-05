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

  @override
  void initState() {
    super.initState();
    _generateRandomQuote();
    // Schedule periodic quote updates
    Timer.periodic(const Duration(minutes: 2), (Timer timer) {
      _generateRandomQuote();
    });
  }

  void _generateRandomQuote() {
    List<String> quotes = [
      "Where Learning Comes to Life: Your Classroom, Your Adventure.",
      "Unlocking Minds, One Class at a Time.",
      "Embrace the Power of Education in Every Lesson.",
      // Add more quotes as needed
    ];
    setState(() {
      quote = quotes[Random().nextInt(quotes.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(0, 0, 128, 1),
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
          Text(
            quote,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}