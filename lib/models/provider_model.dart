import 'package:cloud_firestore/cloud_firestore.dart';

class Provider {
  final String id;
  final String businessName;
  final String businessEmail;
  final String phone;
  final String businessType;
  final List<String> loanTypes;
  final String? website;
  final String? description;
  final double interestRate;
  final String? profileImage;
  final bool verified;
  final DateTime? verifiedAt;
  final Map<String, dynamic>? identificationImages;
  final DateTime createdAt;
  final DateTime updatedAt;

  Provider({
    required this.id,
    required this.businessName,
    required this.businessEmail,
    required this.phone,
    required this.businessType,
    required this.loanTypes,
    this.website,
    this.description,
    required this.interestRate,
    this.profileImage,
    this.verified = false,
    this.verifiedAt,
    this.identificationImages,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Provider.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Provider(
      id: doc.id,
      businessName: data['businessName'] ?? '',
      businessEmail: data['businessEmail'] ?? '',
      phone: data['phone'] ?? '',
      businessType: data['businessType'] ?? '',
      loanTypes: data['loanTypes'] != null
          ? List<String>.from(data['loanTypes'])
          : <String>[], // Ensure empty list instead of null
      website: data['website'],
      description: data['description'],
      interestRate: (data['interestRate'] ?? 0).toDouble(),
      profileImage: data['profileImage'],
      verified: data['verified'] ?? false,
      verifiedAt: data['verifiedAt']?.toDate(),
      identificationImages: data['identificationImages'] != null
          ? Map<String, dynamic>.from(data['identificationImages'])
          : null,
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: data['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'businessName': businessName,
      'businessEmail': businessEmail,
      'phone': phone,
      'businessType': businessType,
      'loanTypes': loanTypes,
      'website': website,
      'description': description,
      'interestRate': interestRate,
      'profileImage': profileImage,
      'verified': verified,
      'verifiedAt': verifiedAt,
      'identificationImages': identificationImages,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
