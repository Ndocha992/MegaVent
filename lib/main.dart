import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:megavent/screens/authentication/forgot_password_screen.dart';
import 'package:megavent/screens/authentication/login_screen.dart';
import 'package:megavent/screens/authentication/register_screen.dart';
import 'package:megavent/screens/authentication/verification_screen.dart';
import 'package:megavent/screens/splash_screen.dart';
import 'package:megavent/services/auth_service.dart';
import 'package:megavent/services/database_service.dart';
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/verify-email': (context) => const VerificationScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
      },
    );
  }
}

// This wrapper handles authentication state and shows appropriate screens
class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Use splash screen during initialization
    return const SplashScreen();
  }
}
