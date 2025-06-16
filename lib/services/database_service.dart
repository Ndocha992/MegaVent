import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:megavent/services/cloudinary.dart';

class DatabaseService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get all students
  Future<Map<String, dynamic>> getAllStudents() async {
    _setLoading(true);
    try {
      final studentDocs = await _firestore.collection('students').get();

      List<Student> students = [];
      for (var doc in studentDocs.docs) {
        students.add(Student.fromFirestore(doc));
      }

      return {'success': true, 'data': students};
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {'success': false, 'message': 'Failed to retrieve students data'};
    } finally {
      _setLoading(false);
    }
  }

  // Get current user profile
  Future<Map<String, dynamic>> getCurrentUserProfile() async {
    _setLoading(true);
    try {
      if (currentUser == null) {
        return {'success': false, 'message': 'No user is currently signed in'};
      }

      // Check if student
      DocumentSnapshot studentDoc =
          await _firestore.collection('students').doc(currentUser!.uid).get();
      if (studentDoc.exists) {
        Student student = Student.fromFirestore(studentDoc);
        return {
          'success': true,
          'data': student,
          'role': 'student',
          'verified': student.verified,
        };
      }

      // Check if provider
      DocumentSnapshot providerDoc =
          await _firestore.collection('providers').doc(currentUser!.uid).get();
      if (providerDoc.exists) {
        Provider provider = Provider.fromFirestore(providerDoc);
        return {
          'success': true,
          'data': provider,
          'role': 'provider',
          'verified': provider.verified,
        };
      }

      return {'success': false, 'message': 'User profile not found'};
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {'success': false, 'message': 'Failed to retrieve user profile'};
    } finally {
      _setLoading(false);
    }
  }

  // Update user profile (works for both students and providers)
  Future<Map<String, dynamic>> updateUserProfile(
    Map<String, dynamic> data,
  ) async {
    _setLoading(true);
    try {
      if (currentUser == null) {
        return {'success': false, 'message': 'No user signed in'};
      }

      // Get current user profile to determine role
      final profileResult = await getCurrentUserProfile();
      if (!profileResult['success']) {
        return profileResult;
      }

      String role = profileResult['role'];
      String userId = currentUser!.uid;

      // Update the appropriate collection based on user role
      if (role == 'student') {
        await _firestore.collection('students').doc(userId).update({
          ...data,
          'updatedAt': DateTime.now(),
        });

        // If fullName is updated, also update it in users collection
        if (data.containsKey('fullName')) {
          await _firestore.collection('users').doc(userId).update({
            'fullName': data['fullName'],
          });
        }
      } else if (role == 'provider') {
        await _firestore.collection('providers').doc(userId).update({
          ...data,
          'updatedAt': DateTime.now(),
        });

        // If businessName is updated, also update it in users collection
        if (data.containsKey('businessName')) {
          await _firestore.collection('users').doc(userId).update({
            'fullName': data['businessName'],
          });
        }
      } else {
        return {'success': false, 'message': 'Invalid user role'};
      }

      return {'success': true, 'message': 'Profile updated successfully'};
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {'success': false, 'message': 'Failed to update profile'};
    } finally {
      _setLoading(false);
    }
  }

  // Alternative version using batch upload for better performance
  Future<Map<String, dynamic>> uploadIdentificationImages({
    required File nationalIdFront,
    required File nationalIdBack,
    required File studentIdFront,
    required File studentIdBack,
  }) async {
    _setLoading(true);
    try {
      if (currentUser == null) {
        return {'success': false, 'message': 'No user signed in'};
      }

      // Get current user profile to determine role
      final profileResult = await getCurrentUserProfile();
      if (!profileResult['success']) {
        return profileResult;
      }

      String role = profileResult['role'];
      String userId = currentUser!.uid;

      // Upload all images using batch upload
      final uploadResults = await Cloudinary.uploadIdentificationImages(
        userId: userId,
        nationalIdFront: nationalIdFront,
        nationalIdBack: nationalIdBack,
        studentIdFront: studentIdFront,
        studentIdBack: studentIdBack,
      );

      // Check if all uploads were successful
      final failedUploads =
          uploadResults.entries
              .where((entry) => entry.value == null)
              .map((entry) => entry.key)
              .toList();

      if (failedUploads.isNotEmpty) {
        return {
          'success': false,
          'message': 'Failed to upload: ${failedUploads.join(', ')}',
        };
      }

      // Prepare identification images data with Cloudinary URLs
      Map<String, dynamic> identificationData = {
        'nationalIdFront': uploadResults['nationalIdFront']!,
        'nationalIdBack': uploadResults['nationalIdBack']!,
        'studentIdFront': uploadResults['studentIdFront']!,
        'studentIdBack': uploadResults['studentIdBack']!,
        'uploadedAt': DateTime.now(),
      };

      // Update the appropriate collection based on user role
      if (role == 'student') {
        await _firestore.collection('students').doc(userId).update({
          'identificationImages': identificationData,
          'updatedAt': DateTime.now(),
        });
      } else if (role == 'provider') {
        await _firestore.collection('providers').doc(userId).update({
          'identificationImages': identificationData,
          'updatedAt': DateTime.now(),
        });
      } else {
        return {'success': false, 'message': 'Invalid user role'};
      }

      return {
        'success': true,
        'message': 'Documents uploaded successfully',
        'imageUrls': identificationData,
      };
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {
        'success': false,
        'message': 'Failed to upload documents: ${e.toString()}',
      };
    } finally {
      _setLoading(false);
    }
  }
}
