import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:megavent/models/admin_dashboard_stats.dart';
import 'package:megavent/models/attendee_stats.dart';
import 'package:megavent/models/event.dart';
import 'package:megavent/models/attendee.dart';
import 'package:megavent/models/organizer_attendee_stats.dart';
import 'package:megavent/models/organizer.dart';
import 'package:megavent/models/staff.dart';
import 'package:megavent/models/registration.dart';
import 'package:megavent/services/modules/database_service/attendee_service.dart';
import 'package:megavent/services/modules/database_service/attendee_stats.dart';
import 'package:megavent/services/modules/database_service/event_service.dart';
import 'package:megavent/services/modules/database_service/organizer_service.dart';
import 'package:megavent/services/modules/database_service/registration_service.dart';
import 'package:megavent/services/modules/database_service/staff_service.dart';
import 'package:megavent/services/modules/database_service/dashboard_service.dart';
import 'package:megavent/services/modules/database_service/stats_service.dart';

class DatabaseService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Service modules
  late final OrganizerService _organizerService;
  late final EventService _eventService;
  late final StaffService _staffService;
  late final AttendeeService _attendeeService;
  late final AttendeeStatsService _attendeeStatsService;
  late final RegistrationService _registrationService;
  late final DashboardService _dashboardService;
  late final StatsService _statsService;

  DatabaseService() {
    // Initialize service modules with shared dependencies
    _organizerService = OrganizerService(_firestore, _auth, this);
    _eventService = EventService(_firestore, _auth, this);
    _staffService = StaffService(_firestore, _auth, this);
    _attendeeService = AttendeeService(_firestore, _auth, this);
    _attendeeStatsService = AttendeeStatsService(_firestore, _auth, this);
    _registrationService = RegistrationService(_firestore, _auth, this);
    _dashboardService = DashboardService(_firestore, _auth, this);
    _statsService = StatsService(_firestore, _auth, this);
  }

  /**
   * ====== GET USER FROM AUTH SERVICE ======
   */
  // Get current user
  User? get currentUser => _auth.currentUser;

  /**
   * ====== ORGANIZER METHODS ======
   */
  Stream<Organizer?> streamCurrentOrganizerData() =>
      _organizerService.streamCurrentOrganizerData();

  Future<void> updateOrganizerProfile(Organizer organizer) =>
      _organizerService.updateOrganizerProfile(organizer);

  // New method to update only specific fields
  Future<void> updateOrganizerProfileFields(
    String organizerId,
    Map<String, dynamic> fields,
  ) => _organizerService.updateOrganizerProfileFields(organizerId, fields);

  /**
   * ====== EVENT METHODS ======
   */
  Future<String> createEvent(Event event) => _eventService.createEvent(event);

  Future<void> updateEvent(Event event) => _eventService.updateEvent(event);

  Future<void> deleteEvent(String eventId) =>
      _eventService.deleteEvent(eventId);

  Future<List<Event>> getEvents() => _eventService.getEvents();

  Future<Event?> getEventById(String eventId) =>
      _eventService.getEventById(eventId);

  Stream<Event?> streamEventById(String eventId) =>
      _eventService.streamEventById(eventId);

  Stream<List<Event>> streamAllEvents() => _eventService.streamAllEvents();

  Stream<List<Event>> streamEventsByOrganizer() =>
      _eventService.streamEventsByOrganizer();

  Stream<List<Event>> streamEventsByCategory(String category) =>
      _eventService.streamEventsByCategory(category);

  Stream<List<Event>> streamUpcomingEvents() =>
      _eventService.streamUpcomingEvents();

  List<String> getEventCategories() => _eventService.getEventCategories();

  Stream<List<Event>> searchEvents(String query) =>
      _eventService.searchEvents(query);

  /**
   * ====== STAFF METHODS ======
   */
  Future<List<Map<String, dynamic>>> getLatestStaff() =>
      _staffService.getLatestStaff();

  Future<List<Staff>> getAllStaff() => _staffService.getAllStaff();

  Stream<List<Staff>> streamStaff() => _staffService.streamStaff();

  Future<String> addStaff(Staff staff) => _staffService.addStaff(staff);

  Future<void> updateStaff(Staff staff) => _staffService.updateStaff(staff);

  Future<void> deleteStaff(String staffId) =>
      _staffService.deleteStaff(staffId);

  Future<List<Event>> getEventsForOrganizer(String organizerId) {
    return _eventService.getEventsForOrganizer(organizerId);
  }

  Future<List<Attendee>> getStaffAttendees(String staffId) {
    return _attendeeService.getStaffAttendees(staffId);
  }

  Future<Map<String, dynamic>> getStaffDashboardStats(String staffId) {
    return _dashboardService.getStaffDashboardStats(staffId);
  }

  // Stream current staff data (for authenticated staff user)
  Stream<Staff?> streamCurrentStaffData() =>
      _staffService.streamCurrentStaffData();

  // Get current staff data as a one-time fetch
  Future<Staff?> getCurrentStaffData() => _staffService.getCurrentStaffData();

  Future<void> updateStaffProfileFields(
    String staffId,
    Map<String, dynamic> fields,
  ) => _staffService.updateStaffProfileFields(staffId, fields);

  /**
   * ====== ATTENDEE METHODS ======
   */
  // New methods returning Attendee objects
  Future<List<Attendee>> getLatestAttendees() =>
      _attendeeService.getLatestAttendees();

  Future<List<Attendee>> getAllAttendees() =>
      _attendeeService.getAllAttendees();

  Future<List<Attendee>> getEventAttendees(String eventId) =>
      _attendeeService.getEventAttendees(eventId);

  Stream<List<Attendee>> streamEventAttendees(String eventId) =>
      _attendeeService.streamEventAttendees(eventId);

  // Legacy methods for backward compatibility (returning Map format)
  Future<List<Map<String, dynamic>>> getLatestAttendeesAsMap() =>
      _attendeeService.getLatestAttendeesAsMap();

  Future<List<Map<String, dynamic>>> getAllAttendeesAsMap() =>
      _attendeeService.getAllAttendeesAsMap();

  Future<List<Map<String, dynamic>>> getEventAttendeesAsMap(String eventId) =>
      _attendeeService.getEventAttendeesAsMap(eventId);

  Stream<Attendee?> streamAttendeeData() =>
      _attendeeService.streamAttendeeData();

  Future<void> updateAttendeeProfile(Attendee attendee) =>
      _attendeeService.updateAttendeeProfile(attendee);

  Future<void> updateAttendeeProfileFields(
    String attendeeId,
    Map<String, dynamic> fields,
  ) => _attendeeService.updateAttendeeProfileFields(attendeeId, fields);

  Future<Attendee?> getCurrentAttendeeData() =>
      _attendeeService.getCurrentAttendeeData();

  Future<AttendeeStats> getAttendeePersonalStats(String userId) =>
      _attendeeService.getAttendeePersonalStats(userId);

  /**
   * ====== ATTENDEE STATS METHODS ======
   */
  Future<OrganizerAttendeeStats> getAttendeeStats() =>
      _attendeeStatsService.getAttendeeStats();

  Future<OrganizerAttendeeStats> getEventAttendeeStats(String eventId) =>
      _attendeeStatsService.getEventAttendeeStats(eventId);

  Stream<OrganizerAttendeeStats> streamAttendeeStats() =>
      _attendeeStatsService.streamAttendeeStats();

  Future<Map<String, int>> getAttendanceGrowthData() =>
      _attendeeStatsService.getAttendanceGrowthData();

  Future<List<Map<String, dynamic>>> getTopEventsByAttendees({int limit = 5}) =>
      _attendeeStatsService.getTopEventsByAttendees(limit: limit);

  Future<Map<String, dynamic>> getAttendanceTrends() =>
      _attendeeStatsService.getAttendanceTrends();

  Future<Map<String, String>> getEventIdToNameMap() =>
      _attendeeStatsService.getEventIdToNameMap();

  Future<List<Registration>> getEventRegistrations(String eventId) =>
      _attendeeStatsService.getEventRegistrations(eventId);

  /// Stream registrations for a specific event with real-time updates
  Stream<List<Registration>> streamEventRegistrations(String eventId) =>
      _attendeeStatsService.streamEventRegistrations(eventId);

  /**
   * ====== REGISTRATION & QR CODE METHODS ======
   */
  Future<bool> isUserRegisteredForEvent(String uid, String eventId) =>
      _registrationService.isUserRegisteredForEvent(uid, eventId);

  Future<Map<String, int>> getEventCapacityInfo(String eventId) =>
      _registrationService.getEventCapacityInfo(eventId);

  Future<void> registerUserForEvent(String uid, String eventId) =>
      _registrationService.registerUserForEvent(uid, eventId);

  Future<void> unregisterUserFromEvent(String uid, String eventId) =>
      _registrationService.unregisterUserFromEvent(uid, eventId);

  // Get registration by user and event
  Future<Registration?> getRegistrationByUserAndEvent(
    String userId,
    String eventId,
  ) => _registrationService.getRegistrationByUserAndEvent(userId, eventId);

  Future<void> markAttendance(String userId, String eventId, String staffId) =>
      _registrationService.markAttendance(userId, eventId, staffId);

  // Mark attendance using QR code
  Future<void> markAttendanceByQRCode(String qrCodeData, String staffId) =>
      _registrationService.markAttendanceByQRCode(qrCodeData, staffId);

  // Get registration by QR code
  Future<Registration?> getRegistrationByQRCode(String qrCodeData) =>
      _registrationService.getRegistrationByQRCode(qrCodeData);

  // Get user's QR code for a specific event
  Future<String?> getUserQRCodeForEvent(String userId, String eventId) =>
      _registrationService.getUserQRCodeForEvent(userId, eventId);

  // Verify QR code data
  bool verifyQRCode(String qrCodeData, String userId, String eventId) =>
      Registration.verifyQRCode(qrCodeData, userId, eventId);

  // Parse QR code data
  Map<String, String>? parseQRCode(String qrCodeData) =>
      Registration.parseQRCode(qrCodeData);

  // Get attendee by ID and event ID (returns combined attendee + registration data)
  Future<Map<String, dynamic>?> getAttendeeByIdAndEvent(
    String attendeeId,
    String eventId,
  ) => _registrationService.getAttendeeByIdAndEvent(attendeeId, eventId);

  // Check in attendee (mark as attended)
  Future<void> checkInAttendee(
    String attendeeId,
    String eventId,
    String staffId,
  ) => _registrationService.checkInAttendee(attendeeId, eventId, staffId);

  /**
   * ====== DASHBOARD METHODS ======
   */
  Future<Map<String, dynamic>> getOrganizerDashboardStats() =>
      _dashboardService.getOrganizerDashboardStats();

  /**
   * ====== STATS METHODS ======
   */
  Future<Map<String, dynamic>> getOrganizerStats() =>
      _statsService.getOrganizerStats();

  Stream<Map<String, dynamic>> streamOrganizerStats() =>
      _statsService.streamOrganizerStats();

  Future<int> getTotalAttendeesCount() =>
      _statsService.getTotalAttendeesCount();

  Future<int> getTotalEventsCount() => _statsService.getTotalEventsCount();

  Future<int> getTotalStaffCount() => _statsService.getTotalStaffCount();

  /**
 * ====== ATTENDEE DASHBOARD METHODS ======
 */
  Future<List<Registration>> getUserRegistrations(String userId) =>
      _registrationService.getUserRegistrations(userId);

  Future<List<Event>> getAllAvailableEvents() =>
      _eventService.getAllAvailableEvents();

  Future<List<Map<String, dynamic>>> getAttendeeRecords(String userId) =>
      _attendeeService.getAttendeeRecords(userId);

  Future<List<Event>> getMyRegisteredEvents(String userId) =>
      _registrationService.getMyRegisteredEvents(userId);

  Future<Map<String, dynamic>> getAttendeeDashboardStats(String userId) =>
      _dashboardService.getAttendeeDashboardStats(userId);

  /**
 * ====== ORGANIZER METHODS ======
 */
  Future<List<Registration>> getAllRegistrations() =>
      _registrationService.getAllRegistrations();

  /**
   * ====== ADMIN METHODS ======
   */
  Future<AdminDashboardStats> getAdminDashboardStats() async {
    return _dashboardService.getAdminDashboardStats();
  }

  Future<List<Organizer>> getAdminAllOrganizers() =>
      _organizerService.getAdminAllOrganizers();
  Stream<List<Organizer>> streamOrganizers() =>
      _organizerService.streamOrganizers();
  Future<List<Event>> getAdminAllEvents() => _eventService.getAdminAllEvents();
  Future<List<Staff>> getAdminAllStaff() => _staffService.getAdminAllStaff();
  Future<List<Attendee>> getAdminAllAttendees() =>
      _attendeeService.getAdminAllAttendees();
  Future<List<Registration>> getAdminAllRegistrations() =>
      _registrationService.getAdminAllRegistrations();
  Future<void> updateOrganizerApproval(String organizerId, bool isApproved) =>
      _organizerService.updateOrganizerApproval(organizerId, isApproved);
  Future<AdminOrganizerStats> getAdminOrganizerStats(String organizerId) =>
      _organizerService.getAdminOrganizerStats(organizerId);
  Future<List<Event>> getAdminOrganizerEvents(String organizerId) {
  return _eventService.getAdminOrganizerEvents(organizerId);
}
}
