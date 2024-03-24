import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:speech_to_text/speech_to_text.dart';


class Speech extends StatefulWidget {
  const Speech({super.key});

  @override
  State<Speech> createState() => _SpeechState();
}

class _SpeechState extends State<Speech> {
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false; // Use _isListening for clarity
  String _wordSpoken = "";
  String _transcribedText = "";

  @override
  void initState() {
    super.initState();
    initSpeech();
  }

  void initSpeech() async {
    _speechToText.initialize().then((value) {
      setState(() {
        _isListening = value;
      });
    });
  }

  void _startListening() async {
    await _speechToText.listen(
      onResult: _onSpeeechResult,
      localeId: 'en-US',
    );
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });
  }

  void _onSpeeechResult(result) {
    setState(() {
      _wordSpoken = "${result.recognizedWords}";
      _transcribedText += _wordSpoken + " ";
    });
  }

  void _saveToFile() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/transcribed_text.txt');

    await file.writeAsString(_transcribedText);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Transcribed text saved to ${file.path}'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("SpeechToText"),
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                _isListening ? "Listening..." : "Tap the Microphone...",
                style: const TextStyle(fontSize: 20.0),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Text(_wordSpoken,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w300,
                    )),
              ),
            ),
            // Example: Add a button at the bottom of your column
            ElevatedButton(
              onPressed: _saveToFile,
              child: const Text('Save Transcription'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isListening ? _stopListening : _startListening,
        tooltip: "Listen",
        child: Icon(
          _isListening ? Icons.mic : Icons.mic_off,
        ),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
