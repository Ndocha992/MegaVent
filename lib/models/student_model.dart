import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  final String id;
  final String fullName;
  final String universityEmail;
  final String studentId;
  final String phone;
  final String course;
  final double yearOfStudy;
  final String? profileImage;
  final bool verified;
  final DateTime? verifiedAt;
  final Map<String, dynamic>? identificationImages;
  final String mpesaPhone;
  final String institutionName;
  final bool hasActiveLoan;
  final Map<String, dynamic>? guarantorDetails;
  final DateTime createdAt;
  final DateTime updatedAt;

  Student({
    required this.id,
    required this.fullName,
    required this.universityEmail,
    required this.studentId,
    required this.phone,
    required this.course,
    required this.yearOfStudy,
    this.profileImage,
    this.verified = false,
    this.verifiedAt,
    this.identificationImages,
    required this.mpesaPhone,
    required this.institutionName,
    required this.hasActiveLoan,
    this.guarantorDetails, // Updated
    required this.createdAt,
    required this.updatedAt,
  });

  factory Student.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Student(
      id: doc.id,
      fullName: data['fullName'],
      universityEmail: data['universityEmail'],
      studentId: data['studentId'],
      phone: data['phone'],
      course: data['course'],
      yearOfStudy: data['yearOfStudy'],
      profileImage: data['profileImage'],
      verified: data['verified'] ?? false,
      verifiedAt: data['verifiedAt']?.toDate(),
      identificationImages: data['identificationImages'] != null
          ? Map<String, dynamic>.from(data['identificationImages'])
          : null,
      mpesaPhone: data['mpesaPhone'],
      institutionName: data['institutionName'],
      hasActiveLoan: data['hasActiveLoan'] ?? false,
      guarantorDetails: data['guarantorDetails'] != null
          ? Map<String, dynamic>.from(data['guarantorDetails'])
          : null,
      createdAt: data['createdAt'].toDate(),
      updatedAt: data['updatedAt'].toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'universityEmail': universityEmail,
      'studentId': studentId,
      'phone': phone,
      'course': course,
      'yearOfStudy': yearOfStudy,
      'profileImage': profileImage,
      'verified': verified,
      'verifiedAt': verifiedAt,
      'identificationImages': identificationImages,
      'mpesaPhone': mpesaPhone,
      'institutionName': institutionName,
      'hasActiveLoan': hasActiveLoan,
      'guarantorDetails': guarantorDetails,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Helper method to get identification images as a list (if needed elsewhere)
  List<String> get identificationImagesList {
    if (identificationImages == null) return [];
    return identificationImages!.values
        .where((value) => value != null && value.toString().isNotEmpty)
        .map((value) => value.toString())
        .toList();
  }

  // Helper method to get specific identification images
  String? get nationalIdFront => identificationImages?['nationalIdFront'];
  String? get nationalIdBack => identificationImages?['nationalIdBack'];
  String? get studentIdFront => identificationImages?['studentIdFront'];
  String? get studentIdBack => identificationImages?['studentIdBack'];

  // Helper method to check if student has any identification images
  bool get hasIdentificationImages {
    return identificationImages != null &&
        identificationImages!.isNotEmpty &&
        identificationImages!.values
            .any((value) => value != null && value.toString().isNotEmpty);
  }

  // Helper method to count valid identification images
  int get identificationImagesCount {
    if (identificationImages == null) return 0;
    return identificationImages!.values
        .where((value) => value != null && value.toString().isNotEmpty)
        .length;
  }

  // New helper methods for guarantor details
  Map<String, dynamic>? get guarantor1Details =>
      guarantorDetails?['guarantor1'];
  Map<String, dynamic>? get guarantor2Details =>
      guarantorDetails?['guarantor2'];

  // Guarantor 1 specific getters
  String? get guarantor1Name => guarantor1Details?['fullName'];
  String? get guarantor1Phone => guarantor1Details?['phoneNumber'];
  String? get guarantor1Relationship => guarantor1Details?['relationship'];
  String? get guarantor1Email => guarantor1Details?['email'];
  String? get guarantor1IdNumber => guarantor1Details?['idNumber'];
  String? get guarantor1Occupation => guarantor1Details?['occupation'];
  String? get guarantor1Address => guarantor1Details?['physicalAddress'];
  DateTime? get guarantor1AddedAt => guarantor1Details?['addedAt']?.toDate();

  // Guarantor 2 specific getters
  String? get guarantor2Name => guarantor2Details?['fullName'];
  String? get guarantor2Phone => guarantor2Details?['phoneNumber'];
  String? get guarantor2Relationship => guarantor2Details?['relationship'];
  String? get guarantor2Email => guarantor2Details?['email'];
  String? get guarantor2IdNumber => guarantor2Details?['idNumber'];
  String? get guarantor2Occupation => guarantor2Details?['occupation'];
  String? get guarantor2Address => guarantor2Details?['physicalAddress'];
  DateTime? get guarantor2AddedAt => guarantor2Details?['addedAt']?.toDate();

  // Helper method to check if student has guarantors
  bool get hasGuarantors {
    return guarantorDetails != null && guarantorDetails!.isNotEmpty;
  }

  // Helper method to check if student has complete guarantor information
  bool get hasCompleteGuarantorInfo {
    if (guarantorDetails == null) return false;

    final g1 = guarantor1Details;
    final g2 = guarantor2Details;

    return g1 != null &&
        g1['fullName'] != null &&
        g1['phoneNumber'] != null &&
        g1['relationship'] != null &&
        g2 != null &&
        g2['fullName'] != null &&
        g2['phoneNumber'] != null &&
        g2['relationship'] != null;
  }

  // Helper method to count valid guarantors
  int get guarantorCount {
    if (guarantorDetails == null) return 0;
    int count = 0;

    if (guarantor1Details != null &&
        guarantor1Details!['fullName'] != null &&
        guarantor1Details!['phoneNumber'] != null) {
      count++;
    }

    if (guarantor2Details != null &&
        guarantor2Details!['fullName'] != null &&
        guarantor2Details!['phoneNumber'] != null) {
      count++;
    }

    return count;
  }

  // Helper method to get all guarantor contact numbers
  List<String> get guarantorContacts {
    List<String> contacts = [];
    if (guarantor1Phone != null && guarantor1Phone!.isNotEmpty) {
      contacts.add(guarantor1Phone!);
    }
    if (guarantor2Phone != null && guarantor2Phone!.isNotEmpty) {
      contacts.add(guarantor2Phone!);
    }
    return contacts;
  }
}
