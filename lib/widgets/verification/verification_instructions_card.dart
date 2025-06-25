import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:megavent/utils/constants.dart';

class VerificationInstructionsCard extends StatelessWidget {
  final String countdownDisplay;
  final bool canResend;
  final bool isLoading;
  final VoidCallback onResendPressed;

  const VerificationInstructionsCard({
    super.key,
    required this.countdownDisplay,
    required this.canResend,
    required this.isLoading,
    required this.onResendPressed,
  });

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
            // Email verification icon with animated background
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppConstants.successColor.withOpacity(0.2),
                    AppConstants.successColor.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(
                  color: AppConstants.successColor.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: const Icon(
                  Icons.mark_email_read_rounded,
                  color: AppConstants.successColor,
                  size: 36,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Instructions text with better typography
            Text(
              'Check Your Inbox',
              textAlign: TextAlign.center,
              style: AppConstants.headlineMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppConstants.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We\'ve sent a verification email with a special link to confirm your account',
              textAlign: TextAlign.center,
              style: AppConstants.bodyMedium.copyWith(
                color: AppConstants.textSecondaryColor,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // Enhanced countdown timer section
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppConstants.backgroundColor,
                    AppConstants.backgroundSecondaryColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppConstants.borderColor, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppConstants.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.timer_outlined,
                            color: AppConstants.primaryColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Resend available in:',
                          style: AppConstants.bodyMedium.copyWith(
                            color: AppConstants.textSecondaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Countdown display with gradient background
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient:
                            canResend
                                ? const LinearGradient(
                                  colors: AppConstants.accentGradient,
                                )
                                : LinearGradient(
                                  colors: [
                                    AppConstants.primaryColor.withOpacity(0.1),
                                    AppConstants.primaryColor.withOpacity(0.05),
                                  ],
                                ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow:
                            canResend
                                ? [
                                  BoxShadow(
                                    color: AppConstants.successColor
                                        .withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                                : null,
                      ),
                      child: Text(
                        canResend ? 'Available Now!' : countdownDisplay,
                        style: AppConstants.headlineSmall.copyWith(
                          color:
                              canResend
                                  ? Colors.white
                                  : AppConstants.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Enhanced resend button
            isLoading
                ? Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppConstants.borderColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    color: AppConstants.primaryColor.withOpacity(0.1),
                    child: const Center(
                      child: SpinKitThreeBounce(
                        color: AppConstants.primaryColor,
                        size: 20.0,
                      ),
                    ),
                  ),
                )
                : AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient:
                        canResend
                            ? const LinearGradient(
                              colors: AppConstants.primaryGradient,
                            )
                            : null,
                    color: canResend ? null : AppConstants.borderColor,
                    borderRadius: BorderRadius.circular(16),
                    border:
                        !canResend
                            ? Border.all(
                              color: AppConstants.borderColor,
                              width: 1.5,
                            )
                            : null,
                    boxShadow:
                        canResend
                            ? [
                              BoxShadow(
                                color: AppConstants.primaryColor.withOpacity(
                                  0.3,
                                ),
                                blurRadius: 15,
                                offset: const Offset(0, 6),
                              ),
                            ]
                            : null,
                  ),
                  child: ElevatedButton(
                    onPressed: canResend ? onResendPressed : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor:
                          canResend
                              ? Colors.white
                              : AppConstants.textSecondaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          canResend
                              ? Icons.send_rounded
                              : Icons.schedule_rounded,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          canResend
                              ? 'Resend Verification Email'
                              : 'Wait to Resend',
                          style: AppConstants.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
