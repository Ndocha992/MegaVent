import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:megavent/models/attendee.dart';

class CheckinService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final ChangeNotifier _notifier;

  CheckinService(this._firestore, this._auth, this._notifier);

  /// Get attendee by ID and event ID
  Future<Attendee?> getAttendeeByIdAndEvent(
    String attendeeId,
    String eventId,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // First, check if this is the organizer's event
      final eventDoc = await _firestore.collection('events').doc(eventId).get();
      if (!eventDoc.exists) {
        throw Exception('Event not found');
      }

      final eventData = eventDoc.data() as Map<String, dynamic>;
      if (eventData['organizerId'] != user.uid) {
        throw Exception(
          'Unauthorized: You can only check attendees for your own events',
        );
      }

      // Check if attendee is registered for this event
      final registrationSnapshot = await _firestore
          .collection('registrations')
          .where('userId', isEqualTo: attendeeId)
          .where('eventId', isEqualTo: eventId)
          .limit(1)
          .get();

      if (registrationSnapshot.docs.isEmpty) {
        return null; // Attendee not registered for this event
      }

      final regData = registrationSnapshot.docs.first.data();

      // Get attendee details
      final attendeeDoc =
          await _firestore.collection('attendees').doc(attendeeId).get();
      if (!attendeeDoc.exists) {
        return null; // Attendee not found
      }

      final attendeeData = attendeeDoc.data() as Map<String, dynamic>;

      // Create and return Attendee object
      return Attendee(
        id: attendeeId,
        fullName: attendeeData['fullName'] ?? attendeeData['name'] ?? 'Unknown',
        email: attendeeData['email'] ?? '',
        phone: attendeeData['phone'] ?? '',
        profileImage: attendeeData['profileImage'],
        eventId: eventId,
        eventName: eventData['name'] ?? '',
        qrCode: regData['qrCode'] ?? '',
        hasAttended: regData['attended'] ?? false,
        isApproved: regData['isApproved'] ?? true,
        createdAt: (attendeeData['createdAt'] as Timestamp?)?.toDate() ??
            DateTime.now(),
        updatedAt: (attendeeData['updatedAt'] as Timestamp?)?.toDate() ??
            DateTime.now(),
        registeredAt:
            (regData['registeredAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        isCheckedIn: regData['attended'] ?? false,
        checkedInAt: (regData['attendedAt'] as Timestamp?)?.toDate(),
      );
    } catch (e) {
      throw Exception('Failed to get attendee: $e');
    }
  }

  /// Check in attendee (mark as attended)
  Future<void> checkInAttendee(String attendeeId, String eventId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Check if event belongs to current organizer
      final eventDoc = await _firestore.collection('events').doc(eventId).get();
      if (!eventDoc.exists) {
        throw Exception('Event not found');
      }

      final eventData = eventDoc.data() as Map<String, dynamic>;
      if (eventData['organizerId'] != user.uid) {
        throw Exception(
          'Unauthorized: You can only check in attendees for your own events',
        );
      }

      // Find the registration
      final registrationSnapshot = await _firestore
          .collection('registrations')
          .where('userId', isEqualTo: attendeeId)
          .where('eventId', isEqualTo: eventId)
          .limit(1)
          .get();

      if (registrationSnapshot.docs.isEmpty) {
        throw Exception('Attendee not registered for this event');
      }

      final registrationDoc = registrationSnapshot.docs.first;
      final registrationData = registrationDoc.data();

      // If already checked in, don't increment count again
      if (registrationData['attended'] == true) {
        return; // Already checked in
      }

      // Use batch write for consistency
      final batch = _firestore.batch();

      // Update registration to mark as attended
      batch.update(registrationDoc.reference, {
        'attended': true,
        'attendedAt': DateTime.now(),
        'updatedAt': DateTime.now(),
      });

      // Update event attended count
      final eventRef = _firestore.collection('events').doc(eventId);
      batch.update(eventRef, {
        'attendedCount': FieldValue.increment(1),
        'updatedAt': DateTime.now(),
      });

      await batch.commit();
      _notifier.notifyListeners();
    } catch (e) {
      throw Exception('Failed to check in attendee: $e');
    }
  }

  /// Register new attendee (for when QR code contains full info)
  Future<void> registerAttendee(Attendee attendee) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Check if event belongs to current organizer
      final eventDoc =
          await _firestore.collection('events').doc(attendee.eventId).get();
      if (!eventDoc.exists) {
        throw Exception('Event not found');
      }

      final eventData = eventDoc.data() as Map<String, dynamic>;
      if (eventData['organizerId'] != user.uid) {
        throw Exception(
          'Unauthorized: You can only register attendees for your own events',
        );
      }

      // Use batch write for consistency
      final batch = _firestore.batch();

      // Add attendee to attendees collection
      final attendeeRef = _firestore.collection('attendees').doc(attendee.id);
      batch.set(attendeeRef, {
        'fullName': attendee.fullName,
        'email': attendee.email,
        'phone': attendee.phone,
        'profileImage': attendee.profileImage,
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
      });

      // Add registration record
      final registrationRef = _firestore.collection('registrations').doc();
      batch.set(registrationRef, {
        'userId': attendee.id,
        'eventId': attendee.eventId,
        'registeredAt': attendee.registeredAt,
        'attended': attendee.hasAttended,
        'attendedAt': attendee.checkedInAt,
        'isApproved': attendee.isApproved,
        'qrCode': attendee.qrCode,
      });

      // Update event counts
      final eventRef = _firestore.collection('events').doc(attendee.eventId);
      batch.update(eventRef, {
        'registeredCount': FieldValue.increment(1),
        'attendedCount': attendee.hasAttended
            ? FieldValue.increment(1)
            : FieldValue.increment(0),
        'updatedAt': DateTime.now(),
      });

      await batch.commit();
      _notifier.notifyListeners();
    } catch (e) {
      throw Exception('Failed to register attendee: $e');
    }
  }

  /// Get attendee check-in statistics for an event
  Future<Map<String, int>> getEventCheckInStats(String eventId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Check if event belongs to current organizer
      final eventDoc = await _firestore.collection('events').doc(eventId).get();
      if (!eventDoc.exists) {
        throw Exception('Event not found');
      }

      final eventData = eventDoc.data() as Map<String, dynamic>;
      if (eventData['organizerId'] != user.uid) {
        throw Exception(
          'Unauthorized: You can only view stats for your own events',
        );
      }

      // Get all registrations for this event
      final registrationsSnapshot = await _firestore
          .collection('registrations')
          .where('eventId', isEqualTo: eventId)
          .get();

      int totalRegistered = registrationsSnapshot.docs.length;
      int checkedIn = 0;

      for (final doc in registrationsSnapshot.docs) {
        final data = doc.data();
        if (data['attended'] == true) {
          checkedIn++;
        }
      }

      return {
        'totalRegistered': totalRegistered,
        'checkedIn': checkedIn,
        'notCheckedIn': totalRegistered - checkedIn,
      };
    } catch (e) {
      throw Exception('Failed to get check-in stats: $e');
    }
  }

  /// Stream real-time check-in stats for an event
  Stream<Map<String, int>> streamEventCheckInStats(String eventId) {
    return _firestore
        .collection('registrations')
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map((snapshot) {
      int totalRegistered = snapshot.docs.length;
      int checkedIn = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        if (data['attended'] == true) {
          checkedIn++;
        }
      }

      return {
        'totalRegistered': totalRegistered,
        'checkedIn': checkedIn,
        'notCheckedIn': totalRegistered - checkedIn,
      };
    });
  }

  /// Check out attendee (mark as not attended) - useful for fixing mistakes
  Future<void> checkOutAttendee(String attendeeId, String eventId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Check if event belongs to current organizer
      final eventDoc = await _firestore.collection('events').doc(eventId).get();
      if (!eventDoc.exists) {
        throw Exception('Event not found');
      }

      final eventData = eventDoc.data() as Map<String, dynamic>;
      if (eventData['organizerId'] != user.uid) {
        throw Exception(
          'Unauthorized: You can only check out attendees for your own events',
        );
      }

      // Find the registration
      final registrationSnapshot = await _firestore
          .collection('registrations')
          .where('userId', isEqualTo: attendeeId)
          .where('eventId', isEqualTo: eventId)
          .limit(1)
          .get();

      if (registrationSnapshot.docs.isEmpty) {
        throw Exception('Attendee not registered for this event');
      }

      final registrationDoc = registrationSnapshot.docs.first;
      final registrationData = registrationDoc.data();

      // If not checked in, no need to do anything
      if (registrationData['attended'] != true) {
        return; // Already not checked in
      }

      // Use batch write for consistency
      final batch = _firestore.batch();

      // Update registration to mark as not attended
      batch.update(registrationDoc.reference, {
        'attended': false,
        'attendedAt': null,
        'updatedAt': DateTime.now(),
      });

      // Update event attended count (decrease)
      final eventRef = _firestore.collection('events').doc(eventId);
      batch.update(eventRef, {
        'attendedCount': FieldValue.increment(-1),
        'updatedAt': DateTime.now(),
      });

      await batch.commit();
      _notifier.notifyListeners();
    } catch (e) {
      throw Exception('Failed to check out attendee: $e');
    }
  }
}