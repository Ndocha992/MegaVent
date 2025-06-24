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

  // Update organizer profile data
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
}