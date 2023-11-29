import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        child: Scaffold(
          body: Navbar(),
        ),
      ),
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          color: Colors.white,
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

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
      Color.fromRGBO(0, 0, 128, 1),
    ];

    return colors[Random().nextInt(colors.length)];
  }

  void _showClassroomFormDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Classroom'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _classNameController,
                decoration: InputDecoration(labelText: 'Class Name'),
              ),
              TextField(
                controller: _academicYearController,
                decoration: InputDecoration(labelText: 'Academic Year'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
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
              child: Text('Add'),
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
    // TODO: Navigate to a new page with the selected classroom information
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ClassroomDetailsPage(selectedClassroom),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate:
                    CustomSearchDelegate(classrooms, _onClassroomSelected),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showClassroomFormDialog(context);
        },
        child: Icon(Icons.add),
        backgroundColor: const Color.fromARGB(221, 252, 249, 249),
        foregroundColor: Color.fromARGB(255, 14, 19, 75),
      ),
      body: Padding(
        padding: const EdgeInsets.only(
            bottom: 8.0), // Adjust the bottom padding as needed
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/geometria_background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TeacherTile(),
              ),
              GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                ),
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
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
    );
  }
}

class TeacherTile extends StatefulWidget {
  const TeacherTile({Key? key}) : super(key: key);

  @override
  _TeacherTileState createState() => _TeacherTileState();
}

class _TeacherTileState extends State<TeacherTile> {
  String quote = '';

  @override
  void initState() {
    super.initState();
    _generateRandomQuote();
    // Schedule periodic quote updates
    Timer.periodic(Duration(minutes: 2), (Timer timer) {
      _generateRandomQuote();
    });
  }

  void _generateRandomQuote() {
    List<String> quotes = [
      "Where Learning Comes to Life: Your Classroom, Your Adventure.",
      "Unlocking Minds, One Class at a Time.",
      "Embrace the Power of Education in Every Lesson.",
      // Add more quotes as needed
    ];
    setState(() {
      quote = quotes[Random().nextInt(quotes.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(0, 0, 128, 1),
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 111, 118, 124).withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'WELCOME!!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Text(
            quote,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class ClassroomTile extends StatelessWidget {
  final ClassroomTileData data;
  final VoidCallback onDelete;
  final VoidCallback onSelect;

  ClassroomTile({
    Key? key,
    required this.data,
    required this.onDelete,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelect,
      child: Container(
        decoration: BoxDecoration(
          color: data.tileColor,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (BuildContext context) {
                  return ['delete'].map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text('Delete'),
                    );
                  }).toList();
                },
                icon: Icon(
                  Icons.more_vert,
                  color: Colors.white,
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data.className,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Academic Year: ${data.academicYear}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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

  const ClassroomDetailsPage(this.classroomData);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(classroomData.className),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
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
              style: TextStyle(fontSize: 20),
            ),
            Text(
              'Academic Year: ${classroomData.academicYear}',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomSearchDelegate extends SearchDelegate {
  final List<ClassroomTileData> classrooms;
  final Function(ClassroomTileData) onSelect;

  CustomSearchDelegate(this.classrooms, this.onSelect);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final List<ClassroomTileData> searchResults = classrooms
        .where((classroom) =>
            classroom.className.toLowerCase().contains(query.toLowerCase()) ||
            classroom.academicYear.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(searchResults[index].className),
          subtitle: Text('Academic Year: ${searchResults[index].academicYear}'),
          onTap: () {
            onSelect(searchResults[index]);
            close(context, null);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<ClassroomTileData> suggestionList = classrooms
        .where((classroom) =>
            classroom.className.toLowerCase().contains(query.toLowerCase()) ||
            classroom.academicYear.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestionList[index].className),
          subtitle:
              Text('Academic Year: ${suggestionList[index].academicYear}'),
          onTap: () {
            onSelect(suggestionList[index]);
            close(context, null);
          },
        );
      },
    );
  }
}
