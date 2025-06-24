import 'package:cloud_firestore/cloud_firestore.dart';

class Staff {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String? profileImage;
  final String organizerId;
  final String? organization;
  final String role;
  final String department;
  final bool isApproved;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime hiredAt;

  Staff({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.profileImage,
    required this.organizerId,
    this.organization,
    required this.role,
    required this.department,
    required this.isApproved,
    required this.createdAt,
    required this.updatedAt,
    required this.hiredAt,
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
      'role': role,
      'department': department,
      'isApproved': isApproved,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'hiredAt': hiredAt,
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
      role: data['role'] ?? '',
      department: data['department'] ?? '',
      isApproved: data['isApproved'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      hiredAt: (data['hiredAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
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
      role: map['role'] ?? '',
      department: map['department'] ?? '',
      isApproved: map['isApproved'] ?? true,
      createdAt:
          map['createdAt'] is Timestamp
              ? (map['createdAt'] as Timestamp).toDate()
              : map['createdAt'] ?? DateTime.now(),
      updatedAt:
          map['updatedAt'] is Timestamp
              ? (map['updatedAt'] as Timestamp).toDate()
              : map['updatedAt'] ?? DateTime.now(),
      hiredAt:
          map['hiredAt'] is Timestamp
              ? (map['hiredAt'] as Timestamp).toDate()
              : map['hiredAt'] ?? DateTime.now(),
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
    String? role,
    String? department,
    bool? isApproved,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? hiredAt,
  }) {
    return Staff(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      organizerId: organizerId ?? this.organizerId,
      organization: organization ?? this.organization,
      role: role ?? this.role,
      department: department ?? this.department,
      isApproved: isApproved ?? this.isApproved,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      hiredAt: hiredAt ?? this.hiredAt,
    );
  }

  // Getter for status display
  String get status {
    if (!isApproved) return 'Suspended';
    return 'Active';
  }

  // Get display name (for compatibility with fake data)
  String get name => fullName;

  // Calculate if staff is "new" (hired within the last 30 minutes)
  bool get isNew {
    final now = DateTime.now();
    final thirtyMinutesAgo = now.subtract(const Duration(minutes: 30));
    return hiredAt.isAfter(thirtyMinutesAgo);
  }

  // Helper getters similar to Event model
  bool get isActive => isApproved;
  
  String get displayName => fullName;
  
  String get initials {
    final names = fullName.trim().split(' ');
    if (names.isEmpty) return '';
    if (names.length == 1) return names[0][0].toUpperCase();
    return '${names[0][0]}${names[names.length - 1][0]}'.toUpperCase();
  }

  // Calculate tenure
  Duration get tenure => DateTime.now().difference(hiredAt);
  
  String get tenureDisplay {
    final days = tenure.inDays;
    if (days < 1) return 'Today';
    if (days < 30) return '$days days';
    if (days < 365) return '${(days / 30).floor()} months';
    return '${(days / 365).floor()} years';
  }

  @override
  String toString() {
    return 'Staff(id: $id, fullName: $fullName, email: $email, role: $role, department: $department, organizerId: $organizerId, isApproved: $isApproved)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Staff && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}