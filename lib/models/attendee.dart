import 'package:cloud_firestore/cloud_firestore.dart';

class Attendee {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String? profileImage;
  final bool emailVerified;
  final bool isActive;
  final bool? isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? suspensionReason;
  final DateTime? suspendedAt;
  final String? suspendedBy;
  final DateTime? reactivatedAt;
  final String? reactivatedBy;
  final DateTime? deletedAt;
  final String? deletedBy;
  final String? updatedBy;

  Attendee({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.profileImage,
    required this.emailVerified,
    required this.isActive,
    this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    this.suspensionReason,
    this.suspendedAt,
    this.suspendedBy,
    this.reactivatedAt,
    this.reactivatedBy,
    this.deletedAt,
    this.deletedBy,
    this.updatedBy,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'emailVerified': emailVerified,
      'isActive': isActive,
      'isDeleted': isDeleted,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'suspensionReason': suspensionReason,
      'suspendedAt': suspendedAt,
      'suspendedBy': suspendedBy,
      'reactivatedAt': reactivatedAt,
      'reactivatedBy': reactivatedBy,
      'deletedAt': deletedAt,
      'deletedBy': deletedBy,
      'updatedBy': updatedBy,
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
      emailVerified: data['emailVerified'] ?? false,
      isActive: data['isActive'] ?? true,
      isDeleted: data['isDeleted'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      suspensionReason: data['suspensionReason'],
      suspendedAt: (data['suspendedAt'] as Timestamp?)?.toDate(),
      suspendedBy: data['suspendedBy'],
      reactivatedAt: (data['reactivatedAt'] as Timestamp?)?.toDate(),
      reactivatedBy: data['reactivatedBy'],
      deletedAt: (data['deletedAt'] as Timestamp?)?.toDate(),
      deletedBy: data['deletedBy'],
      updatedBy: data['updatedBy'],
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
      emailVerified: map['emailVerified'] ?? false,
      isActive: map['isActive'] ?? true,
      isDeleted: map['isDeleted'],
      createdAt: map['createdAt'] is Timestamp 
          ? (map['createdAt'] as Timestamp).toDate()
          : map['createdAt'] ?? DateTime.now(),
      updatedAt: map['updatedAt'] is Timestamp 
          ? (map['updatedAt'] as Timestamp).toDate()
          : map['updatedAt'] ?? DateTime.now(),
      suspensionReason: map['suspensionReason'],
      suspendedAt: map['suspendedAt'] is Timestamp 
          ? (map['suspendedAt'] as Timestamp).toDate()
          : map['suspendedAt'],
      suspendedBy: map['suspendedBy'],
      reactivatedAt: map['reactivatedAt'] is Timestamp 
          ? (map['reactivatedAt'] as Timestamp).toDate()
          : map['reactivatedAt'],
      reactivatedBy: map['reactivatedBy'],
      deletedAt: map['deletedAt'] is Timestamp 
          ? (map['deletedAt'] as Timestamp).toDate()
          : map['deletedAt'],
      deletedBy: map['deletedBy'],
      updatedBy: map['updatedBy'],
    );
  }

  // CopyWith method for easy updates
  Attendee copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? profileImage,
    bool? emailVerified,
    bool? isActive,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? suspensionReason,
    DateTime? suspendedAt,
    String? suspendedBy,
    DateTime? reactivatedAt,
    String? reactivatedBy,
    DateTime? deletedAt,
    String? deletedBy,
    String? updatedBy,
  }) {
    return Attendee(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      emailVerified: emailVerified ?? this.emailVerified,
      isActive: isActive ?? this.isActive,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      suspensionReason: suspensionReason ?? this.suspensionReason,
      suspendedAt: suspendedAt ?? this.suspendedAt,
      suspendedBy: suspendedBy ?? this.suspendedBy,
      reactivatedAt: reactivatedAt ?? this.reactivatedAt,
      reactivatedBy: reactivatedBy ?? this.reactivatedBy,
      deletedAt: deletedAt ?? this.deletedAt,
      deletedBy: deletedBy ?? this.deletedBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  @override
  String toString() {
    return 'Attendee(id: $id, fullName: $fullName, email: $email, phone: $phone, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Attendee && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}