import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';

class StaffSectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const StaffSectionHeader({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppConstants.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppConstants.primaryColor, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: AppConstants.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}