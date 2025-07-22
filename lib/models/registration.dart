import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class Registration {
  final String id;
  final String userId;
  final String eventId;
  final DateTime registeredAt;
  final bool attended;
  final DateTime? attendedAt;
  final String qrCode;
  final String? confirmedBy; // Made nullable

  Registration({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.registeredAt,
    this.attended = false,
    this.attendedAt,
    required this.qrCode,
    this.confirmedBy, // Made optional
  });

  // Create Registration from Firestore document
  factory Registration.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Registration(
      id: doc.id,
      userId: data['userId'] ?? '',
      eventId: data['eventId'] ?? '',
      registeredAt:
          (data['registeredAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      attended: data['attended'] ?? false,
      attendedAt: (data['attendedAt'] as Timestamp?)?.toDate(),
      qrCode: data['qrCode'] ?? '',
      confirmedBy: data['confirmedBy'], // This can be null
    );
  }

  // Convert Registration to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'eventId': eventId,
      'registeredAt': Timestamp.fromDate(registeredAt),
      'attended': attended,
      'attendedAt': attendedAt != null ? Timestamp.fromDate(attendedAt!) : null,
      'qrCode': qrCode,
      'confirmedBy': confirmedBy, // This can be null
    };
  }

  // Generate QR code data - creates a unique, secure identifier
  static String generateQRCode(
    String userId,
    String eventId,
    DateTime registeredAt,
    String organizerId,
  ) {
    final timestamp = registeredAt.millisecondsSinceEpoch.toString();
    final rawData = '$userId|$eventId|$timestamp|$organizerId';

    // Create a hash to make it more secure and consistent length
    final bytes = utf8.encode(rawData);
    final digest = sha256.convert(bytes);

    // Combine original data with hash for verification
    return '$rawData|${digest.toString().substring(0, 16)}';
  }

  // Verify QR code data
  static bool verifyQRCode(String qrCodeData, String userId, String eventId) {
    try {
      final parts = qrCodeData.split('|');
      if (parts.length != 5) return false; // Require exactly 5 parts

      final qrUserId = parts[0];
      final qrEventId = parts[1];
      final qrTimestamp = parts[2];
      final qrOrganizerId = parts[3];
      final qrHash = parts[4];

      // Verify user and event match
      if (qrUserId != userId || qrEventId != eventId) return false;

      // Verify hash
      final rawData = '$qrUserId|$qrEventId|$qrTimestamp|$qrOrganizerId';
      final bytes = utf8.encode(rawData);
      final digest = sha256.convert(bytes);
      final expectedHash = digest.toString().substring(0, 16);

      return qrHash == expectedHash;
    } catch (e) {
      return false;
    }
  }

  static Map<String, String>? parseQRCode(String qrCodeData) {
    try {
      final parts = qrCodeData.split('|');
      if (parts.length != 5) return null; // Require exactly 5 parts

      return {
        'userId': parts[0],
        'eventId': parts[1],
        'timestamp': parts[2],
        'organizerId': parts[3],
        'hash': parts[4],
      };
    } catch (e) {
      return null;
    }
  }

  // Method to get composite ID
  static String getCompositeId(String userId, String eventId) {
    return '${userId}_$eventId';
  }

  // Create a copy with updated fields
  Registration copyWith({
    String? id,
    String? userId,
    String? eventId,
    DateTime? registeredAt,
    bool? attended,
    DateTime? attendedAt,
    String? qrCode,
    String? confirmedBy,
  }) {
    return Registration(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      eventId: eventId ?? this.eventId,
      registeredAt: registeredAt ?? this.registeredAt,
      attended: attended ?? this.attended,
      attendedAt: attendedAt ?? this.attendedAt,
      qrCode: qrCode ?? this.qrCode,
      confirmedBy: confirmedBy ?? this.confirmedBy,
    );
  }

  @override
  String toString() {
    return 'Registration(id: $id, userId: $userId, eventId: $eventId, registeredAt: $registeredAt, attended: $attended, attendedAt: $attendedAt, qrCode: $qrCode, confirmedBy: $confirmedBy)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Registration &&
        other.id == id &&
        other.userId == userId &&
        other.eventId == eventId &&
        other.registeredAt == registeredAt &&
        other.attended == attended &&
        other.attendedAt == attendedAt &&
        other.qrCode == qrCode &&
        other.confirmedBy == confirmedBy;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        eventId.hashCode ^
        registeredAt.hashCode ^
        attended.hashCode ^
        attendedAt.hashCode ^
        qrCode.hashCode ^
        confirmedBy.hashCode;
  }
}
