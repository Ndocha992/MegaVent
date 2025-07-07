import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:megavent/models/event.dart';
import 'package:megavent/models/registration.dart';

class RegistrationService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final ChangeNotifier _notifier;

  RegistrationService(this._firestore, this._auth, this._notifier);

  /**
   * ====== QR CODE & REGISTRATION METHODS ======
   */

  Future<bool> isUserRegisteredForEvent(String uid, String eventId) async {
    try {
      final doc =
          await _firestore
              .collection('registrations')
              .where('userId', isEqualTo: uid)
              .where('eventId', isEqualTo: eventId)
              .limit(1)
              .get();

      return doc.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check registration: $e');
    }
  }

  // ADD THIS NEW METHOD - Get registration by user and event
  Future<Registration?> getRegistrationByUserAndEvent(
    String userId,
    String eventId,
  ) async {
    try {
      final snapshot =
          await _firestore
              .collection('registrations')
              .where('userId', isEqualTo: userId)
              .where('eventId', isEqualTo: eventId)
              .limit(1)
              .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      return Registration.fromFirestore(snapshot.docs.first);
    } catch (e) {
      throw Exception('Failed to get registration: $e');
    }
  }

  Future<Map<String, int>> getEventCapacityInfo(String eventId) async {
    try {
      final doc = await _firestore.collection('events').doc(eventId).get();
      if (!doc.exists) {
        throw Exception('Event not found');
      }

      final event = Event.fromFirestore(doc);

      return {
        'capacity': event.capacity,
        'registered': event.registeredCount,
        'available': event.availableSpots,
      };
    } catch (e) {
      throw Exception('Failed to get capacity info: $e');
    }
  }

  Future<void> registerUserForEvent(String uid, String eventId) async {
    try {
      // Check if user is already registered
      final isRegistered = await isUserRegisteredForEvent(uid, eventId);
      if (isRegistered) {
        throw Exception('User is already registered for this event');
      }

      // Get event to check capacity and end date
      final doc = await _firestore.collection('events').doc(eventId).get();
      if (!doc.exists) {
        throw Exception('Event not found');
      }

      final event = Event.fromFirestore(doc);
      final now = DateTime.now();

      // Parse event end time
      final endTimeParts = event.endTime.split(':');
      final endHour = int.parse(endTimeParts[0]);
      final endMinute = int.parse(endTimeParts[1].split(' ')[0]);
      final isPM = event.endTime.contains('PM') && endHour != 12;

      // Create DateTime for event end
      final eventEndDateTime = DateTime(
        event.endDate.year,
        event.endDate.month,
        event.endDate.day,
        isPM ? endHour + 12 : endHour,
        endMinute,
      );

      // Check if event has ended
      if (eventEndDateTime.isBefore(now)) {
        throw Exception('Registration closed - Event has ended');
      }

      // Check capacity
      if (!event.hasAvailableSpots) {
        throw Exception('Event is full');
      }

      final registrationTime = DateTime.now();

      // Generate QR code data
      final qrCodeData = Registration.generateQRCode(
        uid,
        eventId,
        registrationTime,
      );

      // Use batch write for consistency
      final batch = _firestore.batch();

      // Add registration record with QR code
      final registrationRef = _firestore.collection('registrations').doc();
      batch.set(registrationRef, {
        'userId': uid,
        'eventId': eventId,
        'registeredAt': registrationTime,
        'attended': false,
        'qrCode': qrCodeData,
      });

      // Update event registered count
      final eventRef = _firestore.collection('events').doc(eventId);
      batch.update(eventRef, {
        'registeredCount': FieldValue.increment(1),
        'updatedAt': DateTime.now(),
      });

      await batch.commit();
      _notifier.notifyListeners();
    } catch (e) {
      throw Exception('Failed to register for event: $e');
    }
  }

  // Mark attendee as attended using QR code
  Future<void> markAttendanceByQRCode(String qrCodeData, String staffId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Parse QR code data
      final qrData = Registration.parseQRCode(qrCodeData);
      if (qrData == null) {
        throw Exception('Invalid QR code format');
      }

      final userId = qrData['userId']!;
      final eventId = qrData['eventId']!;

      // Verify QR code
      if (!Registration.verifyQRCode(qrCodeData, userId, eventId)) {
        throw Exception('Invalid or tampered QR code');
      }

      // Check if event belongs to current organizer
      final eventDoc = await _firestore.collection('events').doc(eventId).get();
      if (!eventDoc.exists) {
        throw Exception('Event not found');
      }

      final event = Event.fromFirestore(eventDoc);
      if (event.organizerId != user.uid) {
        throw Exception(
          'Unauthorized: You can only mark attendance for your own events',
        );
      }

      // Find the registration using QR code
      final registrationSnapshot =
          await _firestore
              .collection('registrations')
              .where('qrCode', isEqualTo: qrCodeData)
              .limit(1)
              .get();

      if (registrationSnapshot.docs.isEmpty) {
        throw Exception('Registration not found for this QR code');
      }

      final registrationDoc = registrationSnapshot.docs.first;
      final registrationData = registrationDoc.data();

      // If already attended, don't increment again
      if (registrationData['attended'] == true) {
        throw Exception('Attendance already marked for this user');
      }

      // Use batch write for consistency
      final batch = _firestore.batch();

      // Update registration to mark as attended
      batch.update(registrationDoc.reference, {
        'attended': true,
        'attendedAt': DateTime.now(),
        'confirmedBy': staffId,
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
      throw Exception('Failed to mark attendance: $e');
    }
  }

  // Original mark attendance method (kept for backward compatibility)
  Future<void> markAttendance(
    String userId,
    String eventId,
    String staffId,
  ) async {
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

      final event = Event.fromFirestore(eventDoc);
      if (event.organizerId != user.uid) {
        throw Exception(
          'Unauthorized: You can only mark attendance for your own events',
        );
      }

      // Find the registration
      final registrationSnapshot =
          await _firestore
              .collection('registrations')
              .where('userId', isEqualTo: userId)
              .where('eventId', isEqualTo: eventId)
              .limit(1)
              .get();

      if (registrationSnapshot.docs.isEmpty) {
        throw Exception('Registration not found');
      }

      final registrationDoc = registrationSnapshot.docs.first;
      final registrationData = registrationDoc.data();

      // If already attended, don't increment again
      if (registrationData['attended'] == true) {
        return;
      }

      // Use batch write for consistency
      final batch = _firestore.batch();

      // Update registration to mark as attended
      batch.update(registrationDoc.reference, {
        'attended': true,
        'attendedAt': DateTime.now(),
        'confirmedBy': staffId,
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
      throw Exception('Failed to mark attendance: $e');
    }
  }

  // Get registration by QR code
  Future<Registration?> getRegistrationByQRCode(String qrCodeData) async {
    try {
      final snapshot =
          await _firestore
              .collection('registrations')
              .where('qrCode', isEqualTo: qrCodeData)
              .limit(1)
              .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      return Registration.fromFirestore(snapshot.docs.first);
    } catch (e) {
      throw Exception('Failed to get registration by QR code: $e');
    }
  }

  // Get user's QR code for a specific event
  Future<String?> getUserQRCodeForEvent(String userId, String eventId) async {
    try {
      final snapshot =
          await _firestore
              .collection('registrations')
              .where('userId', isEqualTo: userId)
              .where('eventId', isEqualTo: eventId)
              .limit(1)
              .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      final registration = Registration.fromFirestore(snapshot.docs.first);
      return registration.qrCode;
    } catch (e) {
      throw Exception('Failed to get QR code: $e');
    }
  }

  /**
   * ====== USER REGISTRATION METHODS ======
   */
  Future<List<Registration>> getUserRegistrations(String userId) async {
    try {
      final snapshot =
          await _firestore
              .collection('registrations')
              .where('userId', isEqualTo: userId)
              .orderBy('registeredAt', descending: true)
              .get();

      return snapshot.docs
          .map((doc) => Registration.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user registrations: $e');
    }
  }

  Future<List<Event>> getMyRegisteredEvents(String userId) async {
    try {
      final registrations = await getUserRegistrations(userId);
      if (registrations.isEmpty) return [];

      // Get all event IDs
      final eventIds = registrations.map((reg) => reg.eventId).toSet().toList();

      // Fetch all events in a single query
      final eventsSnapshot =
          await _firestore
              .collection('events')
              .where(FieldPath.documentId, whereIn: eventIds)
              .get();

      return eventsSnapshot.docs
          .map((doc) => Event.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get registered events: $e');
    }
  }

  /**
   * ====== ORGANIZER REGISTRATION METHODS ======
   */

  // Get all registrations for current organizer's events
  Future<List<Registration>> getAllRegistrations() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Get all events by this organizer first
      final eventsSnapshot =
          await _firestore
              .collection('events')
              .where('organizerId', isEqualTo: user.uid)
              .get();

      if (eventsSnapshot.docs.isEmpty) {
        return [];
      }

      final eventIds = eventsSnapshot.docs.map((doc) => doc.id).toList();

      // Get all registrations for these events
      final registrationsSnapshot =
          await _firestore
              .collection('registrations')
              .where('eventId', whereIn: eventIds)
              .orderBy('registeredAt', descending: true)
              .get();

      return registrationsSnapshot.docs
          .map((doc) => Registration.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get all registrations: $e');
    }
  }

  // Add these methods to your RegistrationService class

  /**
   * ====== QR SCANNER SPECIFIC METHODS ======
   */

  // Get attendee by ID and event ID (returns combined attendee + registration data)
  Future<Map<String, dynamic>?> getAttendeeByIdAndEvent(
    String attendeeId,
    String eventId,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Check if event belongs to current organizer
      final eventDoc = await _firestore.collection('events').doc(eventId).get();
      if (!eventDoc.exists) {
        return null;
      }

      final eventData = eventDoc.data() as Map<String, dynamic>;
      if (eventData['organizerId'] != user.uid) {
        throw Exception('Unauthorized: Event does not belong to you');
      }

      // Get registration record
      final registrationSnapshot =
          await _firestore
              .collection('registrations')
              .where('userId', isEqualTo: attendeeId)
              .where('eventId', isEqualTo: eventId)
              .limit(1)
              .get();

      if (registrationSnapshot.docs.isEmpty) {
        return null;
      }

      final registrationData = registrationSnapshot.docs.first.data();

      // Get attendee details
      final attendeeDoc =
          await _firestore.collection('attendees').doc(attendeeId).get();
      if (!attendeeDoc.exists) {
        return null;
      }

      final attendeeData = attendeeDoc.data() as Map<String, dynamic>;

      // Return combined data
      return {
        'id': attendeeId,
        'fullName':
            attendeeData['fullName'] ?? attendeeData['name'] ?? 'Unknown',
        'email': attendeeData['email'] ?? '',
        'phone': attendeeData['phone'] ?? '',
        'profileImage': attendeeData['profileImage'],
        'isApproved': attendeeData['isApproved'] ?? true,
        'createdAt':
            attendeeData['createdAt'] != null
                ? (attendeeData['createdAt'] as Timestamp).toDate()
                : DateTime.now(),
        'updatedAt':
            attendeeData['updatedAt'] != null
                ? (attendeeData['updatedAt'] as Timestamp).toDate()
                : DateTime.now(),
        // Registration specific fields
        'hasAttended': registrationData['attended'] ?? false,
        'registeredAt':
            registrationData['registeredAt'] != null
                ? (registrationData['registeredAt'] as Timestamp).toDate()
                : DateTime.now(),
        'attendedAt':
            registrationData['attendedAt'] != null
                ? (registrationData['attendedAt'] as Timestamp).toDate()
                : null,
        'eventName': eventData['name'] ?? 'Unknown Event',
        'eventId': eventId,
        'qrCode': registrationData['qrCode'] ?? '',
      };
    } catch (e) {
      throw Exception('Failed to get attendee: $e');
    }
  }

  // Check in attendee (mark as attended)
  Future<void> checkInAttendee(
    String attendeeId,
    String eventId,
    String staffId,
  ) async {
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
      final registrationSnapshot =
          await _firestore
              .collection('registrations')
              .where('userId', isEqualTo: attendeeId)
              .where('eventId', isEqualTo: eventId)
              .limit(1)
              .get();

      if (registrationSnapshot.docs.isEmpty) {
        throw Exception('Registration not found');
      }

      final registrationDoc = registrationSnapshot.docs.first;
      final registrationData = registrationDoc.data();

      // If already attended, don't increment again
      if (registrationData['attended'] == true) {
        return;
      }

      // Use batch write for consistency
      final batch = _firestore.batch();

      // Update registration to mark as attended
      batch.update(registrationDoc.reference, {
        'attended': true,
        'attendedAt': DateTime.now(),
        'confirmedBy': staffId,
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

  /**
   * ====== UNREGISTRATION METHOD ======
   */
  Future<void> unregisterUserFromEvent(String uid, String eventId) async {
    try {
      // Check if user is registered for the event
      final registrationSnapshot =
          await _firestore
              .collection('registrations')
              .where('userId', isEqualTo: uid)
              .where('eventId', isEqualTo: eventId)
              .limit(1)
              .get();

      if (registrationSnapshot.docs.isEmpty) {
        throw Exception('Registration not found for this event');
      }

      final registrationDoc = registrationSnapshot.docs.first;
      final registrationData = registrationDoc.data();

      // Get event to update counts
      final eventDoc = await _firestore.collection('events').doc(eventId).get();
      if (!eventDoc.exists) {
        throw Exception('Event not found');
      }

      // Use batch write for consistency
      final batch = _firestore.batch();

      // Delete the registration record
      batch.delete(registrationDoc.reference);

      // Update event registered count
      final eventRef = _firestore.collection('events').doc(eventId);
      batch.update(eventRef, {
        'registeredCount': FieldValue.increment(-1),
        'updatedAt': DateTime.now(),
      });

      // If user had attended, also decrement attended count
      if (registrationData['attended'] == true) {
        batch.update(eventRef, {'attendedCount': FieldValue.increment(-1)});
      }

      await batch.commit();
      _notifier.notifyListeners();
    } catch (e) {
      throw Exception('Failed to unregister from event: $e');
    }
  }
}
