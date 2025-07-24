import 'package:flutter/material.dart';
import 'package:megavent/services/auth_service.dart';
import 'package:megavent/services/database_service.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/screens/loading_screen.dart';
import 'package:provider/provider.dart';
import 'package:app_links/app_links.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:ui';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  BuildContext? _context;
  StreamSubscription<Uri>? _linkSubscription;
  late AppLinks _appLinks;

  void initialize(BuildContext context) {
    _context = context;
    _appLinks = AppLinks();
    _setupDeepLinks();
  }

  void handleWebAppRedirect(String eventId, bool autoRegister) {
    if (_context == null) return;

    print(
      'Handling web app redirect - EventId: $eventId, AutoRegister: $autoRegister',
    );
    _handleEventRegistration(eventId, autoRegister);
  }

  void _setupDeepLinks() {
    // Listen for incoming links when app is already running
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        print('Deep link received: $uri');
        _handleDeepLink(uri);
      },
      onError: (err) {
        print('Deep link error: $err');
      },
    );
  }

  Future<void> handleInitialLink() async {
    try {
      // Handle deep link when app is launched from terminated state
      final Uri? initialUri = await _appLinks.getInitialLink();

      if (initialUri != null) {
        print('Initial deep link: $initialUri');
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      print('Error handling initial link: $e');
    }
  }

  void _handleDeepLink(Uri link) {
    if (_context == null) return;

    print('Processing deep link: ${link.toString()}');
    print('Scheme: ${link.scheme}, Host: ${link.host}, Path: ${link.path}');
    print('Query parameters: ${link.queryParameters}');

    // Handle custom scheme (megavent://)
    bool isCustomSchemeRegister =
        link.scheme == 'megavent' &&
        (link.host == 'register' ||
            link.path.contains('register') ||
            link.queryParameters.containsKey('eventId'));

    // Handle web app URLs (https://megaventqr.vercel.app)
    bool isWebAppRegister =
        (link.host == 'megaventqr.vercel.app' ||
            link.host == 'www.megaventqr.vercel.app') &&
        link.scheme == 'https';

    // Handle any path that contains register
    bool isRegisterPath =
        link.path.contains('register') ||
        link.queryParameters.containsKey('eventId');

    // Extract eventId from various possible parameter names
    String? eventId =
        link.queryParameters['eventId'] ??
        link.queryParameters['eventid'] ??
        link.queryParameters['event_id'];

    bool autoRegister =
        link.queryParameters['autoRegister'] == 'true' ||
        link.queryParameters['autoregister'] == 'true' ||
        link.queryParameters['auto_register'] == 'true';

    print('Link analysis:');
    print('- Is Custom Scheme Register: $isCustomSchemeRegister');
    print('- Is Web App Register: $isWebAppRegister');
    print('- Is Register Path: $isRegisterPath');
    print('- Event ID: $eventId');
    print('- Auto Register: $autoRegister');

    if (eventId != null &&
        eventId.isNotEmpty &&
        (isCustomSchemeRegister || isWebAppRegister || isRegisterPath)) {
      print('Valid event registration link detected, processing...');
      _handleEventRegistration(eventId, autoRegister);
    } else {
      print('Deep link does not contain valid event registration parameters');
      if (eventId == null || eventId.isEmpty) {
        print('ERROR: Event ID is missing or empty');
      }
    }
  }

  void _handleEventRegistration(String eventId, bool autoRegister) async {
    if (_context == null) return;

    print('Handling event registration for: $eventId (auto: $autoRegister)');

    final authService = Provider.of<AuthService>(_context!, listen: false);
    final databaseService = Provider.of<DatabaseService>(
      _context!,
      listen: false,
    );

    // Check if user is logged in
    if (!authService.isLoggedIn) {
      print(
        'User not logged in, storing event for later and redirecting to login',
      );
      _showMessage('Please log in to register for events', isError: true);
      // Store the event ID for after login
      await _storeEventForLaterRegistration(eventId, autoRegister);
      // Navigate to login screen
      Navigator.of(
        _context!,
      ).pushNamedAndRemoveUntil('/login', (route) => false);
      return;
    }

    // Check user role
    final userData = await authService.getUserData();
    if (!userData['success']) {
      // Handle error - user data couldn't be retrieved
      print('Error retrieving user data: ${userData['message']}');
      _showMessage('Failed to retrieve user information', isError: true);
      return;
    }

    final userRole = userData['role'];
    print('User role: $userRole');

    if (userRole != 'attendee') {
      _showEventDetailsForNonAttendee(userRole);
      return;
    }

    // Handle attendee registration
    if (autoRegister) {
      print('Attempting auto registration...');
      await _attemptAutoRegistration(eventId, authService, databaseService);
    } else {
      print('Navigating to event details for manual registration...');
      _navigateToEventDetails(eventId);
    }
  }

  void _showEventDetailsForNonAttendee(String? userType) {
    String message;
    String title;

    switch (userType) {
      case 'organizer':
        title = 'Organizer Account Detected';
        message =
            'As an Organizer, you can manage events but cannot register as an attendee.\n\nPlease log in with an Attendee account to register.';
        break;
      case 'admin':
        title = 'Admin Account Detected';
        message =
            'As an Admin, you can manage the platform but cannot register for events.\n\nPlease log in with an Attendee account to register.';
        break;
      case 'staff':
        title = 'Staff Account Detected';
        message =
            'As Staff, you can assist with events but cannot register as an attendee.\n\nPlease log in with an Attendee account to register.';
        break;
      default:
        title = 'Registration Not Available';
        message =
            'Only Attendee accounts can register for events.\n\nPlease log in with an Attendee account to register.';
    }

    _showStyledModal(
      title: title,
      content: message,
      secondaryButtonText:
          userType != null && ['organizer', 'admin', 'staff'].contains(userType)
              ? 'OK'
              : null,
      onSecondaryPressed:
          userType != null && ['organizer', 'admin', 'staff'].contains(userType)
              ? () => Navigator.of(_context!).pop()
              : null,
      primaryButtonText: 'Cancel',
      onPrimaryPressed: () => Navigator.of(_context!).pop(),
    );
  }

  Future<void> _attemptAutoRegistration(
    String eventId,
    AuthService authService,
    DatabaseService databaseService,
  ) async {
    try {
      LoadingOverlay.show(_context!, message: 'Checking event availability...');

      // Check if event exists and is available for registration
      final event = await databaseService.getEventById(eventId);

      if (event == null) {
        LoadingOverlay.hide();
        _showMessage('Event not found or no longer available', isError: true);
        return;
      }

      // Update loading message
      LoadingOverlay.hide();
      LoadingOverlay.show(
        _context!,
        message: 'Checking your registration status...',
      );

      // Check if user is already registered
      final isRegistered = await databaseService.isUserRegisteredForEvent(
        authService.currentUser!.uid,
        eventId,
      );

      if (isRegistered) {
        LoadingOverlay.hide();
        _showMessage('You are already registered for this event! 🎉');
        _navigateToMyEvents();
        return;
      }

      // Check if event is full
      final capacityInfo = await databaseService.getEventCapacityInfo(eventId);
      final available = capacityInfo['available'] ?? 0;

      if (available <= 0) {
        LoadingOverlay.hide();
        _showEventFullDialog(event.name, eventId);
        return;
      }

      // Update loading message
      LoadingOverlay.hide();
      LoadingOverlay.show(
        _context!,
        message: 'Registering you for the event...',
      );

      // Register user for the event
      await databaseService.registerUserForEvent(
        authService.currentUser!.uid,
        eventId,
      );

      LoadingOverlay.hide();
      _showSuccessDialog(event.name);
    } catch (e) {
      LoadingOverlay.hide();
      print('Auto registration error: $e');

      // Handle specific error cases
      if (e.toString().contains('already registered')) {
        _showMessage('You are already registered for this event! 🎉');
        _navigateToMyEvents();
      } else if (e.toString().contains('Event is full')) {
        // Get event name for the dialog
        try {
          final event = await databaseService.getEventById(eventId);
          _showEventFullDialog(event?.name ?? 'Event', eventId);
        } catch (_) {
          _showMessage('Event is full', isError: true);
        }
      } else {
        _showMessage(
          'An error occurred during registration. Please try manual registration.',
          isError: true,
        );
        _navigateToEventDetails(eventId);
      }
    }
  }

  void _showEventFullDialog(String eventName, String eventId) {
    _showStyledModal(
      title: 'Event Full 😔',
      content:
          'Sorry, "$eventName" has reached its maximum capacity and is now fully booked.\n\nYou can still view the event details or join a waitlist if available.',
      primaryButtonText: 'View Details',
      onPrimaryPressed: () {
        Navigator.of(_context!).pop();
        _navigateToEventDetails(eventId);
      },
      secondaryButtonText: 'OK',
      onSecondaryPressed: () => Navigator.of(_context!).pop(),
    );
  }

  void _showSuccessDialog(String eventName) {
    _showStyledModal(
      title: 'Registration Successful! 🎉',
      content:
          'Congratulations! You have been successfully registered for "$eventName".\n\n🎫 Your registration ticket is now available in your registered event details page.',
      primaryButtonText: 'View My Events',
      onPrimaryPressed: () {
        Navigator.of(_context!).pop();
        _navigateToMyEvents();
      },
      secondaryButtonText: 'Go to Dashboard',
      onSecondaryPressed: () {
        Navigator.of(_context!).pop();
        _navigateToAttendeeDashboard();
      },
    );
  }

  void _showStyledModal({
    required String title,
    required String content,
    required String primaryButtonText,
    required VoidCallback onPrimaryPressed,
    String? secondaryButtonText,
    VoidCallback? onSecondaryPressed,
  }) {
    showDialog(
      context: _context!,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.3),
      builder:
          (context) => BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                constraints: BoxConstraints(
                  maxWidth: 400,
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppConstants.primaryColor.withOpacity(0.15),
                      blurRadius: 30,
                      spreadRadius: 0,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    // Content
                    Flexible(
                      child: SingleChildScrollView(
                        child: Text(
                          content,
                          style: AppConstants.bodyMedium.copyWith(
                            color: AppConstants.textColor,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Buttons
                    if (secondaryButtonText != null &&
                        onSecondaryPressed != null)
                      Row(
                        children: [
                          Expanded(
                            child: _buildModalButton(
                              text: secondaryButtonText,
                              onPressed: onSecondaryPressed,
                              isSecondary: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildModalButton(
                              text: primaryButtonText,
                              onPressed: onPrimaryPressed,
                              isSecondary: false,
                            ),
                          ),
                        ],
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        child: _buildModalButton(
                          text: primaryButtonText,
                          onPressed: onPrimaryPressed,
                          isSecondary: false,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildModalButton({
    required String text,
    required VoidCallback onPressed,
    required bool isSecondary,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isSecondary ? Colors.grey[100] : AppConstants.primaryColor,
        foregroundColor: isSecondary ? AppConstants.textColor : Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side:
              isSecondary
                  ? BorderSide(color: Colors.grey[300]!, width: 1)
                  : BorderSide.none,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showMessage(String message, {bool isError = false}) {
    if (_context == null) return;

    ScaffoldMessenger.of(_context!).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? AppConstants.errorColor : AppConstants.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: Duration(seconds: isError ? 4 : 3),
        action:
            isError
                ? null
                : SnackBarAction(
                  label: 'View',
                  textColor: Colors.white,
                  onPressed: () {
                    if (!isError) _navigateToMyEvents();
                  },
                ),
      ),
    );
  }

  void _navigateToEventDetails(String eventId) {
    Navigator.of(
      _context!,
    ).pushNamed('/attendee-event-details', arguments: {'eventId': eventId});
  }

  void _navigateToMyEvents() {
    Navigator.of(_context!).pushNamed('/attendee-my-events');
  }

  void _navigateToAttendeeDashboard() {
    Navigator.of(
      _context!,
    ).pushNamedAndRemoveUntil('/attendee-dashboard', (route) => false);
  }

  void _navigateToEventManagement(String eventId, String userType) {
    // Navigate based on user type
    switch (userType) {
      case 'organizer':
        Navigator.of(_context!).pushNamed(
          '/organizer-event-details',
          arguments: {'eventId': eventId},
        );
        break;
      case 'admin':
        Navigator.of(
          _context!,
        ).pushNamed('/admin-event-details', arguments: {'eventId': eventId});
        break;
      case 'staff':
        Navigator.of(
          _context!,
        ).pushNamed('/staff-event-details', arguments: {'eventId': eventId});
        break;
    }
  }

  // Store event for registration after login
  Future<void> _storeEventForLaterRegistration(
    String eventId,
    bool autoRegister,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('pending_event_id', eventId);
      await prefs.setBool('pending_auto_register', autoRegister);
      print('Stored pending registration: $eventId (auto: $autoRegister)');
    } catch (e) {
      print('Error storing event: $e');
    }
  }

  // Check for pending registration after login
  Future<void> checkPendingRegistration() async {
    if (_context == null) return;

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? eventId = prefs.getString('pending_event_id');
      bool autoRegister = prefs.getBool('pending_auto_register') ?? false;

      if (eventId != null) {
        print('Found pending registration: $eventId (auto: $autoRegister)');

        // Clear storage immediately
        await prefs.remove('pending_event_id');
        await prefs.remove('pending_auto_register');

        // Small delay to ensure UI is ready
        await Future.delayed(const Duration(milliseconds: 500));

        _handleEventRegistration(eventId, autoRegister);
      }
    } catch (e) {
      print('Error checking pending: $e');
    }
  }

  // Clean up resources
  void dispose() {
    _linkSubscription?.cancel();
    _context = null;
  }
}
