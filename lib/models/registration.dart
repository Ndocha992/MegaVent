import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class Registration {
  final String id;
  final String userId;
  final String eventId;
  final DateTime registeredAt;
  final bool hasAttended;
  final DateTime? attendedAt;
  final String qrCode;
  final String confirmedBy;

  Registration({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.registeredAt,
    this.hasAttended = false,
    this.attendedAt,
    required this.qrCode,
    required this.confirmedBy,
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
      hasAttended: data['attended'] ?? false,
      attendedAt: (data['attendedAt'] as Timestamp?)?.toDate(),
      qrCode: data['qrCode'] ?? '',
      confirmedBy: data['confirmedBy'],
    );
  }

  // Convert Registration to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'eventId': eventId,
      'registeredAt': Timestamp.fromDate(registeredAt),
      'attended': hasAttended,
      'attendedAt': attendedAt != null ? Timestamp.fromDate(attendedAt!) : null,
      'qrCode': qrCode,
      'confirmedBy': confirmedBy,
    };
  }

  // Generate QR code data - creates a unique, secure identifier
  static String generateQRCode(
    String userId,
    String eventId,
    DateTime registeredAt,
  ) {
    final timestamp = registeredAt.millisecondsSinceEpoch.toString();
    final rawData = '$userId|$eventId|$timestamp';

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
      if (parts.length != 4) return false;

      final qrUserId = parts[0];
      final qrEventId = parts[1];
      final qrTimestamp = parts[2];
      final qrHash = parts[3];

      // Verify user and event match
      if (qrUserId != userId || qrEventId != eventId) return false;

      // Verify hash
      final rawData = '$qrUserId|$qrEventId|$qrTimestamp';
      final bytes = utf8.encode(rawData);
      final digest = sha256.convert(bytes);
      final expectedHash = digest.toString().substring(0, 16);

      return qrHash == expectedHash;
    } catch (e) {
      return false;
    }
  }

  // Extract data from QR code
  static Map<String, String>? parseQRCode(String qrCodeData) {
    try {
      final parts = qrCodeData.split('|');
      if (parts.length != 4) return null;

      return {
        'userId': parts[0],
        'eventId': parts[1],
        'timestamp': parts[2],
        'hash': parts[3],
      };
    } catch (e) {
      return null;
    }
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
      hasAttended: attended ?? this.hasAttended,
      attendedAt: attendedAt ?? this.attendedAt,
      qrCode: qrCode ?? this.qrCode,
      confirmedBy: confirmedBy ?? this.confirmedBy,
    );
  }

  @override
  String toString() {
    return 'Registration(id: $id, userId: $userId, eventId: $eventId, registeredAt: $registeredAt, attended: $hasAttended, attendedAt: $attendedAt, qrCode: $qrCode, confirmedBy: $confirmedBy)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Registration &&
        other.id == id &&
        other.userId == userId &&
        other.eventId == eventId &&
        other.registeredAt == registeredAt &&
        other.hasAttended == hasAttended &&
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
        hasAttended.hashCode ^
        attendedAt.hashCode ^
        qrCode.hashCode ^
        confirmedBy.hashCode;
  }
}
