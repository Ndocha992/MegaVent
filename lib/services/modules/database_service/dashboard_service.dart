import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:megavent/models/event.dart';

class DashboardService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final ChangeNotifier _notifier;

  DashboardService(this._firestore, this._auth, this._notifier);

  /**
   * ====== DASHBOARD METHODS ======
   */

  // Get dashboard stats for current organizer
  Future<Map<String, dynamic>> getOrganizerDashboardStats() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Get all events for current organizer
      final eventsSnapshot =
          await _firestore
              .collection('events')
              .where('organizerId', isEqualTo: user.uid)
              .get();

      final events =
          eventsSnapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();

      // Calculate stats
      final totalEvents = events.length;

      // Calculate event status based on dates
      final now = DateTime.now();
      final upcomingEvents =
          events.where((e) => e.startDate.isAfter(now)).length;
      final activeEvents =
          events
              .where((e) => e.startDate.isBefore(now) && e.endDate.isAfter(now))
              .length;
      final completedEvents =
          events.where((e) => e.endDate.isBefore(now)).length;

      // Calculate total attendees (registrations + attendances)
      final totalRegistrations = events.fold<int>(
        0,
        (sum, event) => sum + event.registeredCount,
      );
      final totalAttendances = events.fold<int>(
        0,
        (sum, event) => sum + event.attendedCount,
      );
      // Total attendees combines both registered and attended users
      final totalAttendees = totalRegistrations;

      // Get staff count
      int totalStaff = 0;
      try {
        final staffSnapshot =
            await _firestore
                .collection('staff')
                .where('organizerId', isEqualTo: user.uid)
                .get();
        totalStaff = staffSnapshot.docs.length;
      } catch (e) {
        totalStaff = 0;
      }

      // Calculate additional metrics
      final averageAttendeesPerEvent =
          totalEvents > 0
              ? (totalAttendees / totalEvents).toStringAsFixed(1)
              : '0.0';

      final eventCompletionRate =
          totalEvents > 0
              ? (completedEvents / totalEvents * 100).toStringAsFixed(1)
              : '0.0';

      final attendanceRate =
          totalRegistrations > 0
              ? (totalAttendances / totalRegistrations * 100).toStringAsFixed(1)
              : '0.0';

      return {
        'totalEvents': totalEvents,
        'totalAttendees': totalAttendees,
        'totalStaff': totalStaff,
        'activeEvents': activeEvents,
        'upcomingEvents': upcomingEvents,
        'completedEvents': completedEvents,
        // Additional stats that might be useful
        'totalRegistrations': totalRegistrations,
        'totalAttendances': totalAttendances,
        'averageAttendeesPerEvent': averageAttendeesPerEvent,
        'eventCompletionRate': eventCompletionRate,
        'attendanceRate': attendanceRate,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Failed to get dashboard stats: $e');
    }
  }

  // Get recent activity data
  Future<List<Map<String, dynamic>>> getRecentActivities() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      List<Map<String, dynamic>> activities = [];

      // Get recent events (last 7 days)
      final recentEventsSnapshot =
          await _firestore
              .collection('events')
              .where('organizerId', isEqualTo: user.uid)
              .where(
                'createdAt',
                isGreaterThan: DateTime.now().subtract(const Duration(days: 7)),
              )
              .orderBy('createdAt', descending: true)
              .limit(3)
              .get();

      for (var doc in recentEventsSnapshot.docs) {
        final event = Event.fromFirestore(doc);
        activities.add({
          'title': 'Event "${event.name}" created',
          'time': event.createdAt,
          'icon': 'event',
          'color': 'primary',
          'isNew': _isRecent(event.createdAt),
        });
      }

      // Get recent registrations (last 7 days)
      final recentRegistrationsSnapshot =
          await _firestore
              .collection('registrations')
              .where(
                'createdAt',
                isGreaterThan: DateTime.now().subtract(const Duration(days: 7)),
              )
              .orderBy('createdAt', descending: true)
              .limit(3)
              .get();

      for (var doc in recentRegistrationsSnapshot.docs) {
        final data = doc.data();
        activities.add({
          'title': 'New registration received',
          'time': (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          'icon': 'person_add',
          'color': 'success',
          'isNew': _isRecent(
            (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          ),
        });
      }

      // Get recent staff additions (last 7 days)
      final recentStaffSnapshot =
          await _firestore
              .collection('staff')
              .where('organizerId', isEqualTo: user.uid)
              .where(
                'hiredAt',
                isGreaterThan: DateTime.now().subtract(const Duration(days: 7)),
              )
              .orderBy('hiredAt', descending: true)
              .limit(2)
              .get();

      for (var doc in recentStaffSnapshot.docs) {
        final data = doc.data();
        activities.add({
          'title': 'Staff member ${data['name']} joined',
          'time': (data['hiredAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          'icon': 'badge',
          'color': 'accent',
          'isNew': _isRecent(
            (data['hiredAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          ),
        });
      }

      // Sort by most recent and return top 5
      activities.sort(
        (a, b) => (b['time'] as DateTime).compareTo(a['time'] as DateTime),
      );
      return activities.take(5).toList();
    } catch (e) {
      print('Error getting recent activities: $e');
      return [];
    }
  }

  // Helper method to check if an activity is recent (within 24 hours)
  bool _isRecent(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    return difference.inHours < 24;
  }

  // Get performance metrics
  Future<Map<String, dynamic>> getPerformanceMetrics() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Get events data for calculations
      final eventsSnapshot =
          await _firestore
              .collection('events')
              .where('organizerId', isEqualTo: user.uid)
              .get();

      final events =
          eventsSnapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();

      if (events.isEmpty) {
        return {
          'eventGrowthRate': '0.0',
          'attendeeGrowthRate': '0.0',
          'averageEventCapacity': '0.0',
          'popularEventCategory': 'None',
        };
      }

      // Calculate average event capacity utilization
      final totalCapacity = events.fold<int>(
        0,
        (sum, event) => sum + event.capacity,
      );
      final totalRegistrations = events.fold<int>(
        0,
        (sum, event) => sum + event.registeredCount,
      );
      final averageCapacityUtilization =
          totalCapacity > 0
              ? (totalRegistrations / totalCapacity * 100).toStringAsFixed(1)
              : '0.0';

      // Find most popular event category
      final categoryCount = <String, int>{};
      for (var event in events) {
        categoryCount[event.category] =
            (categoryCount[event.category] ?? 0) + 1;
      }
      final popularCategory =
          categoryCount.entries.isEmpty
              ? 'None'
              : categoryCount.entries
                  .reduce((a, b) => a.value > b.value ? a : b)
                  .key;

      // Calculate monthly growth (mock calculation based on recent events)
      final recentEvents =
          events
              .where(
                (e) => e.createdAt.isAfter(
                  DateTime.now().subtract(const Duration(days: 30)),
                ),
              )
              .length;
      final eventGrowthRate =
          events.length > 0
              ? (recentEvents / events.length * 100).toStringAsFixed(1)
              : '0.0';

      final recentAttendees = events
          .where(
            (e) => e.createdAt.isAfter(
              DateTime.now().subtract(const Duration(days: 30)),
            ),
          )
          .fold<int>(0, (sum, event) => sum + event.registeredCount);
      final attendeeGrowthRate =
          totalRegistrations > 0
              ? (recentAttendees / totalRegistrations * 100).toStringAsFixed(1)
              : '0.0';

      return {
        'eventGrowthRate': eventGrowthRate,
        'attendeeGrowthRate': attendeeGrowthRate,
        'averageEventCapacity': averageCapacityUtilization,
        'popularEventCategory': popularCategory,
      };
    } catch (e) {
      print('Error getting performance metrics: $e');
      return {
        'eventGrowthRate': '0.0',
        'attendeeGrowthRate': '0.0',
        'averageEventCapacity': '0.0',
        'popularEventCategory': 'None',
      };
    }
  }

  /**
 * ====== ATTENDEE DASHBOARD METHODS ======
 */

  // Get dashboard stats for attendee
  Future<Map<String, dynamic>> getAttendeeDashboardStats(String userId) async {
    try {
      // Get attendee records for this user
      final attendeeSnapshot =
          await _firestore
              .collection('attendees')
              .where('userId', isEqualTo: userId)
              .get();

      final attendeeRecords =
          attendeeSnapshot.docs.map((doc) => doc.data()).toList();

      // Calculate stats
      final registeredEvents = attendeeRecords.length;
      final attendedEvents =
          attendeeRecords
              .where((record) => record['hasAttended'] == true)
              .length;
      final notAttendedEvents = registeredEvents - attendedEvents;

      // Get upcoming events count
      final eventIds = attendeeRecords.map((r) => r['eventId']).toList();
      int upcomingEvents = 0;

      if (eventIds.isNotEmpty) {
        // Get events in batches to check which are upcoming
        for (int i = 0; i < eventIds.length; i += 10) {
          final batch = eventIds.skip(i).take(10).toList();
          final eventsSnapshot =
              await _firestore
                  .collection('events')
                  .where(FieldPath.documentId, whereIn: batch)
                  .get();

          final now = DateTime.now();
          upcomingEvents +=
              eventsSnapshot.docs.where((doc) {
                final data = doc.data();
                final startDate = (data['startDate'] as Timestamp).toDate();
                return startDate.isAfter(now);
              }).length;
        }
      }

      return {
        'registeredEvents': registeredEvents,
        'attendedEvents': attendedEvents,
        'notAttendedEvents': notAttendedEvents,
        'upcomingEvents': upcomingEvents,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Failed to get attendee dashboard stats: $e');
    }
  }

  // Get recent activities for attendee
  Future<List<Map<String, dynamic>>> getAttendeeRecentActivities(
    String userId,
  ) async {
    try {
      List<Map<String, dynamic>> activities = [];

      // Get recent registrations (last 30 days)
      final recentRegistrationsSnapshot =
          await _firestore
              .collection('attendees')
              .where('userId', isEqualTo: userId)
              .where(
                'registeredAt',
                isGreaterThan: DateTime.now().subtract(
                  const Duration(days: 30),
                ),
              )
              .orderBy('registeredAt', descending: true)
              .limit(10)
              .get();

      for (var doc in recentRegistrationsSnapshot.docs) {
        final data = doc.data();
        final registeredAt = (data['registeredAt'] as Timestamp).toDate();

        activities.add({
          'title': 'Registered for "${data['eventName']}"',
          'time': registeredAt,
          'icon': 'event_available',
          'color': 'primary',
          'isNew': _isRecent(registeredAt),
          'type': 'registration',
        });

        // Add attendance activity if attended
        if (data['hasAttended'] == true) {
          final updatedAt =
              (data['updatedAt'] as Timestamp?)?.toDate() ?? registeredAt;
          activities.add({
            'title': 'Attended "${data['eventName']}"',
            'time': updatedAt,
            'icon': 'check_circle',
            'color': 'success',
            'isNew': _isRecent(updatedAt),
            'type': 'attendance',
          });
        }
      }

      // Sort by most recent and return top 6
      activities.sort(
        (a, b) => (b['time'] as DateTime).compareTo(a['time'] as DateTime),
      );
      return activities.take(6).toList();
    } catch (e) {
      print('Error getting attendee recent activities: $e');
      return [];
    }
  }

  // Stream attendee dashboard stats for real-time updates
  Stream<Map<String, dynamic>> streamAttendeeDashboardStats(String userId) {
    return _firestore
        .collection('attendees')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot) async {
          return await getAttendeeDashboardStats(userId);
        });
  }

  // Get attendee's event history with pagination
  Future<Map<String, dynamic>> getAttendeeEventHistory(
    String userId, {
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query = _firestore
          .collection('attendees')
          .where('userId', isEqualTo: userId)
          .orderBy('registeredAt', descending: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();
      final attendeeRecords =
          snapshot.docs
              .map((doc) => {'id': doc.id, 'data': doc.data(), 'document': doc})
              .toList();

      // Get event details for each record
      List<Map<String, dynamic>> eventHistory = [];
      for (var record in attendeeRecords) {
        final eventId = record['data']!['eventId'];
        final eventDoc =
            await _firestore.collection('events').doc(eventId).get();

        if (eventDoc.exists) {
          eventHistory.add({
            'attendee': record['data'],
            'event': eventDoc.data(),
            'eventId': eventDoc.id,
          });
        }
      }

      return {
        'events': eventHistory,
        'hasMore': snapshot.docs.length == limit,
        'lastDocument': snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
      };
    } catch (e) {
      throw Exception('Failed to get event history: $e');
    }
  }
}

extension on Object {
  operator [](String other) {}
}
