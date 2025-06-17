import 'package:cloud_firestore/cloud_firestore.dart';

class Organizer {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String? organization;
  final String? profileImage;
  final bool isApproved;
  final DateTime createdAt;
  final DateTime updatedAt;

  Organizer({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.organization,
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
      'organization': organization,
      'profileImage': profileImage,
      'isApproved': isApproved,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Create from Firestore DocumentSnapshot
  factory Organizer.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Organizer(
      id: doc.id,
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      organization: data['organization'],
      profileImage: data['profileImage'],
      isApproved: data['isApproved'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Create from Map
  factory Organizer.fromMap(Map<String, dynamic> map) {
    return Organizer(
      id: map['id'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      organization: map['organization'],
      profileImage: map['profileImage'],
      isApproved: map['isApproved'] ?? false,
      createdAt:
          map['createdAt'] is Timestamp
              ? (map['createdAt'] as Timestamp).toDate()
              : map['createdAt'] ?? DateTime.now(),
      updatedAt:
          map['updatedAt'] is Timestamp
              ? (map['updatedAt'] as Timestamp).toDate()
              : map['updatedAt'] ?? DateTime.now(),
    );
  }

  // CopyWith method for easy updates
  Organizer copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? organization,
    String? profileImage,
    bool? isApproved,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Organizer(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      organization: organization ?? this.organization,
      profileImage: profileImage ?? this.profileImage,
      isApproved: isApproved ?? this.isApproved,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Getter for approval status display
  String get approvalStatus {
    if (isApproved) return 'Approved';
    if (!isApproved) return 'Pending';
    return 'Unknown';
  }

  @override
  String toString() {
    return 'Organizer(id: $id, fullName: $fullName, email: $email, organization: $organization, isApproved: $isApproved)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Organizer && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
