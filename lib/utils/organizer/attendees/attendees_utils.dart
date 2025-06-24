import 'package:megavent/models/attendee.dart';
import 'package:megavent/models/attendee_stats.dart';

class AttendeesUtils {
  /// Get comprehensive attendance statistics using the new AttendeeStats model
  static AttendeeStats getComprehensiveStats(List<Attendee> attendees) {
    return AttendeeStats.fromAttendeesList(attendees);
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

  /// Filter attendees by event - properly filters by event name
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

  /// Filter attendees by approval status
  static List<Attendee> filterAttendeesByApproval(
    List<Attendee> attendees,
    bool? isApproved,
  ) {
    if (isApproved == null) return attendees;
    return attendees.where((a) => a.isApproved == isApproved).toList();
  }

  /// Filter attendees by registration date range
  static List<Attendee> filterAttendeesByDateRange(
    List<Attendee> attendees,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    return attendees.where((attendee) {
      final regDate = attendee.registeredAt;

      if (startDate != null && regDate.isBefore(startDate)) {
        return false;
      }

      if (endDate != null && regDate.isAfter(endDate)) {
        return false;
      }

      return true;
    }).toList();
  }

  /// Get attendee status text
  static String getAttendeeStatus(Attendee attendee) {
    if (!attendee.isApproved) return 'Pending Approval';
    return attendee.hasAttended ? 'Attended' : 'Registered';
  }

  /// Get attendee status color
  static String getAttendeeStatusColor(Attendee attendee) {
    if (!attendee.isApproved) return 'warning';
    return attendee.hasAttended ? 'success' : 'primary';
  }

  /// Check if attendee is recent (registered within last 24 hours)
  static bool isRecentAttendee(Attendee attendee) {
    final now = DateTime.now();
    final difference = now.difference(attendee.registeredAt);
    return difference.inHours < 24;
  }

  /// Check if attendee is new (uses the model's isNew property)
  static bool isNewAttendee(Attendee attendee) {
    return attendee.isNew;
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

  /// Get relative time for any date
  static String getRelativeTime(DateTime dateTime) {
    return getFormattedRegistrationDate(dateTime);
  }

  /// Get readable date format
  static String getReadableDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Sort attendees by various criteria
  static List<Attendee> sortAttendees(List<Attendee> attendees, String sortBy) {
    final sortedList = List<Attendee>.from(attendees);

    switch (sortBy) {
      case 'name':
        sortedList.sort((a, b) => a.fullName.compareTo(b.fullName));
        break;
      case 'email':
        sortedList.sort((a, b) => a.email.compareTo(b.email));
        break;
      case 'registrationDate':
        sortedList.sort((a, b) => b.registeredAt.compareTo(a.registeredAt));
        break;
      case 'registrationDateAsc':
        sortedList.sort((a, b) => a.registeredAt.compareTo(b.registeredAt));
        break;
      case 'status':
        sortedList.sort((a, b) {
          // Sort by approval status first, then attendance
          if (a.isApproved != b.isApproved) {
            return a.isApproved ? -1 : 1;
          }
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

  /// Get approval rate as percentage
  static double getApprovalRate(List<Attendee> attendees) {
    if (attendees.isEmpty) return 0.0;

    final approvedCount = attendees.where((a) => a.isApproved).length;
    return (approvedCount / attendees.length) * 100;
  }

  /// Generate QR code data for attendee
  static String generateQRData(Attendee attendee) {
    // In a real app, this would generate a secure token or reference
    return 'ATTENDEE:${attendee.id}:${attendee.fullName}:${attendee.email}:${attendee.eventId}';
  }

  /// Validate attendee email
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Validate attendee phone
  static bool isValidPhone(String phone) {
    // Enhanced phone validation for Kenyan numbers
    return RegExp(
      r'^\+?254[0-9]{9}$|^0[0-9]{9}$|^\+?[\d\s\-\(\)]{10,}$',
    ).hasMatch(phone);
  }

  /// Format phone number for display
  static String formatPhoneNumber(String phone) {
    // Remove all non-digit characters
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');

    // Format Kenyan numbers
    if (digits.startsWith('254') && digits.length == 12) {
      return '+254 ${digits.substring(3, 6)} ${digits.substring(6, 9)} ${digits.substring(9)}';
    } else if (digits.startsWith('0') && digits.length == 10) {
      return '0${digits.substring(1, 4)} ${digits.substring(4, 7)} ${digits.substring(7)}';
    }

    return phone; // Return original if no formatting applied
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

  /// Get attendees count by status
  static Map<String, int> getAttendeesCountByStatus(List<Attendee> attendees) {
    final Map<String, int> statusCounts = {
      'Registered': 0,
      'Attended': 0,
      'Pending': 0,
    };

    for (final attendee in attendees) {
      if (!attendee.isApproved) {
        statusCounts['Pending'] = statusCounts['Pending']! + 1;
      } else if (attendee.hasAttended) {
        statusCounts['Attended'] = statusCounts['Attended']! + 1;
      } else {
        statusCounts['Registered'] = statusCounts['Registered']! + 1;
      }
    }

    return statusCounts;
  }

  /// Get registration trends over time
  static Map<String, int> getRegistrationTrends(
    List<Attendee> attendees, {
    int days = 7,
  }) {
    final Map<String, int> trends = {};
    final now = DateTime.now();

    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = '${date.day}/${date.month}';
      final count =
          attendees
              .where(
                (a) =>
                    a.registeredAt.year == date.year &&
                    a.registeredAt.month == date.month &&
                    a.registeredAt.day == date.day,
              )
              .length;
      trends[dateKey] = count;
    }

    return trends;
  }

  /// Get attendees with specific filters applied
  static List<Attendee> getFilteredAttendees(
    List<Attendee> attendees, {
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
      filtered = filterAttendeesByEvent(filtered, eventName);
    }

    // Apply tab filter
    if (tabIndex != null) {
      filtered = filterAttendeesByTab(filtered, tabIndex);
    }

    // Apply approval filter
    if (isApproved != null) {
      filtered = filterAttendeesByApproval(filtered, isApproved);
    }

    // Apply date range filter
    if (startDate != null || endDate != null) {
      filtered = filterAttendeesByDateRange(filtered, startDate, endDate);
    }

    // Apply sorting
    filtered = sortAttendees(filtered, sortBy);

    return filtered;
  }

  /// Export attendees data to CSV format
  static String exportAttendeesToCSV(List<Attendee> attendees) {
    final buffer = StringBuffer();

    // Header
    buffer.writeln(
      'Name,Email,Phone,Event,Status,Registered At,Attended,Approved',
    );

    // Data rows
    for (final attendee in attendees) {
      buffer.writeln(
        '"${attendee.fullName}",'
        '"${attendee.email}",'
        '"${attendee.phone}",'
        '"${attendee.eventName}",'
        '"${getAttendeeStatus(attendee)}",'
        '"${getReadableDate(attendee.registeredAt)}",'
        '${attendee.hasAttended ? 'Yes' : 'No'},'
        '${attendee.isApproved ? 'Yes' : 'No'}',
      );
    }

    return buffer.toString();
  }

  /// Get summary statistics for display
  static Map<String, dynamic> getSummaryStats(List<Attendee> attendees) {
    final stats = getComprehensiveStats(attendees);

    return {
      'total': stats.total,
      'attended': stats.attended,
      'registered': stats.registered,
      'noShow': stats.noShow,
      'newAttendees': stats.newAttendees,
      'recentAttendees': stats.recentAttendees,
      'attendanceRate': stats.attendanceRate.toStringAsFixed(1),
      'approvalRate': getApprovalRate(attendees).toStringAsFixed(1),
      'events': getUniqueEvents(attendees).length - 1, // Exclude 'All'
      'eventsByAttendees': stats.attendeesByEvent,
      'attendeesByMonth': stats.attendeesByMonth,
      'lastUpdated': stats.lastUpdated,
    };
  }

  /// Get attendee analytics data
  static Map<String, dynamic> getAttendeeAnalytics(List<Attendee> attendees) {
    final stats = getComprehensiveStats(attendees);

    return {
      'totalAttendees': stats.total,
      'attendanceRate': stats.attendanceRate,
      'approvalRate': getApprovalRate(attendees),
      'newAttendeesLast24h': stats.newAttendees,
      'recentAttendeesLast7d': stats.recentAttendees,
      'eventDistribution': stats.attendeesByEvent,
      'monthlyTrends': stats.attendeesByMonth,
      'statusBreakdown': getAttendeesCountByStatus(attendees),
    };
  }

  /// Get quick stats for dashboard widgets
  static Map<String, int> getQuickStats(List<Attendee> attendees) {
    return {
      'total': attendees.length,
      'attended': attendees.where((a) => a.hasAttended).length,
      'registered':
          attendees.where((a) => a.isApproved && !a.hasAttended).length,
      'pending': attendees.where((a) => !a.isApproved).length,
      'new': attendees.where((a) => a.isNew).length,
      'recent': attendees.where((a) => isRecentAttendee(a)).length,
    };
  }

  /// Check if attendee list has changed significantly
  static bool hasSignificantChange(
    List<Attendee> oldList,
    List<Attendee> newList, {
    double threshold = 0.1, // 10% change threshold
  }) {
    if (oldList.isEmpty) return newList.isNotEmpty;
    if (newList.isEmpty) return oldList.isNotEmpty;

    final oldCount = oldList.length;
    final newCount = newList.length;
    final changeRate = (newCount - oldCount).abs() / oldCount;

    return changeRate >= threshold;
  }

  /// Get attendee engagement score (based on registration time vs event time)
  static double getEngagementScore(List<Attendee> attendees) {
    if (attendees.isEmpty) return 0.0;

    final attendedCount = attendees.where((a) => a.hasAttended).length;
    final approvedCount = attendees.where((a) => a.isApproved).length;
    final newAttendeesCount = attendees.where((a) => a.isNew).length;

    // Calculate engagement based on attendance rate, approval rate, and new registrations
    final attendanceScore = attendedCount / attendees.length;
    final approvalScore = approvedCount / attendees.length;
    final newAttendeesScore = newAttendeesCount / attendees.length;

    // Weighted average (attendance is most important)
    return (attendanceScore * 0.5 +
            approvalScore * 0.3 +
            newAttendeesScore * 0.2) *
        100;
  }
}
