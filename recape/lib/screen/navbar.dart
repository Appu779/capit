import 'package:flutter/material.dart';
import 'package:recape/components/classdetails.dart';
import 'package:recape/components/classroomtile.dart';
import 'package:recape/components/teachertile.dart';
import 'dart:math';
import 'package:recape/screen/audio.dart';

class Navbar extends StatefulWidget {
  const Navbar({Key? key}) : super(key: key);

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  List<ClassroomTileData> classrooms = [];

  final TextEditingController _classNameController = TextEditingController();
  final TextEditingController _academicYearController = TextEditingController();

  Color _getRandomColor() {
    List<Color> colors = [
      const Color.fromRGBO(0, 0, 128, 1),
    ];

    return colors[Random().nextInt(colors.length)];
  }

  void _showClassroomFormDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Classroom'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _classNameController,
                decoration: const InputDecoration(labelText: 'Class Name'),
              ),
              TextField(
                controller: _academicYearController,
                decoration: const InputDecoration(labelText: 'Academic Year'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String className = _classNameController.text;
                String academicYear = _academicYearController.text;
                Color randomColor = _getRandomColor();

                ClassroomTileData newClassroom = ClassroomTileData(
                  className: className,
                  academicYear: academicYear,
                  tileColor: randomColor,
                );

                setState(() {
                  classrooms.add(newClassroom);
                });

                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _deleteClassroom(int index) {
    setState(() {
      classrooms.removeAt(index);
    });
  }

  void _onClassroomSelected(ClassroomTileData selectedClassroom) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Audiopage(selectedClassroom),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0), // Disable the AppBar
        child: Container(), // Empty container to hide AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.only(
            bottom: 8.0), // Adjust the bottom padding as needed
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/geometria_background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: ListView(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: TeacherTile(),
              ),
              GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                ),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: classrooms.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClassroomTile(
                      data: classrooms[index],
                      onDelete: () {
                        _deleteClassroom(index);
                      },
                      onSelect: () {
                        _onClassroomSelected(classrooms[index]);
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showClassroomFormDialog(context);
        },
        child: const Icon(Icons.add),
        backgroundColor: const Color.fromARGB(221, 249, 249, 249),
        foregroundColor: const Color.fromARGB(255, 2, 2, 2),
      ),
    );
  }
}