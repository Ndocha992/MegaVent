import 'package:cloud_firestore/cloud_firestore.dart';

class Registration {
  final String id;
  final String userId;
  final String eventId;
  final DateTime registeredAt;
  final bool attended;
  final DateTime? attendedAt;

  Registration({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.registeredAt,
    this.attended = false,
    this.attendedAt,
  });

  // Create Registration from Firestore document
  factory Registration.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Registration(
      id: doc.id,
      userId: data['userId'] ?? '',
      eventId: data['eventId'] ?? '',
      registeredAt: (data['registeredAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      attended: data['attended'] ?? false,
      attendedAt: (data['attendedAt'] as Timestamp?)?.toDate(),
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
    };
  }

  // Create a copy with updated fields
  Registration copyWith({
    String? id,
    String? userId,
    String? eventId,
    DateTime? registeredAt,
    bool? attended,
    DateTime? attendedAt,
  }) {
    return Registration(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      eventId: eventId ?? this.eventId,
      registeredAt: registeredAt ?? this.registeredAt,
      attended: attended ?? this.attended,
      attendedAt: attendedAt ?? this.attendedAt,
    );
  }

  @override
  String toString() {
    return 'Registration(id: $id, userId: $userId, eventId: $eventId, registeredAt: $registeredAt, attended: $attended, attendedAt: $attendedAt)';
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
        other.attendedAt == attendedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        eventId.hashCode ^
        registeredAt.hashCode ^
        attended.hashCode ^
        attendedAt.hashCode;
  }
}