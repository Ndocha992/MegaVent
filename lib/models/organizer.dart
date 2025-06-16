import 'package:cloud_firestore/cloud_firestore.dart';

class Organizer {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String? organization;
  final String? profileImage;
  final bool emailVerified;
  final bool isApproved;
  final bool isActive;
  final bool? isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? approvedAt;
  final String? approvedBy;
  final DateTime? rejectedAt;
  final String? rejectedBy;
  final String? rejectionReason;
  final String? suspensionReason;
  final DateTime? suspendedAt;
  final String? suspendedBy;
  final DateTime? reactivatedAt;
  final String? reactivatedBy;
  final DateTime? deletedAt;
  final String? deletedBy;
  final String? updatedBy;

  Organizer({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.organization,
    this.profileImage,
    required this.emailVerified,
    required this.isApproved,
    required this.isActive,
    this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    this.approvedAt,
    this.approvedBy,
    this.rejectedAt,
    this.rejectedBy,
    this.rejectionReason,
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
      'organization': organization,
      'profileImage': profileImage,
      'emailVerified': emailVerified,
      'isApproved': isApproved,
      'isActive': isActive,
      'isDeleted': isDeleted,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'approvedAt': approvedAt,
      'approvedBy': approvedBy,
      'rejectedAt': rejectedAt,
      'rejectedBy': rejectedBy,
      'rejectionReason': rejectionReason,
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
  factory Organizer.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return Organizer(
      id: doc.id,
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      organization: data['organization'],
      profileImage: data['profileImage'],
      emailVerified: data['emailVerified'] ?? false,
      isApproved: data['isApproved'] ?? false,
      isActive: data['isActive'] ?? false,
      isDeleted: data['isDeleted'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      approvedAt: (data['approvedAt'] as Timestamp?)?.toDate(),
      approvedBy: data['approvedBy'],
      rejectedAt: (data['rejectedAt'] as Timestamp?)?.toDate(),
      rejectedBy: data['rejectedBy'],
      rejectionReason: data['rejectionReason'],
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
  factory Organizer.fromMap(Map<String, dynamic> map) {
    return Organizer(
      id: map['id'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      organization: map['organization'],
      profileImage: map['profileImage'],
      emailVerified: map['emailVerified'] ?? false,
      isApproved: map['isApproved'] ?? false,
      isActive: map['isActive'] ?? false,
      isDeleted: map['isDeleted'],
      createdAt: map['createdAt'] is Timestamp 
          ? (map['createdAt'] as Timestamp).toDate()
          : map['createdAt'] ?? DateTime.now(),
      updatedAt: map['updatedAt'] is Timestamp 
          ? (map['updatedAt'] as Timestamp).toDate()
          : map['updatedAt'] ?? DateTime.now(),
      approvedAt: map['approvedAt'] is Timestamp 
          ? (map['approvedAt'] as Timestamp).toDate()
          : map['approvedAt'],
      approvedBy: map['approvedBy'],
      rejectedAt: map['rejectedAt'] is Timestamp 
          ? (map['rejectedAt'] as Timestamp).toDate()
          : map['rejectedAt'],
      rejectedBy: map['rejectedBy'],
      rejectionReason: map['rejectionReason'],
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
  Organizer copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? organization,
    String? profileImage,
    bool? emailVerified,
    bool? isApproved,
    bool? isActive,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? approvedAt,
    String? approvedBy,
    DateTime? rejectedAt,
    String? rejectedBy,
    String? rejectionReason,
    String? suspensionReason,
    DateTime? suspendedAt,
    String? suspendedBy,
    DateTime? reactivatedAt,
    String? reactivatedBy,
    DateTime? deletedAt,
    String? deletedBy,
    String? updatedBy,
  }) {
    return Organizer(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      organization: organization ?? this.organization,
      profileImage: profileImage ?? this.profileImage,
      emailVerified: emailVerified ?? this.emailVerified,
      isApproved: isApproved ?? this.isApproved,
      isActive: isActive ?? this.isActive,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      approvedAt: approvedAt ?? this.approvedAt,
      approvedBy: approvedBy ?? this.approvedBy,
      rejectedAt: rejectedAt ?? this.rejectedAt,
      rejectedBy: rejectedBy ?? this.rejectedBy,
      rejectionReason: rejectionReason ?? this.rejectionReason,
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

  // Getter for approval status display
  String get approvalStatus {
    if (isApproved && isActive) return 'Approved';
    if (!isApproved && rejectionReason != null) return 'Rejected';
    if (!isApproved) return 'Pending';
    if (isApproved && !isActive) return 'Suspended';
    return 'Unknown';
  }

  @override
  String toString() {
    return 'Organizer(id: $id, fullName: $fullName, email: $email, organization: $organization, isApproved: $isApproved, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Organizer && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}