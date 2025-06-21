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
  });
}

class Staff {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String department;
  final String profileUrl;
  final DateTime hiredAt;
  final bool isNew;

  Staff({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.department,
    required this.profileUrl,
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
    Event(
      id: '2',
      name: 'Music Festival',
      description: 'Amazing music festival with top artists',
      category: 'Entertainment',
      posterUrl:
          'https://res.cloudinary.com/drmcceprh/image/upload/v1750511826/megavent/event_banners/1750511823753_event_banner_banner_1750511823760_330.jpg',
      startDate: DateTime.now().add(const Duration(days: 30)),
      endDate: DateTime.now().add(const Duration(days: 32)),
      startTime: '02:00 PM',
      endTime: '11:00 PM',
      location: 'Uhuru Gardens',
      capacity: 2000,
      registeredCount: 1500,
      attendedCount: 0,
      createdAt: now.subtract(const Duration(hours: 2)),
      isNew: true,
    ),
    Event(
      id: '3',
      name: 'Business Summit',
      description: 'Leadership and business development summit',
      category: 'Business',
      posterUrl:
          'https://via.placeholder.com/300x200/8B5CF6/FFFFFF?text=Biz+Summit',
      startDate: DateTime.now().add(const Duration(days: 45)),
      endDate: DateTime.now().add(const Duration(days: 45)),
      startTime: '08:00 AM',
      endTime: '05:00 PM',
      location: 'Villa Rosa Kempinski',
      capacity: 300,
      registeredCount: 250,
      attendedCount: 0,
      createdAt: oneDayAgo,
      isNew: false,
    ),
    Event(
      id: '4',
      name: 'Art Exhibition',
      description: 'Contemporary art exhibition by local artists',
      category: 'Art & Culture',
      posterUrl:
          'https://via.placeholder.com/300x200/10B981/FFFFFF?text=Art+Expo',
      startDate: DateTime.now().add(const Duration(days: 60)),
      endDate: DateTime.now().add(const Duration(days: 67)),
      startTime: '10:00 AM',
      endTime: '08:00 PM',
      location: 'National Museums of Kenya',
      capacity: 150,
      registeredCount: 89,
      attendedCount: 0,
      createdAt: oneWeekAgo,
      isNew: false,
    ),
  ];

  static List<Attendee> attendees = [
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
    ),
    Attendee(
      id: '2',
      name: 'Jane Smith',
      email: 'jane.smith@email.com',
      phone: '+254798765432',
      eventId: '1',
      eventName: 'Tech Conference 2025',
      qrCode: 'QR_TECH_CONF_JANE_002',
      hasAttended: true,
      registeredAt: now.subtract(const Duration(hours: 1)),
      isNew: true,
    ),
    Attendee(
      id: '3',
      name: 'Mike Johnson',
      email: 'mike.johnson@email.com',
      phone: '+254723456789',
      eventId: '1',
      eventName: 'Tech Conference 2025',
      qrCode: 'QR_TECH_CONF_JANE_002',
      hasAttended: true,
      registeredAt: oneDayAgo,
      isNew: false,
    ),
    Attendee(
      id: '4',
      name: 'Sarah Williams',
      email: 'sarah.williams@email.com',
      phone: '+254756789012',
      eventId: '3',
      eventName: 'Business Summit',
      qrCode: 'QR_BIZ_SUMMIT_SARAH_004',
      hasAttended: false,
      registeredAt: oneWeekAgo,
      isNew: false,
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
      profileUrl: 'https://via.placeholder.com/150/6B46C1/FFFFFF?text=AM',
      hiredAt: now.subtract(const Duration(hours: 2)),
      isNew: true,
    ),
    Staff(
      id: '2',
      name: 'Bob Coordinator',
      email: 'bob.coordinator@megavent.com',
      phone: '+254712345002',
      role: 'Event Coordinator',
      department: 'Operations',
      profileUrl: 'https://via.placeholder.com/150/06D6A0/FFFFFF?text=BC',
      hiredAt: now.subtract(const Duration(minutes: 45)),
      isNew: true,
    ),
    Staff(
      id: '3',
      name: 'Carol Designer',
      email: 'carol.designer@megavent.com',
      phone: '+254712345003',
      role: 'Graphics Designer',
      department: 'Creative',
      profileUrl: 'https://via.placeholder.com/150/8B5CF6/FFFFFF?text=CD',
      hiredAt: oneDayAgo,
      isNew: false,
    ),
    Staff(
      id: '4',
      name: 'David Tech',
      email: 'david.tech@megavent.com',
      phone: '+254712345004',
      role: 'Technical Support',
      department: 'IT',
      profileUrl: 'https://via.placeholder.com/150/10B981/FFFFFF?text=DT',
      hiredAt: oneWeekAgo,
      isNew: false,
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
}
