import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:megavent/services/auth_service.dart';
import 'package:megavent/services/database_service.dart';
import 'package:megavent/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:app_links/app_links.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

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

    // Handle custom scheme (megavent://)
    bool isCustomSchemeRegister =
        link.scheme == 'megavent' &&
        (link.host == 'register' || link.path.contains('register'));

    // Handle web app URLs (https://megaventqr.vercel.app)
    bool isWebAppRegister =
        (link.host == 'megaventqr.vercel.app' ||
            link.host == 'www.megaventqr.vercel.app') &&
        link.scheme == 'https';

    // Handle any path that contains register
    bool isRegisterPath = link.path.contains('register');

    String? eventId =
        link.queryParameters['eventId'] ?? link.queryParameters['eventid'];

    bool autoRegister =
        link.queryParameters['autoRegister'] == 'true' ||
        link.queryParameters['autoregister'] == 'true';

    print(
      'Link analysis: scheme=${link.scheme}, host=${link.host}, path=${link.path}',
    );
    print('Event ID: $eventId, Auto Register: $autoRegister');
    print('Is Custom Scheme Register: $isCustomSchemeRegister');
    print('Is Web App Register: $isWebAppRegister');
    print('Is Register Path: $isRegisterPath');

    if (eventId != null &&
        (isCustomSchemeRegister || isWebAppRegister || isRegisterPath)) {
      _handleEventRegistration(eventId, autoRegister);
    } else {
      print('Deep link does not contain valid event registration parameters');
    }
  }

  void _handleEventRegistration(String eventId, bool autoRegister) async {
    if (_context == null) return;

    final authService = Provider.of<AuthService>(_context!, listen: false);
    final databaseService = Provider.of<DatabaseService>(
      _context!,
      listen: false,
    );

    // Check if user is logged in
    if (!authService.isLoggedIn) {
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
      return;
    }

    final userRole = userData['role'];
    if (userRole != 'attendee') {
      _showEventDetailsForNonAttendee(eventId, userRole);
      return;
    }

    // Handle attendee registration
    if (autoRegister) {
      await _attemptAutoRegistration(eventId, authService, databaseService);
    } else {
      _navigateToEventDetails(eventId);
    }
  }

  void _showEventDetailsForNonAttendee(String eventId, String? userType) {
    String message;
    String title;

    switch (userType) {
      case 'organizer':
        title = 'Organizer Account Detected';
        message =
            'As an Organizer, you can manage events but cannot register as an attendee.\n\nWould you like to view this event in your organizer dashboard?';
        break;
      case 'admin':
        title = 'Admin Account Detected';
        message =
            'As an Admin, you can manage the platform but cannot register for events.\n\nWould you like to view the event details?';
        break;
      case 'staff':
        title = 'Staff Account Detected';
        message =
            'As Staff, you can assist with events but cannot register as an attendee.\n\nWould you like to view the event details?';
        break;
      default:
        title = 'Registration Not Available';
        message =
            'Only Attendee accounts can register for events.\n\nPlease log in with an Attendee account to register.';
    }

    _showDialog(
      title: title,
      content: message,
      actions: [
        if (userType == 'organizer' ||
            userType == 'admin' ||
            userType == 'staff')
          TextButton(
            onPressed: () {
              Navigator.of(_context!).pop();
              _navigateToEventManagement(eventId, userType!);
            },
            child: const Text('View Event'),
          ),
        TextButton(
          onPressed: () => Navigator.of(_context!).pop(),
          child: const Text('OK'),
        ),
      ],
    );
  }

  Future<void> _attemptAutoRegistration(
    String eventId,
    AuthService authService,
    DatabaseService databaseService,
  ) async {
    try {
      _showLoadingDialog('Checking event availability...');

      // Check if event exists and is available for registration
      final event = await databaseService.getEventById(eventId);

      if (event == null) {
        Navigator.of(_context!).pop(); // Close loading dialog
        _showMessage('Event not found or no longer available', isError: true);
        return;
      }

      // Update loading message
      Navigator.of(_context!).pop();
      _showLoadingDialog('Checking your registration status...');

      // Check if user is already registered
      final isRegistered = await databaseService.isUserRegisteredForEvent(
        authService.currentUser!.uid,
        eventId,
      );

      if (isRegistered) {
        Navigator.of(_context!).pop(); // Close loading dialog
        _showMessage('You are already registered for this event! 🎉');
        _navigateToMyEvents();
        return;
      }

      // Check if event is full
      final capacityInfo = await databaseService.getEventCapacityInfo(eventId);
      final available = capacityInfo['available'] ?? 0;

      if (available <= 0) {
        Navigator.of(_context!).pop(); // Close loading dialog
        _showEventFullDialog(event.name, eventId);
        return;
      }

      // Update loading message
      Navigator.of(_context!).pop();
      _showLoadingDialog('Registering you for the event...');

      // Register user for the event
      await databaseService.registerUserForEvent(
        authService.currentUser!.uid,
        eventId,
      );

      Navigator.of(_context!).pop(); // Close loading dialog
      _showSuccessDialog(event.name);
    } catch (e) {
      Navigator.of(_context!).pop(); // Close loading dialog
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
    _showDialog(
      title: 'Event Full 😔',
      content:
          'Sorry, "$eventName" has reached its maximum capacity and is now fully booked.\n\nYou can still view the event details or join a waitlist if available.',
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(_context!).pop();
            _navigateToEventDetails(eventId);
          },
          child: const Text('View Details'),
        ),
        TextButton(
          onPressed: () => Navigator.of(_context!).pop(),
          child: const Text('OK'),
        ),
      ],
    );
  }

  void _showSuccessDialog(String eventName) {
    _showDialog(
      title: 'Registration Successful! 🎉',
      content:
          'Congratulations! You have been successfully registered for "$eventName".\n\n📧 You will receive confirmation details via email shortly.\n\n🎫 Your registration ticket is now available in your events list.',
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(_context!).pop();
            _navigateToMyEvents();
          },
          child: const Text('View My Events'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(_context!).pop();
            _navigateToAttendeeDashboard();
          },
          child: const Text('Go to Dashboard'),
        ),
      ],
    );
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: _context!,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            content: Row(
              children: [
                Container(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  child: const Center(
                    child: SpinKitThreeBounce(
                      color: AppConstants.primaryColor,
                      size: 20.0,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(message, style: const TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
    );
  }

  void _showDialog({
    required String title,
    required String content,
    required List<Widget> actions,
  }) {
    showDialog(
      context: _context!,
      builder:
          (context) => AlertDialog(
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text(content, style: const TextStyle(height: 1.4)),
            actions: actions,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
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
        // Clear storage immediately
        await prefs.remove('pending_event_id');
        await prefs.remove('pending_auto_register');

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
