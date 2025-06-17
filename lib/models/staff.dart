import 'package:cloud_firestore/cloud_firestore.dart';

class Staff {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String? profileImage;
  final String organizerId;
  final String? organization;
  final bool isApproved;
  final DateTime createdAt;
  final DateTime updatedAt;

  Staff({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.profileImage,
    required this.organizerId,
    this.organization,
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
      'organizerId': organizerId,
      'organization': organization,
      'isApproved': isApproved,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Create from Firestore DocumentSnapshot
  factory Staff.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Staff(
      id: doc.id,
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      profileImage: data['profileImage'],
      organizerId: data['organizerId'] ?? '',
      organization: data['organization'],
      isApproved: data['isApproved'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Create from Map
  factory Staff.fromMap(Map<String, dynamic> map) {
    return Staff(
      id: map['id'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      profileImage: map['profileImage'],
      organizerId: map['organizerId'] ?? '',
      organization: map['organization'],
      isApproved: map['isApproved'] ?? true,
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
  Staff copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? profileImage,
    String? organizerId,
    String? organization,
    bool? isApproved,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Staff(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      organizerId: organizerId ?? this.organizerId,
      organization: organization ?? this.organization,
      isApproved: isApproved ?? this.isApproved,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Getter for status display
  String get status {
    if (!isApproved) return 'Suspended';
    if (!isApproved) return 'Inactive';
    return 'Active';
  }

  @override
  String toString() {
    return 'Staff(id: $id, fullName: $fullName, email: $email, organizerId: $organizerId, isApproved: $isApproved)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Staff && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
