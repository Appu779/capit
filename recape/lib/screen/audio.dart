import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recape/components/classdetails.dart';
import 'package:recape/screen/clsrecord.dart';
import 'package:recape/screen/event.dart';
import 'package:recape/screen/crecord.dart';
import 'package:table_calendar/table_calendar.dart';

class Audiopage extends StatefulWidget {
  final ClassroomTileData
      selectedClassroom; // Define selectedClassroom as a property

  const Audiopage(this.selectedClassroom, {Key? key}) : super(key: key);

  @override
  State<Audiopage> createState() => _AudiopageState();
}

class _AudiopageState extends State<Audiopage> {
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime? _selectedDay;
  Map<DateTime, List<Event>> events = {};
  final TextEditingController _eventController = TextEditingController();
  late ValueNotifier<List<Event>> _selectedEvents;
  String _selectedClassName = '';

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    _fetchEventsData(widget.selectedClassroom.className);
    _onClassSelected(widget.selectedClassroom.className);
  }

  void _fetchEventsData(String className) async {
    try {
      List<Event> eventsForDay = await getEvents(className, _selectedDay!);

      setState(() {
        if (eventsForDay.isNotEmpty) {
          events[_selectedDay!] = [eventsForDay.first];
        } else {
          events.remove(_selectedDay);
        }
        _selectedEvents.value = eventsForDay;
      });
    } catch (e) {
      print('Error fetching events data: $e');
    }
  }

  void _onClassSelected(String className) {
    setState(() {
      _selectedClassName = className; // Update the selected class name
    });
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _focusedDay = focusedDay;
        _selectedDay = selectedDay;
        _fetchEventsData(widget.selectedClassroom.className);
      });
    }
  }

  void _showEventOptionsDialog(Event selectedEvent) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Event Options"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text("Edit"),
                onTap: () {
                  // Handle edit action
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text("Delete"),
                onTap: () {
                  // Handle delete action
                  setState(() {
                    // Remove the selected event from the events map
                    events[_selectedDay]!.remove(selectedEvent);

                    // Update the UI
                    _selectedEvents.value = _getEventsForDay(_selectedDay!);
                  });

                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  List<Event> _getEventsForDay(DateTime day) {
    // Check if events exist for the day, if so, return a list with that day
    if (events.containsKey(day)) {
      return events[day]!;
    }

    return [];
  }

  Future<void> _handleRefresh() async {
    try {
      _fetchEventsData(widget.selectedClassroom.className);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data refreshed'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to refresh data: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(_selectedClassName.isNotEmpty ? _selectedClassName : "Audio"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              _eventController.clear();
              return AlertDialog(
                scrollable: true,
                title: const Text("Class Taken"),
                content: Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextField(
                    controller: _eventController,
                  ),
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      // Get the class name from selectedClassroom
                      String className = widget.selectedClassroom.className;

                      // Create a new event with the text from the TextField
                      Event newEvent =
                          Event(_eventController.text, dateTime: null);

                      // Call addCollectionToClasses with className parameter
                      addSessionToClass(
                        className,
                        _eventController.text,
                        _selectedDay,
                      );

                      // If events already exist for the selected day, append the new event
                      if (events.containsKey(_selectedDay)) {
                        events[_selectedDay]!.add(newEvent);
                      } else {
                        // If no events exist for the selected day, create a new list with the new event
                        events[_selectedDay!] = [newEvent];
                      }

                      // Close the dialog and update the UI
                      Navigator.of(context).pop();
                      _selectedEvents.value = _getEventsForDay(_selectedDay!);
                    },
                    child: const Text("Submit"),
                  )
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: Column(
          children: [
            TableCalendar(
              locale: "en_US",
              rowHeight: 43,
              headerStyle: const HeaderStyle(
                  formatButtonVisible: false, titleCentered: true),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(day, _focusedDay),
              firstDay: DateTime.utc(2023, 1, 1),
              lastDay: DateTime.utc(2050, 12, 31),
              onDaySelected: _onDaySelected,
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarStyle: const CalendarStyle(outsideDaysVisible: false),
              eventLoader: _getEventsForDay,
              onFormatChanged: (format) => {
                if (_calendarFormat != format)
                  {
                    setState(() {
                      _calendarFormat = format;
                    })
                  }
              },
              onPageChanged: (focusedDay) => {_focusedDay = focusedDay},
            ),
            const SizedBox(
              height: 8.0,
            ),
            Expanded(
              child: ValueListenableBuilder<List<Event>>(
                valueListenable: _selectedEvents,
                builder: (context, value, _) {
                  return ListView.builder(
                    itemCount: value.length,
                    itemBuilder: ((context, index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(),
                        ),
                        child: ListTile(
                          // ignore: avoid_print
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TestRecord(),
                            ),
                          ),
                          title: Text('${value[index]}'),
                          trailing: IconButton(
                            icon: const Icon(
                                Icons.more_vert), // More options icon
                            onPressed: () {
                              // Handle more options click here
                              _showEventOptionsDialog(value[index]);
                            },
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void addSessionToClass(
    String className, String sessionName, DateTime? timeDate) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Get a reference to the user document
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      // Get a reference to the classes collection
      CollectionReference classesCollectionRef = userRef.collection('classes');

      // Query the classes collection to find the class document by its name
      QuerySnapshot querySnapshot = await classesCollectionRef
          .where('Class Name', isEqualTo: className)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Assume there's only one document per class, if more handle accordingly
        DocumentReference classDocRef = querySnapshot.docs[0].reference;

        // Add a new collection named 'sessions' inside the class document
        CollectionReference sessionsCollectionRef =
            classDocRef.collection('sessions');

        // Add a document to the 'sessions' collection
        await sessionsCollectionRef.add({
          'Session Name': sessionName,
          'Audio link': "Upload cheyyanam",
          'GeneratedNotes': "Undakkanam",
          'DateTime': timeDate,
          // Add any other fields as needed
        });

        print('Session added successfully to the class document.');
      } else {
        print('No class document found with the name $className.');
      }
    } else {
      print('User is not logged in.');
    }
  } catch (e) {
    print('Error adding session to class document: $e');
  }
}

Future<List<Event>> getEvents(String className, DateTime day) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      CollectionReference classesCollectionRef = userRef.collection('classes');

      QuerySnapshot classQuerySnapshot = await classesCollectionRef
          .where('Class Name', isEqualTo: className)
          .get();

      if (classQuerySnapshot.docs.isNotEmpty) {
        DocumentSnapshot classDoc = classQuerySnapshot.docs.first;
        CollectionReference sessionsCollectionRef =
            classDoc.reference.collection('sessions');

        Timestamp startOfDay =
            Timestamp.fromDate(DateTime(day.year, day.month, day.day, 0, 0, 0));
        Timestamp endOfDay = Timestamp.fromDate(
            DateTime(day.year, day.month, day.day, 23, 59, 59));

        QuerySnapshot eventsQuerySnapshot = await sessionsCollectionRef
            .where('DateTime',
                isGreaterThanOrEqualTo: startOfDay,
                isLessThanOrEqualTo: endOfDay)
            .get();

        List<Event> eventsForClass = eventsQuerySnapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return Event(data['Session Name'], dateTime: null);
        }).toList();

        return eventsForClass;
      }
    }
    return [];
  } catch (e) {
    throw Exception('Error fetching events data from Firestore: $e');
  }
}
