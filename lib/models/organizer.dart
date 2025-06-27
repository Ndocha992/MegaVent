import 'package:cloud_firestore/cloud_firestore.dart';

class Organizer {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String? organization;
  final String? profileImage;
  final String? jobTitle;
  final String? bio;
  final String? website;
  final String? address;
  final String? city;
  final String? country;
  final bool isApproved;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int totalEvents;
  final int totalAttendees;

  Organizer({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.organization,
    this.profileImage,
    this.jobTitle,
    this.bio,
    this.website,
    this.address,
    this.city,
    this.country,
    required this.isApproved,
    required this.createdAt,
    required this.updatedAt,
    this.totalEvents = 0,
    this.totalAttendees = 0,
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
      'jobTitle': jobTitle,
      'bio': bio,
      'website': website,
      'address': address,
      'city': city,
      'country': country,
      'isApproved': isApproved,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'totalEvents': totalEvents,
      'totalAttendees': totalAttendees,
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
      jobTitle: data['jobTitle'],
      bio: data['bio'],
      website: data['website'],
      address: data['address'],
      city: data['city'],
      country: data['country'],
      isApproved: data['isApproved'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      totalEvents: data['totalEvents'] ?? 0,
      totalAttendees: data['totalAttendees'] ?? 0,
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
      jobTitle: map['jobTitle'],
      bio: map['bio'],
      website: map['website'],
      address: map['address'],
      city: map['city'],
      country: map['country'],
      isApproved: map['isApproved'] ?? false,
      createdAt:
          map['createdAt'] is Timestamp
              ? (map['createdAt'] as Timestamp).toDate()
              : map['createdAt'] ?? DateTime.now(),
      updatedAt:
          map['updatedAt'] is Timestamp
              ? (map['updatedAt'] as Timestamp).toDate()
              : map['updatedAt'] ?? DateTime.now(),
      totalEvents: map['totalEvents'] ?? 0,
      totalAttendees: map['totalAttendees'] ?? 0,
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
    String? jobTitle,
    String? bio,
    String? website,
    String? address,
    String? city,
    String? country,
    bool? isApproved,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? totalEvents,
    int? totalAttendees,
  }) {
    return Organizer(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      organization: organization ?? this.organization,
      profileImage: profileImage ?? this.profileImage,
      jobTitle: jobTitle ?? this.jobTitle,
      bio: bio ?? this.bio,
      website: website ?? this.website,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
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

  // Getter for full address
  String get fullAddress {
    List<String> addressParts = [];
    if (address != null && address!.isNotEmpty) addressParts.add(address!);
    if (city != null && city!.isNotEmpty) addressParts.add(city!);
    if (country != null && country!.isNotEmpty) addressParts.add(country!);
    return addressParts.join(', ');
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
