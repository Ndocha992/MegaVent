import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:megavent/screens/attendee/attendee_dashboard.dart';
import 'package:megavent/screens/attendee/events.dart';
import 'package:megavent/screens/attendee/my_events.dart';
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
import 'package:megavent/services/permission_service.dart';
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
    // Initialize services after the app is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  void _initializeApp() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      // Initialize deep links
      DeepLinkService().initialize(context);
      DeepLinkService().handleInitialLink();

      // Request permissions on app start
      _requestInitialPermissions(context);

      // Set up auth state listener for deep links only
      _setupAuthListener();
    }
  }

  void _setupAuthListener() {
    final authService = Provider.of<AuthService>(
      navigatorKey.currentContext!,
      listen: false,
    );

    // Only listen for deep link related auth changes
    authService.addListener(() {
      if (authService.isLoggedIn) {
        // Check for pending event registration after successful login
        DeepLinkService().checkPendingRegistration();
      }
    });
  }

  void _requestInitialPermissions(BuildContext context) async {
    // Wait a bit for the app to fully load
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      // Request all necessary permissions
      await PermissionService().requestAllPermissions(context);
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
      home: const SplashScreen(),
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
        '/attendee-my-events': (context) => const AttendeeMyEvents(),
        '/attendee-profile': (context) => const AttendeeProfile(),
        // Admin and Staff routes can be added here as needed
      },
    );
  }
}
