import 'package:cloud_firestore/cloud_firestore.dart';

class Admin {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String? profileImage;
  final String adminLevel; // 'super_admin', 'admin', 'moderator'
  final List<String> permissions; // List of permissions/roles
  final bool emailVerified;
  final bool isActive;
  final bool? isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? suspensionReason;
  final DateTime? suspendedAt;
  final String? suspendedBy;
  final DateTime? reactivatedAt;
  final String? reactivatedBy;
  final DateTime? deletedAt;
  final String? deletedBy;
  final String? updatedBy;
  final DateTime? lastLoginAt;

  Admin({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.profileImage,
    required this.adminLevel,
    required this.permissions,
    required this.emailVerified,
    required this.isActive,
    this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.suspensionReason,
    this.suspendedAt,
    this.suspendedBy,
    this.reactivatedAt,
    this.reactivatedBy,
    this.deletedAt,
    this.deletedBy,
    this.updatedBy,
    this.lastLoginAt,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'adminLevel': adminLevel,
      'permissions': permissions,
      'emailVerified': emailVerified,
      'isActive': isActive,
      'isDeleted': isDeleted,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'createdBy': createdBy,
      'suspensionReason': suspensionReason,
      'suspendedAt': suspendedAt,
      'suspendedBy': suspendedBy,
      'reactivatedAt': reactivatedAt,
      'reactivatedBy': reactivatedBy,
      'deletedAt': deletedAt,
      'deletedBy': deletedBy,
      'updatedBy': updatedBy,
      'lastLoginAt': lastLoginAt,
    };
  }

  // Create from Firestore DocumentSnapshot
  factory Admin.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return Admin(
      id: doc.id,
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      profileImage: data['profileImage'],
      adminLevel: data['adminLevel'] ?? 'admin',
      permissions: List<String>.from(data['permissions'] ?? []),
      emailVerified: data['emailVerified'] ?? false,
      isActive: data['isActive'] ?? true,
      isDeleted: data['isDeleted'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: data['createdBy'],
      suspensionReason: data['suspensionReason'],
      suspendedAt: (data['suspendedAt'] as Timestamp?)?.toDate(),
      suspendedBy: data['suspendedBy'],
      reactivatedAt: (data['reactivatedAt'] as Timestamp?)?.toDate(),
      reactivatedBy: data['reactivatedBy'],
      deletedAt: (data['deletedAt'] as Timestamp?)?.toDate(),
      deletedBy: data['deletedBy'],
      updatedBy: data['updatedBy'],
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate(),
    );
  }

  // Create from Map
  factory Admin.fromMap(Map<String, dynamic> map) {
    return Admin(
      id: map['id'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      profileImage: map['profileImage'],
      adminLevel: map['adminLevel'] ?? 'admin',
      permissions: List<String>.from(map['permissions'] ?? []),
      emailVerified: map['emailVerified'] ?? false,
      isActive: map['isActive'] ?? true,
      isDeleted: map['isDeleted'],
      createdAt: map['createdAt'] is Timestamp 
          ? (map['createdAt'] as Timestamp).toDate()
          : map['createdAt'] ?? DateTime.now(),
      updatedAt: map['updatedAt'] is Timestamp 
          ? (map['updatedAt'] as Timestamp).toDate()
          : map['updatedAt'] ?? DateTime.now(),
      createdBy: map['createdBy'],
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
      lastLoginAt: map['lastLoginAt'] is Timestamp 
          ? (map['lastLoginAt'] as Timestamp).toDate()
          : map['lastLoginAt'],
    );
  }

  // CopyWith method for easy updates
  Admin copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? profileImage,
    String? adminLevel,
    List<String>? permissions,
    bool? emailVerified,
    bool? isActive,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? suspensionReason,
    DateTime? suspendedAt,
    String? suspendedBy,
    DateTime? reactivatedAt,
    String? reactivatedBy,
    DateTime? deletedAt,
    String? deletedBy,
    String? updatedBy,
    DateTime? lastLoginAt,
  }) {
    return Admin(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      adminLevel: adminLevel ?? this.adminLevel,
      permissions: permissions ?? this.permissions,
      emailVerified: emailVerified ?? this.emailVerified,
      isActive: isActive ?? this.isActive,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      suspensionReason: suspensionReason ?? this.suspensionReason,
      suspendedAt: suspendedAt ?? this.suspendedAt,
      suspendedBy: suspendedBy ?? this.suspendedBy,
      reactivatedAt: reactivatedAt ?? this.reactivatedAt,
      reactivatedBy: reactivatedBy ?? this.reactivatedBy,
      deletedAt: deletedAt ?? this.deletedAt,
      deletedBy: deletedBy ?? this.deletedBy,
      updatedBy: updatedBy ?? this.updatedBy,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  // Getter for formatted admin level display
  String get formattedAdminLevel {
    return adminLevel.replaceAll('_', ' ').split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  // Getter for status display
  String get status {
    if (isDeleted == true) return 'Deleted';
    if (!isActive && suspensionReason != null) return 'Suspended';
    if (!isActive) return 'Inactive';
    if (!emailVerified) return 'Unverified';
    return 'Active';
  }

  // Check if admin has specific permission
  bool hasPermission(String permission) {
    if (adminLevel == 'super_admin') return true;
    return permissions.contains(permission);
  }

  // Check if admin can manage other admins
  bool get canManageAdmins {
    return adminLevel == 'super_admin' || hasPermission('manage_admins');
  }

  // Check if admin can approve organizers
  bool get canApproveOrganizers {
    return adminLevel == 'super_admin' || hasPermission('approve_organizers');
  }

  // Check if admin can manage events
  bool get canManageEvents {
    return adminLevel == 'super_admin' || hasPermission('manage_events');
  }

  // Check if admin can view analytics
  bool get canViewAnalytics {
    return adminLevel == 'super_admin' || hasPermission('view_analytics');
  }

  @override
  String toString() {
    return 'Admin(id: $id, fullName: $fullName, email: $email, adminLevel: $adminLevel, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Admin && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}