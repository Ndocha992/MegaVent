import 'package:megavent/models/attendee.dart';
import 'package:megavent/models/registration.dart';
import 'package:megavent/models/attendee_stats.dart';

class AttendeesUtils {
  /// Get comprehensive attendance statistics using both attendees and registrations
  static OrganizerAttendeeStats getComprehensiveStats(
    List<Attendee> attendees,
    List<Registration> registrations,
    Map<String, String> eventIdToNameMap,
  ) {
    return OrganizerAttendeeStats.fromRegistrationsList(
      registrations,
      eventIdToNameMap,
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
      return attendee.fullName.toLowerCase().contains(lowerQuery) ||
          attendee.email.toLowerCase().contains(lowerQuery) ||
          attendee.phone.contains(query);
    }).toList();
  }

  /// Filter attendees by tab selection using registration data
  static List<Attendee> filterAttendeesByTab(
    List<Attendee> attendees,
    List<Registration> registrations,
    int tabIndex,
  ) {
    // Create a map of userId to registration for quick lookup
    final userRegistrationMap = <String, Registration>{};
    for (final registration in registrations) {
      userRegistrationMap[registration.userId] = registration;
    }

    switch (tabIndex) {
      case 0: // All Attendees
        return attendees;
      case 1: // Attended
        return attendees.where((a) {
          final registration = userRegistrationMap[a.id];
          return registration?.hasAttended ?? false;
        }).toList();
      case 2: // No Show (Not Attended)
        return attendees.where((a) {
          final registration = userRegistrationMap[a.id];
          return registration != null && !registration.hasAttended;
        }).toList();
      default:
        return attendees;
    }
  }

  /// Filter attendees by approval status
  static List<Attendee> filterAttendeesByApproval(
    List<Attendee> attendees,
    bool? isApproved,
  ) {
    if (isApproved == null) return attendees;
    return attendees.where((a) => a.isApproved == isApproved).toList();
  }

  /// Filter attendees by registration date range using registration data
  static List<Attendee> filterAttendeesByDateRange(
    List<Attendee> attendees,
    List<Registration> registrations,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    // Create a map of userId to registration for quick lookup
    final userRegistrationMap = <String, Registration>{};
    for (final registration in registrations) {
      userRegistrationMap[registration.userId] = registration;
    }

    return attendees.where((attendee) {
      final registration = userRegistrationMap[attendee.id];
      if (registration == null) return false;

      final regDate = registration.registeredAt;

      if (startDate != null && regDate.isBefore(startDate)) {
        return false;
      }

      if (endDate != null && regDate.isAfter(endDate)) {
        return false;
      }

      return true;
    }).toList();
  }

  /// Get attendee status text using registration data
  static String getAttendeeStatus(
    Attendee attendee,
    Registration? registration,
  ) {
    if (!attendee.isApproved) return 'Pending Approval';
    return registration?.hasAttended ?? false ? 'Attended' : 'Registered';
  }

  /// Get attendee status color using registration data
  static String getAttendeeStatusColor(
    Attendee attendee,
    Registration? registration,
  ) {
    if (!attendee.isApproved) return 'warning';
    return registration?.hasAttended ?? false ? 'success' : 'primary';
  }

  /// Check if attendee is recent using registration data
  static bool isRecentAttendee(Registration? registration) {
    if (registration == null) return false;
    final now = DateTime.now();
    final difference = now.difference(registration.registeredAt);
    return difference.inHours < 24;
  }

  /// Get formatted registration date from registration data
  static String getFormattedRegistrationDate(Registration? registration) {
    if (registration == null) return 'Unknown';

    final now = DateTime.now();
    final difference = now.difference(registration.registeredAt);

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

  /// Get relative time for any date
  static String getRelativeTime(DateTime? dateTime) {
    if (dateTime == null) return 'Unknown';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

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

  /// Get readable date format
  static String getReadableDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Sort attendees by various criteria using registration data
  static List<Attendee> sortAttendees(
    List<Attendee> attendees,
    List<Registration> registrations,
    Map<String, String> eventIdToNameMap,
    String sortBy,
  ) {
    // Create a map of userId to registration for quick lookup
    final userRegistrationMap = <String, Registration>{};
    for (final registration in registrations) {
      userRegistrationMap[registration.userId] = registration;
    }

    final sortedList = List<Attendee>.from(attendees);

    switch (sortBy) {
      case 'name':
        sortedList.sort((a, b) => a.fullName.compareTo(b.fullName));
        break;
      case 'email':
        sortedList.sort((a, b) => a.email.compareTo(b.email));
        break;
      case 'registrationDate':
        sortedList.sort((a, b) {
          final regA = userRegistrationMap[a.id];
          final regB = userRegistrationMap[b.id];
          if (regA == null && regB == null) return 0;
          if (regA == null) return 1;
          if (regB == null) return -1;
          return regB.registeredAt.compareTo(regA.registeredAt);
        });
        break;
      case 'registrationDateAsc':
        sortedList.sort((a, b) {
          final regA = userRegistrationMap[a.id];
          final regB = userRegistrationMap[b.id];
          if (regA == null && regB == null) return 0;
          if (regA == null) return 1;
          if (regB == null) return -1;
          return regA.registeredAt.compareTo(regB.registeredAt);
        });
        break;
      case 'status':
        sortedList.sort((a, b) {
          final regA = userRegistrationMap[a.id];
          final regB = userRegistrationMap[b.id];

          // Sort by approval status first, then attendance
          if (a.isApproved != b.isApproved) {
            return a.isApproved ? -1 : 1;
          }

          final attendedA = regA?.hasAttended ?? false;
          final attendedB = regB?.hasAttended ?? false;

          if (attendedA && !attendedB) return -1;
          if (!attendedA && attendedB) return 1;
          return 0;
        });
        break;
      case 'event':
        sortedList.sort((a, b) {
          final regA = userRegistrationMap[a.id];
          final regB = userRegistrationMap[b.id];

          final eventNameA =
              regA != null
                  ? eventIdToNameMap[regA.eventId] ?? 'Unknown'
                  : 'Unknown';
          final eventNameB =
              regB != null
                  ? eventIdToNameMap[regB.eventId] ?? 'Unknown'
                  : 'Unknown';

          return eventNameA.compareTo(eventNameB);
        });
        break;
      default:
        // Default sort by registration date (newest first)
        sortedList.sort((a, b) {
          final regA = userRegistrationMap[a.id];
          final regB = userRegistrationMap[b.id];
          if (regA == null && regB == null) return 0;
          if (regA == null) return 1;
          if (regB == null) return -1;
          return regB.registeredAt.compareTo(regA.registeredAt);
        });
    }

    return sortedList;
  }

  /// Get attendance rate as percentage using registration data
  static double getAttendanceRate(
    List<Attendee> attendees,
    List<Registration> registrations,
  ) {
    if (attendees.isEmpty || registrations.isEmpty) return 0.0;

    final attendeeIds = attendees.map((a) => a.id).toSet();
    final relevantRegistrations =
        registrations.where((r) => attendeeIds.contains(r.userId)).toList();

    if (relevantRegistrations.isEmpty) return 0.0;

    final attendedCount =
        relevantRegistrations.where((r) => r.hasAttended).length;
    return (attendedCount / relevantRegistrations.length) * 100;
  }

  /// Get approval rate as percentage
  static double getApprovalRate(List<Attendee> attendees) {
    if (attendees.isEmpty) return 0.0;

    final approvedCount = attendees.where((a) => a.isApproved).length;
    return (approvedCount / attendees.length) * 100;
  }

  /// Get attendees count by status using registration data
  static Map<String, int> getAttendeesCountByStatus(
    List<Attendee> attendees,
    List<Registration> registrations,
  ) {
    final Map<String, int> statusCounts = {
      'Registered': 0,
      'Attended': 0,
      'Pending': 0,
    };

    // Create a map of userId to registration for quick lookup
    final userRegistrationMap = <String, Registration>{};
    for (final registration in registrations) {
      userRegistrationMap[registration.userId] = registration;
    }

    for (final attendee in attendees) {
      final registration = userRegistrationMap[attendee.id];

      if (!attendee.isApproved) {
        statusCounts['Pending'] = statusCounts['Pending']! + 1;
      } else if (registration?.hasAttended ?? false) {
        statusCounts['Attended'] = statusCounts['Attended']! + 1;
      } else {
        statusCounts['Registered'] = statusCounts['Registered']! + 1;
      }
    }

    return statusCounts;
  }

  /// Get registration trends over time using registration data
  static Map<String, int> getRegistrationTrends(
    List<Attendee> attendees,
    List<Registration> registrations, {
    int days = 7,
  }) {
    final Map<String, int> trends = {};
    final now = DateTime.now();

    // Create a map of userId to registration for quick lookup
    final attendeeIds = attendees.map((a) => a.id).toSet();
    final relevantRegistrations =
        registrations.where((r) => attendeeIds.contains(r.userId)).toList();

    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = '${date.day}/${date.month}';
      final count =
          relevantRegistrations
              .where(
                (r) =>
                    r.registeredAt.year == date.year &&
                    r.registeredAt.month == date.month &&
                    r.registeredAt.day == date.day,
              )
              .length;
      trends[dateKey] = count;
    }

    return trends;
  }

  /// Get attendees with specific filters applied using registration data
  static List<Attendee> getFilteredAttendees(
    List<Attendee> attendees,
    List<Registration> registrations,
    Map<String, String> eventIdToNameMap, {
    String? searchQuery,
    String? eventName,
    int? tabIndex,
    bool? isApproved,
    DateTime? startDate,
    DateTime? endDate,
    String sortBy = 'registrationDate',
  }) {
    List<Attendee> filtered = List.from(attendees);

    // Apply search filter
    if (searchQuery != null && searchQuery.isNotEmpty) {
      filtered = filterAttendeesBySearch(filtered, searchQuery);
    }

    // Apply event filter
    if (eventName != null && eventName != 'All') {
      filtered = filterAttendeesByEvent(
        filtered,
        registrations,
        eventIdToNameMap,
        eventName,
      );
    }

    // Apply tab filter
    if (tabIndex != null) {
      filtered = filterAttendeesByTab(filtered, registrations, tabIndex);
    }

    // Apply approval filter
    if (isApproved != null) {
      filtered = filterAttendeesByApproval(filtered, isApproved);
    }

    // Apply date range filter
    if (startDate != null || endDate != null) {
      filtered = filterAttendeesByDateRange(
        filtered,
        registrations,
        startDate,
        endDate,
      );
    }

    // Apply sorting
    filtered = sortAttendees(filtered, registrations, eventIdToNameMap, sortBy);

    return filtered;
  }

  /// Filter attendees by event using registration data
  static List<Attendee> filterAttendeesByEvent(
    List<Attendee> attendees,
    List<Registration> registrations,
    Map<String, String> eventIdToNameMap,
    String eventName,
  ) {
    if (eventName == 'All') return attendees;

    // Create a map of userId to registration for quick lookup
    final userRegistrationMap = <String, Registration>{};
    for (final registration in registrations) {
      userRegistrationMap[registration.userId] = registration;
    }

    return attendees.where((attendee) {
      final registration = userRegistrationMap[attendee.id];
      if (registration == null) return false;

      final attendeeEventName =
          eventIdToNameMap[registration.eventId] ?? 'Unknown';
      return attendeeEventName == eventName;
    }).toList();
  }

  /// Get unique events from registrations
  static List<String> getUniqueEvents(
    List<Registration> registrations,
    Map<String, String> eventIdToNameMap,
  ) {
    final events =
        registrations
            .map((r) => eventIdToNameMap[r.eventId] ?? 'Unknown')
            .toSet()
            .toList();
    events.sort();
    return ['All', ...events];
  }

  /// Export attendees data to CSV format using registration data
  static String exportAttendeesToCSV(
    List<Attendee> attendees,
    List<Registration> registrations,
    Map<String, String> eventIdToNameMap,
  ) {
    final buffer = StringBuffer();

    // Create a map of userId to registration for quick lookup
    final userRegistrationMap = <String, Registration>{};
    for (final registration in registrations) {
      userRegistrationMap[registration.userId] = registration;
    }

    // Header
    buffer.writeln(
      'Name,Email,Phone,Event,Status,Registered At,Attended,Approved',
    );

    // Data rows
    for (final attendee in attendees) {
      final registration = userRegistrationMap[attendee.id];
      final eventName =
          registration != null
              ? eventIdToNameMap[registration.eventId] ?? 'Unknown'
              : 'Unknown';
      final registeredAt = registration?.registeredAt ?? DateTime.now();
      final hasAttended = registration?.hasAttended ?? false;

      buffer.writeln(
        '"${attendee.fullName}",'
        '"${attendee.email}",'
        '"${attendee.phone}",'
        '"$eventName",'
        '"${getAttendeeStatus(attendee, registration)}",'
        '"${getReadableDate(registeredAt)}",'
        '${hasAttended ? 'Yes' : 'No'},'
        '${attendee.isApproved ? 'Yes' : 'No'}',
      );
    }

    return buffer.toString();
  }

  /// Get summary statistics for display using registration data
  static Map<String, dynamic> getSummaryStats(
    List<Attendee> attendees,
    List<Registration> registrations,
    Map<String, String> eventIdToNameMap,
  ) {
    final stats = getComprehensiveStats(
      attendees,
      registrations,
      eventIdToNameMap,
    );

    return {
      'total': stats.total,
      'attended': stats.attended,
      'registered': stats.registered,
      'noShow': stats.noShow,
      'newAttendees': stats.newAttendees,
      'recentAttendees': stats.recentAttendees,
      'attendanceRate': stats.attendanceRate.toStringAsFixed(1),
      'approvalRate': getApprovalRate(attendees).toStringAsFixed(1),
      'events': getUniqueEvents(registrations, eventIdToNameMap).length - 1,
      'eventsByAttendees': stats.attendeesByEvent,
      'attendeesByMonth': stats.attendeesByMonth,
      'lastUpdated': stats.lastUpdated,
    };
  }

  /// Get quick stats for dashboard widgets using registration data
  static Map<String, int> getQuickStats(
    List<Attendee> attendees,
    List<Registration> registrations,
  ) {
    // Create a map of userId to registration for quick lookup
    final userRegistrationMap = <String, Registration>{};
    for (final registration in registrations) {
      userRegistrationMap[registration.userId] = registration;
    }

    final attendedCount =
        attendees.where((a) {
          final registration = userRegistrationMap[a.id];
          return registration?.hasAttended ?? false;
        }).length;

    final registeredCount =
        attendees.where((a) {
          final registration = userRegistrationMap[a.id];
          return a.isApproved && !(registration?.hasAttended ?? false);
        }).length;

    final recentCount =
        attendees.where((a) {
          final registration = userRegistrationMap[a.id];
          return isRecentAttendee(registration);
        }).length;

    return {
      'total': attendees.length,
      'attended': attendedCount,
      'registered': registeredCount,
      'pending': attendees.where((a) => !a.isApproved).length,
      'new': attendees.where((a) => a.isNew).length,
      'recent': recentCount,
    };
  }
}
