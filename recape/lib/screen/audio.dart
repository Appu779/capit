import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recape/components/classdetails.dart';
import 'package:recape/screen/clsrecord.dart';
import 'package:recape/screen/event.dart';
import 'package:table_calendar/table_calendar.dart';

class Audiopage extends StatefulWidget {
  const Audiopage(ClassroomTileData selectedClassroom, {super.key});

  @override
  State<Audiopage> createState() => _AudiopageState();
}

class _AudiopageState extends State<Audiopage> {
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime? _selectedDay;
  Map<DateTime, List<Event>> events = {};
  final TextEditingController _eventController = TextEditingController();
  late final ValueNotifier<List<Event>> _selectedEvents;
  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    _fetchEventsData();
  }

  void _fetchEventsData() async {
    try {
      // Fetch events data from Firestore based on the selected day
      List<Event> eventsForDay = await getEvents(_selectedDay!);

      setState(() {
        events[_selectedDay!] = eventsForDay;
        _selectedEvents.value = eventsForDay;
      });
    } catch (e) {
      print('Error fetching events data: $e');
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _focusedDay = focusedDay;
        _selectedDay = selectedDay;
        _fetchEventsData(); // Fetch events data for the newly selected day
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
    // Fetch events data from Firestore based on the selected day
    List<Event> eventsForDay = events[day] ?? [];

    // You can also fetch events data from Firestore here if needed

    return eventsForDay;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Audio"),
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
                            // Create a new event with the text from the TextField
                            Event newEvent = Event(_eventController.text);
                            addCollectionToClasses(
                                _eventController.text, _selectedDay);
                            // If events already exist for the selected day, append the new event
                            if (events.containsKey(_selectedDay)) {
                              events[_selectedDay]!.add(newEvent);
                            } else {
                              // If no events exist for the selected day, create a new list with the new event
                              events[_selectedDay!] = [newEvent];
                            }

                            // Close the dialog and update the UI
                            Navigator.of(context).pop();
                            _selectedEvents.value =
                                _getEventsForDay(_selectedDay!);
                          },
                          child: const Text("Submit"))
                    ],
                  );
                });
          },
          child: const Icon(Icons.add),
        ),
        body: Column(
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
                                    builder: (context) => const Recorders())),
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
                  }),
            )
          ],
        ));
  }
}

void addCollectionToClasses(String sessionName, DateTime? timeDate) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Get a reference to the user document
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      // Get a reference to the classes collection
      CollectionReference classesCollectionRef = userRef.collection('classes');

      // Create a query to find the current user's instance document in the 'classes' collection
      QuerySnapshot querySnapshot = await classesCollectionRef.get();

      if (querySnapshot.docs.isNotEmpty) {
        // Assume there's only one document per user, if more handle accordingly
        DocumentReference currentClassesDocRef =
            querySnapshot.docs[0].reference;

        // Add a new collection named 'sessions' inside the current user's instance document
        CollectionReference sessionsCollectionRef =
            currentClassesDocRef.collection('sessions');

        // Add a document to the 'sessions' collection
        await sessionsCollectionRef.add({
          'Session Name': sessionName,
          'Audio link': "Upload cheyyanam",
          'Generated Notes': "Undakkanam",
          'DateTime': timeDate,
          // Add any other fields as needed
        });

        print('Session added successfully to classes document.');
      } else {
        print('No classes document found for the current user.');
      }
    } else {
      print('User is not logged in.');
    }
  } catch (e) {
    print('Error adding session to classes document: $e');
  }
}

Future<List<Event>> getEvents(DateTime day) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      CollectionReference classesCollectionRef = userRef.collection('classes');
      QuerySnapshot querySnapshot = await classesCollectionRef.get();

      List<Event> allEvents = [];

      for (DocumentSnapshot classDoc in querySnapshot.docs) {
        DocumentReference classRef = classDoc.reference;
        CollectionReference sessionsCollectionRef =
            classRef.collection('sessions');

        // Convert selected day to start and end timestamps
        Timestamp startOfDay =
            Timestamp.fromDate(DateTime(day.year, day.month, day.day, 0, 0, 0));
        Timestamp endOfDay = Timestamp.fromDate(
            DateTime(day.year, day.month, day.day, 23, 59, 59));

        // Fetch events data from Firestore based on the selected day for this class
        QuerySnapshot eventsQuerySnapshot = await sessionsCollectionRef
            .where('DateTime',
                isGreaterThanOrEqualTo: startOfDay,
                isLessThanOrEqualTo: endOfDay)
            .get();

        // Convert Firestore data to list of Event objects
        List<Event> eventsForClass = eventsQuerySnapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return Event(data['Session Name']);
        }).toList();

        allEvents.addAll(eventsForClass);
      }

      return allEvents;
    }
    return [];
  } catch (e) {
    throw Exception('Error fetching events data from Firestore: $e');
  }
}
