import 'dart:async';
import 'dart:io';
import 'package:audio_session/audio_session.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:recape/screen/navbar.dart';
import 'package:firebase_auth/firebase_auth.dart';

const int tSampleRate = 44000;
typedef _Fn = void Function();

class Recorder extends StatefulWidget {
  const Recorder({Key? key}) : super(key: key);

  @override
  State<Recorder> createState() => _RecorderState();
}

class _RecorderState extends State<Recorder> {
  String status = 'none';
  FlutterSoundPlayer? _mPlayer = FlutterSoundPlayer();
  FlutterSoundRecorder? _mRecorder = FlutterSoundRecorder();
  bool _mPlayerIsInited = false;
  bool _mRecorderIsInited = false;
  bool _mplaybackReady = false;
  String? _mPath;
  StreamSubscription? _mRecordingDataSubscription;

  Future<void> openRecorder() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }
    await _mRecorder!.openRecorder();

    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.allowBluetooth |
              AVAudioSessionCategoryOptions.defaultToSpeaker,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteSharingPolicy:
          AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.voiceCommunication,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));

    setState(() {
      _mRecorderIsInited = true;
    });
  }

  @override
  void initState() {
    super.initState();

    _mPlayer!.openPlayer().then((value) {
      setState(() {
        _mPlayerIsInited = true;
      });
    });
    openRecorder();
  }

  @override
  void dispose() {
    stopPlayer();
    _mPlayer!.closePlayer();
    _mPlayer = null;

    stopRecorder();
    _mRecorder!.closeRecorder();
    _mRecorder = null;
    super.dispose();
  }

  Future<IOSink> createFile() async {
    var tempDir = await getTemporaryDirectory();
    _mPath = '${tempDir.path}/flutter_sound_example.pcm';
    var outputFile = File(_mPath!);
    if (outputFile.existsSync()) {
      await outputFile.delete();
    }
    return outputFile.openWrite();
  }

  Future<void> record() async {
    assert(_mRecorderIsInited && _mPlayer!.isStopped);
    var sink = await createFile();
    var recordingDataController = StreamController<Food>();
    _mRecordingDataSubscription =
        recordingDataController.stream.listen((buffer) {
      if (buffer is FoodData) {
        sink.add(buffer.data!);
      }
    });
    await _mRecorder!.startRecorder(
      toStream: recordingDataController.sink,
      codec: Codec.pcm16,
      numChannels: 1,
      sampleRate: tSampleRate,
    );
    setState(() {
      status = 'recording';
    });
  }

  Future<void> startRecorder() async {
    stopPlayer(); // Stop player if it's playing
    await record();
    setState(() {
      status = 'recording';
    });
  }

  Future<void> stopRecorderAndSave() async {
    await stopRecorder();
    setState(() {
      status = 'recorded';
      _mplaybackReady = true;
    });

    // Upload the audio file to Firebase Storage
    await uploadAudioToStorage();
  }

  Future<void> stopRecorder() async {
    await _mRecorder!.stopRecorder();
    if (_mRecordingDataSubscription != null) {
      await _mRecordingDataSubscription!.cancel();
      _mRecordingDataSubscription = null;
    }
    setState(() {
      _mplaybackReady = true;
      status = 'recorded';
    });
  }

  Future<void> uploadAudioToStorage() async {
    try {
      String fileName =
          DateTime.now().millisecondsSinceEpoch.toString() + '.pcm';
      final Reference storageReference =
          FirebaseStorage.instance.ref().child('audio').child(fileName);
      final File audioFile = File(_mPath!);

      // Upload the audio file to Firebase Storage
      await storageReference.putFile(audioFile);

      // Get the current user
      User? user = FirebaseAuth.instance.currentUser;

      // Access the Firestore collection "users"
      CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('users');

      // Access the document corresponding to the current user
      DocumentReference userDocRef = usersCollection.doc(user!.uid);
      String a = storageReference.toString();
      // Update the document with the download URL of the audio file
      await userDocRef.update({'audio link': a});

      print(
          'Audio file uploaded to Firebase Storage and URL stored in Firestore');
    } catch (e) {
      print('Error uploading audio file: $e');
      // Handle error if upload fails
    }
  }

  Future<void> pausePlayer() async {
    await _mPlayer!.pausePlayer();
    setState(() {
      status = 'paused';
    });
  }

  Future<void> startPlayback() async {
    if (_mPlayer!.isPaused) {
      await _mPlayer!.resumePlayer();
    } else {
      await play();
    }
    setState(() {
      status = 'playing';
    });
  }

  Future<void> pausePlayback() async {
    if (_mPlayer!.isPlaying) {
      await _mPlayer!.pausePlayer();
      setState(() {
        status = 'paused';
      });
    }
  }

  Future<void> play() async {
    assert(
      _mPlayerIsInited &&
          _mplaybackReady &&
          _mRecorder!.isStopped &&
          _mPlayer!.isStopped,
      'Player and recorder must be initialized, playback ready, and recorder stopped.',
    );

    await _mPlayer!.startPlayer(
      fromURI: _mPath,
      sampleRate: tSampleRate,
      codec: Codec.pcm16,
      numChannels: 1,
      whenFinished: () {
        stopPlayer(); // Automatically pause when playback is finished
        setState(() {});
      },
    );

    setState(() {
      status = 'playing';
    });
  }

  Future<void> stopPlayer() async {
    await _mPlayer!.stopPlayer();
    setState(() {
      status = 'none';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white10,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              '"In your own voice, record your\n     name and designation."',
              style: TextStyle(
                fontFamily: 'NotoSans_Condensed',
                fontWeight: FontWeight.bold, // Use bold style
                fontSize: 18.0,
              ),
            ),
            const SizedBox(
              height: 100,
            ),
            _buildRecordStopControl(),
            const SizedBox(height: 20),
            state_text(),
            const SizedBox(
              height: 80,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              _rerecord(),
              const SizedBox(width: 150),
              _nextscreen()
            ]),
            const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordStopControl() {
    late Icon icon;
    late Color color;

    if (status == 'recording') {
      icon = const Icon(Icons.stop, color: Colors.red, size: 100);
      color = Colors.red.withOpacity(0.1);
    } else if (status == 'none') {
      final ThemeData theme = Theme.of(context);
      icon = Icon(Icons.mic, color: theme.primaryColor, size: 100);
      color = theme.primaryColor.withOpacity(0.1);
    } else if (status == 'recorded' || status == 'paused') {
      final ThemeData theme = Theme.of(context);
      icon = const Icon(Icons.play_arrow, color: Colors.green, size: 100);
      color = theme.primaryColor.withOpacity(0.1);
    } else if (status == 'cnt' || status == 'playing') {
      final ThemeData theme = Theme.of(context);
      icon = const Icon(Icons.pause, color: Colors.amber, size: 100);
      color = theme.primaryColor.withOpacity(0.1);
    } else {
      // Handle other cases if needed
      icon = const Icon(Icons.mic, size: 100);
      color = Colors.transparent;
    }

    return ClipOval(
      child: Material(
        color: color,
        child: InkWell(
          child: SizedBox(width: 256, height: 256, child: icon),
          onTap: () {
            if (status == 'none') {
              startRecorder();
            } else if (status == 'recording') {
              stopRecorderAndSave();
            } else if (status == 'recorded') {
              startPlayback();
            } else if (status == 'playing') {
              pausePlayback();
            } else if (status == 'paused') {
              startPlayback();
            } else if (status == 'cnt') {
              startPlayback();
            } else if (status == 'none') {
              startRecorder();
            }
          },
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget state_text() {
    switch (status) {
      case 'recording':
        return const Text('Recording...');
      case 'none':
        return const Text('Start recording.');
      case 'playing':
        return const Text('Playing...');
      case 'paused':
        return const Text('Paused');
      case 'recorded':
        return const Text('Successfully recorded.');
      default:
        return const Text('');
    }
  }

  Widget _rerecord() {
    Icon icon;
    Color color;
    final ThemeData theme = Theme.of(context);
    icon = const Icon(Icons.refresh_rounded, color: Colors.amber, size: 50);
    color = theme.primaryColor.withOpacity(0.1);
    return ClipOval(
      child: Material(
        color: color,
        child: InkWell(
          child: SizedBox(width: 80, height: 80, child: icon),
          onTap: () {
            setState(() {
              status = 'none';
              _mplaybackReady = false; // Reset the playback readiness
            });
          },
        ),
      ),
    );
  }

  Widget _nextscreen() {
    Icon icon;
    Color color;
    final ThemeData theme = Theme.of(context);
    icon = Icon(Icons.arrow_right_alt, color: theme.primaryColor, size: 50);
    color = theme.primaryColor.withOpacity(0.1);
    return ClipOval(
      child: Material(
        color: color,
        child: InkWell(
            child: SizedBox(width: 80, height: 80, child: icon),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Navbar()));
            }),
      ),
    );
  }
}

//Future<void> convertPCMtoMP3(String inputPath, String outputPath) async {
  //final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();

  //try {
    //String command = '-i $inputPath -acodec libmp3lame $outputPath';
    //int rc = await _flutterFFmpeg.execute(command);
    //print('FFmpeg process exited with rc $rc');
  //} catch (e) {
    //print('Error executing FFmpeg command: $e');
  //}
//}
