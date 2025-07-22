import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:megavent/models/admin_dashboard_stats.dart';
import 'package:megavent/models/event.dart';
import 'package:megavent/models/registration.dart';

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
 * ====== ATTENDEE DASHBOARD STATS METHOD ======
 */
  Future<Map<String, dynamic>> getAttendeeDashboardStats(String userId) async {
    try {
      // Get user's registrations
      final registrationsSnapshot =
          await _firestore
              .collection('registrations')
              .where('userId', isEqualTo: userId)
              .get();

      final registrations =
          registrationsSnapshot.docs
              .map((doc) => Registration.fromFirestore(doc))
              .toList();

      // Calculate stats
      final registeredEvents = registrations.length;
      final attendedEvents = registrations.where((r) => r.attended).length;
      final notAttendedEvents = registrations.where((r) => !r.attended).length;

      // Get upcoming events count
      int upcomingEvents = 0;
      for (final registration in registrations) {
        final eventDoc =
            await _firestore
                .collection('events')
                .doc(registration.eventId)
                .get();

        if (eventDoc.exists) {
          final event = Event.fromFirestore(eventDoc);
          if (event.startDate.isAfter(DateTime.now())) {
            upcomingEvents++;
          }
        }
      }

      return {
        'registeredEvents': registeredEvents,
        'attendedEvents': attendedEvents,
        'notAttendedEvents': notAttendedEvents,
        'upcomingEvents': upcomingEvents,
      };
    } catch (e) {
      throw Exception('Failed to get attendee dashboard stats: $e');
    }
  }

  /**
 * ====== ADMIN STATS METHOD ======
 */
  Future<AdminDashboardStats> getAdminDashboardStats() async {
    try {
      final organizers = await _getCollectionCount('organizers');
      final events = await _getCollectionCount('events');
      final staff = await _getCollectionCount('staff');
      final attendees = await _getCollectionCount('attendees');

      final registrations = await _getCollectionCount('registrations');
      final attended = await _getCountByQuery(
        _firestore
            .collection('registrations')
            .where('attended', isEqualTo: true),
      );

      return AdminDashboardStats(
        totalOrganizers: organizers!,
        totalEvents: events!,
        totalStaff: staff!,
        totalAttendees: attendees!,
        totalRegistrations: registrations!,
        attendedRegistrations: attended!,
        notAttendedRegistrations: registrations - attended,
      );
    } catch (e) {
      return AdminDashboardStats(
        totalOrganizers: 0,
        totalEvents: 0,
        totalStaff: 0,
        totalAttendees: 0,
        totalRegistrations: 0,
        attendedRegistrations: 0,
        notAttendedRegistrations: 0,
      );
    }
  }

  // Helper methods
  Future<int?> _getCollectionCount(String collection) async {
    final snapshot = await _firestore.collection(collection).count().get();
    return snapshot.count;
  }

  Future<int?> _getCountByQuery(Query query) async {
    final snapshot = await query.count().get();
    return snapshot.count;
  }
}
