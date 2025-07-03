import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';

class StaffPasswordSection extends StatelessWidget {
  const StaffPasswordSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppConstants.warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.shield_outlined,
                  color: AppConstants.warningColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Default Password',
                style: AppConstants.bodySmall.copyWith(
                  color: AppConstants.warningColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildContactRow(Icons.password, 'Password', 'password254'),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppConstants.backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppConstants.warningColor, size: 20),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppConstants.bodySmall.copyWith(
                      color: AppConstants.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: AppConstants.bodyMedium.copyWith(
                      color: AppConstants.warningColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
