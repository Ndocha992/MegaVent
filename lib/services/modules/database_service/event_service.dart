import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:megavent/models/event.dart';

class EventService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final ChangeNotifier _notifier;

  EventService(this._firestore, this._auth, this._notifier);

  /**
   * ====== EVENT METHODS ======
   */

  // Create a new event
  Future<String> createEvent(Event event) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Create event with auto-generated ID
      final docRef = _firestore.collection('events').doc();

      // Create event with the generated ID and current user as organizer
      final eventWithId = event.copyWith(
        id: docRef.id,
        organizerId: user.uid,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await docRef.set(eventWithId.toMap());

      _notifier.notifyListeners();
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create event: $e');
    }
  }

  // Update an existing event
  Future<void> updateEvent(Event event) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Ensure only the organizer can update their event
      if (event.organizerId != user.uid) {
        throw Exception('Unauthorized: You can only update your own events');
      }

      final updatedEvent = event.copyWith(updatedAt: DateTime.now());

      await _firestore
          .collection('events')
          .doc(event.id)
          .update(updatedEvent.toMap());

      _notifier.notifyListeners();
    } catch (e) {
      throw Exception('Failed to update event: $e');
    }
  }

  // Delete an event
  Future<void> deleteEvent(String eventId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // First check if the event belongs to the current user
      final eventDoc = await _firestore.collection('events').doc(eventId).get();
      if (!eventDoc.exists) {
        throw Exception('Event not found');
      }

      final event = Event.fromFirestore(eventDoc);
      if (event.organizerId != user.uid) {
        throw Exception('Unauthorized: You can only delete your own events');
      }

      await _firestore.collection('events').doc(eventId).delete();

      _notifier.notifyListeners();
    } catch (e) {
      throw Exception('Failed to delete event: $e');
    }
  }

  // Get events for current organizer (used by dashboard)
  Future<List<Event>> getEvents() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final querySnapshot =
          await _firestore
              .collection('events')
              .where('organizerId', isEqualTo: user.uid)
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get events: $e');
    }
  }

  // Get a single event by ID
  Future<Event?> getEventById(String eventId) async {
    try {
      final doc = await _firestore.collection('events').doc(eventId).get();
      if (doc.exists) {
        return Event.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get event: $e');
    }
  }

  // Stream a single event for real-time updates
  Stream<Event?> streamEventById(String eventId) {
    return _firestore.collection('events').doc(eventId).snapshots().map((doc) {
      if (doc.exists) {
        return Event.fromFirestore(doc);
      }
      return null;
    });
  }

  // Stream all events for real-time updates
  Stream<List<Event>> streamAllEvents() {
    return _firestore
        .collection('events')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
        });
  }

  // Stream events by organizer for real-time updates
  Stream<List<Event>> streamEventsByOrganizer() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('events')
        .where('organizerId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
        });
  }

  // Stream events by category
  Stream<List<Event>> streamEventsByCategory(String category) {
    return _firestore
        .collection('events')
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
        });
  }

  // Helper to return full combined date
  DateTime _combineDateAndTime(DateTime date, String timeStr) {
    final parts = timeStr.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1].split(' ')[0]);
    final isPM = timeStr.contains('PM') && hour != 12;

    return DateTime(
      date.year,
      date.month,
      date.day,
      isPM ? hour + 12 : hour,
      minute,
    );
  }

  // Update upcoming events query
  Stream<List<Event>> streamUpcomingEvents() {
    return _firestore
        .collection('events')
        .where('endDate', isGreaterThan: DateTime.now())
        .orderBy('endDate', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) {
                final event = Event.fromFirestore(doc);
                final endDateTime = _combineDateAndTime(
                  event.endDate,
                  event.endTime,
                );

                // Filter out events that have ended today
                if (endDateTime.isBefore(DateTime.now())) {
                  return null;
                }
                return event;
              })
              .whereType<Event>()
              .toList();
        });
  }

  /**
 * ====== ALL AVAILABLE EVENTS METHOD ======
 */
  Future<List<Event>> getAllAvailableEvents() async {
    try {
      final snapshot =
          await _firestore
              .collection('events')
              .orderBy('createdAt', descending: true)
              .get();

      return snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get all available events: $e');
    }
  }

  // Get event categories
  List<String> getEventCategories() {
    return [
      // Business & Professional
      'Technology',
      'Business',
      'Conference',
      'Seminar',
      'Workshop',
      'Networking',
      'Trade Show',
      'Expo',

      // Entertainment & Arts
      'Music',
      'Arts & Culture',
      'Theater & Performing Arts',
      'Comedy Shows',
      'Film & Cinema',
      'Fashion',
      'Entertainment',

      // Community & Cultural
      'Cultural Festival',
      'Community Event',
      'Religious Event',
      'Traditional Ceremony',
      'Charity & Fundraising',
      'Cultural Exhibition',

      // Sports & Recreation
      'Sports & Recreation',
      'Football (Soccer)',
      'Rugby',
      'Athletics',
      'Marathon & Running',
      'Outdoor Adventure',
      'Safari Rally',
      'Water Sports',

      // Education & Development
      'Education',
      'Training & Development',
      'Youth Programs',
      'Academic Conference',
      'Skill Development',

      // Health & Wellness
      'Health & Wellness',
      'Medical Conference',
      'Fitness & Yoga',
      'Mental Health',

      // Food & Agriculture
      'Food & Drink',
      'Agricultural Show',
      'Food Festival',
      'Cooking Workshop',
      'Wine Tasting',

      // Travel & Tourism
      'Travel',
      'Tourism Promotion',
      'Adventure Tourism',
      'Wildlife Conservation',

      // Government & Politics
      'Government Event',
      'Political Rally',
      'Public Forum',
      'Civic Engagement',

      // Special Occasions
      'Wedding',
      'Birthday Party',
      'Anniversary',
      'Graduation',
      'Baby Shower',
      'Corporate Party',

      // Seasonal & Holiday
      'Christmas Event',
      'New Year Celebration',
      'Independence Day',
      'Eid Celebration',
      'Diwali',
      'Easter Event',

      // Markets & Shopping
      'Market Event',
      'Craft Fair',
      'Farmers Market',
      'Pop-up Shop',

      // Other
      'Other',
    ];
  }

  // Search events by name or description
  Stream<List<Event>> searchEvents(String query) {
    if (query.isEmpty) {
      return streamAllEvents();
    }

    return _firestore
        .collection('events')
        .orderBy('name')
        .startAt([query])
        .endAt(['$query\uf8ff'])
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
        });
  }

  Future<List<Event>> getEventsForOrganizer(String organizerId) async {
    try {
      final querySnapshot =
          await _firestore
              .collection('events')
              .where('organizerId', isEqualTo: organizerId)
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get events: $e');
    }
  }

  /**
   * ====== ADMIN METHODS ======
   */

  // Get all events
  Future<List<Event>> getAdminAllEvents() async {
    try {
      final snapshot = await _firestore.collection('events').get();
      return snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get events: $e');
    }
  }

  // Get all organizer events
  Future<List<Event>> getAdminOrganizerEvents(String organizerId) async {
    try {
      final querySnapshot =
          await _firestore
              .collection('events')
              .where('organizerId', isEqualTo: organizerId)
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get organizer events: $e');
    }
  }
}
