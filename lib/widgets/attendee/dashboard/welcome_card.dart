import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';

class AttendeeWelcomeCard extends StatelessWidget {
  const AttendeeWelcomeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppConstants.gradientContainerDecoration,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome Back!',
                  style: AppConstants.headlineMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ready to create amazing events?',
                  style: AppConstants.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                  style: AppConstants.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.celebration, color: Colors.white, size: 48),
        ],
      ),
    );
  }
}
