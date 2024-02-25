import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class EventCalendarScreen extends StatefulWidget {
  const EventCalendarScreen({Key? key}) : super(key: key);

  @override
  State<EventCalendarScreen> createState() => _EventCalendarScreenState();
}

class _EventCalendarScreenState extends State<EventCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDate;
  final DateTime _firstDay = DateTime(2022, 1, 1);
  final DateTime _lastDay = DateTime(2023, 12, 31);

  Map<String, List<Map<String, String>>> mySelectedEvents = {};

  final titleController = TextEditingController();
  final descpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDate = _focusedDay;
    if (!_isWithinRange(_focusedDay, _firstDay, _lastDay)) {
      _focusedDay = _firstDay;
    }

    loadPreviousEvents();
  }

  loadPreviousEvents() {
    mySelectedEvents = {
      "2024-02-25": [
        {"eventDescp": "11", "eventTitle": "111"},
        {"eventDescp": "22", "eventTitle": "22"}
      ],
      "2022-09-30": [
        {"eventDescp": "22", "eventTitle": "22"}
      ],
      "2022-09-20": [
        {"eventTitle": "ss", "eventDescp": "ss"}
      ]
    };
  }

  List<Map<String, String>> _listOfDayEvents(DateTime dateTime) {
    final events = mySelectedEvents[DateFormat('yyyy-MM-dd').format(dateTime)];
    if (events != null) {
      return List<Map<String, String>>.from(events);
    } else {
      return [];
    }
  }

  bool _isWithinRange(DateTime date, DateTime firstDay, DateTime lastDay) {
    return date.isAfter(firstDay.subtract(Duration(days: 1))) &&
        date.isBefore(lastDay.add(Duration(days: 1)));
  }

  Future<void> _showAddEventDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Add New Event',
          textAlign: TextAlign.center,
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Title',
              ),
            ),
            TextField(
              controller: descpController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            child: const Text('Add Event'),
            onPressed: () {
              if (titleController.text.isEmpty &&
                  descpController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Required title and description'),
                    duration: Duration(seconds: 2),
                  ),
                );
                return;
              } else {
                setState(() {
                  final selectedDateFormatted =
                      DateFormat('yyyy-MM-dd').format(_selectedDate!);
                  mySelectedEvents[selectedDateFormatted] ??= [];
                  mySelectedEvents[selectedDateFormatted]!.add({
                    "eventTitle": titleController.text,
                    "eventDescp": descpController.text,
                  });
                });

                titleController.clear();
                descpController.clear();
                Navigator.pop(context);
                return;
              }
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Event Calendar Example'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime(2022),
              lastDay: DateTime(2023),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDate, selectedDay)) {
                  setState(() {
                    _selectedDate = selectedDay;
                    _focusedDay = focusedDay;
                  });
                }
              },
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDate, day);
              },
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              eventLoader: _listOfDayEvents,
            ),
            ..._listOfDayEvents(_selectedDate!).map(
              (myEvents) => ListTile(
                leading: const Icon(
                  Icons.done,
                  color: Colors.teal,
                ),
                title: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text('Event Title:   ${myEvents['eventTitle']}'),
                ),
                subtitle: Text('Description:   ${myEvents['eventDescp']}'),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEventDialog(),
        label: const Text('Add Event'),
      ),
    );
  }
}
