import 'package:megavent/models/registration.dart';

class OrganizerAttendeeStats {
  final int total;
  final int registered;
  final int attended;
  final int noShow;
  final double attendanceRate;
  final int newAttendees; // Attendees registered in last 24 hours
  final int recentAttendees; // Attendees registered in last 7 days
  final Map<String, int> attendeesByEvent;
  final Map<String, int> attendeesByMonth;
  final DateTime lastUpdated;

  OrganizerAttendeeStats({
    required this.total,
    required this.registered,
    required this.attended,
    required this.noShow,
    required this.attendanceRate,
    required this.newAttendees,
    required this.recentAttendees,
    required this.attendeesByEvent,
    required this.attendeesByMonth,
    required this.lastUpdated,
  });

  factory OrganizerAttendeeStats.empty() {
    return OrganizerAttendeeStats(
      total: 0,
      registered: 0,
      attended: 0,
      noShow: 0,
      attendanceRate: 0.0,
      newAttendees: 0,
      recentAttendees: 0,
      attendeesByEvent: {},
      attendeesByMonth: {},
      lastUpdated: DateTime.now(),
    );
  }

  // Create from a list of registrations with event names map
  factory OrganizerAttendeeStats.fromRegistrationsList(
    List<Registration> registrations,
    Map<String, String> eventIdToNameMap, // Map of eventId to eventName
  ) {
    final total = registrations.length;
    final attended = registrations.where((r) => r.attended).length;
    final registered = total;
    final noShow = total - attended;
    final attendanceRate = total > 0 ? (attended / total) * 100 : 0.0;

    // Calculate new attendees (last 24 hours)
    final twentyFourHoursAgo = DateTime.now().subtract(
      const Duration(hours: 24),
    );
    final newAttendees =
        registrations
            .where((r) => r.registeredAt.isAfter(twentyFourHoursAgo))
            .length;

    // Calculate recent attendees (last 7 days)
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    final recentAttendees =
        registrations.where((r) => r.registeredAt.isAfter(sevenDaysAgo)).length;

    // Group attendees by event using event names
    final Map<String, int> attendeesByEvent = {};
    for (final registration in registrations) {
      final eventName =
          eventIdToNameMap[registration.eventId] ?? 'Unknown Event';
      attendeesByEvent[eventName] = (attendeesByEvent[eventName] ?? 0) + 1;
    }

    // Group attendees by month
    final Map<String, int> attendeesByMonth = {};
    for (final registration in registrations) {
      final monthKey =
          '${registration.registeredAt.year}-${registration.registeredAt.month.toString().padLeft(2, '0')}';
      attendeesByMonth[monthKey] = (attendeesByMonth[monthKey] ?? 0) + 1;
    }

    return OrganizerAttendeeStats(
      total: total,
      registered: registered,
      attended: attended,
      noShow: noShow,
      attendanceRate: attendanceRate,
      newAttendees: newAttendees,
      recentAttendees: recentAttendees,
      attendeesByEvent: attendeesByEvent,
      attendeesByMonth: attendeesByMonth,
      lastUpdated: DateTime.now(),
    );
  }

  // Alternative factory method that takes registrations and fetches event names
  static Future<OrganizerAttendeeStats> fromRegistrationsWithEventFetch(
    List<Registration> registrations,
    Future<Map<String, String>> Function(List<String>) fetchEventNames,
  ) async {
    // Extract unique event IDs
    final eventIds = registrations.map((r) => r.eventId).toSet().toList();

    // Fetch event names
    final eventIdToNameMap = await fetchEventNames(eventIds);

    // Create stats using the regular factory method
    return OrganizerAttendeeStats.fromRegistrationsList(
      registrations,
      eventIdToNameMap,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'total': total,
      'registered': registered,
      'attended': attended,
      'noShow': noShow,
      'attendanceRate': attendanceRate,
      'newAttendees': newAttendees,
      'recentAttendees': recentAttendees,
      'attendeesByEvent': attendeesByEvent,
      'attendeesByMonth': attendeesByMonth,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'AttendeeStats(total: $total, attended: $attended, attendanceRate: ${attendanceRate.toStringAsFixed(1)}%)';
  }
}
