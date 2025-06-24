class Event {
  final String id;
  final String name;
  final String description;
  final String category;
  final String posterUrl;
  final DateTime startDate;
  final DateTime endDate;
  final String startTime;
  final String endTime;
  final String location;
  final int capacity;
  final int registeredCount;
  final int attendedCount;
  final DateTime createdAt;
  final bool isNew;

  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.posterUrl,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.capacity,
    required this.registeredCount,
    required this.attendedCount,
    required this.createdAt,
    required this.isNew,
  });
}

class Attendee {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String eventId;
  final String eventName;
  final String qrCode;
  final bool hasAttended;
  final DateTime registeredAt;
  final bool isNew;
  final String profileImage;

  Attendee({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.eventId,
    required this.eventName,
    required this.qrCode,
    required this.hasAttended,
    required this.registeredAt,
    required this.isNew,
    required this.profileImage,
  });
}

class Staff {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String department;
  final String profileImage;
  final DateTime hiredAt;
  final bool isNew;

  Staff({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.department,
    required this.profileImage,
    required this.hiredAt,
    required this.isNew,
  });
}

class DashboardStats {
  final int totalEvents;
  final int totalAttendees;
  final int totalStaff;
  final int activeEvents;
  final int upcomingEvents;
  final int completedEvents;

  DashboardStats({
    required this.totalEvents,
    required this.totalAttendees,
    required this.totalStaff,
    required this.activeEvents,
    required this.upcomingEvents,
    required this.completedEvents,
  });
}

// Fake Data
class FakeData {
  static final DateTime now = DateTime.now();
  static final DateTime threeHoursAgo = now.subtract(const Duration(hours: 3));
  static final DateTime oneDayAgo = now.subtract(const Duration(days: 1));
  static final DateTime oneWeekAgo = now.subtract(const Duration(days: 7));
  static final DateTime twoWeeksAgo = now.subtract(const Duration(days: 14));
  static final DateTime oneMonthAgo = now.subtract(const Duration(days: 30));

  // Available categories
  static List<String> categories = [
    'Technology',
    'Art & Culture',
    'Music',
    'Sports',
    'Business',
    'Education',
    'Entertainment',
    'Health & Wellness',
    'Food & Drink',
    'Networking',
  ];

  static List<Event> events = [
    Event(
      id: '1',
      name: 'Tech Conference 2025',
      description: 'Annual technology conference featuring latest innovations',
      category: 'Technology',
      posterUrl:
          'https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fwww.evenement.com%2Fwp-content%2Fuploads%2F2019%2F09%2Fsamuel-pereira-uf2nnANWa8Q-unsplash-2.jpg&f=1&nofb=1&ipt=8d0212d6ad19ae76b1c896fb1fe4306336f9d76748893ecfb78585bd19a07047',
      startDate: DateTime.now().add(const Duration(days: 15)),
      endDate: DateTime.now().add(const Duration(days: 16)),
      startTime: '09:00 AM',
      endTime: '06:00 PM',
      location: 'Nairobi Convention Center',
      capacity: 500,
      registeredCount: 350,
      attendedCount: 100,
      createdAt: now.subtract(const Duration(hours: 1)),
      isNew: true,
    ),
  ];

  static List<Attendee> attendees = [
    // Tech Conference Attendees
    Attendee(
      id: '1',
      name: 'John Doe',
      email: 'john.doe@email.com',
      phone: '+254712345678',
      eventId: '1',
      eventName: 'Tech Conference 2025',
      qrCode: 'QR_TECH_CONF_JOHN_001',
      hasAttended: false,
      registeredAt: now.subtract(const Duration(minutes: 30)),
      isNew: true,
      profileImage:
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
    ),
  ];

  static List<Staff> staff = [
    Staff(
      id: '1',
      name: 'Alice Manager',
      email: 'alice.manager@megavent.com',
      phone: '+254712345001',
      role: 'Event Manager',
      department: 'Operations',
      profileImage:
          'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150&h=150&fit=crop&crop=face',
      hiredAt: now.subtract(const Duration(hours: 2)),
      isNew: true,
    ),
  ];

  static DashboardStats dashboardStats = DashboardStats(
    totalEvents: events.length,
    totalAttendees: attendees.length,
    totalStaff: staff.length,
    activeEvents:
        events.where((e) => e.startDate.isAfter(DateTime.now())).length,
    upcomingEvents:
        events
            .where(
              (e) =>
                  e.startDate.isAfter(DateTime.now()) &&
                  e.startDate.isBefore(
                    DateTime.now().add(const Duration(days: 30)),
                  ),
            )
            .length,
    completedEvents:
        events.where((e) => e.endDate.isBefore(DateTime.now())).length,
  );

  // Helper methods
  static List<Event> getLatestEvents({int limit = 4}) {
    var sortedEvents = List<Event>.from(events);
    sortedEvents.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedEvents.take(limit).toList();
  }

  static List<Attendee> getLatestAttendees({int limit = 4}) {
    var sortedAttendees = List<Attendee>.from(attendees);
    sortedAttendees.sort((a, b) => b.registeredAt.compareTo(a.registeredAt));
    return sortedAttendees.take(limit).toList();
  }

  static List<Staff> getLatestStaff({int limit = 4}) {
    var sortedStaff = List<Staff>.from(staff);
    sortedStaff.sort((a, b) => b.hiredAt.compareTo(a.hiredAt));
    return sortedStaff.take(limit).toList();
  }

  // Get categories method
  static List<String> getCategories() {
    return List<String>.from(categories);
  }

  // Additional helper methods for better data management
  static List<Attendee> getAttendeesByEvent(String eventId) {
    return attendees.where((attendee) => attendee.eventId == eventId).toList();
  }

  static List<Staff> getStaffByDepartment(String department) {
    return staff
        .where((staffMember) => staffMember.department == department)
        .toList();
  }

  static List<Event> getEventsByCategory(String category) {
    return events.where((event) => event.category == category).toList();
  }

  static List<Attendee> getNewAttendees() {
    return attendees.where((attendee) => attendee.isNew).toList();
  }

  static List<Staff> getNewStaff() {
    return staff.where((staffMember) => staffMember.isNew).toList();
  }

  static List<Event> getUpcomingEvents() {
    return events
        .where((event) => event.startDate.isAfter(DateTime.now()))
        .toList();
  }

  static List<Attendee> getAttendeesWhoAttended() {
    return attendees.where((attendee) => attendee.hasAttended).toList();
  }

  static Map<String, int> getEventRegistrationStats() {
    Map<String, int> stats = {};
    for (var event in events) {
      stats[event.name] = event.registeredCount;
    }
    return stats;
  }

  static Map<String, int> getDepartmentStats() {
    Map<String, int> stats = {};
    for (var staffMember in staff) {
      stats[staffMember.department] = (stats[staffMember.department] ?? 0) + 1;
    }
    return stats;
  }
}
