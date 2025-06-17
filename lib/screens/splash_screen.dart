import 'package:flutter/material.dart';
import 'package:megavent/screens/authentication/login_screen.dart';
import 'package:megavent/screens/authentication/verification_screen.dart';
import 'package:megavent/screens/admin/admin_dashboard.dart';
import 'package:megavent/screens/attendee/attendee_dashboard.dart';
import 'package:megavent/screens/organizer/organizer_dashboard.dart';
import 'package:megavent/screens/staff/staff_dashboard.dart';
import 'package:megavent/services/auth_service.dart';
import 'package:megavent/utils/constants.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainAnimationController;
  late AnimationController _logoAnimationController;
  late AnimationController _pulseAnimationController;
  late AnimationController _backgroundAnimationController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _logoRotationAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _textSlideAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();

    // Check authentication after animation completes
    Future.delayed(const Duration(seconds: 7), () {
      _checkAuthStatus();
    });
  }

  void _setupAnimations() {
    // Main animation controller
    _mainAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // Logo animation controller
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    // Pulse animation controller
    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Background animation controller
    _backgroundAnimationController = AnimationController(
      duration: const Duration(milliseconds: 8000),
      vsync: this,
    );

    // Logo animations
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainAnimationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainAnimationController,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 80.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainAnimationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _logoRotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _logoScaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Text animations
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainAnimationController,
        curve: const Interval(0.4, 0.9, curve: Curves.easeInOut),
      ),
    );

    _textSlideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainAnimationController,
        curve: const Interval(0.5, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    // Background animation
    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _backgroundAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _startAnimations() {
    _mainAnimationController.forward();
    _logoAnimationController.repeat(reverse: true);
    _pulseAnimationController.repeat(reverse: true);
    _backgroundAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _mainAnimationController.dispose();
    _logoAnimationController.dispose();
    _pulseAnimationController.dispose();
    _backgroundAnimationController.dispose();
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
        // User is logged in and verified, navigate to appropriate dashboard
        final userData = await authService.getUserData();
        if (userData['success'] == true) {
          switch (userData['role']) {
            case 'admin':
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AdminDashboard()),
              );
              break;
            case 'attendee':
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AttendeeDashboard()),
              );
              break;
            case 'organizer':
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const OrganizerDashboard()),
              );
              break;
            case 'staff':
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const StaffDashboard()),
              );
              break;
            default:
              Navigator.pushReplacementNamed(context, '/login');
          }
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

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppConstants.splashGradient,
              stops: [0.0, 0.5, 1.0],
              transform: GradientRotation(_backgroundAnimation.value * 0.5),
            ),
          ),
          child: Stack(
            children: [
              // Animated particles/bubbles
              ...List.generate(8, (index) => _buildFloatingParticle(index)),
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.1)],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFloatingParticle(int index) {
    final double size = 8.0 + (index % 3) * 4.0;
    final double left =
        (index * 50.0) % (MediaQuery.of(context).size.width - 20);
    final double top =
        (index * 80.0) % (MediaQuery.of(context).size.height - 20);

    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Positioned(
          left:
              left +
              (_backgroundAnimation.value * 20 * (index % 2 == 0 ? 1 : -1)),
          top:
              top +
              (_backgroundAnimation.value * 30 * (index % 3 == 0 ? 1 : -1)),
          child: Opacity(
            opacity: 0.6 + (_backgroundAnimation.value * 0.4),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.2),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _mainAnimationController,
        _logoAnimationController,
        _pulseAnimationController,
      ]),
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Transform.translate(
              offset: Offset(0, _slideAnimation.value),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer glow effect
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                AppConstants.primaryColor.withOpacity(0.3),
                                Colors.transparent,
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    },
                  ),
                  // Main logo container
                  Transform.rotate(
                    angle: _logoRotationAnimation.value * 0.05,
                    child: Transform.scale(
                      scale: _logoScaleAnimation.value,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.white, Color(0xFFF8FAFC)],
                          ),
                          borderRadius: BorderRadius.circular(35),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 30,
                              spreadRadius: 0,
                              offset: const Offset(0, 15),
                            ),
                            BoxShadow(
                              color: AppConstants.primaryColor.withOpacity(0.4),
                              blurRadius: 40,
                              spreadRadius: 0,
                              offset: const Offset(0, 20),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // App logo instead of calendar icon
                            Center(
                              child: Image.asset(
                                'assets/icons/logo.png',
                                width: 100,
                                height: 100,
                              ),
                            ),
                            // Shine effect
                            Positioned.fill(
                              child: AnimatedBuilder(
                                animation: _logoAnimationController,
                                builder: (context, child) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(35),
                                      gradient: LinearGradient(
                                        begin: Alignment(
                                          -1.0 +
                                              (_logoRotationAnimation.value *
                                                  2.0),
                                          -1.0,
                                        ),
                                        end: Alignment(
                                          1.0 +
                                              (_logoRotationAnimation.value *
                                                  2.0),
                                          1.0,
                                        ),
                                        colors: [
                                          Colors.transparent,
                                          Colors.white.withOpacity(0.1),
                                          Colors.transparent,
                                        ],
                                        stops: const [0.0, 0.5, 1.0],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppName() {
    return FadeTransition(
      opacity: _textFadeAnimation,
      child: Transform.translate(
        offset: Offset(0, _textSlideAnimation.value),
        child: Column(
          children: [
            // Main app name with gradient
            ShaderMask(
              shaderCallback:
                  (bounds) => const LinearGradient(
                    colors: [Colors.white, Color(0xFFE0E7FF)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ).createShader(bounds),
              child: Text(
                'MegaVent',
                style: AppConstants.displayLarge.copyWith(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.0,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(0, 4),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Tagline
            Text(
              'Create • Manage • Experience',
              style: AppConstants.bodyLarge.copyWith(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: 2.0,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.2),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated background
          _buildAnimatedBackground(),
          // Main content - Centered properly
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo
                _buildLogo(),
                const SizedBox(height: 20),
                // App name and tagline
                _buildAppName(),
                const SizedBox(height: 130),
                // Loading indicator at bottom
                FadeTransition(
                  opacity: _textFadeAnimation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Loading amazing experiences...',
                          style: AppConstants.bodyMedium.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for hexagon pattern to match your logo
class HexagonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3;

    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60) * (3.14159 / 180);
      final x = center.dx + radius * (i == 0 ? 1 : cos(angle));
      final y = center.dy + radius * (i == 0 ? 0 : sin(angle));

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Extension to add cosine function
double cos(double radians) {
  return (radians == 0)
      ? 1
      : (radians.abs() < 0.0001)
      ? 1
      : (radians > 0)
      ? _cosineApproximation(radians)
      : _cosineApproximation(-radians);
}

double sin(double radians) {
  return cos(radians - 1.5708); // sin(x) = cos(x - π/2)
}

double _cosineApproximation(double x) {
  // Simple cosine approximation using Taylor series
  x = x % (2 * 3.14159); // Normalize to 0-2π
  if (x > 3.14159) x = 2 * 3.14159 - x; // Use symmetry

  final x2 = x * x;
  return 1 - x2 / 2 + x2 * x2 / 24 - x2 * x2 * x2 / 720;
}
