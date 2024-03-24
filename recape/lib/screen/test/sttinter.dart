import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert'; // Add this import for JSON decoding

class TxtFileViewer extends StatefulWidget {
  const TxtFileViewer({super.key});

  @override
  _TxtFileViewerState createState() => _TxtFileViewerState();
}

class _TxtFileViewerState extends State<TxtFileViewer> {
  final List<String> _transcripts = []; // List to store transcript values
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchTxtFile();
  }

  Future<void> _fetchTxtFile() async {
    // Retrieve the file from Firebase Storage
    final FirebaseStorage storage = FirebaseStorage.instance;
    final Reference ref = storage
        .ref()
        .child('transcriptions')
        .child('electrochemistry.m4a.wav_transcription.txt');
    try {
      final File file =
          File('${(await getTemporaryDirectory()).path}/file.txt');
      await ref.writeToFile(file);

      // Read the content of the file
      final String content = await file.readAsString();

      // Decode JSON data
      final jsonData = json.decode(content);

      // Extract transcript values
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

      _combineTranscripts(); // Combine transcripts into a single string

      setState(() {}); // Trigger a rebuild to update UI
    } catch (e) {
      print('Error: $e');
    }
  }

  // Function to combine transcripts into a single string
  void _combineTranscripts() {
    String combinedText = _transcripts.join('\n'); // Combine transcripts with newlines
    _textEditingController.text = combinedText; // Set the combined text in the controller
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
                decoration: InputDecoration(
                  hintText: 'Enter or edit the transcript here...',
                ),
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                // Save the edited transcript to a new file
                _saveEditedTranscript(_textEditingController.text);
              },
              child: Text('Save Transcript'),
            ),
          ],
        ),
      ),
    );
  }

  // Function to save the edited transcript to a new file
  Future<void> _saveEditedTranscript(String editedTranscript) async {
    try {
      final File newFile = File('${(await getTemporaryDirectory()).path}/edited_transcript.txt');
      await newFile.writeAsString(editedTranscript);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Transcript saved successfully!'),
      ));
    } catch (e) {
      print('Error saving transcript: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error saving transcript. Please try again.'),
      ));
    }
  }
}
