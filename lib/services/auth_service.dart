import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

  // Register student with email and password
  Future<Map<String, dynamic>> registerStudent({
    required String fullName,
    required String email,
    required String password,
    required String studentId,
    required String phone,
    required String course,
    required double yearOfStudy,
    String? profileImage,
    Map<String, dynamic>? identificationImages,
    required String mpesaPhone,
    required String institutionName,
    Map<String, dynamic>? guarantorDetails,
    required bool Function(String) emailValidator,
  }) async {
    _setLoading(true);
    try {
      // Validate inputs
      if (fullName.isEmpty ||
          email.isEmpty ||
          password.isEmpty ||
          studentId.isEmpty ||
          phone.isEmpty ||
          mpesaPhone.isEmpty ||
          institutionName.isEmpty) {
        return {'success': false, 'message': 'All fields are required'};
      }

      // Check if email is a university email
      if (!emailValidator(email)) {
        return {
          'success': false,
          'message': 'Please use a valid university email'
        };
      }

      // Check if email is already used
      final emailQuery = await _firestore
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

      // Create student document
      Student student = Student(
        id: credential.user!.uid,
        fullName: fullName,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('students')
          .doc(credential.user!.uid)
          .set(student.toMap());

      return {
        'success': true,
        'message': 'Registration successful! Please verify your email.',
        'user': student
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
        'message': 'Registration failed. Please try again later.'
      };
    } finally {
      _setLoading(false);
    }
  }

  // Register provider with email and password
  Future<Map<String, dynamic>> registerProvider({
    required String businessName,
    required String email,
  }) async {
    _setLoading(true);
    try {
      // Validate inputs
      if (businessName.isEmpty ||
          email.isEmpty ||
          password.isEmpty ||
          phone.isEmpty) {
        return {'success': false, 'message': 'All fields are required'};
      }

      // Check if email is valid
      if (!emailValidator(email)) {
        return {
          'success': false,
          'message': 'Please use a valid business email'
        };
      }

      // Check if email is already used
      final emailQuery = await _firestore
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
      await credential.user!.updateDisplayName(businessName);

      // Send email verification
      await credential.user!.sendEmailVerification();

      // Create provider document
      Provider provider = Provider(
        id: credential.user!.uid,
        businessName: businessName,
        businessEmail: email,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('providers')
          .doc(credential.user!.uid)
          .set(provider.toMap());

      return {
        'success': true,
        'message': 'Registration successful! Please verify your email.',
        'user': provider
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
        'message': 'Registration failed. Please try again later.'
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
          'message': 'Current password and new password are required'
        };
      }

      if (currentPassword == newPassword) {
        return {
          'success': false,
          'message': 'New password must be different from current password'
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
        'message': 'Failed to change password. Please try again later.'
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

      // Check email verification
      if (!credential.user!.emailVerified) {
        await _auth.signOut();
        return {
          'success': false,
          'message': 'Please verify your email before logging in'
        };
      }

      // Determine user type and get appropriate data
      // Check if student
      DocumentSnapshot studentDoc = await _firestore
          .collection('students')
          .doc(credential.user!.uid)
          .get();
      if (studentDoc.exists) {
        Student student = Student.fromFirestore(studentDoc);
        return {
          'success': true,
          'message': 'Login successful',
          'user': student,
          'role': 'student'
        };
      }

      // Check if provider
      DocumentSnapshot providerDoc = await _firestore
          .collection('providers')
          .doc(credential.user!.uid)
          .get();
      if (providerDoc.exists) {
        Provider provider = Provider.fromFirestore(providerDoc);
        return {
          'success': true,
          'message': 'Login successful',
          'user': provider,
          'role': 'provider'
        };
      }

      // If we get here, user has auth account but no document in Firestore
      await _auth.signOut();
      return {'success': false, 'message': 'User account not found'};
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
        'message': 'Login failed. Please try again later.'
      };
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
        'message': 'Failed to send verification email. Please try again.'
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
        'message': 'Password reset failed. Please try again later.'
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
      // Try to get admin data
      DocumentSnapshot adminDoc =
          await _firestore.collection('admins').doc(currentUser!.uid).get();
      if (adminDoc.exists) {
        Admin admin = Admin.fromFirestore(adminDoc);
        return {'success': true, 'user': admin, 'role': 'admin'};
      }

      // Try to get student data
      DocumentSnapshot studentDoc =
          await _firestore.collection('students').doc(currentUser!.uid).get();
      if (studentDoc.exists) {
        Student student = Student.fromFirestore(studentDoc);
        return {'success': true, 'user': student, 'role': 'student'};
      }

      // Try to get provider data
      DocumentSnapshot providerDoc =
          await _firestore.collection('providers').doc(currentUser!.uid).get();
      if (providerDoc.exists) {
        Provider provider = Provider.fromFirestore(providerDoc);
        return {'success': true, 'user': provider, 'role': 'provider'};
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
        'message': 'Failed to sign out. Please try again.'
      };
    } finally {
      _setLoading(false);
    }
  }
}
