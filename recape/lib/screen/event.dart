class Event {
  String text;
  DateTime creationTime;

  Event(this.text) : creationTime = DateTime.now();

  @override
  String toString() {
    return text;
  }
}
