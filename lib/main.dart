import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:megavent/screens/attendee/attendee_dashboard.dart';
import 'package:megavent/screens/attendee/events.dart';
import 'package:megavent/screens/attendee/profile.dart';
import 'package:megavent/screens/authentication/forgot_password_screen.dart';
import 'package:megavent/screens/authentication/login_screen.dart';
import 'package:megavent/screens/authentication/register_screen.dart';
import 'package:megavent/screens/authentication/verification_screen.dart';
import 'package:megavent/screens/organizer/events_details.dart';
import 'package:megavent/screens/organizer/qr_scanner.dart';
import 'package:megavent/screens/splash_screen.dart';
import 'package:megavent/screens/organizer/organizer_dashboard.dart';
import 'package:megavent/screens/organizer/events.dart';
import 'package:megavent/screens/organizer/staff.dart';
import 'package:megavent/screens/organizer/attendees.dart';
import 'package:megavent/screens/organizer/profile.dart';
import 'package:megavent/services/auth_service.dart';
import 'package:megavent/services/database_service.dart';
import 'package:megavent/services/deep_link_service.dart';
import 'package:megavent/utils/constants.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider<DatabaseService>(
          create: (_) => DatabaseService(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    // Initialize deep link service after the app is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDeepLinks();
    });
  }

  void _initializeDeepLinks() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      DeepLinkService().initialize(context);
      DeepLinkService().handleInitialLink();
    }
  }

  @override
  void dispose() {
    DeepLinkService().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'MegaVent',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppConstants.primaryColor),
        useMaterial3: true,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: AppConstants.backgroundColor,
      ),
      home: const AuthenticationWrapper(),
      routes: {
        // Auth routes
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/verify-email': (context) => const VerificationScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        // Organizer routes
        '/organizer-dashboard': (context) => const OrganizerDashboard(),
        '/organizer-events': (context) => const Events(),
        '/organizer-scanqr': (context) => const QRScanner(),
        '/organizer-staff': (context) => const StaffScreen(),
        '/organizer-attendees': (context) => const Attendees(),
        '/organizer-profile': (context) => const Profile(),
        '/organizer-event-details': (context) => const EventsDetails(),
        // Attendee routes
        '/attendee-dashboard': (context) => const AttendeeDashboard(),
        '/attendee-all-events': (context) => const AttendeeAllEvents(),
        // '/attendee-my-events': (context) => const AttendeeMyEvents(),
        // '/attendee-event-registration':
        //     (context) => const AttendeeEventRegistration(),
        '/attendee-profile': (context) => const AttendeeProfile(),
        // Admin routes
        // '/admin-event-details': (context) => const AdminEventDetails(),
        // Staff routes
        // '/staff-event-details': (context) => const StaffEventDetails(),
      },
    );
  }
}

// This wrapper handles authentication state and shows appropriate screens
class AuthenticationWrapper extends StatefulWidget {
  const AuthenticationWrapper({super.key});

  @override
  State<AuthenticationWrapper> createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  @override
  void initState() {
    super.initState();
    // Listen to auth state changes to check for pending registrations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listenToAuthChanges();
    });
  }

  void _listenToAuthChanges() {
    final authService = Provider.of<AuthService>(context, listen: false);

    // Listen to auth state changes
    authService.addListener(() {
      if (authService.isLoggedIn) {
        // Check for pending event registration after successful login
        DeepLinkService().checkPendingRegistration();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Update deep link service context when this widget builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DeepLinkService().initialize(context);
    });

    return const SplashScreen();
  }
}
