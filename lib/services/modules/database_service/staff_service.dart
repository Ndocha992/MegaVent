import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:megavent/models/staff.dart';

class StaffService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final ChangeNotifier _notifier;

  StaffService(this._firestore, this._auth, this._notifier);

  /**
   * ====== STAFF METHODS ======
   */

  // Get latest staff for current organizer
  Future<List<Map<String, dynamic>>> getLatestStaff() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final querySnapshot =
          await _firestore
              .collection('staff')
              .where('organizerId', isEqualTo: user.uid)
              .orderBy('hiredAt', descending: true)
              .limit(5)
              .get();

      return querySnapshot.docs.map((doc) {
        final staff = Staff.fromFirestore(doc);
        return {
          'id': staff.id,
          'name': staff.fullName,
          'email': staff.email,
          'role': staff.role,
          'department': staff.department,
          'status': staff.status,
          'profileImage': staff.profileImage,
          'joinedAt': staff.hiredAt,
        };
      }).toList();
    } catch (e) {
      // Return empty list if collection doesn't exist or has no data
      return [];
    }
  }

  // Get all staff for current organizer
  Future<List<Staff>> getAllStaff() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final querySnapshot =
          await _firestore
              .collection('staff')
              .where('organizerId', isEqualTo: user.uid)
              .orderBy('hiredAt', descending: true)
              .get();

      return querySnapshot.docs.map((doc) => Staff.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get staff: $e');
    }
  }

  // Stream staff for current organizer
  Stream<List<Staff>> streamStaff() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('staff')
        .where('organizerId', isEqualTo: user.uid)
        .orderBy('hiredAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Staff.fromFirestore(doc)).toList();
        });
  }

  // Add new staff member
  Future<String> addStaff(Staff staff) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final docRef = _firestore.collection('staff').doc();
      final staffWithId = staff.copyWith(
        id: docRef.id,
        organizerId: user.uid,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await docRef.set(staffWithId.toMap());
      _notifier.notifyListeners();
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add staff: $e');
    }
  }

  // Update staff member - FIXED VERSION
  Future<void> updateStaff(Staff staff) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      if (staff.organizerId != user.uid) {
        throw Exception('Unauthorized: You can only update your own staff');
      }

      // Only update the fields that can be modified from the form
      Map<String, dynamic> updateData = {
        'fullName': staff.fullName,
        'email': staff.email,
        'phone': staff.phone,
        'role': staff.role,
        'department': staff.department,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Only add profileImage if it's not null
      if (staff.profileImage != null) {
        updateData['profileImage'] = staff.profileImage;
      }

      await _firestore.collection('staff').doc(staff.id).update(updateData);

      _notifier.notifyListeners();
    } catch (e) {
      throw Exception('Failed to update staff: $e');
    }
  }

  // Delete staff member
  Future<void> deleteStaff(String staffId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Check if staff belongs to current organizer
      final staffDoc = await _firestore.collection('staff').doc(staffId).get();
      if (!staffDoc.exists) {
        throw Exception('Staff member not found');
      }

      final staff = Staff.fromFirestore(staffDoc);
      if (staff.organizerId != user.uid) {
        throw Exception('Unauthorized: You can only delete your own staff');
      }

      await _firestore.collection('staff').doc(staffId).delete();
      _notifier.notifyListeners();
    } catch (e) {
      throw Exception('Failed to delete staff: $e');
    }
  }

  /**
 * ====== STAFF METHODS ======
 */

  // Stream current staff data (for authenticated staff user)
  Stream<Staff?> streamCurrentStaffData() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value(null);
    }

    // Stream staff data where the user's email matches the staff email
    return _firestore
        .collection('staff')
        .where('email', isEqualTo: user.email)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) {
            return null;
          }
          return Staff.fromFirestore(snapshot.docs.first);
        });
  }

  // Get current staff data as a one-time fetch
  Future<Staff?> getCurrentStaffData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return null;
      }

      final querySnapshot =
          await _firestore
              .collection('staff')
              .where('email', isEqualTo: user.email)
              .limit(1)
              .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      return Staff.fromFirestore(querySnapshot.docs.first);
    } catch (e) {
      print('Error getting current staff data: $e');
      return null;
    }
  }

  // Update current staff profile
  Future<void> updateCurrentStaffProfile(Staff staff) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Verify the staff member is the current user
      if (staff.email != user.email) {
        throw Exception('Unauthorized: You can only update your own profile');
      }

      Map<String, dynamic> updateData = {
        'fullName': staff.fullName,
        'email': staff.email,
        'phone': staff.phone,
        'role': staff.role,
        'department': staff.department,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Only add profileImage if it's not null
      if (staff.profileImage != null) {
        updateData['profileImage'] = staff.profileImage;
      }

      await _firestore.collection('staff').doc(staff.id).update(updateData);

      _notifier.notifyListeners();
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }
}
