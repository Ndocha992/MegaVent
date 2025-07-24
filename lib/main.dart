import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:megavent/screens/admin/admin_dashboard.dart';
import 'package:megavent/screens/admin/organizer.dart';
import 'package:megavent/screens/admin/profile.dart';
import 'package:megavent/screens/attendee/attendee_dashboard.dart';
import 'package:megavent/screens/attendee/events.dart';
import 'package:megavent/screens/attendee/events_details.dart';
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
import 'package:megavent/screens/staff/events.dart';
import 'package:megavent/screens/staff/events_details.dart';
import 'package:megavent/screens/staff/profile.dart';
import 'package:megavent/screens/staff/qr_scanner.dart';
import 'package:megavent/screens/staff/staff_dashboard.dart';
import 'package:megavent/services/admin_init_service.dart';
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

  // Initialize admin (runs only once)
  await AdminInitService.initializeAdmin();

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

    authService.addListener(() {
      if (authService.isLoggedIn) {
        // Reinitialize deep links with current context
        DeepLinkService().initialize(navigatorKey.currentContext!);
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
      // Handle both custom scheme and web URLs
      onGenerateRoute: (settings) {
        // Handle web app redirects
        if (settings.name?.startsWith('https://megaventqr.vercel.app') ==
            true) {
          final uri = Uri.parse(settings.name!);
          final eventId = uri.queryParameters['eventId'];
          final autoRegister = uri.queryParameters['autoRegister'] == 'true';

          if (eventId != null) {
            // Use DeepLinkService to handle the registration
            WidgetsBinding.instance.addPostFrameCallback((_) {
              DeepLinkService().handleWebAppRedirect(eventId, autoRegister);
            });
          }

          // Return splash screen while processing
          return MaterialPageRoute(builder: (_) => const SplashScreen());
        }

        // Handle normal routes
        return _generateRoute(settings);
      },
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
        '/attendee-event-details': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map;
          return AttendeeEventsDetails(
            eventId: args['eventId'],
            autoRegister: args['autoRegister'] ?? false,
          );
        },
        '/attendee-my-events': (context) => const AttendeeMyEvents(),
        '/attendee-profile': (context) => const AttendeeProfile(),
        // Staff routes
        '/staff-dashboard': (context) => const StaffDashboard(),
        '/staff-events': (context) => const StaffEvents(),
        '/staff-scanqr': (context) => const StaffQRScanner(),
        '/staff-profile': (context) => const StaffProfile(),
        '/staff-event-details': (context) => const StaffEventsDetails(),
        // Admin routes
        '/admin-dashboard': (context) => const AdminDashboard(),
        '/admin-organizers': (context) => const OrganizerScreen(),
        '/admin-profile': (context) => const AdminProfile(),
      },
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case '/verify-email':
        return MaterialPageRoute(builder: (_) => const VerificationScreen());
      case '/forgot-password':
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      // Organizer routes
      case '/organizer-dashboard':
        return MaterialPageRoute(builder: (_) => const OrganizerDashboard());
      case '/organizer-events':
        return MaterialPageRoute(builder: (_) => const Events());
      case '/organizer-scanqr':
        return MaterialPageRoute(builder: (_) => const QRScanner());
      case '/organizer-staff':
        return MaterialPageRoute(builder: (_) => const StaffScreen());
      case '/organizer-attendees':
        return MaterialPageRoute(builder: (_) => const Attendees());
      case '/organizer-profile':
        return MaterialPageRoute(builder: (_) => const Profile());
      case '/organizer-event-details':
        return MaterialPageRoute(builder: (_) => const EventsDetails());
      // Attendee routes
      case '/attendee-dashboard':
        return MaterialPageRoute(builder: (_) => const AttendeeDashboard());
      case '/attendee-all-events':
        return MaterialPageRoute(builder: (_) => const AttendeeAllEvents());
      case '/attendee-event-details':
        final args = settings.arguments as Map?;
        return MaterialPageRoute(
          builder:
              (_) => AttendeeEventsDetails(
                eventId: args?['eventId'] ?? '',
                autoRegister: args?['autoRegister'] ?? false,
              ),
        );
      case '/attendee-my-events':
        return MaterialPageRoute(builder: (_) => const AttendeeMyEvents());
      case '/attendee-profile':
        return MaterialPageRoute(builder: (_) => const AttendeeProfile());
      // Staff routes
      case '/staff-dashboard':
        return MaterialPageRoute(builder: (_) => const StaffDashboard());
      case '/staff-events':
        return MaterialPageRoute(builder: (_) => const StaffEvents());
      case '/staff-scanqr':
        return MaterialPageRoute(builder: (_) => const StaffQRScanner());
      case '/staff-profile':
        return MaterialPageRoute(builder: (_) => const StaffProfile());
      case '/staff-event-details':
        return MaterialPageRoute(builder: (_) => const StaffEventsDetails());
      // Admin routes
      case '/admin-dashboard':
        return MaterialPageRoute(builder: (_) => const AdminDashboard());
      case '/admin-organizers':
        return MaterialPageRoute(builder: (_) => const OrganizerScreen());
      case '/admin-profile':
        return MaterialPageRoute(builder: (_) => const AdminProfile());
      default:
        return null;
    }
  }
}
