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
      profileImage:
          'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150&h=150&fit=crop&crop=face',
    ),
    Attendee(
      id: '3',
      name: 'Mike Johnson',
      email: 'mike.johnson@email.com',
      phone: '+254723456789',
      eventId: '1',
      eventName: 'Tech Conference 2025',
      qrCode: 'QR_TECH_CONF_MIKE_003',
      hasAttended: true,
      registeredAt: oneDayAgo,
      isNew: false,
      profileImage:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
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
      profileImage:
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&h=150&fit=crop&crop=face',
    ),
    Attendee(
      id: '5',
      name: 'David Kim',
      email: 'david.kim@email.com',
      phone: '+254734567890',
      eventId: '1',
      eventName: 'Tech Conference 2025',
      qrCode: 'QR_TECH_CONF_DAVID_005',
      hasAttended: false,
      registeredAt: now.subtract(const Duration(hours: 3)),
      isNew: true,
      profileImage:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&h=150&fit=crop&crop=face',
    ),
    Attendee(
      id: '6',
      name: 'Emily Chen',
      email: 'emily.chen@email.com',
      phone: '+254745678901',
      eventId: '2',
      eventName: 'Music Festival',
      qrCode: 'QR_MUSIC_FEST_EMILY_006',
      hasAttended: false,
      registeredAt: now.subtract(const Duration(hours: 5)),
      isNew: true,
      profileImage:
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150&h=150&fit=crop&crop=face',
    ),
    Attendee(
      id: '7',
      name: 'Robert Brown',
      email: 'robert.brown@email.com',
      phone: '+254756789012',
      eventId: '2',
      eventName: 'Music Festival',
      qrCode: 'QR_MUSIC_FEST_ROBERT_007',
      hasAttended: false,
      registeredAt: oneDayAgo,
      isNew: false,
      profileImage:
          'https://images.unsplash.com/photo-1519244703995-f4e0f30006d5?w=150&h=150&fit=crop&crop=face',
    ),
    Attendee(
      id: '8',
      name: 'Lisa Anderson',
      email: 'lisa.anderson@email.com',
      phone: '+254767890123',
      eventId: '3',
      eventName: 'Business Summit',
      qrCode: 'QR_BIZ_SUMMIT_LISA_008',
      hasAttended: false,
      registeredAt: twoWeeksAgo,
      isNew: false,
      profileImage:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&h=150&fit=crop&crop=face',
    ),
    Attendee(
      id: '9',
      name: 'James Wilson',
      email: 'james.wilson@email.com',
      phone: '+254778901234',
      eventId: '4',
      eventName: 'Art Exhibition',
      qrCode: 'QR_ART_EXPO_JAMES_009',
      hasAttended: false,
      registeredAt: oneWeekAgo,
      isNew: false,
      profileImage:
          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150&h=150&fit=crop&crop=face',
    ),
    Attendee(
      id: '10',
      name: 'Maria Garcia',
      email: 'maria.garcia@email.com',
      phone: '+254789012345',
      eventId: '1',
      eventName: 'Tech Conference 2025',
      qrCode: 'QR_TECH_CONF_MARIA_010',
      hasAttended: true,
      registeredAt: now.subtract(const Duration(days: 2)),
      isNew: false,
      profileImage:
          'https://images.unsplash.com/photo-1488508872907-592763824245?w=150&h=150&fit=crop&crop=face',
    ),
    Attendee(
      id: '11',
      name: 'Kevin Lee',
      email: 'kevin.lee@email.com',
      phone: '+254790123456',
      eventId: '2',
      eventName: 'Music Festival',
      qrCode: 'QR_MUSIC_FEST_KEVIN_011',
      hasAttended: false,
      registeredAt: now.subtract(const Duration(hours: 8)),
      isNew: true,
      profileImage:
          'https://images.unsplash.com/photo-1521119989659-a83eee488004?w=150&h=150&fit=crop&crop=face',
    ),
    Attendee(
      id: '12',
      name: 'Amanda Taylor',
      email: 'amanda.taylor@email.com',
      phone: '+254701234567',
      eventId: '3',
      eventName: 'Business Summit',
      qrCode: 'QR_BIZ_SUMMIT_AMANDA_012',
      hasAttended: false,
      registeredAt: now.subtract(const Duration(days: 3)),
      isNew: false,
      profileImage:
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150&h=150&fit=crop&crop=face',
    ),
    Attendee(
      id: '13',
      name: 'Daniel Martinez',
      email: 'daniel.martinez@email.com',
      phone: '+254712345670',
      eventId: '4',
      eventName: 'Art Exhibition',
      qrCode: 'QR_ART_EXPO_DANIEL_013',
      hasAttended: false,
      registeredAt: oneWeekAgo,
      isNew: false,
      profileImage:
          'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=150&h=150&fit=crop&crop=face',
    ),
    Attendee(
      id: '14',
      name: 'Rachel White',
      email: 'rachel.white@email.com',
      phone: '+254723456781',
      eventId: '1',
      eventName: 'Tech Conference 2025',
      qrCode: 'QR_TECH_CONF_RACHEL_014',
      hasAttended: false,
      registeredAt: now.subtract(const Duration(minutes: 45)),
      isNew: true,
      profileImage:
          'https://images.unsplash.com/photo-1502685104226-ee32379fefbe?w=150&h=150&fit=crop&crop=face',
    ),
    Attendee(
      id: '15',
      name: 'Chris Thompson',
      email: 'chris.thompson@email.com',
      phone: '+254734567892',
      eventId: '2',
      eventName: 'Music Festival',
      qrCode: 'QR_MUSIC_FEST_CHRIS_015',
      hasAttended: false,
      registeredAt: now.subtract(const Duration(hours: 12)),
      isNew: true,
      profileImage:
          'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=150&h=150&fit=crop&crop=face',
    ),
    Attendee(
      id: '16',
      name: 'Grace Ochieng',
      email: 'grace.ochieng@email.com',
      phone: '+254745678903',
      eventId: '3',
      eventName: 'Business Summit',
      qrCode: 'QR_BIZ_SUMMIT_GRACE_016',
      hasAttended: false,
      registeredAt: twoWeeksAgo,
      isNew: false,
      profileImage:
          'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150&h=150&fit=crop&crop=face',
    ),
    Attendee(
      id: '17',
      name: 'Peter Mwangi',
      email: 'peter.mwangi@email.com',
      phone: '+254756789014',
      eventId: '4',
      eventName: 'Art Exhibition',
      qrCode: 'QR_ART_EXPO_PETER_017',
      hasAttended: false,
      registeredAt: oneWeekAgo,
      isNew: false,
      profileImage:
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
    ),
    Attendee(
      id: '18',
      name: 'Nancy Wanjiku',
      email: 'nancy.wanjiku@email.com',
      phone: '+254767890125',
      eventId: '1',
      eventName: 'Tech Conference 2025',
      qrCode: 'QR_TECH_CONF_NANCY_018',
      hasAttended: true,
      registeredAt: now.subtract(const Duration(days: 1)),
      isNew: false,
      profileImage:
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&h=150&fit=crop&crop=face',
    ),
    Attendee(
      id: '19',
      name: 'Samuel Kiprop',
      email: 'samuel.kiprop@email.com',
      phone: '+254778901236',
      eventId: '2',
      eventName: 'Music Festival',
      qrCode: 'QR_MUSIC_FEST_SAMUEL_019',
      hasAttended: false,
      registeredAt: now.subtract(const Duration(hours: 6)),
      isNew: true,
      profileImage:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
    ),
    Attendee(
      id: '20',
      name: 'Faith Njeri',
      email: 'faith.njeri@email.com',
      phone: '+254789012347',
      eventId: '3',
      eventName: 'Business Summit',
      qrCode: 'QR_BIZ_SUMMIT_FAITH_020',
      hasAttended: false,
      registeredAt: now.subtract(const Duration(days: 4)),
      isNew: false,
      profileImage:
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150&h=150&fit=crop&crop=face',
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
    Staff(
      id: '2',
      name: 'Bob Coordinator',
      email: 'bob.coordinator@megavent.com',
      phone: '+254712345002',
      role: 'Event Coordinator',
      department: 'Operations',
      profileImage:
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
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
      profileImage:
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&h=150&fit=crop&crop=face',
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
      profileImage:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
      hiredAt: oneWeekAgo,
      isNew: false,
    ),
    Staff(
      id: '5',
      name: 'Emma Marketing',
      email: 'emma.marketing@megavent.com',
      phone: '+254712345005',
      role: 'Marketing Specialist',
      department: 'Marketing',
      profileImage:
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150&h=150&fit=crop&crop=face',
      hiredAt: now.subtract(const Duration(hours: 4)),
      isNew: true,
    ),
    Staff(
      id: '6',
      name: 'Frank Security',
      email: 'frank.security@megavent.com',
      phone: '+254712345006',
      role: 'Security Manager',
      department: 'Security',
      profileImage:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&h=150&fit=crop&crop=face',
      hiredAt: now.subtract(const Duration(hours: 1)),
      isNew: true,
    ),
    Staff(
      id: '7',
      name: 'Grace Finance',
      email: 'grace.finance@megavent.com',
      phone: '+254712345007',
      role: 'Finance Manager',
      department: 'Finance',
      profileImage:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&h=150&fit=crop&crop=face',
      hiredAt: twoWeeksAgo,
      isNew: false,
    ),
    Staff(
      id: '8',
      name: 'Henry Audio',
      email: 'henry.audio@megavent.com',
      phone: '+254712345008',
      role: 'Audio Engineer',
      department: 'Technical',
      profileImage:
          'https://images.unsplash.com/photo-1519244703995-f4e0f30006d5?w=150&h=150&fit=crop&crop=face',
      hiredAt: oneWeekAgo,
      isNew: false,
    ),
    Staff(
      id: '9',
      name: 'Ivy Catering',
      email: 'ivy.catering@megavent.com',
      phone: '+254712345009',
      role: 'Catering Manager',
      department: 'Catering',
      profileImage:
          'https://images.unsplash.com/photo-1488508872907-592763824245?w=150&h=150&fit=crop&crop=face',
      hiredAt: now.subtract(const Duration(hours: 6)),
      isNew: true,
    ),
    Staff(
      id: '10',
      name: 'Jack Logistics',
      email: 'jack.logistics@megavent.com',
      phone: '+254712345010',
      role: 'Logistics Coordinator',
      department: 'Operations',
      profileImage:
          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150&h=150&fit=crop&crop=face',
      hiredAt: oneMonthAgo,
      isNew: false,
    ),
    Staff(
      id: '11',
      name: 'Kelly PR',
      email: 'kelly.pr@megavent.com',
      phone: '+254712345011',
      role: 'PR Specialist',
      department: 'Marketing',
      profileImage:
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150&h=150&fit=crop&crop=face',
      hiredAt: now.subtract(const Duration(hours: 3)),
      isNew: true,
    ),
    Staff(
      id: '12',
      name: 'Leo Photography',
      email: 'leo.photography@megavent.com',
      phone: '+254712345012',
      role: 'Photographer',
      department: 'Creative',
      profileImage:
          'https://images.unsplash.com/photo-1521119989659-a83eee488004?w=150&h=150&fit=crop&crop=face',
      hiredAt: twoWeeksAgo,
      isNew: false,
    ),
    Staff(
      id: '13',
      name: 'Mia Venue',
      email: 'mia.venue@megavent.com',
      phone: '+254712345013',
      role: 'Venue Coordinator',
      department: 'Operations',
      profileImage:
          'https://images.unsplash.com/photo-1502685104226-ee32379fefbe?w=150&h=150&fit=crop&crop=face',
      hiredAt: oneWeekAgo,
      isNew: false,
    ),
    Staff(
      id: '14',
      name: 'Noah Video',
      email: 'noah.video@megavent.com',
      phone: '+254712345014',
      role: 'Video Producer',
      department: 'Creative',
      profileImage:
          'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=150&h=150&fit=crop&crop=face',
      hiredAt: now.subtract(const Duration(minutes: 20)),
      isNew: true,
    ),
    Staff(
      id: '15',
      name: 'Olivia Registration',
      email: 'olivia.registration@megavent.com',
      phone: '+254712345015',
      role: 'Registration Manager',
      department: 'Operations',
      profileImage:
          'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150&h=150&fit=crop&crop=face',
      hiredAt: oneMonthAgo,
      isNew: false,
    ),
    Staff(
      id: '16',
      name: 'Paul Cleaning',
      email: 'paul.cleaning@megavent.com',
      phone: '+254712345016',
      role: 'Cleaning Supervisor',
      department: 'Facilities',
      profileImage:
          'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=150&h=150&fit=crop&crop=face',
      hiredAt: twoWeeksAgo,
      isNew: false,
    ),
    Staff(
      id: '17',
      name: 'Quinn Social',
      email: 'quinn.social@megavent.com',
      phone: '+254712345017',
      role: 'Social Media Manager',
      department: 'Marketing',
      profileImage:
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&h=150&fit=crop&crop=face',
      hiredAt: now.subtract(const Duration(hours: 7)),
      isNew: true,
    ),
    Staff(
      id: '18',
      name: 'Ryan Transport',
      email: 'ryan.transport@megavent.com',
      phone: '+254712345018',
      role: 'Transport Coordinator',
      department: 'Logistics',
      profileImage:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
      hiredAt: oneWeekAgo,
      isNew: false,
    ),
    Staff(
      id: '19',
      name: 'Sophia Decor',
      email: 'sophia.decor@megavent.com',
      phone: '+254712345019',
      role: 'Decoration Specialist',
      department: 'Creative',
      profileImage:
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150&h=150&fit=crop&crop=face',
      hiredAt: now.subtract(const Duration(hours: 5)),
      isNew: true,
    ),
    Staff(
      id: '20',
      name: 'Thomas Admin',
      email: 'thomas.admin@megavent.com',
      phone: '+254712345020',
      role: 'Administrative Assistant',
      department: 'Administration',
      profileImage:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&h=150&fit=crop&crop=face',
      hiredAt: oneMonthAgo,
      isNew: false,
    ),
    Staff(
      id: '21',
      name: 'Uma Quality',
      email: 'uma.quality@megavent.com',
      phone: '+254712345021',
      role: 'Quality Assurance',
      department: 'Operations',
      profileImage:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&h=150&fit=crop&crop=face',
      hiredAt: now.subtract(const Duration(hours: 9)),
      isNew: true,
    ),
    Staff(
      id: '22',
      name: 'Victor Maintenance',
      email: 'victor.maintenance@megavent.com',
      phone: '+254712345022',
      role: 'Maintenance Engineer',
      department: 'Facilities',
      profileImage:
          'https://images.unsplash.com/photo-1519244703995-f4e0f30006d5?w=150&h=150&fit=crop&crop=face',
      hiredAt: twoWeeksAgo,
      isNew: false,
    ),
    Staff(
      id: '23',
      name: 'Wendy Sales',
      email: 'wendy.sales@megavent.com',
      phone: '+254712345023',
      role: 'Sales Representative',
      department: 'Sales',
      profileImage:
          'https://images.unsplash.com/photo-1488508872907-592763824245?w=150&h=150&fit=crop&crop=face',
      hiredAt: now.subtract(const Duration(minutes: 15)),
      isNew: true,
    ),
    Staff(
      id: '24',
      name: 'Xavier Legal',
      email: 'xavier.legal@megavent.com',
      phone: '+254712345024',
      role: 'Legal Advisor',
      department: 'Legal',
      profileImage:
          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150&h=150&fit=crop&crop=face',
      hiredAt: oneMonthAgo,
      isNew: false,
    ),
    Staff(
      id: '25',
      name: 'Yara Analytics',
      email: 'yara.analytics@megavent.com',
      phone: '+254712345025',
      role: 'Data Analyst',
      department: 'Analytics',
      profileImage:
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150&h=150&fit=crop&crop=face',
      hiredAt: now.subtract(const Duration(hours: 10)),
      isNew: true,
    ),
    Staff(
      id: '26',
      name: 'Zara Customer',
      email: 'zara.customer@megavent.com',
      phone: '+254712345026',
      role: 'Customer Service Rep',
      department: 'Customer Service',
      profileImage:
          'https://images.unsplash.com/photo-1521119989659-a83eee488004?w=150&h=150&fit=crop&crop=face',
      hiredAt: oneWeekAgo,
      isNew: false,
    ),
    Staff(
      id: '27',
      name: 'Aaron Procurement',
      email: 'aaron.procurement@megavent.com',
      phone: '+254712345027',
      role: 'Procurement Officer',
      department: 'Procurement',
      profileImage:
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
      hiredAt: twoWeeksAgo,
      isNew: false,
    ),
    Staff(
      id: '28',
      name: 'Bella Training',
      email: 'bella.training@megavent.com',
      phone: '+254712345028',
      role: 'Training Coordinator',
      department: 'HR',
      profileImage:
          'https://images.unsplash.com/photo-1502685104226-ee32379fefbe?w=150&h=150&fit=crop&crop=face',
      hiredAt: now.subtract(const Duration(hours: 8)),
      isNew: true,
    ),
    Staff(
      id: '29',
      name: 'Carl Equipment',
      email: 'carl.equipment@megavent.com',
      phone: '+254712345029',
      role: 'Equipment Manager',
      department: 'Technical',
      profileImage:
          'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=150&h=150&fit=crop&crop=face',
      hiredAt: oneMonthAgo,
      isNew: false,
    ),
    Staff(
      id: '30',
      name: 'Diana Research',
      email: 'diana.research@megavent.com',
      phone: '+254712345030',
      role: 'Market Research Analyst',
      department: 'Research',
      profileImage:
          'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150&h=150&fit=crop&crop=face',
      hiredAt: now.subtract(const Duration(hours: 11)),
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
