import 'dart:async';
import 'dart:core';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';

class TestRecord extends StatefulWidget {
  final String? reRecordAudioPath;
  final String? defaultRecordingName;

  const TestRecord(
      {super.key, this.reRecordAudioPath, this.defaultRecordingName});

  @override
  State<TestRecord> createState() => _TestRecordState();
}

class _TestRecordState extends State<TestRecord> {
  final _record = Record();
  late String _audioPath = ''; // Initialize _audioPath here
  Timer? _timer;
  int _time = 0;
  bool _isRecording = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.defaultRecordingName);
    if (widget.reRecordAudioPath != null) {
      _startRecording();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _record.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      setState(() {
        _time = _time + 1;
      });
    });
  }

  Future<void> _startRecording() async {
    try {
      Directory? dir;

      if (Platform.isAndroid) {
        dir = Directory('/storage/emulated/0/Download/');
        if (!await dir.exists()) dir = (await getExternalStorageDirectory())!;
      }

      final path = '${dir?.path}/${_controller.text}.m4a';

      if (widget.reRecordAudioPath != null) {
        // If re-recording, delete the existing audio file
        File(widget.reRecordAudioPath!).deleteSync();
      }

      await _record.start(path: path);
      _startTimer();

      setState(() {
        _isRecording = true;
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _stopRecording() async {
    final path = await _record.stop();
    setState(() {
      _audioPath = path!;
      _isRecording = false;
      _timer?.cancel();
      _time = 0;
    });
    await uploadAudioToStorage(path!);
  }

  Future<void> uploadAudioToStorage(String audioPath) async {
    try {
      String fileName = _controller.text + '.m4a';
      final Reference storageReference =
          FirebaseStorage.instance.ref().child(fileName);
      final File audioFile = File(audioPath);

      // Set content type explicitly
      final metadata = SettableMetadata(contentType: 'audio/x-m4a');

      // Upload the audio file to Firebase Storage with metadata
      await storageReference.putFile(audioFile, metadata);

      // Get the current user
      User? user = FirebaseAuth.instance.currentUser;

      // Access the Firestore collection "users"
      CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('users');

      // Access the document corresponding to the current user
      DocumentReference userDocRef = usersCollection.doc(user!.uid);
      String downloadUrl = await storageReference.getDownloadURL();

      // Update the document with the download URL of the audio file
      await userDocRef.update({'Audio link': downloadUrl});

      print(
          'Audio file uploaded to Firebase Storage and URL stored in Firestore');
    } catch (e) {
      print('Error uploading audio file: $e');
      // Handle error if upload fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Recorder'),
      ),
      body: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 520,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: IconButton(
                    onPressed: () {
                      if (_isRecording) {
                        _stopRecording();
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Enter Recording Name'),
                              content: TextField(
                                controller: _controller,
                                decoration: const InputDecoration(
                                    hintText: 'Enter name...'),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    _startRecording();
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Start Recording'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    iconSize: 200,
                    icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                  ),
                ),
                Text(
                  formattedTime(timeInSecond: _time),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 55,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          if (_audioPath.isNotEmpty) // Display audio item if recording exists
            AudioItem(audioPath: _audioPath),
        ],
      ),
    );
  }
}

String formattedTime({required int timeInSecond}) {
  int sec = timeInSecond % 60;
  int min = (timeInSecond / 60).floor();
  String minute = min.toString().padLeft(2, '0');
  String seconds = sec.toString().padLeft(2, '0');
  return '$minute:$seconds';
}

class AudioItem extends StatefulWidget {
  final String audioPath;
  final AudioPlayer _player = AudioPlayer();

  AudioItem({super.key, required this.audioPath}) {
    _player.setAudioSource(AudioSource.uri(Uri.parse(audioPath)));
  }

  @override
  State<AudioItem> createState() => _AudioItemState();
}

class _AudioItemState extends State<AudioItem> {
  late bool _isPlaying;

  @override
  void initState() {
    super.initState();
    _isPlaying = false;
    widget._player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        setState(() {
          _isPlaying = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.audioPath.split('/').last.split('.').first),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () {
              if (_isPlaying) {
                widget._player.pause();
              } else {
                widget._player.play();
              }
              setState(() {
                _isPlaying = !_isPlaying;
              });
            },
            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
          ),
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => TestRecord(
                    reRecordAudioPath: widget.audioPath,
                    defaultRecordingName:
                        widget.audioPath.split('/').last.split('.').first,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.mic),
          ),
        ],
      ),
    );
  }
}
