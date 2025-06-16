import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';

class PersonalInfoSection extends StatelessWidget {
  final String selectedRole;
  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final TextEditingController phoneController;
  final TextEditingController organizationController;
  final FocusNode fullNameFocusNode;
  final FocusNode emailFocusNode;
  final FocusNode passwordFocusNode;
  final FocusNode confirmPasswordFocusNode;
  final FocusNode phoneFocusNode;
  final FocusNode organizationFocusNode;
  final bool passwordVisible;
  final bool confirmPasswordVisible;
  final VoidCallback onPasswordVisibilityToggle;
  final VoidCallback onConfirmPasswordVisibilityToggle;

  const PersonalInfoSection({
    super.key,
    required this.selectedRole,
    required this.fullNameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.phoneController,
    required this.organizationController,
    required this.fullNameFocusNode,
    required this.emailFocusNode,
    required this.passwordFocusNode,
    required this.confirmPasswordFocusNode,
    required this.phoneFocusNode,
    required this.organizationFocusNode,
    required this.passwordVisible,
    required this.confirmPasswordVisible,
    required this.onPasswordVisibilityToggle,
    required this.onConfirmPasswordVisibilityToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppConstants.primaryGradient,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                selectedRole == 'attendee'
                    ? 'Personal Information'
                    : 'Organizer Details',
                style: AppConstants.headlineSmall,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            selectedRole == 'attendee'
                ? 'Enter your personal details to create your attendee account'
                : 'Provide your details to register as an event organizer',
            style: AppConstants.bodyMediumSecondary,
          ),
          const SizedBox(height: 24),

          // Full Name Field
          TextFormField(
            controller: fullNameController,
            focusNode: fullNameFocusNode,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(emailFocusNode),
            decoration: AppConstants.inputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icons.person_outline,
              hintText: 'Enter your full name',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Full name is required';
              }
              if (value.trim().length < 2) {
                return 'Full name must be at least 2 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Email Field
          TextFormField(
            controller: emailController,
            focusNode: emailFocusNode,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(passwordFocusNode),
            decoration: AppConstants.inputDecoration(
              labelText: 'Email Address',
              prefixIcon: Icons.email_outlined,
              hintText: 'Enter your email address',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email is required';
              }
              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
              if (!emailRegex.hasMatch(value.trim())) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Phone Field
          TextFormField(
            controller: phoneController,
            focusNode: phoneFocusNode,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(passwordFocusNode),
            decoration: AppConstants.inputDecoration(
              labelText: 'Phone Number',
              prefixIcon: Icons.phone_outlined,
              hintText: 'Enter your phone number',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Phone number is required';
              }
              if (value.trim().length < 10) {
                return 'Please enter a valid phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Organization Field (only for organizers)
          if (selectedRole == 'organizer') ...[
            TextFormField(
              controller: organizationController,
              focusNode: organizationFocusNode,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(passwordFocusNode),
              decoration: AppConstants.inputDecoration(
                labelText: 'Organization (Optional)',
                prefixIcon: Icons.business_outlined,
                hintText: 'Enter your organization name',
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Password Field
          TextFormField(
            controller: passwordController,
            focusNode: passwordFocusNode,
            obscureText: !passwordVisible,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(confirmPasswordFocusNode),
            decoration: AppConstants.inputDecoration(
              labelText: 'Password',
              prefixIcon: Icons.lock_outline,
              hintText: 'Create a strong password',
              suffixIcon: IconButton(
                icon: Icon(
                  passwordVisible ? Icons.visibility_off : Icons.visibility,
                  color: AppConstants.textSecondaryColor,
                ),
                onPressed: onPasswordVisibilityToggle,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password is required';
              }
              if (value.length < 8) {
                return 'Password must be at least 8 characters';
              }
              if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
                return 'Password must contain uppercase, lowercase, and number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Confirm Password Field
          TextFormField(
            controller: confirmPasswordController,
            focusNode: confirmPasswordFocusNode,
            obscureText: !confirmPasswordVisible,
            textInputAction: TextInputAction.done,
            decoration: AppConstants.inputDecoration(
              labelText: 'Confirm Password',
              prefixIcon: Icons.lock_outline,
              hintText: 'Confirm your password',
              suffixIcon: IconButton(
                icon: Icon(
                  confirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  color: AppConstants.textSecondaryColor,
                ),
                onPressed: onConfirmPasswordVisibilityToggle,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Password Requirements
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppConstants.primaryColor.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.security,
                      color: AppConstants.primaryColor,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Password Requirements:',
                      style: AppConstants.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildPasswordRequirement('At least 8 characters'),
                _buildPasswordRequirement('One uppercase letter'),
                _buildPasswordRequirement('One lowercase letter'),
                _buildPasswordRequirement('One number'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordRequirement(String requirement) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 14,
            color: AppConstants.textSecondaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            requirement,
            style: AppConstants.bodySmall.copyWith(
              color: AppConstants.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}