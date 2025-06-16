import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // App Logo with Gradient
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppConstants.logoGradient,
            ),
            boxShadow: [
              BoxShadow(
                color: AppConstants.primaryColor.withOpacity(0.3),
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

        // Welcome Text
        Text(
          'Join MegaVent',
          style: AppConstants.displaySmall.copyWith(
            fontWeight: FontWeight.bold,
            color: AppConstants.textColor,
          ),
        ),
        const SizedBox(height: 12),

        // Subtitle with Gradient Background
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppConstants.primaryColor.withOpacity(0.1),
                AppConstants.secondaryColor.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: AppConstants.primaryColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Text(
            'Create unforgettable events & experiences',
            textAlign: TextAlign.center,
            style: AppConstants.bodyMedium.copyWith(
              color: AppConstants.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}