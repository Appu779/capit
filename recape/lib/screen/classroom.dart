import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:recape/components/classdetails.dart';
import 'package:recape/components/classroomtile.dart';
import 'package:recape/components/teachertile.dart';
import 'package:recape/screen/audio.dart';

class Navbar extends StatefulWidget {
  const Navbar({Key? key}) : super(key: key);

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  List<ClassroomTileData> classrooms = [];
  bool _isLoading = false; // Track whether data is currently being loaded

  final TextEditingController _classNameController = TextEditingController();
  final TextEditingController _academicYearController = TextEditingController();

  // Override the initState method
  @override
  void initState() {
    super.initState();
    // Call your initialization function
    _initializeData();
  }

  // Initialize your data here
  void _initializeData() async {
    // Fetch initial data
    await _fetchInitialData();
  }

  // Fetch initial data from Firebase
  Future<void> _fetchInitialData() async {
    setState(() {
      _isLoading = true; // Set loading state to true
    });
    List<ClassroomTileData> initialData = await getClassNamesAndAcademicYears();
    setState(() {
      classrooms = initialData;
      _isLoading = false; // Set loading state to false once data is loaded
    });
  }

  // Handler for pull-to-refresh
  Future<void> _refreshData() async {
    await _fetchInitialData();
  }

  void _deleteClassroom(int index) async {
    ClassroomTileData classroomToDelete = classrooms[index];

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Get a reference to the user document
        DocumentReference userRef =
            FirebaseFirestore.instance.collection('users').doc(user.uid);

        // Get a reference to the classes collection
        CollectionReference classesCollectionRef =
            userRef.collection('classes');

        // Query for the document to delete
        QuerySnapshot querySnapshot = await classesCollectionRef
            .where('Class Name', isEqualTo: classroomToDelete.className)
            .where('Academic Year', isEqualTo: classroomToDelete.academicYear)
            .get();

        // Loop through each document and delete it
        querySnapshot.docs.forEach((doc) {
          doc.reference.delete();
        });

        // Remove the deleted classroom from the local list
        setState(() {
          classrooms.removeAt(index);
        });

        print('Classroom deleted successfully.');
      } else {
        print('User is not logged in.');
      }
    } catch (e) {
      print('Error deleting classroom: $e');
    }
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
              onPressed: () async {
                String className = _classNameController.text;
                String academicYear = _academicYearController.text;
                addCollectionToUser(className, academicYear);
                classrooms.clear();
                // Wait for the future to resolve using await
                List<ClassroomTileData> newClassroom =
                    await getClassNamesAndAcademicYears();
                setState(() {
                  // Assign the resolved list to classrooms
                  classrooms = newClassroom;
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
          child: RefreshIndicator(
            onRefresh: _refreshData, // Set the refresh handler
            child: _isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator(), // Show loading indicator while data is being fetched
                  )
                : ListView(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: TeacherTile(),
                      ),
                      GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
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
                                _deleteClassroom(index); // Call delete method
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

void addCollectionToUser(String className, String academicYear) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Get a reference to the user document
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      // Add a new collection (e.g., 'posts') inside the user document
      CollectionReference postsCollectionRef = userRef.collection('classes');

      // Add a document to the 'posts' collection
      await postsCollectionRef.add({
        'Class Name': className,
        'Academic Year': academicYear,
        // Add any other fields as needed
      });
    }
    if (kDebugMode) {
      print('Collection added successfully to user document.');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error adding collection to user document: $e');
    }
  }
}

Future<List<ClassroomTileData>> getClassNamesAndAcademicYears() async {
  List<ClassroomTileData> refresh = [];
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Get a reference to the user document
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      // Get a reference to the classes collection
      CollectionReference classesCollectionRef = userRef.collection('classes');

      // Get all documents within the classes collection
      QuerySnapshot querySnapshot = await classesCollectionRef.get();

      // Loop through each document and extract 'Class Name' and 'Academic Year'
      querySnapshot.docs.forEach(
        (doc) {
          // Get the data of the document
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          Color randomColor = Colors.blue;
          ClassroomTileData newClassroom = ClassroomTileData(
            className: data['Class Name'],
            academicYear: data['Academic Year'],
            tileColor: randomColor,
          );
          refresh.add(newClassroom);
        },
      );

      print('Class names and academic years retrieved successfully.');
    } else {
      print('User is not logged in.');
    }
  } catch (e) {
    print('Error retrieving class names and academic years: $e');
  }
  return refresh;
}
