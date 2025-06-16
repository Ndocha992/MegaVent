import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';

class VerificationInfoSection extends StatelessWidget {
  final String selectedRole;

  const VerificationInfoSection({
    super.key,
    required this.selectedRole,
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
                  gradient: LinearGradient(
                    colors: selectedRole == 'organizer'
                        ? AppConstants.eventPrimaryGradient
                        : AppConstants.eventSecondaryGradient,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  selectedRole == 'organizer' ? Icons.verified_user : Icons.email,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Verification Process',
                style: AppConstants.headlineSmall,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Process Steps
          if (selectedRole == 'attendee') ...[
            _buildStepItem(
              stepNumber: 1,
              title: 'Email Verification',
              description: 'We\'ll send a verification link to your email address',
              icon: Icons.email_outlined,
              color: AppConstants.secondaryColor,
            ),
            const SizedBox(height: 12),
            _buildStepItem(
              stepNumber: 2,
              title: 'Account Activation',
              description: 'Click the verification link to activate your account',
              icon: Icons.check_circle_outline,
              color: AppConstants.successColor,
            ),
            const SizedBox(height: 12),
            _buildStepItem(
              stepNumber: 3,
              title: 'Start Exploring',
              description: 'Discover and join amazing events in your area',
              icon: Icons.explore_outlined,
              color: AppConstants.primaryColor,
            ),
          ] else ...[
            _buildStepItem(
              stepNumber: 1,
              title: 'Account Review',
              description: 'Our team will review your organizer application',
              icon: Icons.fact_check_outlined,
              color: AppConstants.warningColor,
            ),
            const SizedBox(height: 12),
            _buildStepItem(
              stepNumber: 2,
              title: 'Admin Approval',
              description: 'You\'ll receive an email once your account is approved',
              icon: Icons.admin_panel_settings_outlined,
              color: AppConstants.primaryColor,
            ),
            const SizedBox(height: 12),
            _buildStepItem(
              stepNumber: 3,
              title: 'Start Creating',
              description: 'Begin organizing and managing your events',
              icon: Icons.event_available_outlined,
              color: AppConstants.successColor,
            ),
          ],

          const SizedBox(height: 20),

          // Information Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  (selectedRole == 'organizer' 
                      ? AppConstants.warningColor 
                      : AppConstants.secondaryColor).withOpacity(0.1),
                  (selectedRole == 'organizer' 
                      ? AppConstants.warningColor 
                      : AppConstants.secondaryColor).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: (selectedRole == 'organizer' 
                    ? AppConstants.warningColor 
                    : AppConstants.secondaryColor).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: selectedRole == 'organizer' 
                        ? AppConstants.warningColor.withOpacity(0.2)
                        : AppConstants.secondaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    selectedRole == 'organizer' ? Icons.schedule : Icons.info_outline,
                    color: selectedRole == 'organizer' 
                        ? AppConstants.warningColor 
                        : AppConstants.secondaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedRole == 'organizer' 
                            ? 'Processing Time' 
                            : 'Quick Setup',
                        style: AppConstants.titleMedium.copyWith(
                          color: selectedRole == 'organizer' 
                              ? AppConstants.warningColor 
                              : AppConstants.secondaryDarkColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selectedRole == 'organizer'
                            ? 'Organizer account approval typically takes 1-2 business days. We review each application to ensure quality and authenticity of event organizers.'
                            : 'Attendee accounts are activated immediately after email verification. You can start browsing and joining events right away!',
                        style: AppConstants.bodySmall.copyWith(
                          color: AppConstants.textColor,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Additional Info for Organizers
          if (selectedRole == 'organizer') ...[
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
                        Icons.tips_and_updates_outlined,
                        color: AppConstants.primaryColor,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tips for Faster Approval:',
                        style: AppConstants.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTipItem('Use a professional email address'),
                  _buildTipItem('Provide accurate organization details'),
                  _buildTipItem('Upload a clear profile photo'),
                  _buildTipItem('Check your email regularly for updates'),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStepItem({
    required int stepNumber,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              stepNumber.toString(),
              style: AppConstants.titleMedium.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: AppConstants.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: AppConstants.bodySmall.copyWith(
                  color: AppConstants.textSecondaryColor,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: AppConstants.primaryColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: AppConstants.bodySmall.copyWith(
                color: AppConstants.textColor,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}