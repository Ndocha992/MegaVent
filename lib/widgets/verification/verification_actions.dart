import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:megavent/utils/constants.dart';

class VerificationActions extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onCheckVerification;
  final VoidCallback onChangeEmail;

  const VerificationActions({
    super.key,
    required this.isLoading,
    required this.onCheckVerification,
    required this.onChangeEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Primary action button - Check verification
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient:
                isLoading
                    ? null
                    : const LinearGradient(
                      colors: AppConstants.primaryGradient,
                    ),
            color: isLoading ? AppConstants.borderColor : null,
            borderRadius: BorderRadius.circular(16),
            boxShadow:
                isLoading
                    ? null
                    : [
                      BoxShadow(
                        color: AppConstants.primaryColor.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
          ),
          child: ElevatedButton(
            onPressed: isLoading ? null : onCheckVerification,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child:
                isLoading
                    ? Container(
                      color: AppConstants.primaryColor.withOpacity(0.1),
                      child: const Center(
                        child: SpinKitThreeBounce(
                          color: AppConstants.primaryColor,
                          size: 20.0,
                        ),
                      ),
                    )
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.refresh_rounded, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Check Verification Status',
                          style: AppConstants.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
          ),
        ),
        const SizedBox(height: 16),

        // Secondary action button - Change email
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppConstants.borderColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppConstants.primaryColor.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: isLoading ? null : onChangeEmail,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: AppConstants.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.edit_rounded, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Change Email Address',
                  style: AppConstants.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppConstants.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Additional help section
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppConstants.borderColor.withOpacity(0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppConstants.primaryColor.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              // Help header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.help_outline_rounded,
                      color: AppConstants.primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Need Help?',
                    style: AppConstants.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppConstants.textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Help text
              Text(
                'If you\'re having trouble with email verification, check your spam folder or contact our support team for assistance.',
                textAlign: TextAlign.center,
                style: AppConstants.bodySmall.copyWith(
                  color: AppConstants.textSecondaryColor,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),

              // Support contact button
              GestureDetector(
                onTap: () {
                  // Handle support contact
                  _showSupportDialog(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppConstants.primaryColor.withOpacity(0.1),
                        AppConstants.primaryColor.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppConstants.primaryColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.support_agent_rounded,
                        color: AppConstants.primaryColor,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Contact Support',
                        style: AppConstants.bodySmall.copyWith(
                          color: AppConstants.primaryColor,
                          fontWeight: FontWeight.w600,
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
    );
  }

  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppConstants.primaryGradient,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.support_agent_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Contact Support',
                style: AppConstants.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Need help with email verification? Our support team is here to assist you.',
                textAlign: TextAlign.center,
                style: AppConstants.bodyMedium.copyWith(
                  color: AppConstants.textSecondaryColor,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              // Support options
              _buildSupportOption(
                icon: Icons.email_rounded,
                title: 'Email Support',
                subtitle: 'support@megavent.com',
                onTap: () {
                  // Handle email support
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 12),
              _buildSupportOption(
                icon: Icons.phone_rounded,
                title: 'Phone Support',
                subtitle: '+1 (555) 123-4567',
                onTap: () {
                  // Handle phone support
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: AppConstants.bodyMedium.copyWith(
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

  Widget _buildSupportOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppConstants.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppConstants.borderColor, width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppConstants.primaryColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppConstants.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppConstants.bodySmall.copyWith(
                      color: AppConstants.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppConstants.textSecondaryColor,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
