import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:megavent/models/attendee.dart';
import 'package:megavent/models/attendee_stats.dart';
import 'package:megavent/models/registration.dart';

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

          // Composite ID format
          final compositeId = Registration.getCompositeId(userId, eventId);

          // Create Attendee object with unique ID combining userId and eventId
          final attendee = Attendee(
            id: compositeId,
            fullName: userData['fullName'] ?? userData['name'] ?? 'Unknown',
            email: userData['email'] ?? '',
            phone: userData['phone'] ?? '',
            profileImage: userData['profileImage'],
            isApproved: regData['isApproved'] ?? true,
            createdAt:
                (userData['createdAt'] as Timestamp?)?.toDate() ??
                DateTime.now(),
            updatedAt:
                (userData['updatedAt'] as Timestamp?)?.toDate() ??
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
  // FIXED: This now returns one Attendee object per registration (not per user)
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

          // Composite ID format
          final compositeId = Registration.getCompositeId(userId, eventId);

          // Create Attendee object with unique ID combining userId and eventId
          // This ensures each registration creates a separate attendee entry
          final attendee = Attendee(
            id: compositeId,
            fullName: userData['fullName'] ?? userData['name'] ?? 'Unknown',
            email: userData['email'] ?? '',
            phone: userData['phone'] ?? '',
            profileImage: userData['profileImage'],
            isApproved: regData['isApproved'] ?? true,
            createdAt:
                (userData['createdAt'] as Timestamp?)?.toDate() ??
                DateTime.now(),
            updatedAt:
                (userData['updatedAt'] as Timestamp?)?.toDate() ??
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

          // Composite ID format
          final compositeId = Registration.getCompositeId(userId, eventId);

          // Create Attendee object with unique ID
          final attendee = Attendee(
            id: compositeId,
            fullName: userData['fullName'] ?? userData['name'] ?? 'Unknown',
            email: userData['email'] ?? '',
            phone: userData['phone'] ?? '',
            profileImage: userData['profileImage'],
            isApproved: regData['isApproved'] ?? true,
            createdAt:
                (userData['createdAt'] as Timestamp?)?.toDate() ??
                DateTime.now(),
            updatedAt:
                (userData['updatedAt'] as Timestamp?)?.toDate() ??
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

              // Composite ID format
              final compositeId = Registration.getCompositeId(userId, eventId);

              // Create Attendee object with unique ID
              final attendee = Attendee(
                id: compositeId,
                fullName: userData['fullName'] ?? userData['name'] ?? 'Unknown',
                email: userData['email'] ?? '',
                phone: userData['phone'] ?? '',
                profileImage: userData['profileImage'],
                isApproved: regData['isApproved'] ?? true,
                createdAt:
                    (userData['createdAt'] as Timestamp?)?.toDate() ??
                    DateTime.now(),
                updatedAt:
                    (userData['updatedAt'] as Timestamp?)?.toDate() ??
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
          },
        )
        .toList();
  }

  /**
 * ====== USER ATTENDEE RECORDS METHOD ======
 */
  Future<List<Map<String, dynamic>>> getAttendeeRecords(String userId) async {
    try {
      final snapshot =
          await _firestore
              .collection('registrations')
              .where('userId', isEqualTo: userId)
              .where('attended', isEqualTo: true)
              .orderBy('attendedAt', descending: true)
              .get();

      List<Map<String, dynamic>> attendeeRecords = [];

      for (final doc in snapshot.docs) {
        final registrationData = doc.data();
        final eventId = registrationData['eventId'];

        try {
          // Get event details
          final eventDoc =
              await _firestore.collection('events').doc(eventId).get();
          if (!eventDoc.exists) continue;

          final eventData = eventDoc.data() as Map<String, dynamic>;

          // Get attendee details
          final attendeeDoc =
              await _firestore.collection('attendees').doc(userId).get();
          if (!attendeeDoc.exists) continue;

          final attendeeData = attendeeDoc.data() as Map<String, dynamic>;

          // Create attendee record combining all three models
          final attendeeRecord = {
            'registrationId': doc.id,
            'userId': userId,
            'eventId': eventId,
            'eventName': eventData['name'] ?? 'Unknown Event',
            'eventDescription': eventData['description'] ?? '',
            'eventLocation': eventData['location'] ?? '',
            'eventDate':
                eventData['date'] != null
                    ? (eventData['date'] as Timestamp).toDate()
                    : null,
            // From Registration model
            'hasAttended': registrationData['attended'] ?? false,
            'registeredAt':
                registrationData['registeredAt'] != null
                    ? (registrationData['registeredAt'] as Timestamp).toDate()
                    : DateTime.now(),
            'attendedAt':
                registrationData['attendedAt'] != null
                    ? (registrationData['attendedAt'] as Timestamp).toDate()
                    : null,
            // From Attendee model
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
          };

          attendeeRecords.add(attendeeRecord);
        } catch (e) {
          // Skip this record if there's an error fetching details
          continue;
        }
      }

      return attendeeRecords;
    } catch (e) {
      throw Exception('Failed to get attendee records: $e');
    }
  }

  /**
 * ====== CURRENT USER ATTENDEE DATA METHODS ======
 */

  // Stream current user's attendee data
  Stream<Attendee?> streamAttendeeData() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value(null);
    }

    return _firestore.collection('attendees').doc(user.uid).snapshots().map((
      snapshot,
    ) {
      if (!snapshot.exists) {
        return null;
      }

      final data = snapshot.data() as Map<String, dynamic>;
      return Attendee(
        id: user.uid,
        fullName: data['fullName'] ?? data['name'] ?? 'Unknown',
        email: data['email'] ?? '',
        phone: data['phone'] ?? '',
        profileImage: data['profileImage'],
        isApproved: data['isApproved'] ?? true,
        createdAt:
            (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        updatedAt:
            (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    });
  }

  // Get current user's attendee data (one-time fetch)
  Future<Attendee?> getCurrentAttendeeData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return null;
      }

      final snapshot =
          await _firestore.collection('attendees').doc(user.uid).get();

      if (!snapshot.exists) {
        return null;
      }

      final data = snapshot.data() as Map<String, dynamic>;
      return Attendee(
        id: user.uid,
        fullName: data['fullName'] ?? data['name'] ?? 'Unknown',
        email: data['email'] ?? '',
        phone: data['phone'] ?? '',
        profileImage: data['profileImage'],
        isApproved: data['isApproved'] ?? true,
        createdAt:
            (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        updatedAt:
            (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to get current attendee data: $e');
    }
  }

  // Update attendee profile
  Future<void> updateAttendeeProfile(Attendee attendee) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      await _firestore.collection('attendees').doc(user.uid).update({
        'fullName': attendee.fullName,
        'email': attendee.email,
        'phone': attendee.phone,
        'profileImage': attendee.profileImage,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _notifier.notifyListeners();
    } catch (e) {
      throw Exception('Failed to update attendee profile: $e');
    }
  }

  // Update specific fields of attendee profile
  Future<void> updateAttendeeProfileFields(
    String attendeeId,
    Map<String, dynamic> fields,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Add updatedAt timestamp
      fields['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('attendees').doc(attendeeId).update(fields);
      _notifier.notifyListeners();
    } catch (e) {
      throw Exception('Failed to update attendee profile fields: $e');
    }
  }

  // Get attendee's personal stats
  Future<AttendeeStats> getAttendeePersonalStats(String userId) async {
    try {
      // Get all registrations for this user
      final registrationsSnapshot =
          await _firestore
              .collection('registrations')
              .where('userId', isEqualTo: userId)
              .get();

      int registeredEvents = registrationsSnapshot.docs.length;
      int attendedEvents = 0;
      int upcomingEvents = 0;
      int notAttendedEvents = 0;

      final now = DateTime.now();

      for (final regDoc in registrationsSnapshot.docs) {
        final regData = regDoc.data();
        final eventId = regData['eventId'];
        final hasAttended = regData['attended'] ?? false;

        try {
          // Get event details to check if it's upcoming or past
          final eventDoc =
              await _firestore.collection('events').doc(eventId).get();
          if (!eventDoc.exists) continue;

          final eventData = eventDoc.data() as Map<String, dynamic>;
          final eventDate = (eventData['date'] as Timestamp?)?.toDate();

          if (eventDate != null) {
            if (eventDate.isAfter(now)) {
              upcomingEvents++;
            } else {
              if (hasAttended) {
                attendedEvents++;
              } else {
                notAttendedEvents++;
              }
            }
          }
        } catch (e) {
          continue;
        }
      }

      return AttendeeStats(
        registeredEvents: registeredEvents,
        attendedEvents: attendedEvents,
        notAttendedEvents: notAttendedEvents,
        upcomingEvents: upcomingEvents,
      );
    } catch (e) {
      throw Exception('Failed to get attendee personal stats: $e');
    }
  }

  Future<List<Attendee>> getStaffAttendees(String staffId) async {
    try {
      final registrationsSnapshot =
          await _firestore
              .collection('registrations')
              .where('confirmedBy', isEqualTo: staffId)
              .orderBy('attendedAt', descending: true)
              .limit(5)
              .get();

      List<Attendee> attendees = [];

      for (final regDoc in registrationsSnapshot.docs) {
        final regData = regDoc.data();
        final userId = regData['userId'];

        final userDoc =
            await _firestore.collection('attendees').doc(userId).get();
        if (userDoc.exists) {
          attendees.add(Attendee.fromFirestore(userDoc));
        }
      }

      return attendees;
    } catch (e) {
      throw Exception('Failed to get staff attendees: $e');
    }
  }
}
