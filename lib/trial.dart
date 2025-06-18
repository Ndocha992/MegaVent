import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/data/fake_data.dart';

class EventActionsSection extends StatelessWidget {
  final Event event;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const EventActionsSection({
    super.key,
    required this.event,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Actions', style: AppConstants.titleLarge),
          const SizedBox(height: 16),

          // Primary Actions Row
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Event'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Secondary Actions Grid
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  icon: Icons.share,
                  title: 'Share Event',
                  subtitle: 'Share with others',
                  onTap: _handleShare,
                  color: AppConstants.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  icon: Icons.people,
                  title: 'Attendees',
                  subtitle: '${event.registeredCount} registered',
                  onTap: _handleViewAttendees,
                  color: AppConstants.successColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          
          // Danger Zone
          Container(
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
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppConstants.borderColor, width: 1),
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
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppConstants.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(subtitle, style: AppConstants.bodySmallSecondary),
          ],
        ),
      ),
    );
  }

  void _handleShare() {
    // Handle sharing the event
  }

  void _handleViewAttendees() {
    // Handle viewing attendees list
  }
}