import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:megavent/screens/loading_screen.dart';
import 'package:megavent/services/auth_service.dart';
import 'package:megavent/utils/constants.dart';
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
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _courseController = TextEditingController();
  final TextEditingController _yearOfStudyController = TextEditingController();
  final TextEditingController _businessTypeController = TextEditingController();
  final TextEditingController _loanTypesController = TextEditingController();
  final TextEditingController _interestRateController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _institutionController = TextEditingController();
  final TextEditingController _mpesaPhoneController = TextEditingController();

  // Focus nodes
  final FocusNode _fullNameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _studentIdFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();
  final FocusNode _courseFocusNode = FocusNode();
  final FocusNode _yearOfStudyFocusNode = FocusNode();
  final FocusNode _businessTypeFocusNode = FocusNode();
  final FocusNode _loanTypesFocusNode = FocusNode();
  final FocusNode _interestRateFocusNode = FocusNode();
  final FocusNode _websiteFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();
  final FocusNode _institutionFocusNode = FocusNode();
  final FocusNode _mpesaPhoneFocusNode = FocusNode();

  final _formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _agreedToTerms = true;
  String _selectedRole = 'student';
  String? _profileImageBase64;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String? _loanTypesError;

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
    _studentIdController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _courseController.dispose();
    _yearOfStudyController.dispose();
    _businessTypeController.dispose();
    _loanTypesController.dispose();
    _interestRateController.dispose();
    _websiteController.dispose();
    _descriptionController.dispose();
    _institutionController.dispose();
    _mpesaPhoneController.dispose();

    _fullNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _studentIdFocusNode.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _courseFocusNode.dispose();
    _yearOfStudyFocusNode.dispose();
    _businessTypeFocusNode.dispose();
    _loanTypesFocusNode.dispose();
    _interestRateFocusNode.dispose();
    _websiteFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _institutionFocusNode.dispose();
    _mpesaPhoneFocusNode.dispose();

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

  // Added missing validation methods
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  void _register() async {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must agree to the terms')),
      );
      return;
    }

    if (_loanTypesError != null) return;

    if (_formKey.currentState!.validate()) {
      LoadingOverlay.show(context, message: 'Registering...');
      setState(() => _isLoading = true);

      final authService = Provider.of<AuthService>(context, listen: false);
      Map<String, dynamic> result;

      try {
        if (_selectedRole == 'student') {
          result = await authService.registerStudent(
            fullName: _fullNameController.text,
            email: _emailController.text,
            password: _passwordController.text,
            phone: _phoneController.text,
            profileImage: _profileImageBase64,
          );
        } else {
          result = await authService.registerProvider(
            email: _emailController.text,
            password: _passwordController.text,
            phone: _phoneController.text,
            profileImage: _profileImageBase64,
          );
        }

        LoadingOverlay.hide();
        setState(() => _isLoading = false);

        if (result['success'] == true && mounted) {
          Navigator.pushReplacementNamed(context, '/verify-email');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Registration failed')),
          );
        }
      } catch (e) {
        LoadingOverlay.hide();
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error processing registration')),
        );
      }
    }
  }

  // Validation methods
  String? _validateFullName(String? value) {
    if (value == null || value.isEmpty) return 'This field is required';
    return null;
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
                        // App logo
                        Container(
                          width: 80,
                          height: 80,
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
                              width: 50,
                              height: 50,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Header
                        Text(
                          'Create Account',
                          style: AppConstants.displaySmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppConstants.textColor,
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
                            'Join thousands of students managing their education finances',
                            textAlign: TextAlign.center,
                            style: AppConstants.bodyMedium.copyWith(
                              color: AppConstants.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Profile image picker
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(
                                color:
                                    AppConstants.primaryColor.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: _profileImageBase64 != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(60),
                                    child: Image.memory(
                                      base64Decode(_profileImageBase64!),
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Icon(
                                    Icons.add_a_photo,
                                    size: 40,
                                    color: AppConstants.primaryColor
                                        .withOpacity(0.7),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        Text(
                          'Add profile photo',
                          style: AppConstants.bodyMedium.copyWith(
                            color: AppConstants.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // User Type Selection
                        Container(
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
                            children: [
                              const Text(
                                'Account Type',
                                style: AppConstants.headlineSmall,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Select your account type',
                                style: AppConstants.bodyMediumSecondary,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => setState(() {
                                        _selectedRole = 'student';
                                      }),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        decoration: BoxDecoration(
                                          color: _selectedRole == 'student'
                                              ? AppConstants.primaryColor
                                              : Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          border: Border.all(
                                            color: _selectedRole == 'student'
                                                ? AppConstants.primaryColor
                                                : Colors.grey.withOpacity(0.3),
                                            width: 1,
                                          ),
                                          boxShadow: _selectedRole == 'student'
                                              ? [
                                                  BoxShadow(
                                                    color: AppConstants
                                                        .primaryColor
                                                        .withOpacity(0.3),
                                                    blurRadius: 8,
                                                    spreadRadius: 0,
                                                    offset: const Offset(0, 3),
                                                  )
                                                ]
                                              : null,
                                        ),
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.school,
                                              size: 28,
                                              color: _selectedRole == 'student'
                                                  ? Colors.white
                                                  : AppConstants
                                                      .textSecondaryColor,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Student',
                                              style: AppConstants.bodyMedium
                                                  .copyWith(
                                                color: _selectedRole ==
                                                        'student'
                                                    ? Colors.white
                                                    : AppConstants.textColor,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => setState(() {
                                        _selectedRole = 'provider';
                                      }),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        decoration: BoxDecoration(
                                          color: _selectedRole == 'provider'
                                              ? AppConstants.primaryColor
                                              : Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          border: Border.all(
                                            color: _selectedRole == 'provider'
                                                ? AppConstants.primaryColor
                                                : Colors.grey.withOpacity(0.3),
                                            width: 1,
                                          ),
                                          boxShadow: _selectedRole == 'provider'
                                              ? [
                                                  BoxShadow(
                                                    color: AppConstants
                                                        .primaryColor
                                                        .withOpacity(0.3),
                                                    blurRadius: 8,
                                                    spreadRadius: 0,
                                                    offset: const Offset(0, 3),
                                                  )
                                                ]
                                              : null,
                                        ),
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.business_center,
                                              size: 28,
                                              color: _selectedRole == 'provider'
                                                  ? Colors.white
                                                  : AppConstants
                                                      .textSecondaryColor,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Provider',
                                              style: AppConstants.bodyMedium
                                                  .copyWith(
                                                color: _selectedRole ==
                                                        'provider'
                                                    ? Colors.white
                                                    : AppConstants.textColor,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _selectedRole == 'student'
                                    ? 'Student accounts can apply for loans and access educational financial services.'
                                    : 'Provider accounts can offer loan services and financial products to students.',
                                style: AppConstants.bodySmall.copyWith(
                                  color: AppConstants.textSecondaryColor,
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Personal Information Section
                        Container(
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
                            children: [
                              Text(
                                _selectedRole == 'student'
                                    ? 'Personal Information'
                                    : 'Business Information',
                                style: AppConstants.headlineSmall,
                              ),
                              const SizedBox(height: 20),

                              // Full Name/Business Name
                              TextFormField(
                                controller: _fullNameController,
                                focusNode: _fullNameFocusNode,
                                decoration: AppConstants.inputDecoration(
                                  labelText: _selectedRole == 'student'
                                      ? 'Full Name'
                                      : 'Business Name',
                                  prefixIcon: Icons.person_outline,
                                ),
                                validator: _validateFullName,
                              ),
                              const SizedBox(height: 20),

                              if (_selectedRole == 'student')
                                const SizedBox(height: 20),

                              // Phone Number
                              TextFormField(
                                controller: _phoneController,
                                focusNode: _phoneFocusNode,
                                decoration: AppConstants.inputDecoration(
                                  labelText: 'Phone Number',
                                  prefixIcon: Icons.phone,
                                ),
                                validator: (value) =>
                                    value?.isEmpty ?? true ? 'Required' : null,
                              ),
                              const SizedBox(height: 20),],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Verification info
                        Container(
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
                          child: const Padding(
                            padding: EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(
                                  'Account Verification',
                                  style: AppConstants.headlineSmall,
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Your account requires verification with valid university credentials. This helps us ensure secure access to student loan services.',
                                  style: AppConstants.bodyMediumSecondary,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Terms and conditions
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Checkbox(
                              value: _agreedToTerms,
                              onChanged: (newValue) =>
                                  setState(() => _agreedToTerms = newValue!),
                              activeColor: AppConstants.primaryColor,
                            ),
                            Expanded(
                              child: Text(
                                'I agree to the Terms & Conditions and Privacy Policy',
                                style: AppConstants.bodyMedium.copyWith(
                                  color: AppConstants.textSecondaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Register button
                        AppConstants.gradientButton(
                          text: 'Register',
                          onPressed: _agreedToTerms ? _register : () {},
                          isLoading: _isLoading,
                        ),
                        const SizedBox(height: 24),

                        // Login link
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
                              onPressed: () => Navigator.pushReplacementNamed(
                                  context, '/login'),
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
