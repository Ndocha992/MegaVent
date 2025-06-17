import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:megavent/screens/loading_screen.dart';
import 'package:megavent/services/auth_service.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/widgets/registration/app_header.dart';
import 'package:megavent/widgets/registration/profile_image_picker.dart';
import 'package:megavent/widgets/registration/user_type_selector.dart';
import 'package:megavent/widgets/registration/personal_info_section.dart';
import 'package:megavent/widgets/registration/verification_info_section.dart';
import 'package:megavent/widgets/registration/terms_checkbox.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  // Controllers for text fields
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _organizationController = TextEditingController();

  // Focus nodes
  final FocusNode _fullNameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _organizationFocusNode = FocusNode();

  final _formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _agreedToTerms = false;
  String _selectedRole = 'attendee';
  String? _profileImageBase64;
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
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _organizationController.dispose();
    _fullNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _phoneFocusNode.dispose();
    _organizationFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() => _profileImageBase64 = base64Encode(bytes));
    }
  }

  void _onRoleChanged(String role) {
    setState(() => _selectedRole = role);
  }

  void _onTermsChanged(bool value) {
    setState(() => _agreedToTerms = value);
  }

  void _onPasswordVisibilityToggle() {
    setState(() => _passwordVisible = !_passwordVisible);
  }

  void _onConfirmPasswordVisibilityToggle() {
    setState(() => _confirmPasswordVisible = !_confirmPasswordVisible);
  }

  void _showOrganizerApprovalDialog() {
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
                  'Registration Submitted',
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
                'Your organizer account has been created successfully! Please note:',
                style: TextStyle(
                  fontSize: 14,
                  color: AppConstants.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppConstants.primaryColor.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.email_outlined,
                          size: 16,
                          color: AppConstants.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Step 1: Verify your email address',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppConstants.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.admin_panel_settings_outlined,
                          size: 16,
                          color: AppConstants.warningColor,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Step 2: Wait for admin approval',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppConstants.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '⚠️ Even after email verification, you will need admin approval before you can access your organizer account.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppConstants.warningColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/verify-email');
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
                'Continue to Email Verification',
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

  void _register() async {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must agree to the terms and conditions'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      LoadingOverlay.show(context, message: 'Creating account...');
      setState(() => _isLoading = true);

      final authService = Provider.of<AuthService>(context, listen: false);
      Map<String, dynamic> result;

      try {
        if (_selectedRole == 'attendee') {
          result = await authService.registerAttendee(
            fullName: _fullNameController.text,
            email: _emailController.text,
            password: _passwordController.text,
            phone: _phoneController.text,
            profileImage: _profileImageBase64,
          );
        } else {
          // Organizer registration
          result = await authService.registerOrganizer(
            fullName: _fullNameController.text,
            email: _emailController.text,
            password: _passwordController.text,
            phone: _phoneController.text,
            organization:
                _organizationController.text.isNotEmpty
                    ? _organizationController.text
                    : null,
            profileImage: _profileImageBase64,
          );
        }

        LoadingOverlay.hide();
        setState(() => _isLoading = false);

        if (result['success'] == true && mounted) {
          // Show success message first
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _selectedRole == 'organizer'
                    ? 'Account created! Please verify your email and wait for admin approval.'
                    : 'Account created successfully! Please verify your email to continue.',
              ),
              backgroundColor: AppConstants.successColor,
            ),
          );

          // Small delay to show the success message
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) {
              if (_selectedRole == 'organizer') {
                // Show organizer-specific approval dialog
                _showOrganizerApprovalDialog();
              } else {
                // For attendees, go directly to verification screen
                Navigator.pushReplacementNamed(context, '/verify-email');
              }
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Registration failed'),
              backgroundColor: AppConstants.errorColor,
            ),
          );
        }
      } catch (e) {
        LoadingOverlay.hide();
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error processing registration'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
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
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // App Header
                        const AppHeader(),
                        const SizedBox(height: 32),

                        // Profile Image Picker
                        ProfileImagePicker(
                          profileImageBase64: _profileImageBase64,
                          onImagePicked: _pickImage,
                        ),
                        const SizedBox(height: 24),

                        // User Type Selection
                        UserTypeSelector(
                          selectedRole: _selectedRole,
                          onRoleChanged: _onRoleChanged,
                        ),
                        const SizedBox(height: 20),

                        // Personal Information Section
                        PersonalInfoSection(
                          selectedRole: _selectedRole,
                          fullNameController: _fullNameController,
                          emailController: _emailController,
                          passwordController: _passwordController,
                          confirmPasswordController: _confirmPasswordController,
                          phoneController: _phoneController,
                          organizationController: _organizationController,
                          fullNameFocusNode: _fullNameFocusNode,
                          emailFocusNode: _emailFocusNode,
                          passwordFocusNode: _passwordFocusNode,
                          confirmPasswordFocusNode: _confirmPasswordFocusNode,
                          phoneFocusNode: _phoneFocusNode,
                          organizationFocusNode: _organizationFocusNode,
                          passwordVisible: _passwordVisible,
                          confirmPasswordVisible: _confirmPasswordVisible,
                          onPasswordVisibilityToggle:
                              _onPasswordVisibilityToggle,
                          onConfirmPasswordVisibilityToggle:
                              _onConfirmPasswordVisibilityToggle,
                        ),
                        const SizedBox(height: 20),

                        // Verification Info Section
                        VerificationInfoSection(selectedRole: _selectedRole),
                        const SizedBox(height: 24),

                        // Terms and Conditions
                        TermsCheckbox(
                          agreedToTerms: _agreedToTerms,
                          onChanged: _onTermsChanged,
                        ),
                        const SizedBox(height: 24),

                        // Register Button
                        AppConstants.gradientButton(
                          text:
                              _selectedRole == 'organizer'
                                  ? 'Submit for Approval'
                                  : 'Create Account',
                          onPressed: _agreedToTerms ? _register : () {},
                          isLoading: _isLoading,
                          gradientColors:
                              _selectedRole == 'organizer'
                                  ? AppConstants.eventPrimaryGradient
                                  : AppConstants.primaryGradient,
                        ),
                        const SizedBox(height: 24),

                        // Login Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: AppConstants.bodyMedium.copyWith(
                                color: AppConstants.textSecondaryColor,
                              ),
                            ),
                            TextButton(
                              onPressed:
                                  () => Navigator.pushReplacementNamed(
                                    context,
                                    '/login',
                                  ),
                              child: Text(
                                'Sign In',
                                style: AppConstants.bodyMedium.copyWith(
                                  color: AppConstants.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
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
