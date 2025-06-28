import 'package:cloud_firestore/cloud_firestore.dart';

class Attendee {
  final String id; // User ID
  final String fullName;
  final String email;
  final String phone;
  final String? profileImage;
  final String eventId;
  final String eventName;
  final String qrCode;
  final bool hasAttended;
  final bool isApproved;
  final DateTime createdAt; // User account creation date
  final DateTime updatedAt; // Last profile update
  final DateTime registeredAt; // Event registration date
  final bool isCheckedIn; // Check-in status for the event
  final DateTime? checkedInAt; // Check-in timestamp
  final String? userId; // For backward compatibility with registration data

  Attendee({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.profileImage,
    required this.eventId,
    required this.eventName,
    required this.qrCode,
    required this.hasAttended,
    required this.isApproved,
    required this.createdAt,
    required this.updatedAt,
    required this.registeredAt,
    bool? isCheckedIn,
    this.checkedInAt,
    this.userId,
  }) : isCheckedIn = isCheckedIn ?? hasAttended;

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'eventId': eventId,
      'eventName': eventName,
      'qrCode': qrCode,
      'hasAttended': hasAttended,
      'isApproved': isApproved,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'registeredAt': Timestamp.fromDate(registeredAt),
      'isCheckedIn': isCheckedIn,
      'checkedInAt':
          checkedInAt != null ? Timestamp.fromDate(checkedInAt!) : null,
      'userId': userId ?? id,
    };
  }

  // Create from Firestore DocumentSnapshot (for attendees collection)
  factory Attendee.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Attendee(
      id: doc.id,
      fullName: data['fullName'] ?? data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      profileImage: data['profileImage'],
      eventId: data['eventId'] ?? '',
      eventName: data['eventName'] ?? '',
      qrCode: data['qrCode'] ?? '',
      hasAttended: data['hasAttended'] ?? false,
      isApproved: data['isApproved'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      registeredAt:
          (data['registeredAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isCheckedIn: data['isCheckedIn'] ?? data['hasAttended'] ?? false,
      checkedInAt: (data['checkedInAt'] as Timestamp?)?.toDate(),
      userId: data['userId'],
    );
  }

  // Create from registration data (when combining registration + user data)
  factory Attendee.fromRegistrationData({
    required Map<String, dynamic> registrationData,
    required Map<String, dynamic> userData,
    required Map<String, dynamic> eventData,
    required String userId,
    required String eventId,
  }) {
    return Attendee(
      id: userId,
      fullName: userData['fullName'] ?? userData['name'] ?? 'Unknown',
      email: userData['email'] ?? '',
      phone: userData['phone'] ?? '',
      profileImage: userData['profileImage'],
      eventId: eventId,
      eventName: eventData['name'] ?? '',
      qrCode: registrationData['qrCode'] ?? '',
      hasAttended: registrationData['attended'] ?? false,
      isApproved: registrationData['isApproved'] ?? true,
      createdAt:
          (userData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:
          (userData['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      registeredAt:
          (registrationData['registeredAt'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      isCheckedIn: registrationData['attended'] ?? false,
      checkedInAt:
          registrationData['attendedAt'] != null
              ? (registrationData['attendedAt'] as Timestamp?)?.toDate()
              : null,
      userId: userId,
    );
  }

  // Create from Map
  factory Attendee.fromMap(Map<String, dynamic> map) {
    return Attendee(
      id: map['id'] ?? '',
      fullName: map['fullName'] ?? map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      profileImage: map['profileImage'],
      eventId: map['eventId'] ?? '',
      eventName: map['eventName'] ?? '',
      qrCode: map['qrCode'] ?? '',
      hasAttended: map['hasAttended'] ?? map['attended'] ?? false,
      isApproved: map['isApproved'] ?? true,
      createdAt:
          map['createdAt'] is Timestamp
              ? (map['createdAt'] as Timestamp).toDate()
              : map['createdAt'] is DateTime
              ? map['createdAt']
              : DateTime.now(),
      updatedAt:
          map['updatedAt'] is Timestamp
              ? (map['updatedAt'] as Timestamp).toDate()
              : map['updatedAt'] is DateTime
              ? map['updatedAt']
              : DateTime.now(),
      registeredAt:
          map['registeredAt'] is Timestamp
              ? (map['registeredAt'] as Timestamp).toDate()
              : map['registeredAt'] is DateTime
              ? map['registeredAt']
              : DateTime.now(),
      isCheckedIn:
          map['isCheckedIn'] ?? map['hasAttended'] ?? map['attended'] ?? false,
      checkedInAt:
          map['checkedInAt'] is Timestamp
              ? (map['checkedInAt'] as Timestamp).toDate()
              : map['checkedInAt'] is DateTime
              ? map['checkedInAt']
              : map['attendedAt'] is Timestamp
              ? (map['attendedAt'] as Timestamp).toDate()
              : map['attendedAt'] is DateTime
              ? map['attendedAt']
              : null,
      userId: map['userId'],
    );
  }

  // CopyWith method for easy updates
  Attendee copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? profileImage,
    String? eventId,
    String? eventName,
    String? qrCode,
    bool? hasAttended,
    bool? isApproved,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? registeredAt,
    bool? isCheckedIn,
    DateTime? checkedInAt,
    String? userId,
  }) {
    return Attendee(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      eventId: eventId ?? this.eventId,
      eventName: eventName ?? this.eventName,
      qrCode: qrCode ?? this.qrCode,
      hasAttended: hasAttended ?? this.hasAttended,
      isApproved: isApproved ?? this.isApproved,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      registeredAt: registeredAt ?? this.registeredAt,
      isCheckedIn: isCheckedIn ?? this.isCheckedIn,
      checkedInAt: checkedInAt ?? this.checkedInAt,
      userId: userId ?? this.userId,
    );
  }

  // Get display name (for compatibility with existing code)
  String get name => fullName;

  // Get attendance status display
  String get attendanceStatus {
    if (isCheckedIn) {
      return 'Checked In';
    } else if (hasAttended) {
      return 'Attended';
    } else {
      return 'Registered';
    }
  }

  // Get check-in status with emoji
  String get checkInStatusWithIcon {
    if (isCheckedIn) {
      return '✅ Checked In';
    } else {
      return '⏳ Not Checked In';
    }
  }

  // Calculate if attendee registration is "new" (registered within the last 6 hours)
  bool get isNew {
    final now = DateTime.now();
    final sixHoursAgo = now.subtract(const Duration(hours: 6));
    return registeredAt.isAfter(sixHoursAgo);
  }

  // Check if the event is upcoming based on registration data
  bool get isUpcoming {
    final now = DateTime.now();
    return registeredAt.isAfter(now);
  }

  // Get formatted registration date
  String get formattedRegistrationDate {
    final now = DateTime.now();
    final difference = now.difference(registeredAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  // Convert to legacy map format for backward compatibility
  Map<String, dynamic> toLegacyMap() {
    return {
      'id': id,
      'name': fullName,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'eventName': eventName,
      'eventId': eventId,
      'registeredAt': registeredAt,
      'attended': hasAttended,
      'attendedAt': checkedInAt,
    };
  }

  @override
  String toString() {
    return 'Attendee(id: $id, fullName: $fullName, email: $email, phone: $phone, eventId: $eventId, eventName: $eventName, hasAttended: $hasAttended, isApproved: $isApproved, registeredAt: $registeredAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Attendee &&
        other.id == id &&
        other.eventId == eventId; // Compare both ID and eventId for uniqueness
  }

  @override
  int get hashCode => Object.hash(id, eventId);
}

// Helper class for attendee statistics
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

  factory AttendeeStats.fromMap(Map<String, dynamic> map) {
    return AttendeeStats(
      registeredEvents: map['registeredEvents'] ?? 0,
      attendedEvents: map['attendedEvents'] ?? 0,
      notAttendedEvents: map['notAttendedEvents'] ?? 0,
      upcomingEvents: map['upcomingEvents'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'registeredEvents': registeredEvents,
      'attendedEvents': attendedEvents,
      'notAttendedEvents': notAttendedEvents,
      'upcomingEvents': upcomingEvents,
    };
  }

  @override
  String toString() {
    return 'AttendeeStats(registeredEvents: $registeredEvents, attendedEvents: $attendedEvents, notAttendedEvents: $notAttendedEvents, upcomingEvents: $upcomingEvents)';
  }
}
