import 'package:flutter/material.dart';
import 'package:megavent/models/organizer.dart';
import 'package:megavent/utils/constants.dart';

class OrganizerActionsSectionWidget extends StatelessWidget {
  final Organizer organizer;
  final AdminOrganizerStats? stats;
  final VoidCallback onDelete;
  final VoidCallback onViewEvents;

  const OrganizerActionsSectionWidget({
    super.key,
    required this.organizer,
    this.stats,
    required this.onDelete,
    required this.onViewEvents,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Primary Actions Row
          Row(
            children: [
              Expanded(
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
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.person_remove_outlined),
                  label: const Text('Remove'),
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

          const SizedBox(height: 12),

          // Quick Stats Row
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppConstants.backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppConstants.primaryColor.withOpacity(0.1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: Icons.event,
                  label: 'Events',
                  value: stats?.eventsCount.toString() ?? '0',
                ),
                _buildStatItem(
                  icon: Icons.people,
                  label: 'Staff',
                  value: stats?.totalStaff.toString() ?? '0',
                ),
                _buildStatItem(
                  icon: Icons.people,
                  label: 'Attendees',
                  value: stats?.totalAttendees.toString() ?? '0',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppConstants.primaryColor, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppConstants.bodyMedium.copyWith(
            color: AppConstants.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppConstants.bodySmall.copyWith(
            color: AppConstants.textSecondaryColor,
          ),
        ),
      ],
    );
  }
}
