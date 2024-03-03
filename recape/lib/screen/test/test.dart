import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_speech/google_speech.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'dart:io';
import 'dart:async';

class MyHomePage extends StatefulWidget {
  const MyHomePage({required Key key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // ignore: non_constant_identifier_names
  bool is_Transcribing = false;
  String content = '';

  void transcribe() async {
    setState(() {
      is_Transcribing = true;
    });
    final serviceAccount = ServiceAccount.fromString(
        '${(await rootBundle.loadString('assets/androdrop-12345-c0f399677f1e.json'))}');
    final speechToText = SpeechToText.viaServiceAccount(serviceAccount);

    final config = RecognitionConfig(
        encoding: AudioEncoding.LINEAR16,
        model: RecognitionModel.basic,
        enableAutomaticPunctuation: true,
        sampleRateHertz: 16000,
        languageCode: 'en-US');

    final audio = await _getAudioContent('test.wav');
    await speechToText.recognize(config, audio).then((value) {
      setState(() {
        content = value.results.map((e) => e.alternatives.first.transcript).join('\n');
      });
    }).whenComplete(() {
      setState(() {
        is_Transcribing = false;
      });
    });
  }

  Future<List<int>> _getAudioContent(String name) async {
    //final directory = await getApplicationDocumentsDirectory();
    //final path = directory.path + '/$name';
    const path = '/sdcard/Download/temp.wav';
    return File(path).readAsBytesSync().toList();
  }

  @override
  void initState() {
    setPermissions();
    super.initState();
  }

  void setPermissions() async {
    await Permission.manageExternalStorage.request();
    await Permission.storage.request();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 108, 96, 225),
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: const Color.fromARGB(255, 108, 96, 225),
        elevation: 0,
        centerTitle: true,
        title: const Text('Transcribe Your Audio'),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(50),
              topLeft: Radius.circular(50),
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const SizedBox(
                  height: 70,
                ),
                Container(
                  height: 200,
                  width: 300,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(5.0),
                  child: content == ''
                      ? const Text(
                          'Your text will appear here',
                          style: TextStyle(color: Colors.grey),
                        )
                      : Text(
                          content,
                          style: const TextStyle(fontSize: 20),
                        ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  child: is_Transcribing
                      ? const Expanded(
                          child: LoadingIndicator(
                            indicatorType: Indicator.ballPulse,
                            colors: [Colors.red, Colors.green, Colors.blue],
                          ),
                        )
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 10, backgroundColor: const Color.fromARGB(255, 108, 96, 225),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: is_Transcribing ? () {} : transcribe,
                          child: is_Transcribing
                              ? const CircularProgressIndicator()
                              : const Text(
                                  'Transcribe',
                                  style: TextStyle(fontSize: 20),
                                ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}