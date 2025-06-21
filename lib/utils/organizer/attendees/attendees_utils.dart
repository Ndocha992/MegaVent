import 'package:megavent/data/fake_data.dart';

class AttendeesStats {
  final int total;
  final int registered;
  final int attended;
  final int noShow;

  AttendeesStats({
    required this.total,
    required this.registered,
    required this.attended,
    required this.noShow,
  });
}

class AttendeesUtils {
  /// Get attendance statistics from a list of attendees
  static AttendeesStats getAttendeesStats(List<Attendee> attendees) {
    final total = attendees.length;
    final attended = attendees.where((a) => a.hasAttended).length;
    final registered = total;
    final noShow = total - attended;

    return AttendeesStats(
      total: total,
      registered: registered,
      attended: attended,
      noShow: noShow,
    );
  }

  /// Filter attendees by search query
  static List<Attendee> filterAttendeesBySearch(
    List<Attendee> attendees,
    String query,
  ) {
    if (query.isEmpty) return attendees;

    final lowerQuery = query.toLowerCase();
    return attendees.where((attendee) {
      return attendee.name.toLowerCase().contains(lowerQuery) ||
          attendee.email.toLowerCase().contains(lowerQuery) ||
          attendee.phone.contains(query);
    }).toList();
  }

  /// Filter attendees by event - FIXED: Now properly filters by event name
  static List<Attendee> filterAttendeesByEvent(
    List<Attendee> attendees,
    String eventName,
  ) {
    if (eventName == 'All') return attendees;

    // Filter by the attendee's event name property
    return attendees
        .where((attendee) => attendee.eventName == eventName)
        .toList();
  }

  /// Filter attendees by tab selection
  static List<Attendee> filterAttendeesByTab(
    List<Attendee> attendees,
    int tabIndex,
  ) {
    switch (tabIndex) {
      case 0: // All Attendees
        return attendees;
      case 1: // Attended
        return attendees.where((a) => a.hasAttended).toList();
      case 2: // No Show (Not Attended)
        return attendees.where((a) => !a.hasAttended).toList();
      default:
        return attendees;
    }
  }

  /// Get attendee status text
  static String getAttendeeStatus(Attendee attendee) {
    return attendee.hasAttended ? 'Attended' : 'Registered';
  }

  /// Check if attendee is recent (registered within last 24 hours)
  static bool isRecentAttendee(Attendee attendee) {
    final now = DateTime.now();
    final difference = now.difference(attendee.registeredAt);
    return difference.inHours < 24;
  }

  /// Get formatted registration date
  static String getFormattedRegistrationDate(DateTime registrationDate) {
    final now = DateTime.now();
    final difference = now.difference(registrationDate);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  /// Sort attendees by various criteria
  static List<Attendee> sortAttendees(List<Attendee> attendees, String sortBy) {
    final sortedList = List<Attendee>.from(attendees);

    switch (sortBy) {
      case 'name':
        sortedList.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'registrationDate':
        sortedList.sort((a, b) => b.registeredAt.compareTo(a.registeredAt));
        break;
      case 'status':
        sortedList.sort((a, b) {
          if (a.hasAttended && !b.hasAttended) return -1;
          if (!a.hasAttended && b.hasAttended) return 1;
          return 0;
        });
        break;
      case 'event':
        sortedList.sort((a, b) => a.eventName.compareTo(b.eventName));
        break;
      default:
        // Default sort by registration date (newest first)
        sortedList.sort((a, b) => b.registeredAt.compareTo(a.registeredAt));
    }

    return sortedList;
  }

  /// Get attendance rate as percentage
  static double getAttendanceRate(List<Attendee> attendees) {
    if (attendees.isEmpty) return 0.0;

    final attendedCount = attendees.where((a) => a.hasAttended).length;
    return (attendedCount / attendees.length) * 100;
  }

  /// Generate QR code data for attendee
  static String generateQRData(Attendee attendee) {
    // In a real app, this would generate a secure token or reference
    return 'ATTENDEE:${attendee.id}:${attendee.name}:${attendee.email}';
  }

  /// Validate attendee email
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Validate attendee phone
  static bool isValidPhone(String phone) {
    // Basic phone validation - can be enhanced based on requirements
    return RegExp(r'^\+?[\d\s\-\(\)]{10,}$').hasMatch(phone);
  }

  /// Get attendee initials for avatar
  static String getAttendeeInitials(String name) {
    return name
        .split(' ')
        .map((n) => n.isNotEmpty ? n[0] : '')
        .take(2)
        .join()
        .toUpperCase();
  }

  /// Get unique events from attendees list
  static List<String> getUniqueEvents(List<Attendee> attendees) {
    final events = attendees.map((a) => a.eventName).toSet().toList();
    events.sort();
    return ['All', ...events];
  }

  /// Get attendees count by event
  static Map<String, int> getAttendeesCountByEvent(List<Attendee> attendees) {
    final Map<String, int> eventCounts = {};

    for (final attendee in attendees) {
      eventCounts[attendee.eventName] =
          (eventCounts[attendee.eventName] ?? 0) + 1;
    }

    return eventCounts;
  }
}
