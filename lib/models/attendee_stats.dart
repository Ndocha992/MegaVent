class AttendeeStats {
  final int registeredEvents;
  final int attendedEvents;
  final int notAttendedEvents;
  final int upcomingEvents;

  AttendeeStats({
    required this.registeredEvents,
    required this.attendedEvents,
    required this.notAttendedEvents,
    required this.upcomingEvents,
  });

  AttendeeStats copyWith({
    int? registeredEvents,
    int? attendedEvents,
    int? notAttendedEvents,
    int? upcomingEvents,
  }) {
    return AttendeeStats(
      registeredEvents: registeredEvents ?? this.registeredEvents,
      attendedEvents: attendedEvents ?? this.attendedEvents,
      notAttendedEvents: notAttendedEvents ?? this.notAttendedEvents,
      upcomingEvents: upcomingEvents ?? this.upcomingEvents,
    );
  }
}