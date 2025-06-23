import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:megavent/models/attendee.dart';
import 'package:megavent/models/organizer.dart';
import 'package:megavent/models/staff.dart';
import 'package:megavent/models/admin.dart';

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

  // Get all attendees
  Future<Map<String, dynamic>> getAllAttendees() async {
    _setLoading(true);
    try {
      final attendeeDocs = await _firestore.collection('attendees').get();

      List<Attendee> attendees = [];
      for (var doc in attendeeDocs.docs) {
        attendees.add(Attendee.fromFirestore(doc));
      }

      return {'success': true, 'data': attendees};
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {'success': false, 'message': 'Failed to retrieve attendees data'};
    } finally {
      _setLoading(false);
    }
  }

  // Get all organizers
  Future<Map<String, dynamic>> getAllOrganizers() async {
    _setLoading(true);
    try {
      final organizerDocs = await _firestore.collection('organizers').get();

      List<Organizer> organizers = [];
      for (var doc in organizerDocs.docs) {
        organizers.add(Organizer.fromFirestore(doc));
      }

      return {'success': true, 'data': organizers};
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {
        'success': false,
        'message': 'Failed to retrieve organizers data',
      };
    } finally {
      _setLoading(false);
    }
  }

  // Get all staff members
  Future<Map<String, dynamic>> getAllStaff({String? organizerId}) async {
    _setLoading(true);
    try {
      Query query = _firestore.collection('staff');

      if (organizerId != null) {
        query = query.where('organizerId', isEqualTo: organizerId);
      }

      final staffDocs = await query.get();

      List<Staff> staff = [];
      for (var doc in staffDocs.docs) {
        staff.add(Staff.fromFirestore(doc));
      }

      return {'success': true, 'data': staff};
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {'success': false, 'message': 'Failed to retrieve staff data'};
    } finally {
      _setLoading(false);
    }
  }

  // Get pending organizers (for admin approval)
  Future<Map<String, dynamic>> getPendingOrganizers() async {
    _setLoading(true);
    try {
      final organizerDocs =
          await _firestore
              .collection('organizers')
              .where('isApproved', isEqualTo: false)
              .orderBy('createdAt', descending: true)
              .get();

      List<Organizer> organizers = [];
      for (var doc in organizerDocs.docs) {
        organizers.add(Organizer.fromFirestore(doc));
      }

      return {'success': true, 'data': organizers};
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {
        'success': false,
        'message': 'Failed to retrieve pending organizers',
      };
    } finally {
      _setLoading(false);
    }
  }

  // Get approved organizers
  Future<Map<String, dynamic>> getApprovedOrganizers() async {
    _setLoading(true);
    try {
      final organizerDocs =
          await _firestore
              .collection('organizers')
              .where('isApproved', isEqualTo: true)
              .where('isActive', isEqualTo: true)
              .orderBy('createdAt', descending: true)
              .get();

      List<Organizer> organizers = [];
      for (var doc in organizerDocs.docs) {
        organizers.add(Organizer.fromFirestore(doc));
      }

      return {'success': true, 'data': organizers};
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {
        'success': false,
        'message': 'Failed to retrieve approved organizers',
      };
    } finally {
      _setLoading(false);
    }
  }

  // Approve organizer
  Future<Map<String, dynamic>> approveOrganizer(String organizerId) async {
    _setLoading(true);
    try {
      // Update organizer document
      await _firestore.collection('organizers').doc(organizerId).update({
        'isApproved': true,
        'isActive': true,
        'approvedAt': DateTime.now(),
        'approvedBy': currentUser?.uid,
        'updatedAt': DateTime.now(),
      });

      // Update user document
      await _firestore.collection('users').doc(organizerId).update({
        'isApproved': true,
        'isActive': true,
        'approvedAt': DateTime.now(),
        'approvedBy': currentUser?.uid,
        'updatedAt': DateTime.now(),
      });

      return {'success': true, 'message': 'Organizer approved successfully'};
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {'success': false, 'message': 'Failed to approve organizer'};
    } finally {
      _setLoading(false);
    }
  }

  // Update user profile
  Future<Map<String, dynamic>> updateUserProfile({
    required String userId,
    required String userType,
    required Map<String, dynamic> updates,
  }) async {
    _setLoading(true);
    try {
      // Add timestamp
      updates['updatedAt'] = DateTime.now();
      updates['updatedBy'] = currentUser?.uid;

      // Update in specific collection
      await _firestore.collection(userType).doc(userId).update(updates);

      // Update in users collection (exclude collection-specific fields)
      Map<String, dynamic> userUpdates = Map.from(updates);
      userUpdates.removeWhere(
        (key, value) =>
            key.startsWith('organization') && userType != 'organizers' ||
            key.startsWith('staff') && userType != 'staff',
      );

      await _firestore.collection('users').doc(userId).update(userUpdates);

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

  // Get user by ID
  Future<Map<String, dynamic>> getUserById(String userId) async {
    _setLoading(true);
    try {
      // Get from users collection first to determine type
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        return {'success': false, 'message': 'User not found'};
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      String role = userData['role'];

      // Get detailed data from specific collection
      DocumentSnapshot detailedDoc;
      dynamic user;

      switch (role) {
        case 'attendee':
          detailedDoc =
              await _firestore.collection('attendees').doc(userId).get();
          if (detailedDoc.exists) {
            user = Attendee.fromFirestore(detailedDoc);
          }
          break;
        case 'organizer':
          detailedDoc =
              await _firestore.collection('organizers').doc(userId).get();
          if (detailedDoc.exists) {
            user = Organizer.fromFirestore(detailedDoc);
          }
          break;
        case 'staff':
          detailedDoc = await _firestore.collection('staff').doc(userId).get();
          if (detailedDoc.exists) {
            user = Staff.fromFirestore(detailedDoc);
          }
          break;
        case 'admin':
          detailedDoc = await _firestore.collection('admins').doc(userId).get();
          if (detailedDoc.exists) {
            user = Admin.fromFirestore(detailedDoc);
          }
          break;
        default:
          return {'success': false, 'message': 'Invalid user role'};
      }

      if (user == null) {
        return {'success': false, 'message': 'User details not found'};
      }

      return {'success': true, 'user': user, 'role': role};
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {'success': false, 'message': 'Failed to retrieve user data'};
    } finally {
      _setLoading(false);
    }
  }

  // Search users
  Future<Map<String, dynamic>> searchUsers({
    required String searchTerm,
    String? role,
    int limit = 20,
  }) async {
    _setLoading(true);
    try {
      Query query = _firestore.collection('users');

      if (role != null && role.isNotEmpty) {
        query = query.where('role', isEqualTo: role);
      }

      // For name search, we'll use a simple approach with where clause
      // Note: For better search, consider using Algolia or similar service
      if (searchTerm.isNotEmpty) {
        query = query
            .where('fullName', isGreaterThanOrEqualTo: searchTerm)
            .where('fullName', isLessThanOrEqualTo: '$searchTerm\uf8ff');
      }

      query = query.limit(limit);

      final userDocs = await query.get();
      List<Map<String, dynamic>> users = [];

      for (var doc in userDocs.docs) {
        Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
        users.add(userData);
      }

      return {'success': true, 'data': users};
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {'success': false, 'message': 'Failed to search users'};
    } finally {
      _setLoading(false);
    }
  }

  // Get user statistics
  Future<Map<String, dynamic>> getUserStatistics() async {
    _setLoading(true);
    try {
      // Get counts for each user type
      final attendeesCount =
          await _firestore.collection('attendees').count().get();
      final organizersCount =
          await _firestore.collection('organizers').count().get();
      final staffCount = await _firestore.collection('staff').count().get();
      final adminsCount = await _firestore.collection('admins').count().get();

      // Get pending organizers count
      final pendingOrganizersCount =
          await _firestore
              .collection('organizers')
              .where('isApproved', isEqualTo: false)
              .count()
              .get();

      // Get active users count
      final activeUsersCount =
          await _firestore
              .collection('users')
              .where('isActive', isEqualTo: true)
              .count()
              .get();

      Map<String, dynamic> stats = {
        'totalUsers':
            attendeesCount.count! +
            organizersCount.count! +
            staffCount.count! +
            adminsCount.count!,
        'attendees': attendeesCount.count!,
        'organizers': organizersCount.count!,
        'staff': staffCount.count!,
        'admins': adminsCount.count!,
        'pendingOrganizers': pendingOrganizersCount.count!,
        'activeUsers': activeUsersCount.count!,
      };

      return {'success': true, 'data': stats};
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {'success': false, 'message': 'Failed to retrieve statistics'};
    } finally {
      _setLoading(false);
    }
  }

  // Delete user (soft delete by deactivating)
  Future<Map<String, dynamic>> deleteUser(
    String userId,
    String userType,
  ) async {
    _setLoading(true);
    try {
      // Instead of hard delete, we'll deactivate the user
      await _firestore.collection(userType).doc(userId).update({
        'isActive': false,
        'isDeleted': true,
        'deletedAt': DateTime.now(),
        'deletedBy': currentUser?.uid,
        'updatedAt': DateTime.now(),
      });

      await _firestore.collection('users').doc(userId).update({
        'isActive': false,
        'isDeleted': true,
        'deletedAt': DateTime.now(),
        'deletedBy': currentUser?.uid,
        'updatedAt': DateTime.now(),
      });

      return {'success': true, 'message': 'User deleted successfully'};
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {'success': false, 'message': 'Failed to delete user'};
    } finally {
      _setLoading(false);
    }
  }

  // Bulk operations for admin
  Future<Map<String, dynamic>> bulkUpdateUsers({
    required List<String> userIds,
    required String userType,
    required Map<String, dynamic> updates,
  }) async {
    _setLoading(true);
    try {
      WriteBatch batch = _firestore.batch();

      updates['updatedAt'] = DateTime.now();
      updates['updatedBy'] = currentUser?.uid;

      for (String userId in userIds) {
        // Update in specific collection
        DocumentReference userTypeRef = _firestore
            .collection(userType)
            .doc(userId);
        batch.update(userTypeRef, updates);

        // Update in users collection
        DocumentReference userRef = _firestore.collection('users').doc(userId);
        batch.update(userRef, updates);
      }

      await batch.commit();

      return {'success': true, 'message': 'Bulk update completed successfully'};
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {'success': false, 'message': 'Failed to perform bulk update'};
    } finally {
      _setLoading(false);
    }
  }

  // Stream methods for real-time updates
  Stream<List<Organizer>> streamPendingOrganizers() {
    return _firestore
        .collection('organizers')
        .where('isApproved', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Organizer.fromFirestore(doc)).toList(),
        );
  }

  Stream<List<dynamic>> streamUsersByType(String userType) {
    return _firestore
        .collection(userType)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          switch (userType) {
            case 'attendees':
              return snapshot.docs
                  .map((doc) => Attendee.fromFirestore(doc))
                  .toList();
            case 'organizers':
              return snapshot.docs
                  .map((doc) => Organizer.fromFirestore(doc))
                  .toList();
            case 'staff':
              return snapshot.docs
                  .map((doc) => Staff.fromFirestore(doc))
                  .toList();
            case 'admins':
              return snapshot.docs
                  .map((doc) => Admin.fromFirestore(doc))
                  .toList();
            default:
              return [];
          }
        });
  }

  // Get event by ID
  Future<Map<String, dynamic>> getEventById(String eventId) async {
    _setLoading(true);
    try {
      DocumentSnapshot eventDoc =
          await _firestore.collection('events').doc(eventId).get();

      if (!eventDoc.exists) {
        return {'success': false, 'message': 'Event not found'};
      }

      Map<String, dynamic> eventData = eventDoc.data() as Map<String, dynamic>;
      eventData['id'] = eventDoc.id;

      return {'success': true, 'event': eventData};
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {'success': false, 'message': 'Failed to retrieve event data'};
    } finally {
      _setLoading(false);
    }
  }

  // Check if user is registered for event
  Future<Map<String, dynamic>> isUserRegisteredForEvent(
    String userId,
    String eventId,
  ) async {
    _setLoading(true);
    try {
      QuerySnapshot registrationQuery =
          await _firestore
              .collection('registrations')
              .where('userId', isEqualTo: userId)
              .where('eventId', isEqualTo: eventId)
              .where('status', isEqualTo: 'registered')
              .get();

      bool isRegistered = registrationQuery.docs.isNotEmpty;

      return {'success': true, 'isRegistered': isRegistered};
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {
        'success': false,
        'message': 'Failed to check registration status',
      };
    } finally {
      _setLoading(false);
    }
  }

  // Get event capacity information
  Future<Map<String, dynamic>> getEventCapacityInfo(String eventId) async {
    _setLoading(true);
    try {
      // Get event details
      DocumentSnapshot eventDoc =
          await _firestore.collection('events').doc(eventId).get();

      if (!eventDoc.exists) {
        return {'success': false, 'message': 'Event not found'};
      }

      Map<String, dynamic> eventData = eventDoc.data() as Map<String, dynamic>;
      int capacity = eventData['capacity'] ?? 0;

      // Get registration count
      QuerySnapshot registrationsQuery =
          await _firestore
              .collection('registrations')
              .where('eventId', isEqualTo: eventId)
              .where('status', isEqualTo: 'registered')
              .get();

      int registeredCount = registrationsQuery.docs.length;
      bool isFull = registeredCount >= capacity;

      return {
        'success': true,
        'capacity': capacity,
        'registeredCount': registeredCount,
        'isFull': isFull,
        'availableSpots': capacity - registeredCount,
      };
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {'success': false, 'message': 'Failed to check event capacity'};
    } finally {
      _setLoading(false);
    }
  }

  // Register user for event
  Future<Map<String, dynamic>> registerUserForEvent(
    String userId,
    String eventId,
  ) async {
    _setLoading(true);
    try {
      // Check if user is already registered
      final registrationCheck = await isUserRegisteredForEvent(userId, eventId);
      if (!registrationCheck['success']) {
        return registrationCheck;
      }

      if (registrationCheck['isRegistered']) {
        return {
          'success': false,
          'message': 'User is already registered for this event',
        };
      }

      // Check event capacity
      final capacityInfo = await getEventCapacityInfo(eventId);
      if (!capacityInfo['success']) {
        return capacityInfo;
      }

      if (capacityInfo['isFull']) {
        return {'success': false, 'message': 'Event is full'};
      }

      // Get event details
      final eventResult = await getEventById(eventId);
      if (!eventResult['success']) {
        return eventResult;
      }

      // Get user details
      final userResult = await getUserById(userId);
      if (!userResult['success']) {
        return userResult;
      }

      // Create registration document
      String registrationId = _firestore.collection('registrations').doc().id;

      Map<String, dynamic> registrationData = {
        'id': registrationId,
        'userId': userId,
        'eventId': eventId,
        'status': 'registered',
        'registrationDate': DateTime.now(),
        'paymentStatus': 'pending', // or 'completed' based on your logic
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
      };

      // Add registration to database
      await _firestore
          .collection('registrations')
          .doc(registrationId)
          .set(registrationData);

      // Update event registered count (optional - you can calculate this dynamically)
      await _firestore.collection('events').doc(eventId).update({
        'registeredCount': FieldValue.increment(1),
        'updatedAt': DateTime.now(),
      });

      return {
        'success': true,
        'message': 'Registration successful',
        'registrationId': registrationId,
      };
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {'success': false, 'message': 'Failed to register for event'};
    } finally {
      _setLoading(false);
    }
  }

  // Get user's registered events
  Future<Map<String, dynamic>> getUserRegisteredEvents(String userId) async {
    _setLoading(true);
    try {
      QuerySnapshot registrationsQuery =
          await _firestore
              .collection('registrations')
              .where('userId', isEqualTo: userId)
              .where('status', isEqualTo: 'registered')
              .orderBy('registrationDate', descending: true)
              .get();

      List<Map<String, dynamic>> registeredEvents = [];

      for (var registrationDoc in registrationsQuery.docs) {
        Map<String, dynamic> registrationData =
            registrationDoc.data() as Map<String, dynamic>;
        String eventId = registrationData['eventId'];

        // Get event details
        DocumentSnapshot eventDoc =
            await _firestore.collection('events').doc(eventId).get();
        if (eventDoc.exists) {
          Map<String, dynamic> eventData =
              eventDoc.data() as Map<String, dynamic>;
          eventData['id'] = eventDoc.id;
          eventData['registrationData'] = registrationData;
          registeredEvents.add(eventData);
        }
      }

      return {'success': true, 'events': registeredEvents};
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {
        'success': false,
        'message': 'Failed to retrieve registered events',
      };
    } finally {
      _setLoading(false);
    }
  }

  // Cancel event registration
  Future<Map<String, dynamic>> cancelEventRegistration(
    String userId,
    String eventId,
  ) async {
    _setLoading(true);
    try {
      // Find the registration
      QuerySnapshot registrationsQuery =
          await _firestore
              .collection('registrations')
              .where('userId', isEqualTo: userId)
              .where('eventId', isEqualTo: eventId)
              .where('status', isEqualTo: 'registered')
              .get();

      if (registrationsQuery.docs.isEmpty) {
        return {'success': false, 'message': 'Registration not found'};
      }

      // Update registration status
      String registrationId = registrationsQuery.docs.first.id;
      await _firestore.collection('registrations').doc(registrationId).update({
        'status': 'cancelled',
        'cancelledAt': DateTime.now(),
        'updatedAt': DateTime.now(),
      });

      // Update event registered count
      await _firestore.collection('events').doc(eventId).update({
        'registeredCount': FieldValue.increment(-1),
        'updatedAt': DateTime.now(),
      });

      return {
        'success': true,
        'message': 'Registration cancelled successfully',
      };
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {'success': false, 'message': 'Failed to cancel registration'};
    } finally {
      _setLoading(false);
    }
  }

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
    } catch (e) {
      throw Exception('Failed to update organizer profile: $e');
    }
  }
}
