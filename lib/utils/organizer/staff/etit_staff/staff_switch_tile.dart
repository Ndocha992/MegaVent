import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';

class StaffSwitchTile extends StatelessWidget {
  final bool value;
  final void Function(bool) onChanged;
  final String title;
  final String subtitle;
  final IconData icon;

  const StaffSwitchTile({
    super.key,
    required this.value,
    required this.onChanged,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppConstants.borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppConstants.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppConstants.bodyMedium),
                Text(
                  subtitle,
                  style: AppConstants.bodySmall.copyWith(
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppConstants.primaryColor,
          ),
        ],
      ),
    );
  }
}