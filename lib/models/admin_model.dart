import 'package:cloud_firestore/cloud_firestore.dart';

class Admin {
  final String id;
  final String fullName;
  final String adminEmail;
  final String role;
  final String? profileImage;
  final String? phone;
  final DateTime createdAt;
  final DateTime updatedAt;

  Admin({
    required this.id,
    required this.fullName,
    required this.adminEmail,
    required this.role,
    this.profileImage,
    this.phone,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Admin.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Admin(
      id: doc.id,
      fullName: data['fullName'],
      adminEmail: data['adminEmail'],
      role: data['role'],
      profileImage: data['profileImage'],
      phone: data['phone'],
      createdAt: data['createdAt'].toDate(),
      updatedAt: data['updatedAt'].toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'adminEmail': adminEmail,
      'role': role,
      'profileImage': profileImage,
      'phone': phone,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
