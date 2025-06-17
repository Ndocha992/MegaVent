import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: AppConstants.headlineSmall),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.4,
          children: [
            _buildActionCard(
              title: 'Create Event',
              description: 'Start planning a new event',
              icon: Icons.add_circle_outline,
              color: AppConstants.primaryColor,
              onTap: () {
                // Navigate to create event page
              },
            ),
            _buildActionCard(
              title: 'Add Staff',
              description: 'Invite new team members',
              icon: Icons.person_add_outlined,
              color: AppConstants.secondaryColor,
              onTap: () {
                // Navigate to add staff page
              },
            ),
            _buildActionCard(
              title: 'Scan QR Code',
              description: 'Check-in attendees',
              icon: Icons.qr_code_scanner,
              color: AppConstants.accentColor,
              onTap: () {
                // Open QR scanner
              },
            ),
            _buildActionCard(
              title: 'Generate Report',
              description: 'Export event analytics',
              icon: Icons.analytics_outlined,
              color: AppConstants.warningColor,
              onTap: () {
                // Generate and download report
              },
            ),
            _buildActionCard(
              title: 'Send Notifications',
              description: 'Alert attendees & staff',
              icon: Icons.notifications_outlined,
              color: AppConstants.successColor,
              onTap: () {
                // Open notification center
              },
            ),
            _buildActionCard(
              title: 'Manage Settings',
              description: 'Configure app preferences',
              icon: Icons.settings_outlined,
              color: Colors.grey.shade600,
              onTap: () {
                // Open settings page
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: AppConstants.cardDecoration,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppConstants.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: AppConstants.bodySmall.copyWith(
                        color: AppConstants.textSecondaryColor,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
