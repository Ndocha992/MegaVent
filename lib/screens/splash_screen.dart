import 'package:flutter/material.dart';
import 'package:megavent/screens/authentication/login_screen.dart';
import 'package:megavent/screens/authentication/verification_screen.dart';
import 'package:megavent/services/auth_service.dart';
import 'package:megavent/utils/constants.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Setup animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();

    // Check authentication after animation completes
    Future.delayed(const Duration(milliseconds: 2000), () {
      _checkAuthStatus();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthStatus() async {
    final authService = Provider.of<AuthService>(context, listen: false);

    // Check if user is already logged in
    final user = authService.currentUser;

    if (user != null) {
      // Check if email is verified
      await user.reload();
      final isVerified = user.emailVerified;

      if (isVerified) {
        // User is logged in and verified, navigate to dashboard
        final userData = await authService.getUserData();
        if (userData['success'] == true) {
          // switch (userData['role']) {
          //   case 'admin':
          //     Navigator.pushReplacement(
          //       context,
          //       MaterialPageRoute(builder: (_) => const AdminDashboard()),
          //     );
          //     break;
          //   case 'student':
          //     Navigator.pushReplacement(
          //       context,
          //       MaterialPageRoute(builder: (_) => const StudentDashboard()),
          //     );
          //     break;
          //   case 'provider':
          //     Navigator.pushReplacement(
          //       context,
          //       MaterialPageRoute(builder: (_) => const ProviderDashboard()),
          //     );
          //     break;
          // }
        } else {
          Navigator.pushReplacementNamed(context, '/login');
        }
      } else {
        // User is logged in but not verified, navigate to verification screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const VerificationScreen()),
        );
      }
    } else {
      // User is not logged in, navigate to login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppConstants.splashGradient,
          ),
        ),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 1),
                  // Logo container with shadow
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 20,
                              spreadRadius: 1,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/icons/logo.png',
                            width: 70,
                            height: 70,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 35),
                  // App name
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Transform.translate(
                      offset: Offset(0, _slideAnimation.value),
                      child: Text(
                        'FinTech Bridge',
                        style: AppConstants.displayLarge.copyWith(
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 10,
                              color: Colors.black.withOpacity(0.2),
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Tagline
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Transform.translate(
                      offset: Offset(0, _slideAnimation.value),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Financial Solutions for Students',
                          style: AppConstants.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(flex: 1),
                  // Custom loader
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
