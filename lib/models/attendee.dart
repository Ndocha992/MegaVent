import 'package:cloud_firestore/cloud_firestore.dart';

class Attendee {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String? profileImage;
  final String eventId;
  final String eventName;
  final String qrCode;
  final bool hasAttended;
  final bool isApproved;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime registeredAt;

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
  });

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
    };
  }

  // Create from Firestore DocumentSnapshot
  factory Attendee.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Attendee(
      id: doc.id,
      fullName: data['fullName'] ?? '',
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
    );
  }

  // Create from Map
  factory Attendee.fromMap(Map<String, dynamic> map) {
    return Attendee(
      id: map['id'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      profileImage: map['profileImage'],
      eventId: map['eventId'] ?? '',
      eventName: map['eventName'] ?? '',
      qrCode: map['qrCode'] ?? '',
      hasAttended: map['hasAttended'] ?? false,
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
    );
  }

  // Get display name (for compatibility with fake data)
  String get name => fullName;

  // Get attendance status display
  String get attendanceStatus {
    return hasAttended ? 'Attended' : 'Registered';
  }

  // Calculate if attendee registration is "new" (registered within the last 30 minutes)
  bool get isNew {
    final now = DateTime.now();
    final thirtyMinutesAgo = now.subtract(const Duration(minutes: 30));
    return registeredAt.isAfter(thirtyMinutesAgo);
  }

  @override
  String toString() {
    return 'Attendee(id: $id, fullName: $fullName, email: $email, phone: $phone, eventId: $eventId, hasAttended: $hasAttended, isApproved: $isApproved)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Attendee && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
