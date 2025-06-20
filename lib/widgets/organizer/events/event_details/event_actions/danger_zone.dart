import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';

class DangerZoneWidget extends StatelessWidget {
  final VoidCallback onDelete;

  const DangerZoneWidget({
    super.key,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.errorColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppConstants.errorColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_outlined,
                color: AppConstants.errorColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Danger Zone',
                style: AppConstants.titleMedium.copyWith(
                  color: AppConstants.errorColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Actions in this section cannot be undone.',
            style: AppConstants.bodySmallSecondary,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete Event'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppConstants.errorColor,
                side: BorderSide(color: AppConstants.errorColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}