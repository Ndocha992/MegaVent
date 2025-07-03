import 'package:cloud_firestore/cloud_firestore.dart';

class Attendee {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String? profileImage;
  final bool isApproved;
  final DateTime createdAt;
  final DateTime updatedAt;

  Attendee({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.profileImage,
    required this.isApproved,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'isApproved': isApproved,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
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
      isApproved: data['isApproved'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
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
    );
  }

  // CopyWith method for easy updates
  Attendee copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? profileImage,
    bool? isApproved,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Attendee(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      isApproved: isApproved ?? this.isApproved,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Get display name (for compatibility with fake data)
  String get name => fullName;

  // Calculate if attendee registration is "new" (registered within the last 6 hours)
  bool get isNew {
    final now = DateTime.now();
    final sixHoursAgo = now.subtract(const Duration(hours: 6));
    return createdAt.isAfter(sixHoursAgo);
  }

  @override
  String toString() {
    return 'Attendee(id: $id, fullName: $fullName, email: $email, phone: $phone, isApproved: $isApproved)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Attendee && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
