import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StatsService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final ChangeNotifier _notifier;

  StatsService(this._firestore, this._auth, this._notifier);

  // Calculate experience level based on total events
  String _calculateExperienceLevel(int totalEvents) {
    if (totalEvents >= 50) return 'Expert';
    if (totalEvents >= 20) return 'Advanced';
    if (totalEvents >= 5) return 'Intermediate';
    return 'Beginner';
  }

  // Get organizer stats (counts only, more efficient than fetching full data)
  Future<Map<String, dynamic>> getOrganizerStats() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Get events count
      final eventsSnapshot =
          await _firestore
              .collection('events')
              .where('organizerId', isEqualTo: user.uid)
              .get();

      final eventIds = eventsSnapshot.docs.map((doc) => doc.id).toList();
      final totalEvents = eventsSnapshot.docs.length;

      // Get attendees count (registrations for organizer's events)
      int attendeesCount = 0;
      if (eventIds.isNotEmpty) {
        final registrationsSnapshot =
            await _firestore
                .collection('registrations')
                .where('eventId', whereIn: eventIds)
                .get();
        attendeesCount = registrationsSnapshot.docs.length;
      }

      // Get staff count
      final staffSnapshot =
          await _firestore
              .collection('staff')
              .where('organizerId', isEqualTo: user.uid)
              .get();

      final totalStaff = staffSnapshot.docs.length;

      // Calculate experience level
      final experienceLevel = _calculateExperienceLevel(totalEvents);

      return {
        'totalEvents': totalEvents,
        'totalAttendees': attendeesCount,
        'totalStaff': totalStaff,
        'experienceLevel': experienceLevel,
      };
    } catch (e) {
      return {
        'totalEvents': 0,
        'totalAttendees': 0,
        'totalStaff': 0,
        'experienceLevel': 'Beginner',
      };
    }
  }

  // Stream organizer stats for real-time updates
  Stream<Map<String, dynamic>> streamOrganizerStats() async* {
    final user = _auth.currentUser;
    if (user == null) {
      yield {
        'totalEvents': 0,
        'totalAttendees': 0,
        'totalStaff': 0,
        'experienceLevel': 'Beginner',
      };
      return;
    }

    // Listen to events changes
    await for (final eventsSnapshot
        in _firestore
            .collection('events')
            .where('organizerId', isEqualTo: user.uid)
            .snapshots()) {
      final eventIds = eventsSnapshot.docs.map((doc) => doc.id).toList();
      final totalEvents = eventsSnapshot.docs.length;

      // Get current attendees count
      int attendeesCount = 0;
      if (eventIds.isNotEmpty) {
        final registrationsSnapshot =
            await _firestore
                .collection('registrations')
                .where('eventId', whereIn: eventIds)
                .get();
        attendeesCount = registrationsSnapshot.docs.length;
      }

      // Get current staff count
      final staffSnapshot =
          await _firestore
              .collection('staff')
              .where('organizerId', isEqualTo: user.uid)
              .get();

      final totalStaff = staffSnapshot.docs.length;

      // Calculate experience level
      final experienceLevel = _calculateExperienceLevel(totalEvents);

      yield {
        'totalEvents': totalEvents,
        'totalAttendees': attendeesCount,
        'totalStaff': totalStaff,
        'experienceLevel': experienceLevel,
      };
    }
  }

  // Get total attendees count only (more efficient)
  Future<int> getTotalAttendeesCount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 0;

      // Get all events by this organizer
      final eventsSnapshot =
          await _firestore
              .collection('events')
              .where('organizerId', isEqualTo: user.uid)
              .get();

      if (eventsSnapshot.docs.isEmpty) return 0;

      final eventIds = eventsSnapshot.docs.map((doc) => doc.id).toList();

      // Get registrations count for these events
      final registrationsSnapshot =
          await _firestore
              .collection('registrations')
              .where('eventId', whereIn: eventIds)
              .get();

      return registrationsSnapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  // Get total events count only
  Future<int> getTotalEventsCount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 0;

      final snapshot =
          await _firestore
              .collection('events')
              .where('organizerId', isEqualTo: user.uid)
              .get();

      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  // Get total staff count only
  Future<int> getTotalStaffCount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 0;

      final snapshot =
          await _firestore
              .collection('staff')
              .where('organizerId', isEqualTo: user.uid)
              .get();

      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }
}
