import 'package:flutter/material.dart';
import 'package:megavent/screens/loading_screen.dart';
import 'package:megavent/services/auth_service.dart';
import 'package:megavent/utils/constants.dart';
import 'package:provider/provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
  }

  @override
  void dispose() {
    _emailController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Show loading overlay
    LoadingOverlay.show(context, message: 'Sending reset link...');

    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      // Use the map-based response from auth service
      final Map<String, dynamic> result =
          await authService.sendPasswordResetEmail(_emailController.text);

      // Hide loading overlay
      LoadingOverlay.hide();

      if (result['success'] && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: AppConstants.successColor,
          ),
        );
        // Navigate back after success message
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.pop(context);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    } catch (e) {
      // Hide loading overlay
      LoadingOverlay.hide();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 60),

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

                              // Title
                              Text(
                                'Forgot Password?',
                                style: AppConstants.displaySmall.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Subtitle info pill
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppConstants.primaryColor
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'We\'ll send a reset link to your email',
                                  style: AppConstants.bodyMedium.copyWith(
                                    color: AppConstants.primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),

                              // Form container - full width
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
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Enter Your Email',
                                      style: AppConstants.titleLarge.copyWith(
                                        color: AppConstants.textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'We\'ll send the password recovery instructions to your university email address',
                                      style: AppConstants.bodyMedium.copyWith(
                                        color: AppConstants.textSecondaryColor,
                                      ),
                                    ),
                                    const SizedBox(height: 24),

                                    // Email field
                                    TextFormField(
                                      controller: _emailController,
                                      decoration: AppConstants.inputDecoration(
                                        labelText: 'Email',
                                        prefixIcon: Icons.email_outlined,
                                      ),
                                      style: AppConstants.bodyLarge,
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (value) {
                                        if (value?.isEmpty ?? true) {
                                          return 'Email is required';
                                        }
                                        if (!RegExp(
                                                r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
                                            .hasMatch(value!)) {
                                          return 'Enter a valid email';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 32),

                                    // Send Reset Link button
                                    AppConstants.gradientButton(
                                      text: 'Send Reset Link',
                                      onPressed: _sendResetLink,
                                      isLoading: _isLoading,
                                    ),
                                  ],
                                ),
                              ),

                              // Back to login
                              Padding(
                                padding: const EdgeInsets.only(bottom: 32),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Remember your password? ',
                                      style: AppConstants.bodyMedium.copyWith(
                                        color: AppConstants.textSecondaryColor,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(
                                        'Login',
                                        style: AppConstants.bodyMedium.copyWith(
                                          color: AppConstants.primaryColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
