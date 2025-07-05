import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';

class QuickActionsSection extends StatelessWidget {
  final Function(String) onQuickAction;

  const QuickActionsSection({
    super.key,
    required this.onQuickAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: AppConstants.headlineSmall),
        const SizedBox(height: 16),
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionCard(
                    'View All Events',
                    Icons.event,
                    AppConstants.primaryColor,
                    () => onQuickAction('view_all_events'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionCard(
                    'My Events',
                    Icons.bookmark,
                    AppConstants.accentColor,
                    () => onQuickAction('view_my_events'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppConstants.cardDecoration,
        child: Column(
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
            const SizedBox(height: 12),
            Text(
              title,
              style: AppConstants.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}