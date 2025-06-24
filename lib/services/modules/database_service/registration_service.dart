import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:megavent/models/event.dart';

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
      final doc = await _firestore
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

      // Get event to check capacity
      final doc = await _firestore.collection('events').doc(eventId).get();
      if (!doc.exists) {
        throw Exception('Event not found');
      }

      final event = Event.fromFirestore(doc);
      if (!event.hasAvailableSpots) {
        throw Exception('Event is full');
      }

      // Use batch write for consistency
      final batch = _firestore.batch();

      // Add registration record
      final registrationRef = _firestore.collection('registrations').doc();
      batch.set(registrationRef, {
        'userId': uid,
        'eventId': eventId,
        'registeredAt': DateTime.now(),
        'attended': false,
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

  // Mark attendee as attended
  Future<void> markAttendance(String userId, String eventId) async {
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
      final registrationSnapshot = await _firestore
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
}