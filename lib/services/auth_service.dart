import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:megavent/models/admin.dart';
import 'package:megavent/models/attendee.dart';
import 'package:megavent/models/organizer.dart';
import 'package:megavent/models/staff.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Secondary Firebase app for creating users without switching auth context
  FirebaseApp? _secondaryApp;
  FirebaseAuth? _secondaryAuth;

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;

  // Alternative getter that also checks email verification
  bool get isLoggedInAndVerified =>
      _auth.currentUser != null && (_auth.currentUser?.emailVerified ?? false);

  // Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // User state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Initialize secondary Firebase app for creating users
  Future<void> _initializeSecondaryApp() async {
    if (_secondaryApp == null) {
      try {
        _secondaryApp = await Firebase.initializeApp(
          name: 'SecondaryApp',
          options: Firebase.app().options,
        );
        _secondaryAuth = FirebaseAuth.instanceFor(app: _secondaryApp!);
      } catch (e) {
        // If app already exists, get it
        _secondaryApp = Firebase.app('SecondaryApp');
        _secondaryAuth = FirebaseAuth.instanceFor(app: _secondaryApp!);
      }
    }
  }

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

      // Initialize secondary app
      await _initializeSecondaryApp();

      // Create user in Firebase Auth using secondary app
      UserCredential credential = await _secondaryAuth!
          .createUserWithEmailAndPassword(email: email, password: password);

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

      // Sign out from secondary app
      await _secondaryAuth!.signOut();

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

  // Create staff member (only callable by organizer) - MODIFIED METHOD
  Future<Map<String, dynamic>> createStaff({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    required String role,
    required String department,
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
      if (!organizer.isApproved) {
        return {
          'success': false,
          'message': 'Your organizer account must be approved first',
        };
      }

      // Validate inputs
      if (fullName.isEmpty ||
          email.isEmpty ||
          password.isEmpty ||
          phone.isEmpty ||
          role.isEmpty ||
          department.isEmpty) {
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

      // Initialize secondary app
      await _initializeSecondaryApp();

      // Create user in Firebase Auth using secondary app (doesn't switch auth context)
      UserCredential credential = await _secondaryAuth!
          .createUserWithEmailAndPassword(email: email, password: password);

      // Update display name
      await credential.user!.updateDisplayName(fullName);

      // Send email verification
      await credential.user!.sendEmailVerification();

      // Create complete staff document with all fields
      Staff staff = Staff(
        id: credential.user!.uid,
        fullName: fullName,
        email: email,
        phone: phone,
        profileImage: profileImage,
        organizerId: organizer.id,
        organization: organizer.organization,
        role: role,
        department: department,
        isApproved: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        hiredAt: DateTime.now(),
      );

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
        'department': department,
        'profileImage': profileImage,
        'isApproved': true,
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
      });

      // Sign out from secondary app to avoid any auth context issues
      await _secondaryAuth!.signOut();

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

      // Reload user to get the latest verification status
      await credential.user!.reload();
      User? refreshedUser = _auth.currentUser;

      // Check email verification - but be more intelligent about it
      if (refreshedUser != null && !refreshedUser.emailVerified) {
        // First check if user data exists in Firestore (might be pre-verified)
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(refreshedUser.uid).get();

        if (!userDoc.exists) {
          await _auth.signOut();
          return {
            'success': false,
            'message': 'User account not found. Please register first.',
          };
        }

        // DON'T sign out the user - keep them authenticated for verification
        // Just return the verification status
        return {
          'success': false,
          'message': 'Please verify your email before logging in',
          'emailVerified': false,
          'needsVerification': true, // Add this flag
          'userExists': true,
        };
      }

      // Get user data based on role
      final userData = await getUserData();

      if (!userData['success']) {
        await _auth.signOut();
        return userData;
      }

      // Add additional verification status and role info
      userData['emailVerified'] = refreshedUser?.emailVerified ?? true;

      // For organizers, check approval status
      if (userData['role'] == 'organizer') {
        final organizer = userData['user'];
        userData['status'] = organizer.isApproved ? 'active' : 'pending';
      }

      return userData;
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
        case 'too-many-requests':
          errorMessage = 'Too many login attempts. Please try again later.';
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

  // Get user data based on type - UPDATED METHOD
  Future<Map<String, dynamic>> getUserData() async {
    if (currentUser == null) {
      return {'success': false, 'message': 'No user signed in'};
    }

    _setLoading(true);
    try {
      String userId = currentUser!.uid;

      // Try to get from users collection first for role identification
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        return {'success': false, 'message': 'User data not found'};
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      String userRole = userData['role'] ?? '';

      // Get detailed data from specific collection based on role
      switch (userRole) {
        case 'admin':
          DocumentSnapshot adminDoc =
              await _firestore.collection('admins').doc(userId).get();
          if (adminDoc.exists) {
            Admin admin = Admin.fromFirestore(adminDoc);
            return {
              'success': true,
              'user': admin,
              'role': 'admin',
              'emailVerified': currentUser!.emailVerified,
            };
          }
          break;

        case 'organizer':
          DocumentSnapshot organizerDoc =
              await _firestore.collection('organizers').doc(userId).get();
          if (organizerDoc.exists) {
            Organizer organizer = Organizer.fromFirestore(organizerDoc);
            return {
              'success': true,
              'user': organizer,
              'role': 'organizer',
              'status': organizer.isApproved ? 'active' : 'pending',
              'emailVerified': currentUser!.emailVerified,
            };
          }
          break;

        case 'attendee':
          DocumentSnapshot attendeeDoc =
              await _firestore.collection('attendees').doc(userId).get();
          if (attendeeDoc.exists) {
            Attendee attendee = Attendee.fromFirestore(attendeeDoc);
            return {
              'success': true,
              'user': attendee,
              'role': 'attendee',
              'emailVerified': currentUser!.emailVerified,
            };
          }
          break;

        case 'staff':
          DocumentSnapshot staffDoc =
              await _firestore.collection('staff').doc(userId).get();
          if (staffDoc.exists) {
            Staff staff = Staff.fromFirestore(staffDoc);
            return {
              'success': true,
              'user': staff,
              'role': 'staff',
              'emailVerified': currentUser!.emailVerified,
            };
          }
          break;

        default:
          return {'success': false, 'message': 'Unknown user role: $userRole'};
      }

      return {'success': false, 'message': 'User profile data not found'};
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {
        'success': false,
        'message': 'Failed to retrieve user data: ${e.toString()}',
      };
    } finally {
      _setLoading(false);
    }
  }

  // Check if email is verified with proper refresh - UPDATED METHOD
  Future<bool> checkEmailVerified() async {
    try {
      if (currentUser == null) return false;

      // Reload user to get latest verification status
      await currentUser!.reload();

      // Get the refreshed user
      User? refreshedUser = _auth.currentUser;

      return refreshedUser?.emailVerified ?? false;
    } catch (e) {
      print('Error checking email verification: $e');
      return false;
    }
  }

  // Add this method to handle verification status more intelligently
  Future<Map<String, dynamic>> checkUserVerificationStatus() async {
    try {
      if (currentUser == null) {
        return {'verified': false, 'message': 'No user signed in'};
      }

      // Reload user first
      await currentUser!.reload();
      User? refreshedUser = _auth.currentUser;

      if (refreshedUser == null) {
        return {'verified': false, 'message': 'User session expired'};
      }

      // Check if email is verified
      bool emailVerified = refreshedUser.emailVerified;

      // Also check if user exists in Firestore
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(refreshedUser.uid).get();

      if (!userDoc.exists) {
        return {'verified': false, 'message': 'User profile not found'};
      }

      return {
        'verified': emailVerified,
        'message': emailVerified ? 'Email verified' : 'Email not verified',
        'userExists': true,
      };
    } catch (e) {
      return {'verified': false, 'message': 'Verification check failed: $e'};
    }
  }

  // Resend email verification
  Future<Map<String, dynamic>> resendVerificationEmail() async {
    _setLoading(true);
    try {
      if (currentUser == null) {
        return {
          'success': false,
          'message': 'No user is currently signed in. Please login again.',
        };
      }

      // Reload user to ensure we have the latest state
      await currentUser!.reload();
      User? refreshedUser = _auth.currentUser;

      if (refreshedUser == null) {
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
        };
      }

      // Check if email is already verified
      if (refreshedUser.emailVerified) {
        return {'success': false, 'message': 'Email is already verified!'};
      }

      await refreshedUser.sendEmailVerification();
      return {
        'success': true,
        'message': 'Verification email sent successfully!',
      };
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'User not found. Please login again.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many requests. Please wait before trying again.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address.';
          break;
        default:
          errorMessage = 'Failed to send verification email. Please try again.';
      }
      return {'success': false, 'message': errorMessage};
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {
        'success': false,
        'message': 'Failed to send verification email. Please try again later.',
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

  // Clean up resources
  @override
  void dispose() {
    _secondaryApp?.delete();
    super.dispose();
  }

  // Delete staff member (only callable by organizer) - NEW METHOD
  Future<Map<String, dynamic>> deleteStaff(String staffId) async {
    _setLoading(true);
    try {
      // Check if current user is an organizer
      final currentUserData = await getUserData();
      if (!currentUserData['success'] ||
          currentUserData['role'] != 'organizer') {
        return {
          'success': false,
          'message': 'Only organizers can delete staff',
        };
      }

      // Check if organizer is approved and active
      final organizer = currentUserData['user'] as Organizer;
      if (!organizer.isApproved) {
        return {
          'success': false,
          'message': 'Your organizer account must be approved first',
        };
      }

      // Get staff data first to verify they belong to this organizer
      DocumentSnapshot staffDoc =
          await _firestore.collection('staff').doc(staffId).get();

      if (!staffDoc.exists) {
        return {'success': false, 'message': 'Staff member not found'};
      }

      Map<String, dynamic> staffData = staffDoc.data() as Map<String, dynamic>;

      // Verify this staff member belongs to the current organizer
      if (staffData['organizerId'] != organizer.id) {
        return {
          'success': false,
          'message': 'You can only delete staff members from your organization',
        };
      }

      // Start a batch write for atomic operations
      WriteBatch batch = _firestore.batch();

      // Add staff document deletion to batch
      DocumentReference staffRef = _firestore.collection('staff').doc(staffId);
      batch.delete(staffRef);

      // Add user document deletion to batch
      DocumentReference userRef = _firestore.collection('users').doc(staffId);
      batch.delete(userRef);

      // Check if staff has any associated data and clean it up

      // Delete any staff-related event assignments
      QuerySnapshot eventAssignments =
          await _firestore
              .collection('event_assignments')
              .where('staffId', isEqualTo: staffId)
              .get();

      for (DocumentSnapshot doc in eventAssignments.docs) {
        batch.delete(doc.reference);
      }

      // Delete any staff-related notifications
      QuerySnapshot notifications =
          await _firestore
              .collection('notifications')
              .where('userId', isEqualTo: staffId)
              .get();

      for (DocumentSnapshot doc in notifications.docs) {
        batch.delete(doc.reference);
      }

      // Delete any staff-related activity logs
      QuerySnapshot activityLogs =
          await _firestore
              .collection('activity_logs')
              .where('userId', isEqualTo: staffId)
              .get();

      for (DocumentSnapshot doc in activityLogs.docs) {
        batch.delete(doc.reference);
      }

      // Execute all deletions atomically
      await batch.commit();

      // Add a deletion record for audit trail
      await _firestore.collection('deleted_users').add({
        'deletedUserId': staffId,
        'deletedUserEmail': staffData['email'],
        'deletedUserName': staffData['fullName'],
        'deletedUserRole': 'staff',
        'deletedBy': organizer.id,
        'deletedByName': organizer.fullName,
        'deletedByRole': 'organizer',
        'organizationId': organizer.id,
        'organizationName': organizer.organization,
        'deletedAt': DateTime.now(),
        'reason': 'Staff member deleted by organizer',
        'authUserStatus': 'requires_manual_cleanup', // Flag for Auth cleanup
      });

      // Log the successful deletion
      await _firestore.collection('activity_logs').add({
        'userId': organizer.id,
        'userRole': 'organizer',
        'action': 'staff_deleted',
        'targetUserId': staffId,
        'targetUserEmail': staffData['email'],
        'details': {
          'staffName': staffData['fullName'],
          'staffRole': staffData['role'],
          'department': staffData['department'],
          'organizationId': organizer.id,
        },
        'timestamp': DateTime.now(),
        'success': true,
      });

      return {
        'success': true,
        'message': 'Staff member deleted successfully from all collections',
        'warning': 'Firebase Auth account cleanup may be required',
        'deletedStaffInfo': {
          'name': staffData['fullName'],
          'email': staffData['email'],
          'role': staffData['role'],
          'department': staffData['department'],
        },
      };
    } on FirebaseException catch (e) {
      // Log the failed deletion attempt
      try {
        await _firestore.collection('activity_logs').add({
          'userId': currentUser?.uid ?? 'unknown',
          'userRole': 'organizer',
          'action': 'staff_deletion_failed',
          'targetUserId': staffId,
          'error': e.message,
          'errorCode': e.code,
          'timestamp': DateTime.now(),
          'success': false,
        });
      } catch (logError) {
        print('Failed to log deletion error: $logError');
      }

      if (e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {
        'success': false,
        'message': 'Failed to delete staff member: ${e.message}',
      };
    } catch (e) {
      // Log the failed deletion attempt
      try {
        await _firestore.collection('activity_logs').add({
          'userId': currentUser?.uid ?? 'unknown',
          'userRole': 'organizer',
          'action': 'staff_deletion_failed',
          'targetUserId': staffId,
          'error': e.toString(),
          'timestamp': DateTime.now(),
          'success': false,
        });
      } catch (logError) {
        print('Failed to log deletion error: $logError');
      }

      return {
        'success': false,
        'message': 'Failed to delete staff member. Please try again later.',
      };
    } finally {
      _setLoading(false);
    }
  }

  // Helper method to get all staff members that need Auth cleanup
  Future<Map<String, dynamic>> getOrphanedAuthUsers() async {
    try {
      final currentUserData = await getUserData();
      if (!currentUserData['success'] || currentUserData['role'] != 'admin') {
        return {'success': false, 'message': 'Admin access required'};
      }

      QuerySnapshot deletedUsers =
          await _firestore
              .collection('deleted_users')
              .where('authUserStatus', isEqualTo: 'requires_manual_cleanup')
              .orderBy('deletedAt', descending: true)
              .get();

      List<Map<String, dynamic>> orphanedUsers =
          deletedUsers.docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            data['documentId'] = doc.id;
            return data;
          }).toList();

      return {
        'success': true,
        'orphanedUsers': orphanedUsers,
        'count': orphanedUsers.length,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to get orphaned users: ${e.toString()}',
      };
    }
  }

  // Helper method to mark Auth user as manually cleaned up
  Future<Map<String, dynamic>> markAuthUserCleanedUp(String documentId) async {
    try {
      await _firestore.collection('deleted_users').doc(documentId).update({
        'authUserStatus': 'manually_cleaned',
        'cleanedUpAt': DateTime.now(),
      });

      return {'success': true, 'message': 'Auth user marked as cleaned up'};
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to update cleanup status: ${e.toString()}',
      };
    }
  }

  // Delete organizer (only callable by admin)
  Future<Map<String, dynamic>> deleteOrganizer(String organizerId) async {
    _setLoading(true);
    try {
      // Check if current user is an admin
      final currentUserData = await getUserData();
      if (!currentUserData['success'] || currentUserData['role'] != 'admin') {
        return {
          'success': false,
          'message': 'Only admins can delete organizers',
        };
      }

      // Check if admin is approved and active
      final admin = currentUserData['user'] as Admin;
      if (!admin.isApproved) {
        return {
          'success': false,
          'message': 'Your admin account must be approved first',
        };
      }

      // Get organizer data first to verify they exist
      DocumentSnapshot organizerDoc =
          await _firestore.collection('organizers').doc(organizerId).get();

      if (!organizerDoc.exists) {
        return {'success': false, 'message': 'Organizer not found'};
      }

      Map<String, dynamic> organizerData =
          organizerDoc.data() as Map<String, dynamic>;

      // Start a batch write for atomic operations
      WriteBatch batch = _firestore.batch();

      // Add organizer document deletion to batch
      DocumentReference organizerRef = _firestore
          .collection('organizers')
          .doc(organizerId);
      batch.delete(organizerRef);

      // Add user document deletion to batch
      DocumentReference userRef = _firestore
          .collection('users')
          .doc(organizerId);
      batch.delete(userRef);

      // Delete all staff members created by this organizer
      QuerySnapshot staffMembers =
          await _firestore
              .collection('staff')
              .where('organizerId', isEqualTo: organizerId)
              .get();

      for (DocumentSnapshot staffDoc in staffMembers.docs) {
        batch.delete(staffDoc.reference);
        // Also delete from users collection
        batch.delete(_firestore.collection('users').doc(staffDoc.id));
      }

      // Delete any organizer-related event assignments
      QuerySnapshot eventAssignments =
          await _firestore
              .collection('event_assignments')
              .where('organizerId', isEqualTo: organizerId)
              .get();

      for (DocumentSnapshot doc in eventAssignments.docs) {
        batch.delete(doc.reference);
      }

      // Delete any events created by this organizer
      QuerySnapshot events =
          await _firestore
              .collection('events')
              .where('organizerId', isEqualTo: organizerId)
              .get();

      for (DocumentSnapshot doc in events.docs) {
        batch.delete(doc.reference);
      }

      // Delete any organizer-related notifications
      QuerySnapshot notifications =
          await _firestore
              .collection('notifications')
              .where('userId', isEqualTo: organizerId)
              .get();

      for (DocumentSnapshot doc in notifications.docs) {
        batch.delete(doc.reference);
      }

      // Delete any organizer-related activity logs
      QuerySnapshot activityLogs =
          await _firestore
              .collection('activity_logs')
              .where('userId', isEqualTo: organizerId)
              .get();

      for (DocumentSnapshot doc in activityLogs.docs) {
        batch.delete(doc.reference);
      }

      // Execute all deletions atomically
      await batch.commit();

      // Add a deletion record for audit trail
      await _firestore.collection('deleted_users').add({
        'deletedUserId': organizerId,
        'deletedUserEmail': organizerData['email'],
        'deletedUserName': organizerData['fullName'],
        'deletedUserRole': 'organizer',
        'deletedBy': admin.id,
        'deletedByName': admin.fullName,
        'deletedByRole': 'admin',
        'organizationName': organizerData['organization'],
        'deletedAt': DateTime.now(),
        'reason': 'Organizer deleted by admin',
        'authUserStatus': 'requires_manual_cleanup', // Flag for Auth cleanup
        'staffDeletedCount': staffMembers.docs.length,
      });

      // Log the successful deletion
      await _firestore.collection('activity_logs').add({
        'userId': admin.id,
        'userRole': 'admin',
        'action': 'organizer_deleted',
        'targetUserId': organizerId,
        'targetUserEmail': organizerData['email'],
        'details': {
          'organizerName': organizerData['fullName'],
          'organizationName': organizerData['organization'],
          'staffDeletedCount': staffMembers.docs.length,
          'eventsDeletedCount': events.docs.length,
        },
        'timestamp': DateTime.now(),
        'success': true,
      });

      return {
        'success': true,
        'message': 'Organizer and all related data deleted successfully',
        'warning': 'Firebase Auth account cleanup may be required',
        'deletedOrganizerInfo': {
          'name': organizerData['fullName'],
          'email': organizerData['email'],
          'organization': organizerData['organization'],
          'staffDeletedCount': staffMembers.docs.length,
          'eventsDeletedCount': events.docs.length,
        },
      };
    } on FirebaseException catch (e) {
      // Log the failed deletion attempt
      try {
        await _firestore.collection('activity_logs').add({
          'userId': currentUser?.uid ?? 'unknown',
          'userRole': 'admin',
          'action': 'organizer_deletion_failed',
          'targetUserId': organizerId,
          'error': e.message,
          'errorCode': e.code,
          'timestamp': DateTime.now(),
          'success': false,
        });
      } catch (logError) {
        print('Failed to log deletion error: $logError');
      }

      if (e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {
        'success': false,
        'message': 'Failed to delete organizer: ${e.message}',
      };
    } catch (e) {
      // Log the failed deletion attempt
      try {
        await _firestore.collection('activity_logs').add({
          'userId': currentUser?.uid ?? 'unknown',
          'userRole': 'admin',
          'action': 'organizer_deletion_failed',
          'targetUserId': organizerId,
          'error': e.toString(),
          'timestamp': DateTime.now(),
          'success': false,
        });
      } catch (logError) {
        print('Failed to log deletion error: $logError');
      }

      return {
        'success': false,
        'message': 'Failed to delete organizer. Please try again later.',
      };
    } finally {
      _setLoading(false);
    }
  }
}
