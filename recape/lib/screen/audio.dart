import 'package:flutter/material.dart';
import 'package:recape/components/classdetails.dart';
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
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _focusedDay = focusedDay;
        _selectedDay = selectedDay;
        _selectedEvents.value = _getEventsForDay(selectedDay);
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
    //reterive all events from selected day
    return events[day] ?? [];
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
                            onTap: () => print(""),
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
