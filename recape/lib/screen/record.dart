import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_sound_record/flutter_sound_record.dart';

class AudioSampler extends StatefulWidget {
  const AudioSampler({super.key});

  @override
  _AudioSamplerState createState() => _AudioSamplerState();
}

class _AudioSamplerState extends State<AudioSampler> {
  String status = 'none';
  final FlutterSoundRecord _audioRecorder = FlutterSoundRecord();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
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
            Text(
              '\"In your own voice, record your\n     name and designation.\"',
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
            SizedBox(
              height: 80,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              _rerecord(),
              SizedBox(width: 150),
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
      icon = Icon(Icons.pause, color: Colors.amber, size: 100);
      color = theme.primaryColor.withOpacity(0.1);
    }

    return ClipOval(
      child: Material(
        color: color,
        child: InkWell(
          child: SizedBox(width: 256, height: 256, child: icon),
          onTap: () {
            if (status == 'none') {
              _startRecording();
            } else if (status == 'recording')
              // ignore: curly_braces_in_flow_control_structures
              _stopRecording();
            else if (status == 'recorded')
              // ignore: curly_braces_in_flow_control_structures
              _startplay();
            else if (status == 'playing')
              _pauseplay();
            else if (status == 'paused')
              _continueplay();
            else if (status == 'cnt')
              _pauseplay();
            else if (status == 'none') _startRecording();
          },
        ),
      ),
    );
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        await _audioRecorder.start();
        setState(() {
          status = 'recording';
        });
      }
    } catch (e) {
      print('Error starting recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    await _audioRecorder.stop();
    setState(() {
      status = 'recorded';
    });
  }

  Future<void> _startplay() async {
    setState(() {
      status = 'playing';
    });
  }

  Future<void> _pauseplay() async {
    setState(() {
      status = 'paused';
    });
  }

  Future<void> _continueplay() async {
    setState(() {
      status = 'cnt';
    });
  }

  Widget state_text() {
    if (status == 'recording')
      return Text('recording..........');
    else if (status == 'none')
      return Text('Start recording.');
    else if (status == 'playing' || status == 'cnt')
      return Text('Playing record..........');
    else if (status == 'paused')
      return Text('Paused');
    else if (status == 'recorded')
      return Text('Successfully recorded.');
    else
      return Text('');
  }

  Widget _rerecord() {
    Icon icon;
    Color color;
    final ThemeData theme = Theme.of(context);
    icon = Icon(Icons.refresh_rounded, color: Colors.amber, size: 50);
    color = theme.primaryColor.withOpacity(0.1);
    return ClipOval(
      child: Material(
        color: color,
        child: InkWell(
            child: SizedBox(width: 80, height: 80, child: icon),
            onTap: () {
              setState(() {
                status = 'none';
              });
            }),
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
                  MaterialPageRoute(builder: (context) => AudioSampler()));
            }),
      ),
    );
  }
}
