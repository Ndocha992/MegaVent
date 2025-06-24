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

  // Stream upcoming events
  Stream<List<Event>> streamUpcomingEvents() {
    return _firestore
        .collection('events')
        .where('startDate', isGreaterThan: DateTime.now())
        .orderBy('startDate', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
        });
  }

  // Get event categories (you can modify this to fetch from Firestore if needed)
  List<String> getEventCategories() {
    return [
      'Technology',
      'Business',
      'Health & Wellness',
      'Education',
      'Arts & Culture',
      'Sports & Recreation',
      'Food & Drink',
      'Music',
      'Fashion',
      'Travel',
      'Networking',
      'Workshop',
      'Conference',
      'Seminar',
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
}