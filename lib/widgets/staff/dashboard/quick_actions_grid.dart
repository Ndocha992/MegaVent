import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';

class StaffQuickActionsGrid extends StatelessWidget {
  final Function(String) onNavigate;

  const StaffQuickActionsGrid({super.key, required this.onNavigate});

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
              title: 'View Events',
              description: 'See Events',
              icon: Icons.add_circle_outline,
              color: AppConstants.primaryColor,
              onTap: () => onNavigate('event'),
            ),
            _buildActionCard(
              title: 'Scan QR Code',
              description: 'Check-in attendees',
              icon: Icons.qr_code_scanner,
              color: AppConstants.accentColor,
              onTap: () => onNavigate('scan_qr'),
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
