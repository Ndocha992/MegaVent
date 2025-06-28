import 'package:megavent/models/attendee.dart';

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

  // Create from a list of attendees (for real-time calculations)
  factory OrganizerAttendeeStats.fromAttendeesList(List<Attendee> attendees) {
    final total = attendees.length;
    final attended = attendees.where((a) => a.hasAttended).length;
    final registered = total;
    final noShow = total - attended;
    final attendanceRate = total > 0 ? (attended / total) * 100 : 0.0;

    // Calculate new attendees (last 24 hours)
    final twentyFourHoursAgo = DateTime.now().subtract(
      const Duration(hours: 24),
    );
    final newAttendees =
        attendees
            .where((a) => a.registeredAt.isAfter(twentyFourHoursAgo))
            .length;

    // Calculate recent attendees (last 7 days)
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    final recentAttendees =
        attendees.where((a) => a.registeredAt.isAfter(sevenDaysAgo)).length;

    // Group attendees by event
    final Map<String, int> attendeesByEvent = {};
    for (final attendee in attendees) {
      attendeesByEvent[attendee.eventName] =
          (attendeesByEvent[attendee.eventName] ?? 0) + 1;
    }

    // Group attendees by month
    final Map<String, int> attendeesByMonth = {};
    for (final attendee in attendees) {
      final monthKey =
          '${attendee.registeredAt.year}-${attendee.registeredAt.month.toString().padLeft(2, '0')}';
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
