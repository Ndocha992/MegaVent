import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';

class VerificationProgressCard extends StatelessWidget {
  const VerificationProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryColor.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            // Progress header with icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppConstants.primaryGradient,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.track_changes_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Verification Progress',
                  style: AppConstants.headlineMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Enhanced progress bar with animation effect
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppConstants.backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 12,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: AppConstants.accentGradient,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: AppConstants.successColor.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Container(
                      height: 12,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: AppConstants.accentGradient,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: AppConstants.successColor.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppConstants.borderColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Enhanced progress steps
            Row(
              children: [
                Expanded(
                  child: _buildProgressStep(
                    icon: Icons.person_add_rounded,
                    title: 'Account Created',
                    isCompleted: true,
                    isActive: false,
                  ),
                ),
                Expanded(
                  child: _buildProgressStep(
                    icon: Icons.email_rounded,
                    title: 'Email Sent',
                    isCompleted: true,
                    isActive: false,
                  ),
                ),
                Expanded(
                  child: _buildProgressStep(
                    icon: Icons.verified_user_rounded,
                    title: 'Verification',
                    isCompleted: false,
                    isActive: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Helpful tip section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppConstants.primaryColor.withOpacity(0.05),
                    AppConstants.secondaryColor.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppConstants.warningColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.lightbulb_outline_rounded,
                      color: AppConstants.warningColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pro Tip',
                          style: AppConstants.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppConstants.warningColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Check your spam folder if you don\'t see the email',
                          style: AppConstants.bodySmall.copyWith(
                            color: AppConstants.textSecondaryColor,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStep({
    required IconData icon,
    required String title,
    required bool isCompleted,
    required bool isActive,
  }) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: isCompleted
                ? const LinearGradient(colors: AppConstants.accentGradient)
                : isActive
                    ? LinearGradient(
                        colors: [
                          AppConstants.primaryColor.withOpacity(0.2),
                          AppConstants.primaryColor.withOpacity(0.1),
                        ],
                      )
                    : null,
            color: !isCompleted && !isActive ? AppConstants.borderColor : null,
            shape: BoxShape.circle,
            border: isActive && !isCompleted
                ? Border.all(
                    color: AppConstants.primaryColor,
                    width: 2,
                  )
                : null,
            boxShadow: isCompleted
                ? [
                    BoxShadow(
                      color: AppConstants.successColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            isCompleted ? Icons.check_rounded : icon,
            color: isCompleted
                ? Colors.white
                : isActive
                    ? AppConstants.primaryColor
                    : AppConstants.textSecondaryColor,
            size: isCompleted ? 28 : 24,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppConstants.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: isCompleted || isActive
                ? AppConstants.textColor
                : AppConstants.textSecondaryColor,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}