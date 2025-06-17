import 'package:cloud_firestore/cloud_firestore.dart';

class Admin {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String? profileImage;
  final String adminLevel; // 'super_admin', 'admin', 'moderator'
  final List<String> permissions; // List of permissions/roles
  final bool isApproved;
  final DateTime createdAt;
  final DateTime updatedAt;

  Admin({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.profileImage,
    required this.adminLevel,
    required this.permissions,
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
      'adminLevel': adminLevel,
      'permissions': permissions,
      'isApproved': isApproved,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
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
      isApproved: data['isApproved'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
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
  Admin copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? profileImage,
    String? adminLevel,
    List<String>? permissions,
    bool? isApproved,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Admin(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      adminLevel: adminLevel ?? this.adminLevel,
      permissions: permissions ?? this.permissions,
      isApproved: isApproved ?? this.isApproved,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Getter for formatted admin level display
  String get formattedAdminLevel {
    return adminLevel
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  // Getter for status display
  String get status {
    if (!isApproved) return 'Suspended';
    if (!isApproved) return 'Inactive';
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
    return 'Admin(id: $id, fullName: $fullName, email: $email, adminLevel: $adminLevel, isApproved: $isApproved)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Admin && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
