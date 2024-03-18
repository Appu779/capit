
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: HomePage(),
//     );
//   }
// }

// class HomePage extends StatelessWidget {
//   final FirebaseStorage storage = FirebaseStorage.instance;
//   final FirebaseFirestore firestore = FirebaseFirestore.instance;
//   final userId = 'exampleUserId'; // Assuming you know userId from the context

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Audio Transcription'),
//       ),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () {
//             handleFileUpload(context);
//           },
//           child: Text('Upload Audio'),
//         ),
//       ),
//     );
//   }

//   void handleFileUpload(BuildContext context) async {
//     // Get the file from the user's device
//     // For simplicity, assume file is obtained through file picker
//     var file; // Obtain file using file picker
//     // Now upload the file to Firebase Storage
//     String fileName = 'exampleAudioId'; // Replace with your logic to get file name
//     Reference audioRef = storage.ref().child('users/$userId/audio/$fileName');
//     await audioRef.putFile(file);

//     // Listen for transcription
//     listenForTranscription(fileName);
//   }

//   void listenForTranscription(String fileName) {
//     CollectionReference transcriptionsRef =
//         firestore.collection('users/$userId/transcriptions');
//     Query query = transcriptionsRef.where('fileName', isEqualTo: fileName);
//     query.snapshots().listen((QuerySnapshot querySnapshot) {
//       if (querySnapshot.docs.isNotEmpty) {
//         querySnapshot.docs.forEach((doc) {
//           var data = doc.data();
//           // Assuming 'transcription' is the field name for the transcription text
//           print('Transcription for $fileName: ${da ta('transcription')}');
//           // You can now use this data in your UI
//         });
//       } else {
//         print('No transcription document found for fileName: $fileName');
//       }
//     }, onError: (error) {
//       print('Error listening to transcription documents: $error');
//     });
//   }
// }
