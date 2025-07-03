import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:megavent/models/registration.dart';
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

      // Create event ID to name mapping
      final Map<String, String> eventIdToNameMap = {};
      for (final eventDoc in eventsSnapshot.docs) {
        final eventData = eventDoc.data();
        eventIdToNameMap[eventDoc.id] =
            eventData['title'] ?? eventData['name'] ?? 'Unknown Event';
      }

      // Get all registrations for these events
      final registrationsSnapshot =
          await _firestore
              .collection('registrations')
              .where('eventId', whereIn: eventIds)
              .get();

      // Convert Firestore documents to Registration objects
      final List<Registration> registrations =
          registrationsSnapshot.docs
              .map((doc) => Registration.fromFirestore(doc))
              .toList();

      // Generate stats from registrations list
      return OrganizerAttendeeStats.fromRegistrationsList(
        registrations,
        eventIdToNameMap,
      );
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

      // Convert to Registration objects
      final List<Registration> registrations =
          registrationsSnapshot.docs
              .map((doc) => Registration.fromFirestore(doc))
              .toList();

      // Create event name map for this single event
      final eventName =
          eventData['title'] ?? eventData['name'] ?? 'Unknown Event';
      final Map<String, String> eventIdToNameMap = {eventId: eventName};

      return OrganizerAttendeeStats.fromRegistrationsList(
        registrations,
        eventIdToNameMap,
      );
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

          // Create event ID to name mapping
          final Map<String, String> eventIdToNameMap = {};
          for (final eventDoc in eventsSnapshot.docs) {
            final eventData = eventDoc.data();
            eventIdToNameMap[eventDoc.id] =
                eventData['title'] ?? eventData['name'] ?? 'Unknown Event';
          }

          // Get all registrations for these events
          final registrationsSnapshot =
              await _firestore
                  .collection('registrations')
                  .where('eventId', whereIn: eventIds)
                  .get();

          // Convert to Registration objects
          final List<Registration> registrations =
              registrationsSnapshot.docs
                  .map((doc) => Registration.fromFirestore(doc))
                  .toList();

          return OrganizerAttendeeStats.fromRegistrationsList(
            registrations,
            eventIdToNameMap,
          );
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

  // Helper method to get registrations for organizer's events
  Future<List<Registration>> _getOrganizerRegistrations() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      // Get organizer's events
      final eventsSnapshot =
          await _firestore
              .collection('events')
              .where('organizerId', isEqualTo: user.uid)
              .get();

      if (eventsSnapshot.docs.isEmpty) return [];

      final eventIds = eventsSnapshot.docs.map((doc) => doc.id).toList();

      // Get registrations for these events
      final registrationsSnapshot =
          await _firestore
              .collection('registrations')
              .where('eventId', whereIn: eventIds)
              .get();

      return registrationsSnapshot.docs
          .map((doc) => Registration.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting organizer registrations: $e');
      return [];
    }
  }

  // Helper method to create event ID to name mapping
  Future<Map<String, String>> getEventIdToNameMap() async {
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

      final Map<String, String> eventIdToNameMap = {};
      for (final eventDoc in eventsSnapshot.docs) {
        final eventData = eventDoc.data();
        eventIdToNameMap[eventDoc.id] =
            eventData['title'] ?? eventData['name'] ?? 'Unknown Event';
      }

      return eventIdToNameMap;
    } catch (e) {
      print('Error getting event names: $e');
      return {};
    }
  }

  // Get detailed registration data for a specific event
  Future<List<Registration>> getEventRegistrations(String eventId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Verify event ownership
      final eventDoc = await _firestore.collection('events').doc(eventId).get();
      if (!eventDoc.exists) {
        throw Exception('Event not found');
      }

      final eventData = eventDoc.data() as Map<String, dynamic>;
      if (eventData['organizerId'] != user.uid) {
        throw Exception('Unauthorized: You can only access your own events');
      }

      // Get registrations for this event
      final registrationsSnapshot =
          await _firestore
              .collection('registrations')
              .where('eventId', isEqualTo: eventId)
              .get();

      return registrationsSnapshot.docs
          .map((doc) => Registration.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get event registrations: $e');
    }
  }

  // Stream registrations for a specific event
  Stream<List<Registration>> streamEventRegistrations(String eventId) {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('registrations')
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => Registration.fromFirestore(doc))
                  .toList(),
        );
  }
}
