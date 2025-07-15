import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:megavent/models/admin.dart';

class AdminService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final ChangeNotifier _notifier;

  AdminService(this._firestore, this._auth, this._notifier);

  Stream<Admin?> streamCurrentAdminData() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value(null);
    }
    return _firestore.collection('admins').doc(user.uid).snapshots().map((doc) {
      if (doc.exists) {
        return Admin.fromFirestore(doc);
      }
      return null;
    });
  }

  Future<void> updateAdminProfileFields(
    String adminId,
    Map<String, dynamic> fields,
  ) async {
    try {
      // Add updatedAt timestamp
      final cleanFields = Map<String, dynamic>.from(fields)
        ..['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('admins').doc(adminId).update(cleanFields);
      _notifier.notifyListeners();
    } catch (e) {
      throw Exception('Failed to update admin profile: $e');
    }
  }
}
