import 'package:flutter/material.dart';
import 'package:megavent/models/organizer.dart';
import 'package:megavent/utils/constants.dart';

class OrganizerActionsSectionWidget extends StatelessWidget {
  final Organizer organizer;
  final VoidCallback onDelete;
  final VoidCallback onViewEvents;

  const OrganizerActionsSectionWidget({
    super.key,
    required this.organizer,
    required this.onDelete,
    required this.onViewEvents,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: AppConstants.headlineMedium.copyWith(
              color: AppConstants.primaryColor,
            ),
          ),
          const SizedBox(height: 16),

          // Primary View Events Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onViewEvents,
              icon: const Icon(Icons.event_outlined),
              label: const Text('View Events'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Danger Zone Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppConstants.errorColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppConstants.errorColor.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: AppConstants.errorColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Danger Zone',
                      style: AppConstants.bodyLarge.copyWith(
                        color: AppConstants.errorColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Actions in this section cannot be undone.',
                  style: AppConstants.bodyMedium.copyWith(
                    color: AppConstants.errorColor.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete Organizer'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppConstants.errorColor,
                      side: BorderSide(color: AppConstants.errorColor),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
