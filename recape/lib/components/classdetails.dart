import 'package:flutter/material.dart';

class ClassroomTileData {
  final String className;
  final String academicYear;
  final Color tileColor;

  ClassroomTileData({
    required this.className,
    required this.academicYear,
    required this.tileColor,
  });
}

class ClassroomDetailsPage extends StatelessWidget {
  final ClassroomTileData classroomData;

  const ClassroomDetailsPage(this.classroomData, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(classroomData.className),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Class Name: ${classroomData.className}',
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              'Academic Year: ${classroomData.academicYear}',
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}