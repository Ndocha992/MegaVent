import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:megavent/models/attendee.dart';
import 'package:megavent/models/event.dart';

class AttendeeService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final ChangeNotifier _notifier;

  AttendeeService(this._firestore, this._auth, this._notifier);

  /**
   * ====== ATTENDEE METHODS ======
   */

  // Get latest attendees for current organizer's events (returns Attendee objects)
  Future<List<Attendee>> getLatestAttendees() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // First get all events by this organizer
      final eventsSnapshot =
          await _firestore
              .collection('events')
              .where('organizerId', isEqualTo: user.uid)
              .get();

      if (eventsSnapshot.docs.isEmpty) {
        return [];
      }

      final eventIds = eventsSnapshot.docs.map((doc) => doc.id).toList();

      // Get registrations for these events
      final registrationsSnapshot =
          await _firestore
              .collection('registrations')
              .where('eventId', whereIn: eventIds)
              .orderBy('registeredAt', descending: true)
              .limit(10)
              .get();

      List<Attendee> attendees = [];

      for (final regDoc in registrationsSnapshot.docs) {
        final regData = regDoc.data();
        final userId = regData['userId'];
        final eventId = regData['eventId'];

        try {
          // Get user details
          final userDoc =
              await _firestore.collection('attendees').doc(userId).get();
          if (!userDoc.exists) continue;

          final userData = userDoc.data() as Map<String, dynamic>;

          // Get event details
          final eventDoc =
              await _firestore.collection('events').doc(eventId).get();
          if (!eventDoc.exists) continue;

          final eventData = eventDoc.data() as Map<String, dynamic>;

          // Create Attendee object
          final attendee = Attendee(
            id: userId,
            fullName: userData['fullName'] ?? userData['name'] ?? 'Unknown',
            email: userData['email'] ?? '',
            phone: userData['phone'] ?? '',
            profileImage: userData['profileImage'],
            eventId: eventId,
            eventName: eventData['name'] ?? '',
            qrCode: regData['qrCode'] ?? '',
            hasAttended: regData['attended'] ?? false,
            isApproved: regData['isApproved'] ?? true,
            createdAt:
                (userData['createdAt'] as Timestamp?)?.toDate() ??
                DateTime.now(),
            updatedAt:
                (userData['updatedAt'] as Timestamp?)?.toDate() ??
                DateTime.now(),
            registeredAt:
                (regData['registeredAt'] as Timestamp?)?.toDate() ??
                DateTime.now(),
          );

          attendees.add(attendee);
        } catch (e) {
          // Skip this attendee if there's an error fetching details
          continue;
        }
      }

      return attendees.take(5).toList();
    } catch (e) {
      // Return empty list if there's an error
      return [];
    }
  }

  // Get all attendees for current organizer's events (returns Attendee objects)
  Future<List<Attendee>> getAllAttendees() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Get all events by this organizer
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

      List<Attendee> attendees = [];

      for (final regDoc in registrationsSnapshot.docs) {
        final regData = regDoc.data();
        final userId = regData['userId'];
        final eventId = regData['eventId'];

        try {
          // Get user details
          final userDoc =
              await _firestore.collection('attendees').doc(userId).get();
          if (!userDoc.exists) continue;

          final userData = userDoc.data() as Map<String, dynamic>;

          // Get event details
          final eventDoc =
              await _firestore.collection('events').doc(eventId).get();
          if (!eventDoc.exists) continue;

          final eventData = eventDoc.data() as Map<String, dynamic>;

          // Create Attendee object
          final attendee = Attendee(
            id: userId,
            fullName: userData['fullName'] ?? userData['name'] ?? 'Unknown',
            email: userData['email'] ?? '',
            phone: userData['phone'] ?? '',
            profileImage: userData['profileImage'],
            eventId: eventId,
            eventName: eventData['name'] ?? '',
            qrCode: regData['qrCode'] ?? '',
            hasAttended: regData['attended'] ?? false,
            isApproved: regData['isApproved'] ?? true,
            createdAt:
                (userData['createdAt'] as Timestamp?)?.toDate() ??
                DateTime.now(),
            updatedAt:
                (userData['updatedAt'] as Timestamp?)?.toDate() ??
                DateTime.now(),
            registeredAt:
                (regData['registeredAt'] as Timestamp?)?.toDate() ??
                DateTime.now(),
          );

          attendees.add(attendee);
        } catch (e) {
          continue;
        }
      }

      return attendees;
    } catch (e) {
      throw Exception('Failed to get attendees: $e');
    }
  }

  // Get attendees for a specific event (returns Attendee objects)
  Future<List<Attendee>> getEventAttendees(String eventId) async {
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
          'Unauthorized: You can only view attendees for your own events',
        );
      }

      // Get registrations for this event
      final registrationsSnapshot =
          await _firestore
              .collection('registrations')
              .where('eventId', isEqualTo: eventId)
              .orderBy('registeredAt', descending: true)
              .get();

      List<Attendee> attendees = [];

      for (final regDoc in registrationsSnapshot.docs) {
        final regData = regDoc.data();
        final userId = regData['userId'];

        try {
          // Get user details
          final userDoc =
              await _firestore.collection('attendees').doc(userId).get();
          if (!userDoc.exists) continue;

          final userData = userDoc.data() as Map<String, dynamic>;

          // Create Attendee object
          final attendee = Attendee(
            id: userId,
            fullName: userData['fullName'] ?? userData['name'] ?? 'Unknown',
            email: userData['email'] ?? '',
            phone: userData['phone'] ?? '',
            profileImage: userData['profileImage'],
            eventId: eventId,
            eventName: eventData['name'] ?? '',
            qrCode: regData['qrCode'] ?? '',
            hasAttended: regData['attended'] ?? false,
            isApproved: regData['isApproved'] ?? true,
            createdAt:
                (userData['createdAt'] as Timestamp?)?.toDate() ??
                DateTime.now(),
            updatedAt:
                (userData['updatedAt'] as Timestamp?)?.toDate() ??
                DateTime.now(),
            registeredAt:
                (regData['registeredAt'] as Timestamp?)?.toDate() ??
                DateTime.now(),
          );

          attendees.add(attendee);
        } catch (e) {
          continue;
        }
      }

      return attendees;
    } catch (e) {
      throw Exception('Failed to get event attendees: $e');
    }
  }

  // Stream attendees for a specific event (for real-time updates)
  Stream<List<Attendee>> streamEventAttendees(String eventId) {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('registrations')
        .where('eventId', isEqualTo: eventId)
        .orderBy('registeredAt', descending: true)
        .snapshots()
        .asyncMap((registrationsSnapshot) async {
          List<Attendee> attendees = [];

          for (final regDoc in registrationsSnapshot.docs) {
            final regData = regDoc.data();
            final userId = regData['userId'];

            try {
              // Get user details
              final userDoc =
                  await _firestore.collection('attendees').doc(userId).get();
              if (!userDoc.exists) continue;

              final userData = userDoc.data() as Map<String, dynamic>;

              // Get event details
              final eventDoc =
                  await _firestore.collection('events').doc(eventId).get();
              if (!eventDoc.exists) continue;

              final eventData = eventDoc.data() as Map<String, dynamic>;

              // Create Attendee object
              final attendee = Attendee(
                id: userId,
                fullName: userData['fullName'] ?? userData['name'] ?? 'Unknown',
                email: userData['email'] ?? '',
                phone: userData['phone'] ?? '',
                profileImage: userData['profileImage'],
                eventId: eventId,
                eventName: eventData['name'] ?? '',
                qrCode: regData['qrCode'] ?? '',
                hasAttended: regData['attended'] ?? false,
                isApproved: regData['isApproved'] ?? true,
                createdAt:
                    (userData['createdAt'] as Timestamp?)?.toDate() ??
                    DateTime.now(),
                updatedAt:
                    (userData['updatedAt'] as Timestamp?)?.toDate() ??
                    DateTime.now(),
                registeredAt:
                    (regData['registeredAt'] as Timestamp?)?.toDate() ??
                    DateTime.now(),
              );

              attendees.add(attendee);
            } catch (e) {
              continue;
            }
          }

          return attendees;
        });
  }

  // Legacy methods for backward compatibility (returning Map format)
  Future<List<Map<String, dynamic>>> getLatestAttendeesAsMap() async {
    final attendees = await getLatestAttendees();
    return attendees
        .map(
          (attendee) => {
            'id': attendee.id,
            'name': attendee.fullName,
            'email': attendee.email,
            'phone': attendee.phone,
            'profileImage': attendee.profileImage,
            'eventName': attendee.eventName,
            'eventId': attendee.eventId,
            'registeredAt': attendee.registeredAt,
            'attended': attendee.hasAttended,
          },
        )
        .toList();
  }

  Future<List<Map<String, dynamic>>> getAllAttendeesAsMap() async {
    final attendees = await getAllAttendees();
    return attendees
        .map(
          (attendee) => {
            'id': attendee.id,
            'name': attendee.fullName,
            'email': attendee.email,
            'phone': attendee.phone,
            'profileImage': attendee.profileImage,
            'eventName': attendee.eventName,
            'eventId': attendee.eventId,
            'registeredAt': attendee.registeredAt,
            'attended': attendee.hasAttended,
          },
        )
        .toList();
  }

  Future<List<Map<String, dynamic>>> getEventAttendeesAsMap(
    String eventId,
  ) async {
    final attendees = await getEventAttendees(eventId);
    return attendees
        .map(
          (attendee) => {
            'id': attendee.id,
            'name': attendee.fullName,
            'email': attendee.email,
            'phone': attendee.phone,
            'profileImage': attendee.profileImage,
            'registeredAt': attendee.registeredAt,
            'attended': attendee.hasAttended,
            'attendedAt':
                null, // You might want to add this field to the Attendee model
          },
        )
        .toList();
  }

  /**
 * ====== ATTENDEE-SPECIFIC METHODS ======
 */

  // Get attendee records for a specific user
  Future<List<Attendee>> getAttendeeRecords(String userId) async {
    try {
      final snapshot =
          await _firestore
              .collection('attendees')
              .where('userId', isEqualTo: userId)
              .orderBy('registeredAt', descending: true)
              .get();

      return snapshot.docs.map((doc) => Attendee.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get attendee records: $e');
    }
  }

  // Stream attendee records for real-time updates
  Stream<List<Attendee>> streamAttendeeRecords(String userId) {
    return _firestore
        .collection('attendees')
        .where('userId', isEqualTo: userId)
        .orderBy('registeredAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Attendee.fromFirestore(doc)).toList(),
        );
  }

  // Get events that the user is registered for
  Future<List<Event>> getMyRegisteredEvents(String userId) async {
    try {
      // First get all attendee records for this user
      final attendeeRecords = await getAttendeeRecords(userId);

      if (attendeeRecords.isEmpty) {
        return [];
      }

      // Get event IDs from attendee records
      final eventIds = attendeeRecords.map((a) => a.eventId).toList();

      // Get events in batches (Firestore 'in' query limit is 10)
      List<Event> events = [];
      for (int i = 0; i < eventIds.length; i += 10) {
        final batch = eventIds.skip(i).take(10).toList();
        final snapshot =
            await _firestore
                .collection('events')
                .where(FieldPath.documentId, whereIn: batch)
                .get();

        events.addAll(
          snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList(),
        );
      }

      return events;
    } catch (e) {
      throw Exception('Failed to get registered events: $e');
    }
  }

  // Stream registered events for real-time updates
  Stream<List<Event>> streamMyRegisteredEvents(String userId) {
    return streamAttendeeRecords(userId).asyncMap((attendeeRecords) async {
      if (attendeeRecords.isEmpty) {
        return <Event>[];
      }

      final eventIds = attendeeRecords.map((a) => a.eventId).toList();

      // Get events in batches
      List<Event> events = [];
      for (int i = 0; i < eventIds.length; i += 10) {
        final batch = eventIds.skip(i).take(10).toList();
        final snapshot =
            await _firestore
                .collection('events')
                .where(FieldPath.documentId, whereIn: batch)
                .get();

        events.addAll(
          snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList(),
        );
      }

      return events;
    });
  }
}
