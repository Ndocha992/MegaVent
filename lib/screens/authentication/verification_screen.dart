import 'dart:async';
import 'package:flutter/material.dart';
import 'package:megavent/services/auth_service.dart';
import 'package:megavent/utils/constants.dart';
import 'package:provider/provider.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen>
    with SingleTickerProviderStateMixin {
  late Timer _verificationTimer;
  late Timer _countdownTimer;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Countdown for resend functionality (5 minutes)
  int _countdownSeconds = 300; // 5 minutes in seconds
  bool _canResend = false;
  bool _isLoading = false;

  String get _countdownDisplay {
    int minutes = _countdownSeconds ~/ 60;
    int seconds = _countdownSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();

    // Initialize the timers
    _verificationTimer = Timer(Duration.zero, () {});
    _countdownTimer = Timer(Duration.zero, () {});

    // Start verification check and countdown after initialization
    _startVerificationCheck();
    _startCountdown();
  }

  void _startVerificationCheck() {
    // Cancel existing timer if it exists
    if (_verificationTimer.isActive) {
      _verificationTimer.cancel();
    }

    _verificationTimer =
        Timer.periodic(const Duration(seconds: 5), (timer) async {
      final authService = Provider.of<AuthService>(context, listen: false);
      final isVerified = await authService.checkEmailVerified();

      if (isVerified && mounted) {
        timer.cancel();
        // Show success message before navigation
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email verified successfully!'),
            backgroundColor: AppConstants.successColor,
          ),
        );

        // Small delay to show the success message
        Future.delayed(const Duration(seconds: 1), () async {
          if (mounted) {
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
              //       MaterialPageRoute(
              //           builder: (_) => const ProviderDashboard()),
              //     );
              //     break;
              // }
            }
          }
        });
      }
    });
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdownSeconds > 0) {
          _countdownSeconds--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _resendVerificationEmail() async {
    setState(() {
      _isLoading = true;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    final result = await authService.resendVerificationEmail();

    setState(() {
      _isLoading = false;
    });

    if (result['success']) {
      // Reset the countdown and disable resend
      setState(() {
        _canResend = false;
        _countdownSeconds = 300; // Reset to 5 minutes
      });

      // Start countdown again
      _startCountdown();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: AppConstants.successColor,
        ),
      );
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: AppConstants.errorColor,
        ),
      );
    }
  }

  void _checkVerificationManually() async {
    setState(() {
      _isLoading = true;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    final isVerified = await authService.checkEmailVerified();

    setState(() {
      _isLoading = false;
    });

    if (isVerified && mounted) {
      // Show success message before navigation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email verified successfully!'),
          backgroundColor: AppConstants.successColor,
        ),
      );

      // Small delay to show the success message
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      });
    } else {
      // Show not verified message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email not verified yet. Please check your inbox.'),
          backgroundColor: Color(0xFFFF9800), // Orange warning color
        ),
      );
    }
  }

  @override
  void dispose() {
    _verificationTimer.cancel();
    _countdownTimer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF9FAFC),
              Color(0xFFEEF1F7),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo with shadow
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 20,
                            spreadRadius: 1,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/icons/logo.png',
                          width: 60,
                          height: 60,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Title and subtitle
                    Text(
                      'Verify Your Email',
                      style: AppConstants.displaySmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'We\'ve sent a verification link to your email',
                        style: AppConstants.bodyMedium.copyWith(
                          color: AppConstants.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Verification Instructions Card
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            spreadRadius: 0,
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            // Email icon
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: const Icon(
                                Icons.mark_email_read,
                                color: AppConstants.successColor,
                                size: 30,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Instructions text
                            Text(
                              'Check your inbox for the verification email',
                              textAlign: TextAlign.center,
                              style: AppConstants.bodyLarge.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Click the link in the email to verify your account',
                              textAlign: TextAlign.center,
                              style: AppConstants.bodyMediumSecondary,
                            ),
                            const SizedBox(height: 20),

                            // Countdown timer
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFE0E0E0),
                                  width: 1,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    const Text(
                                      'Resend available in:',
                                      style: AppConstants.bodyMediumSecondary,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _canResend
                                          ? 'Available now'
                                          : _countdownDisplay,
                                      style:
                                          AppConstants.headlineSmall.copyWith(
                                        color: const Color(0xFF1A2980),
                                        fontSize: 24,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Resend Code button
                            _isLoading
                                ? const CircularProgressIndicator()
                                : OutlinedButton(
                                    onPressed: _canResend
                                        ? () => _resendVerificationEmail()
                                        : null,
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFF1A2980),
                                      minimumSize: Size(
                                          MediaQuery.of(context).size.width,
                                          48),
                                      padding: const EdgeInsets.all(8),
                                      side: BorderSide(
                                        color: _canResend
                                            ? const Color(0xFF1A2980)
                                            : const Color(0xFF1A2980)
                                                .withOpacity(0.5),
                                        width: 1,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                    ),
                                    child: Text(
                                      _canResend
                                          ? 'Resend Verification Email'
                                          : 'Wait to Resend',
                                      style: AppConstants.bodyMedium.copyWith(
                                        color: _canResend
                                            ? const Color(0xFF1A2980)
                                            : const Color(0xFF1A2980)
                                                .withOpacity(0.5),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Progress tracking card
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            spreadRadius: 0,
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            const Text(
                              'Verification Progress',
                              style: AppConstants.headlineSmall,
                            ),
                            const SizedBox(height: 24),

                            // Progress bar
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: AppConstants.successColor
                                          .withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        width: double.infinity,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: AppConstants.successColor,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Container(
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: AppConstants.successColor
                                          .withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        width: double.infinity,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: AppConstants.successColor,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Container(
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE0E0E0),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Progress steps
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: const BoxDecoration(
                                          color: AppConstants.successColor,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Account',
                                        textAlign: TextAlign.center,
                                        style: AppConstants.bodyMedium.copyWith(
                                          color: AppConstants.successColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: const BoxDecoration(
                                          color: AppConstants.successColor,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Email',
                                        textAlign: TextAlign.center,
                                        style: AppConstants.bodyMedium.copyWith(
                                          color: AppConstants.successColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color:
                                                AppConstants.textSecondaryColor,
                                            width: 1,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.circle,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Complete',
                                        textAlign: TextAlign.center,
                                        style: AppConstants.bodyMedium.copyWith(
                                          color:
                                              AppConstants.textSecondaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Change Email button
                    TextButton(
                      onPressed: () {
                        // Handle change email
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppConstants.primaryColor,
                      ),
                      child: Text(
                        'Change Email Address',
                        style: AppConstants.bodyMedium.copyWith(
                          color: AppConstants.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Check verification status button
                    _isLoading
                        ? const CircularProgressIndicator()
                        : AppConstants.gradientButton(
                            text: 'Check Verification Status',
                            onPressed: () => _checkVerificationManually(),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
