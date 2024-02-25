class Event {
  final String sessionName;
  final DateTime? dateTime;

  Event(this.sessionName, {this.dateTime});

  @override
  String toString() {
    return 'Event: $sessionName';
  }
}
