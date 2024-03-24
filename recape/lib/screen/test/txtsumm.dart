import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:recape/screen/test/transcript.dart';


class TxtFileViewer extends StatefulWidget {
  const TxtFileViewer({Key? key}) : super(key: key);

  @override
  _TxtFileViewerState createState() => _TxtFileViewerState();
}

class _TxtFileViewerState extends State<TxtFileViewer> {
  final List<String> _transcripts = [];
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchTxtFile();
  }

  Future<void> _fetchTxtFile() async {
    final FirebaseStorage storage = FirebaseStorage.instance;
    final Reference ref = storage
        .ref()
        .child('transcriptions')
        .child('electrochemistry.m4a.wav_transcription.txt');
    try {
      final File file =
          File('${(await getTemporaryDirectory()).path}/file.txt');
      await ref.writeToFile(file);

      final String content = await file.readAsString();

      final jsonData = json.decode(content);

      List<dynamic> results = jsonData["results"];
      for (var result in results) {
        if (result.containsKey("alternatives")) {
          List<dynamic> alternatives = result["alternatives"];
          for (var alternative in alternatives) {
            if (alternative.containsKey("transcript")) {
              _transcripts.add(alternative["transcript"]);
            }
          }
        }
      }

      _combineTranscripts();

      setState(() {});
    } catch (e) {
      print('Error: $e');
    }
  }

  void _combineTranscripts() {
    String combinedText = _transcripts.join('\n');
    _textEditingController.text = combinedText;
    _saveToFirestore(combinedText); // Save to Firestore
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transcripts Viewer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: TextField(
                controller: _textEditingController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Enter or edit the transcript here...',
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                _saveEditedTranscript(_textEditingController.text);
              },
              child: const Text('Save Transcript'),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TranscriptChat()),
                );
              },
              child: const Text('View Transcript Chat'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveEditedTranscript(String editedTranscript) async {
    try {
      final File newFile = File('${(await getTemporaryDirectory()).path}/edited_transcript.txt');
      await newFile.writeAsString(editedTranscript);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Transcript saved successfully!'),
      ));
    } catch (e) {
      print('Error saving transcript: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Error saving transcript. Please try again.'),
      ));
    }
  }

  // Function to save transcript to Firestore
  Future<void> _saveToFirestore(String transcript) async {
    try {
      await FirebaseFirestore.instance.collection('generate').add({
        'text': transcript,
      });
      print('Transcript saved to Firestore');
    } catch (e) {
      print('Error saving transcript to Firestore: $e');
    }
  }
}
