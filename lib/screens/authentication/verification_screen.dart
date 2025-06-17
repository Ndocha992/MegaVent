import 'dart:async';
import 'package:flutter/material.dart';
import 'package:megavent/screens/admin/admin_dashboard.dart';
import 'package:megavent/screens/attendee/attendee_dashboard.dart';
import 'package:megavent/screens/organizer/organizer_dashboard.dart';
import 'package:megavent/screens/staff/staff_dashboard.dart';
import 'package:megavent/services/auth_service.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/widgets/verification/verification_header.dart';
import 'package:megavent/widgets/verification/verification_instructions_card.dart';
import 'package:megavent/widgets/verification/verification_progress_card.dart';
import 'package:megavent/widgets/verification/verification_actions.dart';
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
  late Animation<Offset> _slideAnimation;

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
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
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

    _verificationTimer = Timer.periodic(const Duration(seconds: 5), (
      timer,
    ) async {
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
            await _handleVerificationSuccess();
          }
        });
      }
    });
  }

  Future<void> _handleVerificationSuccess() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userData = await authService.getUserData();

    if (userData['success'] == true) {
      final userRole = userData['role'];
      final userStatus = userData['status']; // Assuming you have status field

      // For organizers, check if they're approved
      if (userRole == 'organizer') {
        if (userStatus == 'pending' || userStatus != 'active') {
          // Show organizer approval pending dialog
          _showOrganizerPendingDialog();
          return;
        }
      }

      // For all other cases, navigate to respective dashboard
      switch (userRole) {
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
          // Only navigate if organizer is approved
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
      // If getUserData fails, redirect to login
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _showOrganizerPendingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppConstants.warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.schedule,
                  color: AppConstants.warningColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Email Verified!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppConstants.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your email has been successfully verified! However, your organizer account is still pending admin approval.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppConstants.textSecondaryColor,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppConstants.warningColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppConstants.warningColor.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.admin_panel_settings_outlined,
                      size: 16,
                      color: AppConstants.warningColor,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Waiting for admin activation',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppConstants.warningColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'You will be notified via email once your account is approved. You can then log in with your credentials.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppConstants.textSecondaryColor,
                  height: 1.3,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Sign out the user and redirect to login
                _signOutAndRedirectToLogin();
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Back to Login',
                style: TextStyle(
                  color: AppConstants.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _signOutAndRedirectToLogin() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
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
      Future.delayed(const Duration(seconds: 1), () async {
        if (mounted) {
          await _handleVerificationSuccess();
        }
      });
    } else {
      // Show not verified message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email not verified yet. Please check your inbox.'),
          backgroundColor: AppConstants.warningColor,
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
            colors: [Color(0xFFF9FAFC), Color(0xFFEEF1F7)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Header with logo and title
                      const VerificationHeader(),
                      const SizedBox(height: 32),

                      // Verification Instructions Card
                      VerificationInstructionsCard(
                        countdownDisplay: _countdownDisplay,
                        canResend: _canResend,
                        isLoading: _isLoading,
                        onResendPressed: _resendVerificationEmail,
                      ),
                      const SizedBox(height: 24),

                      // Progress tracking card
                      const VerificationProgressCard(),
                      const SizedBox(height: 32),

                      // Action buttons
                      VerificationActions(
                        isLoading: _isLoading,
                        onCheckVerification: _checkVerificationManually,
                        onChangeEmail: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
