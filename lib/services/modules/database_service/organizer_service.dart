import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:megavent/models/organizer.dart';

class OrganizerService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final ChangeNotifier _notifier;

  OrganizerService(this._firestore, this._auth, this._notifier);

  /**
   * ====== ORGANIZER METHODS ======
   */

  // Stream current organizer data for real-time updates
  Stream<Organizer?> streamCurrentOrganizerData() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value(null);
    }

    return _firestore.collection('organizers').doc(user.uid).snapshots().map((
      doc,
    ) {
      if (doc.exists) {
        return Organizer.fromFirestore(doc);
      }
      return null;
    });
  }

  // Update organizer profile data (existing method)
  Future<void> updateOrganizerProfile(Organizer organizer) async {
    try {
      await _firestore
          .collection('organizers')
          .doc(organizer.id)
          .update(organizer.toMap());
      _notifier.notifyListeners();
    } catch (e) {
      throw Exception('Failed to update organizer profile: $e');
    }
  }

  // New method to update only specific fields
  Future<void> updateOrganizerProfileFields(
    String organizerId,
    Map<String, dynamic> fields,
  ) async {
    try {
      // Validate that the fields map is not empty
      if (fields.isEmpty) {
        throw Exception('No fields provided for update');
      }

      // Clean the fields map to ensure no invalid values
      final cleanFields = <String, dynamic>{};

      fields.forEach((key, value) {
        // Skip null values for optional fields, but allow them for clearing fields
        if (value != null || _isOptionalField(key)) {
          cleanFields[key] = value;
        }
      });

      if (cleanFields.isEmpty) {
        throw Exception('No valid fields to update');
      }

      print('Updating organizer $organizerId with fields: $cleanFields');

      await _firestore
          .collection('organizers')
          .doc(organizerId)
          .update(cleanFields);

      _notifier.notifyListeners();
    } catch (e) {
      print('Error updating organizer profile fields: $e');
      throw Exception('Failed to update organizer profile: $e');
    }
  }

  // Helper method to determine if a field is optional (can be null)
  bool _isOptionalField(String fieldName) {
    const optionalFields = [
      'organization',
      'jobTitle',
      'bio',
      'website',
      'address',
      'city',
      'country',
      'profileImage',
    ];
    return optionalFields.contains(fieldName);
  }

  /**
   * ====== ORGANIZER METHODS ======
   */
  // Get all Organizers
  Future<List<Organizer>> getAdminAllOrganizers() async {
    try {
      final snapshot =
          await _firestore
              .collection('organizers')
              .orderBy('createdAt', descending: true)
              .get();
      return snapshot.docs.map((doc) => Organizer.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get organizers: $e');
    }
  }

  // Stream all organizers
  Stream<List<Organizer>> streamOrganizers() {
    return _firestore
        .collection('organizers')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Organizer.fromFirestore(doc))
              .toList();
        });
  }

  // Update organizer approval
  Future<void> updateOrganizerApproval(
    String organizerId,
    bool isApproved,
  ) async {
    try {
      await _firestore.collection('organizers').doc(organizerId).update({
        'isApproved': isApproved,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _notifier.notifyListeners();
    } catch (e) {
      throw Exception('Failed to update organizer approval: $e');
    }
  }

  Future<AdminOrganizerStats> getAdminOrganizerStats(String organizerId) async {
    try {
      final eventsCount = await _firestore
          .collection('events')
          .where('organizerId', isEqualTo: organizerId)
          .count()
          .get()
          .then((value) => value.count);

      final totalStaff = await _firestore
          .collection('staff')
          .where('organizerId', isEqualTo: organizerId)
          .count()
          .get()
          .then((value) => value.count);

      final eventIds = await _firestore
          .collection('events')
          .where('organizerId', isEqualTo: organizerId)
          .get()
          .then((snapshot) => snapshot.docs.map((doc) => doc.id).toList());

      int totalAttendees = 0;
      if (eventIds.isNotEmpty) {
        totalAttendees = await _firestore
            .collection('registrations')
            .where('eventId', whereIn: eventIds)
            .count()
            .get()
            .then((value) => value.count ?? 0);
      }

      return AdminOrganizerStats(
        eventsCount: eventsCount ?? 0,
        totalStaff: totalStaff ?? 0,
        totalAttendees: totalAttendees,
      );
    } catch (e) {
      throw Exception('Failed to get organizer stats: $e');
    }
  }
}
