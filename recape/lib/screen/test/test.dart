// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:speech_to_text/speech_to_text.dart';
// import 'package:speech_to_text_plugin/speech_to_text_plugin.dart';

// class Speech extends StatefulWidget {
//   const Speech({Key key}) : super(key: key);

//   @override
//   _SpeechState createState() => _SpeechState();
// }

// class _SpeechState extends State<Speech> {
//   final SpeechToText _speechToText = SpeechToText();
//   String _transcribedText = "";

//   void _transcribeAudio() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       type: FileType.audio,
//       allowMultiple: false,
//     );

//     if (result != null) {
//       File file = File(result.files.single.path!);
//       List<int> audioBytes = await file.readAsBytes();

//       String transcribedText = await _speechToText.recognize(
//         bytes: audioBytes,
//         samplingRate: 16000,
//         localeId: 'en_US',
//       );

//       setState(() {
//         _transcribedText = transcribedText;
//       });
//     } else {
//       // User canceled the picker
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("SpeechToText"),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: _transcribeAudio,
//               child: Text("Choose Audio File"),
//             ),
//             SizedBox(height: 20),
//             Text(
//               _transcribedText,
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 20),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
