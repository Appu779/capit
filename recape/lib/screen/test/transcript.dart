import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TranscriptChat extends StatelessWidget {
  const TranscriptChat({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transcript Chat'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('generate').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final transcripts = snapshot.data!.docs
              .map((doc) => doc['output'])
              .toList()
              .reversed
              .toList();

          return ListView.builder(
            reverse: true,
            itemCount: transcripts.length,
            itemBuilder: (context, index) {
              final transcript = transcripts[index];
              return ListTile(
                title: Text(transcript ?? 'No Output'),
                tileColor: index % 2 == 0
                    ? Colors.grey[200]
                    : Colors.grey[300], // Alternate background color
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Transcript Details'),
                        content: SingleChildScrollView(
                          child: TextField(
                            maxLines: null,
                            readOnly: true,
                            controller: TextEditingController(text: transcript),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Output',
                            ),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Close'),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
