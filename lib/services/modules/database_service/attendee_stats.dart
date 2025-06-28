import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:megavent/models/attendee.dart';
import 'package:megavent/models/attendee_stats.dart';

class AttendeeStatsService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final ChangeNotifier _notifier;

  AttendeeStatsService(this._firestore, this._auth, this._notifier);

  /**
   * ====== ATTENDEE STATS METHODS ======
   */

  // Get comprehensive attendee statistics for current organizer
  Future<OrganizerAttendeeStats> getAttendeeStats() async {
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
        return OrganizerAttendeeStats.empty();
      }

      final eventIds = eventsSnapshot.docs.map((doc) => doc.id).toList();

      // Get all registrations for these events
      final registrationsSnapshot =
          await _firestore
              .collection('registrations')
              .where('eventId', whereIn: eventIds)
              .get();

      List<Attendee> attendees = [];

      // Build attendee objects from registrations
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

      // Generate stats from attendees list
      return OrganizerAttendeeStats.fromAttendeesList(attendees);
    } catch (e) {
      print('Error getting attendee stats: $e');
      return OrganizerAttendeeStats.empty();
    }
  }

  // Get attendee statistics for a specific event
  Future<OrganizerAttendeeStats> getEventAttendeeStats(String eventId) async {
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

      // Get registrations for this event
      final registrationsSnapshot =
          await _firestore
              .collection('registrations')
              .where('eventId', isEqualTo: eventId)
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

      return OrganizerAttendeeStats.fromAttendeesList(attendees);
    } catch (e) {
      throw Exception('Failed to get event attendee stats: $e');
    }
  }

  // Stream attendee stats for real-time updates
  Stream<OrganizerAttendeeStats> streamAttendeeStats() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value(OrganizerAttendeeStats.empty());
    }

    return _firestore
        .collection('events')
        .where('organizerId', isEqualTo: user.uid)
        .snapshots()
        .asyncMap((eventsSnapshot) async {
          if (eventsSnapshot.docs.isEmpty) {
            return OrganizerAttendeeStats.empty();
          }

          final eventIds = eventsSnapshot.docs.map((doc) => doc.id).toList();

          // Get all registrations for these events
          final registrationsSnapshot =
              await _firestore
                  .collection('registrations')
                  .where('eventId', whereIn: eventIds)
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

          return OrganizerAttendeeStats.fromAttendeesList(attendees);
        });
  }

  // Get attendance growth over time (monthly breakdown)
  Future<Map<String, int>> getAttendanceGrowthData() async {
    try {
      final stats = await getAttendeeStats();
      return stats.attendeesByMonth;
    } catch (e) {
      print('Error getting attendance growth data: $e');
      return {};
    }
  }

  // Get top performing events by attendee count
  Future<List<Map<String, dynamic>>> getTopEventsByAttendees({
    int limit = 5,
  }) async {
    try {
      final stats = await getAttendeeStats();

      final sortedEvents =
          stats.attendeesByEvent.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

      return sortedEvents
          .take(limit)
          .map(
            (entry) => {'eventName': entry.key, 'attendeeCount': entry.value},
          )
          .toList();
    } catch (e) {
      print('Error getting top events by attendees: $e');
      return [];
    }
  }

  // Calculate attendance trends (comparing current month to previous)
  Future<Map<String, dynamic>> getAttendanceTrends() async {
    try {
      final now = DateTime.now();
      final currentMonth =
          '${now.year}-${now.month.toString().padLeft(2, '0')}';
      final previousMonth =
          now.month == 1
              ? '${now.year - 1}-12'
              : '${now.year}-${(now.month - 1).toString().padLeft(2, '0')}';

      final stats = await getAttendeeStats();
      final currentMonthCount = stats.attendeesByMonth[currentMonth] ?? 0;
      final previousMonthCount = stats.attendeesByMonth[previousMonth] ?? 0;

      double growthRate = 0.0;
      if (previousMonthCount > 0) {
        growthRate =
            ((currentMonthCount - previousMonthCount) / previousMonthCount) *
            100;
      }

      return {
        'currentMonth': currentMonthCount,
        'previousMonth': previousMonthCount,
        'growthRate': growthRate,
        'isGrowing': growthRate > 0,
      };
    } catch (e) {
      print('Error getting attendance trends: $e');
      return {
        'currentMonth': 0,
        'previousMonth': 0,
        'growthRate': 0.0,
        'isGrowing': false,
      };
    }
  }
}
