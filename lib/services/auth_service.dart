import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:megavent/models/admin.dart';
import 'package:megavent/models/attendee.dart';
import 'package:megavent/models/organizer.dart';
import 'package:megavent/models/staff.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  // User state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register attendee with email and password
  Future<Map<String, dynamic>> registerAttendee({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    String? profileImage,
  }) async {
    _setLoading(true);
    try {
      // Validate inputs
      if (fullName.isEmpty ||
          email.isEmpty ||
          password.isEmpty ||
          phone.isEmpty) {
        return {'success': false, 'message': 'All fields are required'};
      }

      // Check if email is already used
      final emailQuery =
          await _firestore
              .collection('users')
              .where('email', isEqualTo: email)
              .get();

      if (emailQuery.docs.isNotEmpty) {
        return {'success': false, 'message': 'Email already registered'};
      }

      // Create user in Firebase Auth
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await credential.user!.updateDisplayName(fullName);

      // Send email verification
      await credential.user!.sendEmailVerification();

      // Create attendee document
      Attendee attendee = Attendee(
        id: credential.user!.uid,
        fullName: fullName,
        email: email,
        phone: phone,
        profileImage: profileImage,
        isApproved: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Create in attendees collection
      await _firestore
          .collection('attendees')
          .doc(credential.user!.uid)
          .set(attendee.toMap());

      // Create in users collection for unified queries
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'id': credential.user!.uid,
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'role': 'attendee',
        'profileImage': profileImage,
        'isApproved': true,
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
      });

      return {
        'success': true,
        'message': 'Registration successful! Please verify your email.',
        'user': attendee,
      };
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'Email already in use';
          break;
        case 'weak-password':
          errorMessage = 'Password is too weak';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email format';
          break;
        default:
          errorMessage = 'Registration failed. Please try again.';
      }
      return {'success': false, 'message': errorMessage};
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {
        'success': false,
        'message': 'Registration failed. Please try again later.',
      };
    } finally {
      _setLoading(false);
    }
  }

  // Register organizer with email and password
  Future<Map<String, dynamic>> registerOrganizer({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    String? organization,
    String? profileImage,
  }) async {
    _setLoading(true);
    try {
      // Validate inputs
      if (fullName.isEmpty ||
          email.isEmpty ||
          password.isEmpty ||
          phone.isEmpty) {
        return {'success': false, 'message': 'All fields are required'};
      }

      // Check if email is already used
      final emailQuery =
          await _firestore
              .collection('users')
              .where('email', isEqualTo: email)
              .get();

      if (emailQuery.docs.isNotEmpty) {
        return {'success': false, 'message': 'Email already registered'};
      }

      // Create user in Firebase Auth
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await credential.user!.updateDisplayName(fullName);

      // Send email verification
      await credential.user!.sendEmailVerification();

      // Create organizer document
      Organizer organizer = Organizer(
        id: credential.user!.uid,
        fullName: fullName,
        email: email,
        phone: phone,
        organization: organization,
        profileImage: profileImage,
        isApproved: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Create in organizers collection
      await _firestore
          .collection('organizers')
          .doc(credential.user!.uid)
          .set(organizer.toMap());

      // Create in users collection for unified queries
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'id': credential.user!.uid,
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'role': 'organizer',
        'organization': organization,
        'profileImage': profileImage,
        'isApproved': false,
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
      });

      return {
        'success': true,
        'message':
            'Registration successful! Please verify your email and wait for approval.',
        'user': organizer,
      };
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'Email already in use';
          break;
        case 'weak-password':
          errorMessage = 'Password is too weak';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email format';
          break;
        default:
          errorMessage = 'Registration failed. Please try again.';
      }
      return {'success': false, 'message': errorMessage};
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {
        'success': false,
        'message': 'Registration failed. Please try again later.',
      };
    } finally {
      _setLoading(false);
    }
  }

  // Create Admin (only callable by existing Admin)
  Future<Map<String, dynamic>> createAdmin({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    String? profileImage,
  }) async {
    _setLoading(true);
    try {
      // Check if current user is a Admin
      final currentUserData = await getUserData();
      if (!currentUserData['success'] || currentUserData['role'] != 'admin') {
        return {'success': false, 'message': 'Unauthorized access'};
      }

      // Validate inputs
      if (fullName.isEmpty ||
          email.isEmpty ||
          password.isEmpty ||
          phone.isEmpty) {
        return {'success': false, 'message': 'All fields are required'};
      }

      // Check if email is already used
      final emailQuery =
          await _firestore
              .collection('users')
              .where('email', isEqualTo: email)
              .get();

      if (emailQuery.docs.isNotEmpty) {
        return {'success': false, 'message': 'Email already registered'};
      }

      // Create user in Firebase Auth
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await credential.user!.updateDisplayName(fullName);

      // Create Admin document
      Admin admin = Admin(
        id: credential.user!.uid,
        fullName: fullName,
        email: email,
        phone: phone,
        profileImage: profileImage,
        isApproved: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        adminLevel: '',
        permissions: [],
      );

      // Create in admins collection
      await _firestore
          .collection('admins')
          .doc(credential.user!.uid)
          .set(admin.toMap());

      // Create in users collection
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'id': credential.user!.uid,
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'role': 'admin',
        'profileImage': profileImage,
        'isApproved': true,
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
      });

      return {
        'success': true,
        'message': 'Admin created successfully!',
        'user': admin,
      };
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'Email already in use';
          break;
        case 'weak-password':
          errorMessage = 'Password is too weak';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email format';
          break;
        default:
          errorMessage = 'Failed to create Admin. Please try again.';
      }
      return {'success': false, 'message': errorMessage};
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {
        'success': false,
        'message': 'Failed to create Admin. Please try again later.',
      };
    } finally {
      _setLoading(false);
    }
  }

  // Create staff member (only callable by organizer)
  Future<Map<String, dynamic>> createStaff({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    String? profileImage,
  }) async {
    _setLoading(true);
    try {
      // Check if current user is an organizer
      final currentUserData = await getUserData();
      if (!currentUserData['success'] ||
          currentUserData['role'] != 'organizer') {
        return {
          'success': false,
          'message': 'Only organizers can create staff',
        };
      }

      // Check if organizer is approved and active
      final organizer = currentUserData['user'] as Organizer;
      if (!organizer.isApproved || !organizer.isApproved) {
        return {
          'success': false,
          'message': 'Your organizer account must be approved first',
        };
      }

      // Validate inputs
      if (fullName.isEmpty ||
          email.isEmpty ||
          password.isEmpty ||
          phone.isEmpty) {
        return {'success': false, 'message': 'All fields are required'};
      }

      // Check if email is already used
      final emailQuery =
          await _firestore
              .collection('users')
              .where('email', isEqualTo: email)
              .get();

      if (emailQuery.docs.isNotEmpty) {
        return {'success': false, 'message': 'Email already registered'};
      }

      // Create user in Firebase Auth
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await credential.user!.updateDisplayName(fullName);

      // Create staff document
      Staff staff = Staff(
        id: credential.user!.uid,
        fullName: fullName,
        email: email,
        phone: phone,
        profileImage: profileImage,
        organizerId: organizer.id,
        organization: organizer.organization,
        isApproved: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Send email verification
      await credential.user!.sendEmailVerification();

      // Create in staff collection
      await _firestore
          .collection('staff')
          .doc(credential.user!.uid)
          .set(staff.toMap());

      // Create in users collection
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'id': credential.user!.uid,
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'role': 'staff',
        'organizerId': organizer.id,
        'organization': organizer.organization,
        'profileImage': profileImage,
        'isApproved': true,
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
      });

      return {
        'success': true,
        'message': 'Staff member created successfully!',
        'user': staff,
      };
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'Email already in use';
          break;
        case 'weak-password':
          errorMessage = 'Password is too weak';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email format';
          break;
        default:
          errorMessage = 'Failed to create staff member. Please try again.';
      }
      return {'success': false, 'message': errorMessage};
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {
        'success': false,
        'message': 'Failed to create staff member. Please try again later.',
      };
    } finally {
      _setLoading(false);
    }
  }

  // Login with email/password
  Future<Map<String, dynamic>> loginWithEmailAndPassword(
    String email,
    String password,
  ) async {
    _setLoading(true);
    try {
      if (email.isEmpty || password.isEmpty) {
        return {'success': false, 'message': 'Email and password are required'};
      }

      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check email verification for ALL users (including admins)
      if (!credential.user!.emailVerified) {
        await _auth.signOut();
        return {
          'success': false,
          'message': 'Please verify your email before logging in',
        };
      }

      // Get user data based on role
      return await getUserData();
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email format';
          break;
        default:
          errorMessage = 'Login failed. Please try again.';
      }
      return {'success': false, 'message': errorMessage};
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {
        'success': false,
        'message': 'Login failed. Please try again later.',
      };
    } finally {
      _setLoading(false);
    }
  }

  // Get user data based on type
  Future<Map<String, dynamic>> getUserData() async {
    if (currentUser == null) {
      return {'success': false, 'message': 'No user signed in'};
    }

    _setLoading(true);
    try {
      // Try to get Admin data
      DocumentSnapshot adminDoc =
          await _firestore.collection('admins').doc(currentUser!.uid).get();
      if (adminDoc.exists) {
        Admin admin = Admin.fromFirestore(adminDoc);
        return {'success': true, 'user': admin, 'role': 'admin'};
      }

      // Try to get organizer data
      DocumentSnapshot organizerDoc =
          await _firestore.collection('organizers').doc(currentUser!.uid).get();
      if (organizerDoc.exists) {
        Organizer organizer = Organizer.fromFirestore(organizerDoc);
        return {'success': true, 'user': organizer, 'role': 'organizer'};
      }

      // Try to get attendee data
      DocumentSnapshot attendeeDoc =
          await _firestore.collection('attendees').doc(currentUser!.uid).get();
      if (attendeeDoc.exists) {
        Attendee attendee = Attendee.fromFirestore(attendeeDoc);
        return {'success': true, 'user': attendee, 'role': 'attendee'};
      }

      // Try to get staff data
      DocumentSnapshot staffDoc =
          await _firestore.collection('staff').doc(currentUser!.uid).get();
      if (staffDoc.exists) {
        Staff staff = Staff.fromFirestore(staffDoc);
        return {'success': true, 'user': staff, 'role': 'staff'};
      }

      return {'success': false, 'message': 'User data not found'};
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {'success': false, 'message': 'Failed to retrieve user data'};
    } finally {
      _setLoading(false);
    }
  }

  // Check if email is verified
  Future<bool> checkEmailVerified() async {
    try {
      // Reload user to get latest verification status
      await currentUser?.reload();
      return currentUser?.emailVerified ?? false;
    } catch (e) {
      return false;
    }
  }

  // Resend email verification
  Future<Map<String, dynamic>> resendVerificationEmail() async {
    _setLoading(true);
    try {
      if (currentUser == null) {
        return {'success': false, 'message': 'No user is currently signed in'};
      }

      await currentUser!.sendEmailVerification();
      return {'success': true, 'message': 'Verification email sent'};
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {
        'success': false,
        'message': 'Failed to send verification email. Please try again.',
      };
    } finally {
      _setLoading(false);
    }
  }

  // Password reset
  Future<Map<String, dynamic>> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    try {
      if (email.isEmpty) {
        return {'success': false, 'message': 'Email is required'};
      }

      await _auth.sendPasswordResetEmail(email: email);
      return {'success': true, 'message': 'Password reset email sent'};
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email format';
          break;
        default:
          errorMessage = 'Password reset failed. Please try again.';
      }
      return {'success': false, 'message': errorMessage};
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {
        'success': false,
        'message': 'Password reset failed. Please try again later.',
      };
    } finally {
      _setLoading(false);
    }
  }

  // Change password method
  Future<Map<String, dynamic>> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    _setLoading(true);
    try {
      if (currentUser == null) {
        return {'success': false, 'message': 'No user is currently signed in'};
      }

      if (currentPassword.isEmpty || newPassword.isEmpty) {
        return {
          'success': false,
          'message': 'Current password and new password are required',
        };
      }

      if (currentPassword == newPassword) {
        return {
          'success': false,
          'message': 'New password must be different from current password',
        };
      }

      // Re-authenticate user with current password
      final credential = EmailAuthProvider.credential(
        email: currentUser!.email!,
        password: currentPassword,
      );

      await currentUser!.reauthenticateWithCredential(credential);

      // Update password
      await currentUser!.updatePassword(newPassword);

      return {'success': true, 'message': 'Password changed successfully'};
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'wrong-password':
          errorMessage = 'Current password is incorrect';
          break;
        case 'weak-password':
          errorMessage = 'New password is too weak';
          break;
        case 'requires-recent-login':
          errorMessage = 'Please log in again and try changing your password';
          break;
        case 'user-mismatch':
          errorMessage = 'The credential does not correspond to the user';
          break;
        case 'user-not-found':
          errorMessage = 'No user found with this email';
          break;
        case 'invalid-credential':
          errorMessage = 'Current password is incorrect';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many failed attempts. Please try again later';
          break;
        default:
          errorMessage = 'Failed to change password. Please try again.';
      }
      return {'success': false, 'message': errorMessage};
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {
        'success': false,
        'message': 'Failed to change password. Please try again later.',
      };
    } finally {
      _setLoading(false);
    }
  }

  // Sign out
  Future<Map<String, dynamic>> signOut() async {
    _setLoading(true);
    try {
      await _auth.signOut();
      return {'success': true, 'message': 'Signed out successfully'};
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {
        'success': false,
        'message': 'Failed to sign out. Please try again.',
      };
    } finally {
      _setLoading(false);
    }
  }
}
